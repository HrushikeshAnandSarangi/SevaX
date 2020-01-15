import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

class RequestService extends BaseService {
  /// Create a request[requestModel]
  Future<void> createRequest({@required RequestModel requestModel}) async {
    log.i('createRequest: RequestModel: ${requestModel.toMap()}');
    return await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .setData(requestModel.toMap());
  }

  ///  get a stream of requests created by an user using the [sevaUserID]
  Stream<List<RequestModel>> getRequestStreamCreatedByUser({
    @required String sevaUserID,
  }) async* {
    log.i('getRequestStreamCreatedByUser: SevaUserID: $sevaUserID');
    var data = Firestore.instance
        .collection('requests')
        .where('accepted', isEqualTo: false)
        .where('sevauserid', isEqualTo: sevaUserID)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
              requestList.add(model);
            },
          );
          requestSink.add(requestList);
        },
      ),
    );
  }

  /// get all request as stream for a [timebankId]
  Stream<List<RequestModel>> getRequestListStream({String timebankId}) async* {
    log.i('getRequestListStream: TimeBankId: $timebankId');
    var query = timebankId == null
        ? Firestore.instance
            .collection('requests')
            .where('accepted', isEqualTo: false)
        : Firestore.instance
            .collection('requests')
            .where('timebankId', isEqualTo: timebankId)
            .where('accepted', isEqualTo: false);

    var data = query.snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            },
          );
          requestSink.add(requestList);
        },
      ),
    );
  }

  /// Create notification for offer request from request creator[requestSevaID] to offer creator[offermodel]
  Future<void> sendOfferRequest({
    @required OfferModel offerModel,
    @required String requestSevaID,
    @required String communityId,
  }) async {
    log.i(
        'sendOfferRequest: OfferModel: ${offerModel.toMap()} \n RequestSevaId: $requestSevaID');
    NotificationsModel model = NotificationsModel(
      targetUserId: offerModel.sevaUserId,
      data: offerModel.toMap(),
      type: NotificationType.OfferAccept,
      id: utils.Utils.getUuid(),
      isRead: false,
      senderUserId: requestSevaID,
      communityId: communityId,
    );
    await utils.offerAcceptNotification(
      model: model,
    );
  }

  /// create notification for Request Accept from [senderUserId] to request creator[requestModel]
  Future<void> acceptRequest({
    @required RequestModel requestModel,
    @required String senderUserId,
    bool isWithdrawal = false,
    bool fromOffer = false,
    @required String communityId,
  }) async {

    // log.i(
    //     'acceptRequest: RequestModel: ${requestModel.toMap()} \n SenderUserId: $senderUserId');
    // assert(requestModel != null);

    print("==============${requestModel}");

    return;

    await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData(requestModel.toMap());

    if (!fromOffer) {
      NotificationsModel model = NotificationsModel(
        targetUserId: requestModel.sevaUserId,
        data: requestModel.toMap(),
        type: NotificationType.RequestAccept,
        id: utils.Utils.getUuid(),
        isRead: false,
        senderUserId: senderUserId,
        communityId: communityId,
      );

      if (isWithdrawal)
        await utils.withdrawAcceptRequestNotification(
          notificationsModel: model,
        );
      else
        await utils.createAcceptRequestNotification(
          notificationsModel: model,
        );
    }
  }

  /// Update a request[model] as completed and add transaction field
  Future<void> requestComplete({
    @required RequestModel model,
  }) async {
    log.i('requestComplete: RequestModel: ${model.toMap()}');
    await Firestore.instance
        .collection('requests')
        .document(model.id)
        .setData(model.toMap(), merge: true);
  }

  /// Reject a request completion and update DB and create a RequestCompletedRejected Notification from request creator[model] to [userId]
  Future<void> rejectRequestCompletion({
    @required RequestModel model,
    @required String userId,
    @required String communityId,
  }) async {
    log.i(
        'rejectRequestCompletion: RequestModel: ${model.toMap()} \n UserId: $userId');
    await Firestore.instance
        .collection('requests')
        .document(model.id)
        .setData(model.toMap(), merge: true);

    NotificationsModel notification = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: userId,
      senderUserId: model.sevaUserId,
      type: NotificationType.RequestCompletedRejected,
      data: model.toMap(),
      communityId: communityId,
    );
    await utils.createTaskCompletedApprovedNotification(model: notification);
  }

  /// Approve a request completion and update DB and create a RequestCompletedApproved Notification from request creator[model] to [userId]
  /// Update currentBalance in User's firestore document and create transaction notification
  Future<void> approveRequestCompletion({
    @required RequestModel model,
    @required String userId,
    @required String communityId,
  }) async {
    log.i(
        'approveRequestCompletion: RequestModel: ${model.toMap()} \n UserID: $userId');
    await Firestore.instance
        .collection('requests')
        .document(model.id)
        .setData(model.toMap(), merge: true);

    UserModel user = await utils.getUserForId(sevaUserId: userId);

    NotificationsModel notification = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: userId,
      senderUserId: model.sevaUserId,
      type: NotificationType.RequestCompletedApproved,
      data: model.toMap(),
      communityId: communityId,
    );

    num transactionvalue = model.durationOfRequest / 60;
    String credituser = model.approvedUsers.toString();
    await Firestore.instance
        .collection('users')
        .document(user.email)
        .updateData({'currentBalance': FieldValue.increment(transactionvalue)});
    NotificationsModel creditnotification = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: userId,
      senderUserId: model.sevaUserId,
      communityId: communityId,
      type: NotificationType.TransactionCredit,
      data: model.transactions
          .where((transactionModel) {
            if (transactionModel.from == model.sevaUserId &&
                transactionModel.to == userId) {
              return true;
            } else {
              return false;
            }
          })
          .elementAt(0)
          .toMap(),
    );

    await utils.createTaskCompletedApprovedNotification(model: notification);
    await utils.createTransactionNotification(model: creditnotification);
  }

  /// Approve AcceptRequest, update DB and Create RequestApprove Notification from request creator[requestModel] to [approvedUserId]
  /// Remove AcceptRequest Notification[notificationId]
  Future<void> approveAcceptRequest({
    @required RequestModel requestModel,
    @required String approvedUserId,
    @required String notificationId,
    @required String communityId,
  }) async {
    log.i(
        'approveAcceptRequest: RequestModel: ${requestModel.toMap()} \n ApprovedUserID: $approvedUserId \n NotificationID: $notificationId');
    await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData(requestModel.toMap());

    NotificationsModel model = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: approvedUserId,
      senderUserId: requestModel.sevaUserId,
      type: NotificationType.RequestApprove,
      data: requestModel.toMap(),
      communityId: communityId,
    );

    await utils.removeAcceptRequestNotification(
      model: model,
      notificationId: notificationId,
    );
    await utils.createRequestApprovalNotification(model: model);
  }

  /// Reject AcceptRequest, update DB and Create RequestReject Notification from request creator[requestModel] to [approvedUserId]
  /// Remove AcceptRequest Notification[notificationId]
  Future<void> rejectAcceptRequest({
    @required RequestModel requestModel,
    @required String rejectedUserId,
    @required String notificationId,
    @required String communityId,
  }) async {
    log.i(
        'rejectAcceptRequest: RequestModel: ${requestModel.toMap()} \n ApprovedUserID: $rejectedUserId \n NotificationID: $notificationId');

    await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData(requestModel.toMap());

    NotificationsModel model = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: rejectedUserId,
      senderUserId: requestModel.sevaUserId,
      type: NotificationType.RequestReject,
      data: requestModel.toMap(),
      communityId: communityId,
    );

    await utils.removeAcceptRequestNotification(
      model: model,
      notificationId: notificationId,
    );
    await utils.createRequestApprovalNotification(model: model);
  }

  /// Get tasks as stream for a [userEmail]
  Stream<List<RequestModel>> getTaskStreamForUserWithEmail({
    @required String userEmail,
    @required String userId,
  }) async* {
    log.i(
        'getTaskStreamForUserWithEmail: UserEmail: $userEmail \n UserID: $userId');
    var data = Firestore.instance
        .collection('requests')
        .where('approvedUsers', arrayContains: userEmail)
        .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestModelList = [];
          snapshot.documents.forEach((documentSnapshot) {
            RequestModel model = RequestModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            bool isCompletedByUser = false;

            model.transactions?.forEach((transaction) {
              if (transaction.to == userId) isCompletedByUser = true;
            });
            if (!isCompletedByUser) {
              requestModelList.add(model);
            }
          });

          requestSink.add(requestModelList);
        },
      ),
    );
  }

  /// get requests as future by [requestId]
  Future<RequestModel> getRequestFutureById({
    @required String requestId,
  }) async {
    log.i('getRequestFutureById: RequestID: $requestId');
    var documentsnapshot = await Firestore.instance
        .collection('requests')
        .document(requestId)
        .get();

    return RequestModel.fromMap(documentsnapshot.data);
  }

  /// get requests as stream by [requestId]
  Stream<RequestModel> getRequestStreamById({
    @required String requestId,
  }) async* {
    log.i('getRequestStreamById: RequestID: $requestId');
    var data = Firestore.instance
        .collection('requests')
        .document(requestId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<DocumentSnapshot, RequestModel>.fromHandlers(
        handleData: (snapshot, requestSink) {
          RequestModel model = RequestModel.fromMap(snapshot.data);
          model.id = snapshot.documentID;
          requestSink.add(model);
        },
      ),
    );
  }

  /// Get a stream of completed requests of a [userEmail]
  Stream<List<RequestModel>> getCompletedRequestStream({
    @required String userEmail,
    @required String userId,
  }) async* {
    log.i(
        'getCompletedRequestStream: UserEmail: $userEmail \n UserID: $userId');
    var data = Firestore.instance
        .collection('requests')
        .where('approvedUsers', arrayContains: userEmail)
        .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach((document) {
            RequestModel model = RequestModel.fromMap(document.data);
            model.id = document.documentID;
            bool isRequestCompleted = false;
            model.transactions?.forEach((transaction) {
              if (transaction.isApproved && transaction.to == userId)
                isRequestCompleted = true;
            });
            if (isRequestCompleted) requestList.add(model);
          });
          requestSink.add(requestList);
        },
      ),
    );
  }

  /// Get a stream of not accepted requests of a [userEmail]
  Stream<List<RequestModel>> getNotAcceptedRequestStream({
    @required String userEmail,
    @required String userId,
  }) async* {
    log.i(
        'getNotAcceptedRequestStream: UserEmail: $userEmail \n UserID: $userId');
    var data = Firestore.instance
        .collection('requests')
        .where('acceptors', arrayContains: userEmail)
        .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach((document) {
            RequestModel model = RequestModel.fromMap(document.data);
            model.id = document.documentID;
            bool isApproved = false;
            if (model.approvedUsers.contains(userEmail)) {
              isApproved = true;
            }
            if (!isApproved) requestList.add(model);
          });
          requestSink.add(requestList);
        },
      ),
    );
  }
}
