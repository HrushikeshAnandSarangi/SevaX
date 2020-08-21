import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class DonationsRepository {
  static final CollectionReference _donation_ref =
      Firestore.instance.collection(
    DBCollection.donations,
  );

  Stream<QuerySnapshot> getDonationsOfRequest(String requestId) {
    return _donation_ref.where('requestId', isEqualTo: requestId).snapshots();
  }

  Future<void> acknowledgeDonation({
    String donationId,
    bool isTimebankNotification,
    String associatedId,
    String notificationId,
    NotificationsModel acknowledgementNotification,
    @required DonationStatus donationStatus,
    @required RequestType requestType,
  }) async {
    var batch = Firestore.instance.batch();
    batch.updateData(_donation_ref.document(donationId), {
      'donationStatus': donationStatus.toString().split('.')[1],
      if (donationStatus == DonationStatus.ACKNOWLEDGED &&
          requestType == RequestType.CASH)
        'cashDetails.pledgedAmount':
            (acknowledgementNotification.data as DonationModel)
                .cashDetails
                .pledgedAmount,
      if (donationStatus == DonationStatus.ACKNOWLEDGED &&
          requestType == RequestType.CASH)
        'goodsDetails.donatedGoods':
            (acknowledgementNotification.data as DonationModel)
                .goodsDetails
                .donatedGoods,
    });

    var notificationReference = Firestore.instance
        .collection(isTimebankNotification ? 'timebanksnew' : 'users')
        .document(associatedId)
        .collection('notifications');

    batch.updateData(
      notificationReference.document(notificationId),
      {'isRead': true},
    );
    //Create disputeNotification notification
    batch.setData(
      notificationReference.document(acknowledgementNotification.id),
      acknowledgementNotification.toMap(),
    );
    batch.commit();
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
    batch.updateData(_donation_ref.document(donationId), {
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
