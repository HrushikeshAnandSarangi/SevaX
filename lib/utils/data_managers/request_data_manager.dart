import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/request_model.dart';

Future<void> createRequest({@required RequestModel requestModel}) async {
  return await Firestore.instance
      .collection('requests')
      .document(requestModel.id)
      .setData(requestModel.toMap());
}

Stream<List<RequestModel>> getRequestStreamCreatedByUser({
  @required String sevaUserID,
}) async* {
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

Stream<List<RequestModel>> getRequestListStream({String timebankId}) async* {
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

Future<void> sendOfferRequest(
    {@required OfferModel offerModel, @required String requestSevaID}) async {
  NotificationsModel model = NotificationsModel(
    targetUserId: offerModel.sevaUserId,
    data: offerModel.toMap(),
    type: NotificationType.OfferAccept,
    id: utils.Utils.getUuid(),
    isRead: false,
    senderUserId: requestSevaID,
  );
  await utils.offerAcceptNotification(
    model: model,
  );
}

Future<void> acceptRequest({
  @required RequestModel requestModel,
  @required String senderUserId,
  bool isWithdrawal = false,
  bool fromOffer = false,
}) async {
  assert(requestModel != null);

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
  // if (fromOffer) {
  //   NotificationsModel model = NotificationsModel(
  //     targetUserId: requestModel.sevaUserId,
  //     data: requestModel.toMap(),
  //     type: NotificationType.RequestAccept,
  //     id: utils.Utils.getUuid(),
  //     isRead: false,
  //     senderUserId: senderUserId,
  //   );

  //   if (isWithdrawal)
  //     await utils.withdrawAcceptRequestNotification(
  //       notificationsModel: model,
  //     );
  //   else
  //     await utils.createAcceptRequestNotification(
  //       notificationsModel: model,
  //     );
  // }
}

Future<void> requestComplete({
  @required RequestModel model,
}) async {
  await Firestore.instance
      .collection('requests')
      .document(model.id)
      .setData(model.toMap(), merge: true);
}

Future<void> rejectRequestCompletion({
  @required RequestModel model,
  @required String userId,
}) async {
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
  );
  await utils.createTaskCompletedApprovedNotification(model: notification);
}

Future<void> approveRequestCompletion({
  @required RequestModel model,
  @required String userId,
}) async {
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
  );

  num transactionvalue = model.durationOfRequest / 60;
  String credituser = model.approvedUsers.toString();
  print(credituser);
  print(user.email);

  if (FlavorConfig.appFlavor == Flavor.APP) {
    await Firestore.instance
        .collection('users')
        .document(model.email)
        .updateData(
            {'currentBalance': FieldValue.increment(-(transactionvalue))});

    NotificationsModel debitnotification = NotificationsModel(
      id: utils.Utils.getUuid(),
      targetUserId: model.sevaUserId,
      senderUserId: userId,
      type: NotificationType.TransactionDebit,
      data: model.transactions
          .where((transactionModel) {
            if (transactionModel.from == model.sevaUserId &&
                transactionModel.to == userId) {
              print(
                  'DEBIT DATA: ${transactionModel.to} == ${model.sevaUserId}');
              print('DEBIT DATA: ${transactionModel.from} == $userId');
              return true;
            } else {
              print(
                  'DEBIT DATA: ${transactionModel.to} == ${model.sevaUserId}');
              print('DEBIT DATA: ${transactionModel.from} == $userId');
              return false;
            }
          })
          .elementAt(0)
          .toMap(),
    );
    await utils.createTransactionNotification(model: debitnotification);
  }

  await Firestore.instance
      .collection('users')
      .document(user.email)
      .updateData({'currentBalance': FieldValue.increment(transactionvalue)});
  NotificationsModel creditnotification = NotificationsModel(
    id: utils.Utils.getUuid(),
    targetUserId: userId,
    senderUserId: model.sevaUserId,
    type: NotificationType.TransactionCredit,
    data: model.transactions
        .where((transactionModel) {
          if (transactionModel.from == model.sevaUserId &&
              transactionModel.to == userId) {
            print(
                'CREDIT DATA: ${transactionModel.from} == ${model.sevaUserId}');
            print('CREDIT DATA: ${transactionModel.to} == $userId');
            return true;
          } else {
            print(
                'CREDIT DATA: ${transactionModel.from} == ${model.sevaUserId}');
            print('CREDIT DATA: ${transactionModel.to} == $userId');
            return false;
          }
        })
        .elementAt(0)
        .toMap(),
  );

  await utils.createTaskCompletedApprovedNotification(model: notification);
  await utils.createTransactionNotification(model: creditnotification);
}

Future<void> approveAcceptRequest({
  @required RequestModel requestModel,
  @required String approvedUserId,
  @required String notificationId,
}) async {
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
  );

  await utils.removeAcceptRequestNotification(
    model: model,
    notificationId: notificationId,
  );
  await utils.createRequestApprovalNotification(model: model);
}

Future<void> rejectAcceptRequest({
  @required RequestModel requestModel,
  @required String rejectedUserId,
  @required String notificationId,
}) async {
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
  );

  await utils.removeAcceptRequestNotification(
    model: model,
    notificationId: notificationId,
  );
  await utils.createRequestApprovalNotification(model: model);
}

Stream<List<RequestModel>> getTaskStreamForUserWithEmail({
  @required String userEmail,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('requests')
      .where('approvedUsers', arrayContains: userEmail)
      .where('timebankId', isEqualTo: FlavorConfig.timebankId)
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

// Future<void> rejectRequestCompletion({
//   @required RequestModel requestModel,
//   @required String approvedUserId,
// }) async {
//   Firestore.instance
//       .collection('notifications')
//       .document(requestModel.sevaUserId)
//       .collection('requestCompletion')
//       .document(requestModel.id)
//       .delete();

//   Firestore.instance
//       .collection('notifications')
//       .document(approvedUserId)
//       .collection('requestRejection')
//       .document(requestModel.id)
//       .setData(requestModel.toMap());
// }

Future<RequestModel> getRequestFutureById({
  @required String requestId,
}) async {
  var documentsnapshot =
      await Firestore.instance.collection('requests').document(requestId).get();

  return RequestModel.fromMap(documentsnapshot.data);
}

Stream<RequestModel> getRequestStreamById({
  @required String requestId,
}) async* {
  var data =
      Firestore.instance.collection('requests').document(requestId).snapshots();

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

Stream<List<RequestModel>> getCompletedRequestStream({
  @required String userEmail,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('requests')
      // .where('transactions.to', isEqualTo: userId)
      // .where('transactions', arrayContains: {'to': '6TSPDyOpdQbUmBcDwfwEWj7Zz0z1', 'isApproved': true})
      //.where('transactions', arrayContains: true)
      .where('approvedUsers', arrayContains: userEmail)
      .where('timebankId', isEqualTo: FlavorConfig.timebankId)
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

Stream<List<RequestModel>> getNotAcceptedRequestStream({
  @required String userEmail,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('requests')
      .where('acceptors', arrayContains: userEmail)
      .where('timebankId', isEqualTo: FlavorConfig.timebankId)
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
