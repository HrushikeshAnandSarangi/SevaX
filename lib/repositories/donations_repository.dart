import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class DonationsRepository {
  static final CollectionReference _donationRef = Firestore.instance.collection(
    DBCollection.donations,
  );

  static final CollectionReference _requestRef = Firestore.instance.collection(
    DBCollection.requests,
  );

  Stream<QuerySnapshot> getDonationsOfRequest(String requestId) {
    return _donationRef.where('requestId', isEqualTo: requestId).snapshots();
  }

  Stream<QuerySnapshot> getDonationsOfOffer(String offerId) {
    return _donationRef.where('requestId', isEqualTo: offerId).snapshots();
  }

  Future<void> acknowledgeDonation({
    String donationId,
    bool isTimebankNotification,
    String associatedId,
    String notificationId,
    NotificationsModel acknowledgementNotification,
    @required DonationStatus donationStatus,
    @required RequestType requestType,
    @required OperatingMode operatoreMode,
  }) async {
    try {
      var donationModel =
          DonationModel.fromMap(acknowledgementNotification.data);

      var batch = Firestore.instance.batch();
      batch.updateData(_donationRef.document(donationId), {
        'donationStatus': donationStatus.toString().split('.')[1],
        if (requestType == RequestType.CASH)
          'cashDetails.pledgedAmount':
              (donationModel).cashDetails.pledgedAmount,
        if (donationStatus == DonationStatus.ACKNOWLEDGED &&
            requestType == RequestType.GOODS)
          'goodsDetails.donatedGoods':
              (donationModel).goodsDetails.donatedGoods,
        'lastModifiedBy': associatedId,
      });

      //update request model with amount raised if donation is acknowledged
      if (donationStatus == DonationStatus.ACKNOWLEDGED) {
        if (requestType == RequestType.CASH) {
          batch.updateData(
            _requestRef.document(donationModel.requestId),
            {
              'cashModeDetails.amountRaised':
                  FieldValue.increment(donationModel.cashDetails.pledgedAmount),
            },
          );
        }
        //send acknowledgement reciept
        await MailDonationReciept.sendReciept(donationModel);
      }

      var notificationReference = Firestore.instance
          .collection(
            isTimebankNotification ? DBCollection.timebank : DBCollection.users,
          )
          .document(associatedId)
          .collection(DBCollection.notifications);
      batch.updateData(
        notificationReference.document(notificationId),
        {'isRead': true},
      );

      //Create disputeNotification notification
      var notificationReferenceForDonor;
      if (donationStatus == DonationStatus.ACKNOWLEDGED) {
        notificationReferenceForDonor = Firestore.instance
            .collection(DBCollection.users)
            .document(donationModel.donorDetails.email)
            .collection(DBCollection.notifications);
        //donor member reference
      } else {
        if (operatoreMode == OperatingMode.CREATOR &&
            donationModel.donatedToTimebank) {
          notificationReferenceForDonor = Firestore.instance
              .collection(DBCollection.users)
              .document(donationModel.donorDetails.email)
              .collection(DBCollection.notifications);
          // direct towards timebank
        } else {
          //direct it towards creator

          if (donationModel.donatedToTimebank) {
            notificationReferenceForDonor = Firestore.instance
                .collection(DBCollection.timebank)
                .document(donationModel.timebankId)
                .collection(DBCollection.notifications);
          } else {
            notificationReferenceForDonor = Firestore.instance
                .collection(DBCollection.users)
                .document(donationModel.requestId.split('*')[0])
                .collection(DBCollection.notifications);
          }
        }
      }

      batch.setData(
        notificationReferenceForDonor.document(acknowledgementNotification.id),
        acknowledgementNotification.toMap(),
      );

      await batch.commit();
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> createDisputeNotification({
    String donationId,
    bool isTimebankNotification,
    String associatedId,
    String notificationId,
    NotificationsModel disputedNotification,
  }) async {
    // Make notificaiton as read for the moderator

    var batch = Firestore.instance.batch();
    batch.updateData(_donationRef.document(donationId), {
      'donationStatus': DonationStatus.MODIFIED.toString().split('.')[1],
    });
    var notificationReference = Firestore.instance
        .collection(isTimebankNotification ? 'timebanksnew' : 'users')
        .document(associatedId)
        .collection('notifications');

    batch.updateData(
      notificationReference.document(notificationId),
      {'isRead': true},
    );

    //Create acknowledgement notification
    batch.setData(
      notificationReference.document(disputedNotification.id),
      disputedNotification.toMap(),
    );
    batch.commit();
  }
}
