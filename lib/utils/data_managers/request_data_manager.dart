import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/timebank_balance_transction_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;

import '../app_config.dart';
import 'notifications_data_manager.dart';

Location location = new Location();
Geoflutterfire geo = Geoflutterfire();

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
  var query = timebankId == null || timebankId == 'All'
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

Stream<List<RequestModel>> getAllRequestListStream() async* {
  var query = Firestore.instance
      .collection('requests')
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
            if (model.approvedUsers != null) {
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            }
          },
        );
        requestSink.add(requestList);
      },
    ),
  );
}

Stream<List<ProjectModel>> getAllProjectListStream({String timebankid}) async* {
  var query = Firestore.instance
      .collection('projects')
      .where('timebank_id', isEqualTo: timebankid)
      .orderBy("created_at", descending: true);

  var data = query.snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ProjectModel>>.fromHandlers(
      handleData: (snapshot, projectSink) {
        print("inside streamtransformer");
        List<ProjectModel> projectsList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            print("documentSnapshot.data.name --------" +
                documentSnapshot.data["name"]);
            ProjectModel model = ProjectModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            projectsList.add(model);
          },
        );
        projectSink.add(projectsList);
      },
    ),
  );
}

Stream<List<RequestModel>> getTimebankRequestListStream(
    {String timebankId}) async* {
  var query = Firestore.instance
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
            if (model.approvedUsers != null) {
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            }
          },
        );

        print("request list size ____________ ${requestList.length}");

        requestSink.add(requestList);
      },
    ),
  );
}

Stream<List<RequestModel>> getTimebankExistingRequestListStream(
    {String timebankId}) async* {
  var query = Firestore.instance
      .collection('requests')
      .where('timebankId', isEqualTo: timebankId)
      .where('accepted', isEqualTo: false)
      .where('requestMode', isEqualTo: 'TIMEBANK_REQUEST');

  var data = query.snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<RequestModel> requestList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            RequestModel model = RequestModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            if (model.approvedUsers != null) {
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            }
          },
        );

        print(
            "request list size ____________ ${requestList.length.toString()}");

        requestSink.add(requestList);
      },
    ),
  );
}

Stream<List<RequestModel>> getPersonalRequestListStream(
    {String sevauserid}) async* {
  var query = Firestore.instance
      .collection('requests')
      .where('sevauserid', isEqualTo: sevauserid)
      .where('accepted', isEqualTo: false)
      .where('requestMode', isEqualTo: 'PERSONAL_REQUEST');

  var data = query.snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<RequestModel> requestList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            RequestModel model = RequestModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            if (model.approvedUsers != null) {
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            }
          },
        );
        requestSink.add(requestList);
      },
    ),
  );
}

Stream<List<RequestModel>> getProjectRequestsStream(
    {String project_id}) async* {
  var query = Firestore.instance
      .collection('requests')
      .where('projectId', isEqualTo: project_id)
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
            if (model.approvedUsers != null) {
              if (model.approvedUsers.length <= model.numberOfApprovals)
                requestList.add(model);
            }
          },
        );
        requestSink.add(requestList);
      },
    ),
  );
}

Stream<List<RequestModel>> getNearRequestListStream(
    {String timebankId, UserModel loggedInUser}) async* {
  // LocationData pos = await location.getLocation();
  // double lat = pos.latitude;
  // double lng = pos.longitude;

  Geolocator geolocator = Geolocator();
  Position userLocation;
  userLocation = await geolocator.getCurrentPosition();
  double lat = userLocation.latitude;
  double lng = userLocation.longitude;
  print("timebank id ->--------------------- " + timebankId);

  print(
      "Location retrieved fom user ->  ${lat.toString()} + ${lng.toString()}");
  GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
  var query = timebankId == null || timebankId == 'All'
      ? Firestore.instance
          .collection('requests')
          .where('accepted', isEqualTo: false)
          .orderBy('posttimestamp', descending: true)
      : Firestore.instance
          .collection('requests')
          .where('timebankId', isEqualTo: timebankId)
          .orderBy('posttimestamp', descending: true);

  var radius = 20;
  try {
    radius = json.decode(AppConfig.remoteConfig.getString('radius'));
  } on Exception {
    print("Exception raised while getting user minimum balance ");
  }
  print(
      "radius is fetched from remote config near request item ${radius.toDouble()}");

  var data = geo.collection(collectionRef: query).within(
        center: center,
        radius: radius.toDouble(),
        field: 'location',
        strictMode: true,
      );

  yield* data.transform(
    StreamTransformer<List<DocumentSnapshot>, List<RequestModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<RequestModel> requestList = [];
        snapshot.forEach(
          (documentSnapshot) {
            if (documentSnapshot.data['accepted'] == false ||
                (documentSnapshot.data['accepted'] == true &&
                    documentSnapshot.data['sevauserid'] ==
                        loggedInUser.sevaUserID)) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
              if (model.approvedUsers != null) {
                if (model.approvedUsers.length <= model.numberOfApprovals)
                  requestList.add(model);
              }
            }
          },
        );
        requestSink.add(requestList);
      },
    ),
  );
}

Future<void> sendOfferRequest({
  @required OfferModel offerModel,
  @required String requestSevaID,
  @required String communityId,
  bool directToMember = true,
}) async {
  NotificationsModel model = NotificationsModel(
    timebankId: offerModel.timebankId,
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

Future<void> acceptRequest({
  @required RequestModel requestModel,
  @required String senderUserId,
  bool isWithdrawal = false,
  bool fromOffer = false,
  @required String communityId,
  bool directToMember,
}) async {
  assert(requestModel != null);

  await Firestore.instance
      .collection('requests')
      .document(requestModel.id)
      .updateData(requestModel.toMap());

  if (!fromOffer) {
    NotificationsModel model = NotificationsModel(
      timebankId: requestModel.timebankId,
      targetUserId: requestModel.sevaUserId,
      data: requestModel.toMap(),
      type: NotificationType.RequestAccept,
      id: utils.Utils.getUuid(),
      isRead: false,
      senderUserId: senderUserId,
      communityId: communityId,
    );

    print("Creating notificationss model $requestModel");

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
  @required String communityid,
}) async {
  await Firestore.instance
      .collection('requests')
      .document(model.id)
      .setData(model.toMap(), merge: true);

  NotificationsModel notification = NotificationsModel(
    timebankId: model.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: userId,
    senderUserId: model.sevaUserId,
    type: NotificationType.RequestCompletedRejected,
    data: model.toMap(),
    communityId: communityid,
  );
  await utils.createTaskCompletedApprovedNotification(model: notification);
}

List<TransactionModel> updateListTransactionsCreditsAsPerTimebankTaxPolicy({
  List<TransactionModel> originalModel,
  double credits,
  String userIdToBeCredited,
  double userAmout,
}) {
  List<TransactionModel> modelTransactions =
      originalModel.map((f) => f).toList();

  return modelTransactions.map((t) {
    if (t.to == userIdToBeCredited) {
      TransactionModel editedTransaction = t;
      editedTransaction.credits = userAmout;
      return editedTransaction;
    }
    return t;
  }).toList();
}

Future<void> approveRequestCompletion({
  @required RequestModel model,
  @required String userId,
  @required String communityId,
  // @required num taxPercentage,
}) async {
  List<TransactionModel> transactions =
      model.transactions.map((t) => t).toList();
  TransactionModel editedTransaction;
  model.transactions = transactions.map((t) {
    if (t.to == userId) {
      editedTransaction = t;
      editedTransaction.isApproved = true;
      return editedTransaction;
    }
    return t;
  }).toList();

  if (model.transactions.where((model) => model.isApproved).length ==
      model.numberOfApprovals) {}

  var approvalCount = 0;
  if (model.transactions != null) {
    for (var i = 0; i < model.transactions.length; i++) {
      if (model.transactions[i].isApproved) {
        approvalCount++;
      }
    }
  }
  model.accepted = approvalCount >= model.numberOfApprovals;

  double transactionvalue = (model.durationOfRequest / 60);

  TimeBankBalanceTransactionModel balanceTransactionModel;
  var updatedRequestModel = model;

  print("========================================================== Step1");
  if (model.requestMode == RequestMode.TIMEBANK_REQUEST) {
    double taxPercentage;

    DocumentSnapshot data = await Firestore.instance
        .collection('communities')
        .document(communityId)
        .get();

    taxPercentage = data.data['taxPercentage'] ?? 0;
    print('---->tax percentage $taxPercentage');

    double tax = transactionvalue * taxPercentage;
    transactionvalue = transactionvalue - tax;

    balanceTransactionModel = TimeBankBalanceTransactionModel(
      communityId: communityId,
      userId: userId,
      requestId: model.id,
      amount: tax,
      timestamp: FieldValue.serverTimestamp(),
    );

    updatedRequestModel.transactions =
        updateListTransactionsCreditsAsPerTimebankTaxPolicy(
      credits: transactionvalue,
      originalModel: model.transactions,
      userAmout: transactionvalue,
      userIdToBeCredited: userId,
    );
  }

  NotificationsModel notification = NotificationsModel(
    timebankId: model.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: userId,
    senderUserId: model.sevaUserId,
    type: NotificationType.RequestCompletedApproved,
    data: model.toMap(),
    communityId: communityId,
  );

  print("========================================================== Step2");

  Map<String, dynamic> transactionData = model.transactions
      .where((transactionModel) {
        if (transactionModel.from == model.sevaUserId &&
            transactionModel.to == userId) {
          return true;
        } else {
          return false;
        }
      })
      .elementAt(0)
      .toMap();

  print("========================================================== Step3");

  //Create transaction record for timebank

  if (model.requestMode == RequestMode.TIMEBANK_REQUEST) {
    Firestore.instance
        .collection("timebanknew")
        .document(model.timebankId)
        .collection("balance")
        .add(
          balanceTransactionModel.toJson(),
        );
  } else {
    NotificationsModel debitnotification = NotificationsModel(
      timebankId: model.timebankId,
      id: utils.Utils.getUuid(),
      targetUserId: model.sevaUserId,
      senderUserId: userId,
      communityId: communityId,
      type: NotificationType.TransactionDebit,
      data: transactionData,
    );
    print("${debitnotification.id}");

    await utils.createTransactionNotification(model: debitnotification);
    print("==>debit notification sent<==");
  }

  // }

  print("========================================================== Step6");

  // await Firestore.instance
  //     .collection('users')
  //     .document(user.email)
  //     .updateData({'currentBalance': FieldValue.increment(userAmount)});

  //User gets a notification with amount after tax deducation
  transactionData["credits"] = transactionvalue;

  await Firestore.instance.collection('requests').document(model.id).setData(
        model.requestMode == RequestMode.PERSONAL_REQUEST
            ? model.toMap()
            : updatedRequestModel.toMap(),
        merge: true,
      );
  await transactionBloc.updateNewTransaction(
      model.requestMode == RequestMode.PERSONAL_REQUEST
          ? editedTransaction.from
          : editedTransaction.timestamp,
      editedTransaction.to,
      editedTransaction.timestamp,
      editedTransaction.credits,
      editedTransaction.isApproved,
      model.requestMode,
      model.id,
      model.timebankId,
      false);
  NotificationsModel creditnotification = NotificationsModel(
    timebankId: model.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: userId,
    senderUserId: model.sevaUserId,
    communityId: communityId,
    type: NotificationType.TransactionCredit,
    data: transactionData,
  );

  print("========================================================== Step7");

  await utils.createTaskCompletedApprovedNotification(model: notification);
  await utils.createTransactionNotification(model: creditnotification);
  print("==>Transaction complete<==");
}

Future<void> approveAcceptRequest({
  @required RequestModel requestModel,
  @required String approvedUserId,
  @required String notificationId,
  @required String communityId,
  @required bool directToMember,
}) async {
  var approvalCount = 0;
  if (requestModel.transactions != null) {
    for (var i = 0; i < requestModel.transactions.length; i++) {
      if (requestModel.transactions[i].isApproved) {
        approvalCount++;
      }
    }
  }
  requestModel.accepted = approvalCount >= requestModel.numberOfApprovals;
  await Firestore.instance
      .collection('requests')
      .document(requestModel.id)
      .updateData(requestModel.toMap());

  var timebankModel = await fetchTimebankData(requestModel.timebankId);
  var tempRequestModel = requestModel;

  if (timebankModel.protected) {
    tempRequestModel.photoUrl = timebankModel.photoUrl;
    tempRequestModel.fullName = timebankModel.name;
  }

  NotificationsModel model = NotificationsModel(
    timebankId: requestModel.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: approvedUserId,
    communityId: communityId,
    senderUserId: requestModel.sevaUserId,
    type: NotificationType.RequestApprove,
    data: tempRequestModel.toMap(),
  );

  await utils.removeAcceptRequestNotification(
    model: model,
    notificationId: notificationId,
  );
  await utils.createRequestApprovalNotification(model: model);
}

Future<void> approveAcceptRequestForTimebank({
  @required RequestModel requestModel,
  @required String approvedUserId,
  @required String notificationId,
  @required String communityId,
}) async {
  var approvalCount = 0;
  if (requestModel.transactions != null) {
    for (var i = 0; i < requestModel.transactions.length; i++) {
      if (requestModel.transactions[i].isApproved) {
        approvalCount++;
      }
    }
  }
  requestModel.accepted = approvalCount >= requestModel.numberOfApprovals;
  await Firestore.instance
      .collection('requests')
      .document(requestModel.id)
      .updateData(requestModel.toMap());

  var timebankModel = await fetchTimebankData(requestModel.timebankId);
  var tempTimebankModel = requestModel;
  tempTimebankModel.photoUrl = timebankModel.photoUrl;
  tempTimebankModel.fullName = timebankModel.name;

  NotificationsModel model = NotificationsModel(
    timebankId: requestModel.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: approvedUserId,
    communityId: communityId,
    senderUserId: tempTimebankModel.sevaUserId,
    type: NotificationType.RequestApprove,
    data: tempTimebankModel.toMap(),
  );

  await utils.readTimeBankNotification(
    timebankId: requestModel.timebankId,
    notificationId: notificationId,
  );
  await utils.createApprovalNotificationForMember(model: model);
}

Future<void> rejectAcceptRequest({
  @required RequestModel requestModel,
  @required String rejectedUserId,
  @required String notificationId,
  @required String communityId,
}) async {
  await Firestore.instance
      .collection('requests')
      .document(requestModel.id)
      .updateData(requestModel.toMap());

  var tempRequestModel = requestModel;
  if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
    var timebankModel = await fetchTimebankData(requestModel.timebankId);
    tempRequestModel.photoUrl = timebankModel.photoUrl;
    tempRequestModel.fullName = timebankModel.name;
  }

  NotificationsModel model = NotificationsModel(
    timebankId: requestModel.timebankId,
    id: utils.Utils.getUuid(),
    targetUserId: rejectedUserId,
    senderUserId: requestModel.sevaUserId,
    type: NotificationType.RequestReject,
    data: tempRequestModel.toMap(),
    communityId: communityId,
  );

  await utils.removeAcceptRequestNotification(
    model: model,
    notificationId: notificationId,
  );
  await utils.createRequestApprovalNotification(model: model);
}

Future<void> rejectInviteRequest({
  @required String requestId,
  @required String rejectedUserId,
  @required String notificationId,
}) async {
  await Firestore.instance
      .collection('requests')
      .document(requestId)
      .updateData({
    'invitedUsers': FieldValue.arrayRemove([rejectedUserId])
  });
}

Future<void> acceptInviteRequest({
  @required String requestId,
  @required String acceptedUserEmail,
  @required String acceptedUserId,
  @required String notificationId,
}) async {
  await Firestore.instance
      .collection('requests')
      .document(requestId)
      .updateData({
    'approvedUsers': FieldValue.arrayUnion([acceptedUserEmail]),
    'acceptors': FieldValue.arrayUnion([acceptedUserEmail]),
    'invitedUsers': FieldValue.arrayRemove([acceptedUserId])
  });
}

Stream<List<RequestModel>> getTaskStreamForUserWithEmail({
  @required String userEmail,
  @required String userId,
}) async* {
  /* TODO needs flow correction need to be corrected as below when tasks introduced- Eswar
  *   var data = Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('tasks')
      .snapshots();
      *
      * */
  var data = Firestore.instance
      .collection('requests')
      .where('approvedUsers', arrayContains: userEmail)
      .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        // TODO needs flow correction to Tasks model need to be corrected
        List<RequestModel> requestModelList = [];
        snapshot.documents.forEach((documentSnapshot) {
          RequestModel model = RequestModel.fromMap(documentSnapshot.data);
          model.id = documentSnapshot.documentID;
          bool isCompletedByUser = false;

          model.transactions?.forEach((transaction) {
            if (transaction.to == userId) isCompletedByUser = true;
          });
          if (!isCompletedByUser) {
            // model.timebankId/
            requestModelList.add(model);
          }
        });

        requestSink.add(requestModelList);
      },
    ),
  );
  // END OF CODE correction mentioned above
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

Future<ProjectModel> getProjectFutureById({
  @required String projectId,
}) async {
  var documentsnapshot =
      await Firestore.instance.collection('projects').document(projectId).get();

  return ProjectModel.fromMap(documentsnapshot.data);
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

Stream<ProjectModel> getProjectStream({
  @required String projectId,
}) async* {
  var data =
      Firestore.instance.collection('projects').document(projectId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, ProjectModel>.fromHandlers(
      handleData: (snapshot, requestSink) {
        ProjectModel model = ProjectModel.fromMap(snapshot.data);
        model.id = snapshot.documentID;
        requestSink.add(model);
      },
    ),
  );
}

Future<void> createProject({@required ProjectModel projectModel}) async {
  return await Firestore.instance
      .collection('projects')
      .document(projectModel.id)
      .setData(projectModel.toMap());
}

Future<void> updateProject({@required ProjectModel projectModel}) async {
  return await Firestore.instance
      .collection('projects')
      .document(projectModel.id)
      .updateData(projectModel.toMap());
}

Future<void> updateProjectCompletedRequest(
    {@required String projectId, @required String requestId}) async {
  return await Firestore.instance
      .collection('projects')
      .document(projectId)
      .updateData({
    'completedRequests': FieldValue.arrayUnion(
      [requestId],
    ),
    'pendingRequests': FieldValue.arrayRemove([requestId])
  });
}

/// Get all timebanknew associated with a User as a Stream
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
      .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
      // .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
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

        print("request model --->>> ${requestList.toString()}");
      },
    ),
  );
}

Stream<List<TransactionModel>> getTimebankCreditsDebitsStream({
  @required String timebankid,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('transactions')
      .where('transactionbetween', arrayContains: timebankid)
      .where("isApproved", isEqualTo: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TransactionModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<TransactionModel> requestList = [];
        snapshot.documents.forEach((document) {
          TransactionModel model = TransactionModel.fromMap(document.data);
          requestList.add(model);
        });
        requestSink.add(requestList);
        print("request model --->>> ${requestList.toString()}");
      },
    ),
  );
}

Stream<List<TransactionModel>> getUsersCreditsDebitsStream({
  @required String userEmail,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('transactions')
      .where('transactionbetween', arrayContains: userId)
      .where("isApproved", isEqualTo: true)
      .orderBy("timestamp", descending: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TransactionModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<TransactionModel> requestList = [];
        snapshot.documents.forEach((document) {
          TransactionModel model = TransactionModel.fromMap(document.data);
          requestList.add(model);
        });
        requestSink.add(requestList);

        print("request model --->>> ${requestList.toString()}");
      },
    ),
  );
}

Future<bool> hasSufficientCredits({
  String userId,
  double credits,
}) async {
  var sevaCoinsBalance = await getMemberBalance(
    userId,
  );

  var lowerLimit = 50;
  try {
    lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));
  } on Exception {
    print("Exception raised while getting user minimum balance");
  }

  var maxAvailableBalance = (sevaCoinsBalance + lowerLimit ?? 50);

  print(
      "Seva Credits ($sevaCoinsBalance) Credits requested $credits ----------------------------- LOWER LIMIT BALANCE $maxAvailableBalance can credit + ${maxAvailableBalance - credits >= 0}");

  return maxAvailableBalance - credits >= 0;
}

Future<double> getMemberBalance(userId) async {
  double sevaCoins = 0;
  var userModel = await FirestoreManager.getUserForIdFuture(
    sevaUserId: userId,
  );
  sevaCoins = userModel.currentBalance;
  print("listen to coins -> " + sevaCoins.toString());
  return double.parse(sevaCoins.toStringAsFixed(2));
}

///NOTE Removed as a part of version 1.1 update as balance should be a meta not through calculation
//Future<double> getMyDebits(userEmail, userId) {
//  double myDebits = 0;
//  return Firestore.instance
//      .collection('requests')
//      .where('email', isEqualTo: userEmail)
//      .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
//      .getDocuments()
//      .then((QuerySnapshot querySnapshot) {
//    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
//      RequestModel model = RequestModel.fromMap(documentSnapshot.data);
//      model.transactions?.forEach((transaction) {
//        if (model.requestMode == RequestMode.PERSONAL_REQUEST &&
//            transaction.isApproved &&
//            transaction.from == userId) myDebits += transaction.credits;
//      });
//    });
//    return myDebits;
//  }).catchError((onError) {
//    return myDebits;
//  });
//}

Stream<List<RequestModel>> getNotAcceptedRequestStream({
  @required String userEmail,
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('requests')
      .where('acceptors', arrayContains: userEmail)
      .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
      // .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
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
