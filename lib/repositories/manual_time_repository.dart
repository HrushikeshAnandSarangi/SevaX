import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';

import '../flavor_config.dart';

class ManualTimeRepository {
  static Future<void> createClaim(ManualTimeModel model) async {
    assert(model.id != null);
    await CollectionRef.manualTimeClaims.doc(model.id).set(model.toMap());
  }

  static Future<bool> approveManualCreditClaim({
    required ManualTimeModel model,
    required TransactionModel memberTransactionModel,
    required TransactionModel timebankTransaction,
    required String notificationId,
    required UserModel userModel,
  }) async {
    return await _getApproveManualCreditClaimBatch(
      model: model,
      memberTransactionModel: memberTransactionModel,
      timebankTransaction: timebankTransaction,
      notificationId: notificationId,
      userModel: userModel,
    ).commit().then((value) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

  static Future<bool> rejectManualCreditClaim({
    required ManualTimeModel model,
    required String notificationId,
    required UserModel userModel,
  }) async {
    return await _rejectManualtimeClaimBatch(
      model: model,
      notificationId: notificationId,
      userModel: userModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static Future<bool> approveCreditForCreator({
    required ManualTimeModel model,
    required TransactionModel memberTransactionModel,
    required TransactionModel timebankTransaction,
    required UserModel userModel,
  }) async {
    return await _getApproveManualCreditClaimForCreatorBatch(
      model: model,
      memberTransactionModel: memberTransactionModel,
      timebankTransaction: timebankTransaction,
      userModel: userModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  // =============================UTILS========================================

  static WriteBatch _getApproveManualCreditClaimForCreatorBatch({
    required ManualTimeModel model,
    required TransactionModel memberTransactionModel,
    required TransactionModel timebankTransaction,
    required UserModel userModel,
  }) {
    assert(model.status != ClaimStatus.NoAction);
    assert(model.actionBy != null);
    var batchWrite = CollectionRef.batch;

    //Update Model in collection
    batchWrite.update(
      CollectionRef.manualTimeClaims.doc(model.id),
      {
        "status": model.status.toString().split('.')[1],
        "actionBy": model.actionBy,
      },
    );

    // Create Transaction for reciever
    batchWrite.set(
      CollectionRef.transactions.doc(),
      memberTransactionModel.toMap(),
    );

    // Create Transaction for timebank
    batchWrite.set(
      CollectionRef.transactions.doc(),
      timebankTransaction.toMap(),
    );

    // //Update Balance
    // batchWrite.update(
    //   _firestore.doc(model.userDetails.email),
    //   {
    //     AppConfig.isTestCommunity ? 'sandboxCurrentBalance' : 'currentBalance':
    //         FieldValue.increment(model.claimedTime / 60),
    //   },
    // );

    //create credit notification
    // var notificationsModel = _getCreditNotification(
    //   model: model,
    // );
    // batchWrite.set(
    //   _firestore
    //       .users
    //       .doc(model.userDetails.email)
    //       .collection('notifications')
    //       .doc(notificationsModel.id),
    //   notificationsModel.toMap(),
    // );

    return batchWrite;
  }

  static WriteBatch _getApproveManualCreditClaimBatch({
    required ManualTimeModel model,
    required TransactionModel memberTransactionModel,
    required TransactionModel timebankTransaction,
    required String notificationId,
    required UserModel userModel,
  }) {
    assert(model.status != ClaimStatus.NoAction);
    assert(model.actionBy != null);
    var batchWrite = CollectionRef.batch;

    //Update Model in collection
    batchWrite.update(
      CollectionRef.manualTimeClaims.doc(model.id),
      {
        "status": model.status.toString().split('.')[1],
        "actionBy": model.actionBy,
      },
    );

    // Create Transaction for reciever
    batchWrite.set(
      CollectionRef.transactions.doc(),
      memberTransactionModel.toMap(),
    );

    // Create Transaction for reciever
    batchWrite.set(
      CollectionRef.transactions.doc(),
      timebankTransaction.toMap(),
    );

    //Update Balance
    // batchWrite.update(
    //   CollectionRef.users.doc(model.userDetails.email),
    //   {
    //     AppConfig.isTestCommunity ? 'sandboxCurrentBalance' : 'currentBalance':
    //         FieldValue.increment(model.claimedTime / 60),
    //   },
    // );

    //Create notification
    var notificationModel = getNotificationModel(
      model: model,
      user: userModel,
    );
    batchWrite.set(
      getNotificationDocumentReference(
        model: notificationModel,
        userEmail: model.userDetails!.email!,
      ),
      notificationModel.toMap(),
    );

    //create credit notification
    // var notificationsModel = _getCreditNotification(
    //   model: model,
    // );
    // batchWrite.set(
    //   CollectionRef
    //       .users
    //       .doc(model.userDetails.email)
    //       .collection('notifications')
    //       .doc(notificationsModel.id),
    //   notificationsModel.toMap(),
    // );

    //Clear notification
    if (notificationId != null && notificationId != '') {
      batchWrite.update(
        CollectionRef.timebank
            .doc(model.timebankId)
            .collection('notifications')
            .doc(notificationId),
        {
          'isRead': true,
        },
      );
    }
    return batchWrite;
  }

  static _rejectManualtimeClaimBatch({
    required ManualTimeModel model,
    required String notificationId,
    required UserModel userModel,
  }) {
    var batchWrite = CollectionRef.batch;

    //Update Model in collection
    batchWrite.update(
      CollectionRef.manualTimeClaims.doc(model.id),
      {
        "status": model.status.toString().split('.')[1],
        "actionBy": model.actionBy,
      },
    );

    //Create notification
    var notificationModel = getNotificationModel(
      model: model,
      user: userModel,
    );
    batchWrite.set(
      getNotificationDocumentReference(
        model: notificationModel,
        userEmail: model.userDetails!.email!,
      ),
      notificationModel.toMap(),
    );

    //Clear notification
    if (notificationId != null) {
      batchWrite.update(
        CollectionRef.timebank
            .doc(model.timebankId)
            .collection('notifications')
            .doc(notificationId),
        {
          'isRead': true,
        },
      );
    }
    return batchWrite;
  }

  static _getCreditNotification({required ManualTimeModel model}) {
    return NotificationsModel(
      communityId: model.communityId,
      id: uuid.Uuid().v4(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: model.timebankId,
      targetUserId: model.userDetails?.id,
      timebankId: model.timebankId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.SEVA_COINS_CREDITED,
      data: {
        'credits': model.claimedTime! / 60,
      },
    );
  }

  static TransactionModel getMemberTransactionModel(
    ManualTimeModel model,
  ) {
    return TransactionModel(
        communityId: model.communityId,
        credits: model.claimedTime! / 60,
        from: model.timebankId,
        fromEmail_Id: model.timebankId,
        toEmail_Id: model.userDetails?.email,
        isApproved: true,
        timebankid: model.timebankId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        to: model.userDetails?.id,
        transactionbetween: [
          model.userDetails?.id ?? '',
          model.timebankId ?? '',
        ],
        type: 'MANNUAL_TIME',
        typeid: model.typeId,
        liveMode: !AppConfig.isTestCommunity);
  }

  static TransactionModel getTimebankTransactionModel(
    ManualTimeModel model,
  ) {
    return TransactionModel(
        communityId: model.communityId,
        credits: model.claimedTime! / 60,
        from: FlavorConfig.values.timebankId,
        fromEmail_Id: FlavorConfig.values.timebankId,
        toEmail_Id: model.timebankId,
        isApproved: true,
        timebankid: model.timebankId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        to: model.timebankId,
        transactionbetween: [
          model.timebankId ?? '',
          FlavorConfig.values.timebankId,
        ],
        type: 'MANNUAL_TIME',
        typeid: model.typeId,
        liveMode: !AppConfig.isTestCommunity);
  }

  static DocumentReference getNotificationDocumentReference({
    required NotificationsModel model,
    required String userEmail,
  }) {
    CollectionReference ref;
    if (model.isTimebankNotification ?? false) {
      ref = CollectionRef.timebankNotification(model.timebankId!);
    } else {
      ref = CollectionRef.userNotification(userEmail);
    }
    return ref.doc(model.id);
  }

  static NotificationsModel getNotificationModel({
    UserModel? user,
    ManualTimeModel? model,
  }) {
    NotificationsModel notificationsModel = NotificationsModel()
      ..id = uuid.Uuid().v4()
      ..type = model?.status == ClaimStatus.Approved
          ? NotificationType.MANUAL_TIME_CLAIM_APPROVED
          : NotificationType.MANUAL_TIME_CLAIM_REJECTED
      ..data = model?.toMap()
      ..communityId = user?.currentCommunity
      ..isTimebankNotification = false
      ..timebankId = model?.timebankId
      ..senderUserId = user?.sevaUserID;

    return notificationsModel;
  }
}
