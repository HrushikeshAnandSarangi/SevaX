import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';

class ManualTimeRepository {
  static final String _userCollection = "users";

  static Firestore _firestore = Firestore.instance;
  static final String _timebankCollection = "timebanknew";
  static String _notificationCollection = "notifications";

  static final _ref = Firestore.instance.collection('manualTimeClaims');

  static Future<void> createClaim(ManualTimeModel model) async {
    assert(model.id != null);
    await _ref.document(model.id).setData(model.toMap());
  }

  static Future<bool> approveManualCreditClaim({
    @required ManualTimeModel model,
    @required TransactionModel memberTransactionModel,
    @required TransactionModel timebankTransaction,
    @required String notificationId,
    @required UserModel userModel,
  }) async {
    return await _getApproveManualCreditClaimBatch(
      model: model,
      memberTransactionModel: memberTransactionModel,
      timebankTransaction: timebankTransaction,
      notificationId: notificationId,
      userModel: userModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static Future<bool> rejectManualCreditClaim({
    @required ManualTimeModel model,
    @required String notificationId,
    @required UserModel userModel,
  }) async {
    return await _rejectManualtimeClaimBatch(
      model: model,
      notificationId: notificationId,
      userModel: userModel,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static Future<bool> approveCreditForCreator({
    @required ManualTimeModel model,
    @required TransactionModel memberTransactionModel,
    @required TransactionModel timebankTransaction,
    @required UserModel userModel,
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
    @required ManualTimeModel model,
    @required TransactionModel memberTransactionModel,
    @required TransactionModel timebankTransaction,
    @required UserModel userModel,
  }) {
    assert(model.status != ClaimStatus.NoAction);
    assert(model.actionBy != null);
    var batchWrite = Firestore.instance.batch();

    //Update Model in collection
    batchWrite.updateData(
      _ref.document(model.id),
      {
        "status": model.status.toString().split('.')[1],
        "actionBy": model.actionBy,
      },
    );

    // Create Transaction for reciever
    batchWrite.setData(
      _firestore.collection('transactions').document(),
      memberTransactionModel.toMap(),
    );

    // Create Transaction for timebank
    batchWrite.setData(
      _firestore.collection('transactions').document(),
      timebankTransaction.toMap(),
    );

    //Update Balance
    batchWrite.updateData(
      _firestore.document(model.userDetails.email),
      {
        'balance': FieldValue.increment(model.claimedTime / 60),
      },
    );

    //create credit notification
    var notificationsModel = _getCreditNotification(
      model: model,
    );
    batchWrite.setData(
      _firestore
          .collection('users')
          .document(model.userDetails.email)
          .collection('notifications')
          .document(notificationsModel.id),
      notificationsModel.toMap(),
    );

    return batchWrite;
  }

  static WriteBatch _getApproveManualCreditClaimBatch({
    @required ManualTimeModel model,
    @required TransactionModel memberTransactionModel,
    @required TransactionModel timebankTransaction,
    @required String notificationId,
    @required UserModel userModel,
  }) {
    assert(model.status != ClaimStatus.NoAction);
    assert(model.actionBy != null);
    var batchWrite = Firestore.instance.batch();

    //Update Model in collection
    batchWrite.updateData(
      _ref.document(model.id),
      {
        "status": model.status.toString().split('.')[1],
        "actionBy": model.actionBy,
      },
    );

    // Create Transaction for reciever
    batchWrite.setData(
      _firestore.collection('transactions').document(),
      memberTransactionModel.toMap(),
    );

    // Create Transaction for reciever
    batchWrite.setData(
      _firestore.collection('transactions').document(),
      timebankTransaction.toMap(),
    );

    //Update Balance
    batchWrite.updateData(
      _firestore.document(model.userDetails.email),
      {
        'balance': FieldValue.increment(model.claimedTime / 60),
      },
    );

    //Create notification
    var notificationModel = getNotificationModel(
      model: model,
      user: userModel,
    );
    batchWrite.setData(
      getNotificationDocumentReference(
        model: notificationModel,
        userEmail: model.userDetails.email,
      ),
      notificationModel.toMap(),
    );

    //create credit notification
    var notificationsModel = _getCreditNotification(
      model: model,
    );
    batchWrite.setData(
      _firestore
          .collection('users')
          .document(model.userDetails.email)
          .collection('notifications')
          .document(notificationsModel.id),
      notificationsModel.toMap(),
    );

    //Clear notification
    batchWrite.updateData(
      _firestore
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(notificationId),
      {
        'isRead': true,
      },
    );
    return batchWrite;
  }

  static _rejectManualtimeClaimBatch({
    @required ManualTimeModel model,
    @required String notificationId,
    @required UserModel userModel,
  }) {
    var batchWrite = Firestore.instance.batch();

    //Update Model in collection
    batchWrite.updateData(
      _ref.document(model.id),
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
    batchWrite.setData(
      getNotificationDocumentReference(
        model: notificationModel,
        userEmail: model.userDetails.email,
      ),
      notificationModel.toMap(),
    );

    //Clear notification
    batchWrite.updateData(
      _firestore
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(notificationId),
      {
        'isRead': true,
      },
    );
  }

  static _getCreditNotification({ManualTimeModel model}) {
    return NotificationsModel(
      communityId: model.communityId,
      id: Uuid().generateV4(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: model.timebankId,
      targetUserId: model.userDetails.id,
      timebankId: model.timebankId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.SEVA_COINS_CREDITED,
      data: {},
    );
  }

  static TransactionModel getMemberTransactionModel(
    ManualTimeModel model,
  ) {
    return TransactionModel(
      associatedCommunity: model.communityId,
      credits: model.claimedTime / 60,
      from: model.timebankId,
      isApproved: true,
      timebankid: model.timebankId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      to: model.userDetails.id,
      transactionbetween: [
        model.userDetails.id,
        model.timebankId,
      ],
      type: 'MANNUAL_TIME',
      typeid: model.typeId,
    );
  }

  static TransactionModel getTimebankTransactionModel(
    ManualTimeModel model,
  ) {
    return TransactionModel(
      associatedCommunity: model.communityId,
      credits: model.claimedTime / 60,
      from: model.timebankId,
      isApproved: true,
      timebankid: model.timebankId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      to: model.timebankId,
      transactionbetween: [
        model.timebankId,
        model.timebankId,
      ],
      type: 'MANNUAL_TIME',
      typeid: model.typeId,
    );
  }

  static DocumentReference getNotificationDocumentReference({
    NotificationsModel model,
    String userEmail,
  }) {
    CollectionReference ref;
    if (model.isTimebankNotification) {
      ref = _firestore
          .collection(_timebankCollection)
          .document(model.timebankId)
          .collection(_notificationCollection);
    } else {
      ref = _firestore
          .collection(_userCollection)
          .document(userEmail)
          .collection(_notificationCollection);
    }
    return ref.document(model.id);
  }

  static NotificationsModel getNotificationModel({
    UserModel user,
    ManualTimeModel model,
  }) {
    NotificationsModel notificationsModel = NotificationsModel()
      ..id = Uuid().generateV4()
      ..type = model.status == ClaimStatus.Approved
          ? NotificationType.MANUAL_TIME_CLAIM_APPROVED
          : NotificationType.MANUAL_TIME_CLAIM_REJECTED
      ..data = model.toMap()
      ..communityId = user.currentCommunity
      ..isTimebankNotification = false
      ..timebankId = model.timebankId
      ..senderUserId = user.sevaUserID;

    return notificationsModel;
  }
}
