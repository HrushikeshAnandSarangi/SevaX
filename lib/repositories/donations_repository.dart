import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:uuid/uuid.dart';

class DonationsRepository {
  Stream<QuerySnapshot> getDonationsOfRequest(String requestId) {
    return CollectionRef.donations
        .where('requestId', isEqualTo: requestId)
        .snapshots();
  }

  Stream<QuerySnapshot> getDonationsOfOffer(String offerId) {
    return CollectionRef.donations
        .where('requestId', isEqualTo: offerId)
        .snapshots();
  }

  Future<void> donateOfferCreatorPledge({
    required String donationId,
    required bool isTimebankNotification,
    required String associatedId,
    required String notificationId,
    required NotificationsModel acknowledgementNotification,
    required DonationStatus donationStatus,
    required RequestType requestType,
    required OperatingMode operatoreMode,
  }) async {
    try {
      var donationModel =
          DonationModel.fromMap(acknowledgementNotification.data!);
      var batch = CollectionRef.batch;
      batch.update(CollectionRef.donations.doc(donationId), {
        'donationStatus': donationStatus.toString().split('.')[1],
        if (requestType == RequestType.CASH)
          'cashDetails.pledgedAmount':
              (donationModel).cashDetails!.pledgedAmount,
        if (donationStatus == DonationStatus.ACKNOWLEDGED &&
            requestType == RequestType.GOODS)
          'goodsDetails.donatedGoods':
              (donationModel).goodsDetails!.donatedGoods,
        'lastModifiedBy': associatedId,
        'notificationId': notificationId,
      });

      log("=========STG 1");

      // mark current notificaiton as read with offer creator

      CollectionReference notificationReference = isTimebankNotification
          ? CollectionRef.timebankNotification(associatedId)
          : CollectionRef.userNotification(associatedId);
      batch.update(
        notificationReference.doc(notificationId),
        {'isRead': true},
      );

      log("=========STG 2  $associatedId");

      // create new notification for reciever to acknowledge
      var notificationReferenceForDonor;
      if (operatoreMode == OperatingMode.CREATOR &&
          donationModel.donatedToTimebank!) {
        notificationReferenceForDonor = CollectionRef.userNotification(
            donationModel.receiverDetails!.email!);
        // direct towards timebank
      } else {
        //direct it towards creator
        if (donationModel.donatedToTimebank!) {
          notificationReferenceForDonor =
              CollectionRef.timebankNotification(donationModel.timebankId!);
        } else {
          notificationReferenceForDonor = CollectionRef.userNotification(
              donationModel.receiverDetails!.email!);
        }
      }

      batch.set(
        notificationReferenceForDonor.doc(acknowledgementNotification.id),
        acknowledgementNotification.toMap(),
      );

      log("=========STG 4  $associatedId");

      await batch.commit().catchError((onError) {
        log("=========ERROR BATCH  $onError");
      });
    } on Exception catch (e) {
      log("=========Error Caugh");
      logger.e(e);
    }
  }

  Future<void> acknowledgeDonation({
    required String donationId,
    required bool isTimebankNotification,
    required String associatedId,
    required String notificationId,
    required NotificationsModel acknowledgementNotification,
    required DonationStatus donationStatus,
    required RequestType requestType,
    required OperatingMode operatoreMode,
  }) async {
    try {
      var donationModel =
          DonationModel.fromMap(acknowledgementNotification.data!);

      var batch = CollectionRef.batch;
      batch.update(CollectionRef.donations.doc(donationId), {
        'donationStatus': donationStatus.toString().split('.')[1],
        if (requestType == RequestType.CASH)
          'cashDetails.pledgedAmount':
              (donationModel).cashDetails!.pledgedAmount,
        if (requestType == RequestType.GOODS)
          'goodsDetails.donatedGoods':
              (donationModel).goodsDetails!.donatedGoods,
        'lastModifiedBy': associatedId,
      });

      //update request model with amount raised if donation is acknowledged
      if (donationStatus == DonationStatus.ACKNOWLEDGED &&
          donationModel.requestIdType == 'request') {
        if (requestType == RequestType.CASH) {
          batch.update(
            CollectionRef.requests.doc(donationModel.requestId),
            {
              'cashModeDetails.amountRaised': FieldValue.increment(
                  donationModel.cashDetails!.pledgedAmount!),
            },
          );
        }
        //send acknowledgement reciept
        await MailDonationReciept.sendReciept(donationModel);
      } else if (donationStatus == DonationStatus.ACKNOWLEDGED &&
          donationModel.requestIdType == 'offer') {
        if (requestType == RequestType.CASH) {
          batch.update(
            CollectionRef.offers.doc(donationModel.requestId),
            {
              'cashModeDetails.amountRaised': FieldValue.increment(
                  donationModel.cashDetails!.pledgedAmount!),
            },
          );
        }
        //send acknowledgement reciept
        await MailDonationReciept.sendReciept(donationModel);
      }

      log("================  $associatedId ============");

      CollectionReference notificationReference;

      if (isTimebankNotification) {
        notificationReference =
            CollectionRef.timebankNotification(associatedId);
      } else {
        notificationReference = CollectionRef.userNotification(associatedId);
      }
      batch.update(
        notificationReference.doc(notificationId),
        {'isRead': true},
      );

      //Create disputeNotification notification
      var notificationReferenceForDonor;
      if (donationStatus == DonationStatus.ACKNOWLEDGED) {
        notificationReferenceForDonor =
            CollectionRef.userNotification(donationModel.donorDetails!.email!);
        acknowledgementNotification.isTimebankNotification = false;
        acknowledgementNotification.isRead = false;
        //donor member reference
      } else {
        if (operatoreMode == OperatingMode.CREATOR &&
            donationModel.donatedToTimebank!) {
          notificationReferenceForDonor = CollectionRef.userNotification(
              donationModel.donorDetails!.email!);
          acknowledgementNotification.isTimebankNotification = false;
          acknowledgementNotification.isRead = false;

          // direct towards timebank
        } else if (operatoreMode != OperatingMode.CREATOR &&
            donationModel.donatedToTimebank != null &&
            donationModel.donatedToTimebank == true &&
            donationModel.requestIdType == 'request') {
          //direct it towards creator
          notificationReferenceForDonor =
              CollectionRef.timebankNotification(donationModel.timebankId!);
        } else if (operatoreMode != OperatingMode.CREATOR &&
            donationModel.requestIdType == 'offer') {
          notificationReferenceForDonor = CollectionRef.userNotification(
              donationModel.receiverDetails!.email!);
          acknowledgementNotification.isTimebankNotification = false;
          acknowledgementNotification.isRead = false;
        } else if (operatoreMode == OperatingMode.CREATOR &&
            donationModel.requestIdType == 'offer') {
          notificationReferenceForDonor = CollectionRef.userNotification(
              donationModel.donorDetails!.email!);
          acknowledgementNotification.isTimebankNotification = false;
          acknowledgementNotification.isRead = false;
        } else {
          notificationReferenceForDonor = CollectionRef.userNotification(
              donationModel.requestId!.split('*')[0]);
          acknowledgementNotification.isTimebankNotification = false;
          acknowledgementNotification.isRead = false;
        }
      }

      batch.set(
        notificationReferenceForDonor.doc(acknowledgementNotification.id),
        acknowledgementNotification.toMap(),
      );

      await batch.commit();
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> createDisputeNotification({
    required String donationId,
    required bool isTimebankNotification,
    required String associatedId,
    required String notificationId,
    required NotificationsModel disputedNotification,
  }) async {
    // Make notificaiton as read for the moderator

    var batch = CollectionRef.batch;
    batch.update(CollectionRef.donations.doc(donationId), {
      'donationStatus': DonationStatus.MODIFIED.toString().split('.')[1],
    });
    CollectionReference notificationReference = isTimebankNotification
        ? CollectionRef.timebankNotification(associatedId)
        : CollectionRef.userNotification(associatedId);

    batch.update(
      notificationReference.doc(notificationId),
      {'isRead': true},
    );

    //Create acknowledgement notification
    batch.set(
      notificationReference.doc(disputedNotification.id),
      disputedNotification.toMap(),
    );
    batch.commit();
  }

  Future<void> donationCreditedNotificationToMember({
    required TimebankModel model,
    required UserModel user,
    required double donateAmount,
    required BuildContext context,
    required bool toMember,
  }) async {
    NotificationsModel notification = NotificationsModel(
      communityId: model.communityId,
      id: const Uuid().v4(),
      isRead: false,
      isTimebankNotification: toMember ? false : true,
      senderUserId:
          toMember ? model.id : SevaCore.of(context).loggedInUser.sevaUserID,
      targetUserId: toMember ? user.sevaUserID : model.id,
      timebankId: model.id,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: toMember
          ? NotificationType.MEMBER_RECEIVED_CREDITS_DONATION
          : NotificationType.COMMUNITY_RECEIVED_CREDITS_DONATION,
      data: {
        'credits': donateAmount,
        'donorName': SevaCore.of(context).loggedInUser.fullname,
        'donorPhotoUrl': toMember
            ? model.photoUrl
            : SevaCore.of(context).loggedInUser.photoURL,
        'donorId': SevaCore.of(context).loggedInUser.sevaUserID,
        'communityName': model.name,
      },
    );

    logger.e('TIMEBANK ID:  ' + model.id);
    toMember
        ? await CollectionRef.users
            .doc(user.email)
            .collection("notifications")
            .doc(notification.id)
            .set(notification.toMap())
        : await CollectionRef.timebank
            .doc(model.id)
            .collection("notifications")
            .doc(notification.id)
            .set(notification.toMap());
  }
}
