import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/claimedRequestStatus.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';

import '../utils.dart';

Future<bool> fetchProtectedStatus(String timebankId) async {
  DocumentSnapshot timebank = await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get();
  return timebank.data['protected'];
}

Future<TimebankModel> fetchTimebankData(String timebankId) async {
  DocumentSnapshot timebank = await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get();
  return TimebankModel.fromMap(timebank.data);
}

//Fetch timebank from timebank id
Future<void> createAcceptRequestNotification({
  NotificationsModel notificationsModel,
}) async {
  var requestModel = RequestModel.fromMap(notificationsModel.data);
  switch (requestModel.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      UserModel user =
          await getUserForId(sevaUserId: notificationsModel.targetUserId);
      await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(notificationsModel.id)
          .setData(notificationsModel.toMap());
      break;

    case RequestMode.TIMEBANK_REQUEST:
      await Firestore.instance
          .collection('timebanknew')
          .document(notificationsModel.timebankId)
          .collection('notifications')
          .document(notificationsModel.id)
          .setData(notificationsModel.toMap());
      break;
  }
}

Future<void> withdrawAcceptRequestNotification({
  NotificationsModel notificationsModel,
  bool isAlreadyApproved,
  UserModel loggedInUser,
}) async {
  RequestModel requestModel = RequestModel.fromMap(notificationsModel.data);
  var withdrawlNotification = getApprovedMemberWithdrawingNotification(
    notificationsModel,
    loggedInUser,
    requestModel,
  );
  switch (requestModel.requestMode) {
    case RequestMode.TIMEBANK_REQUEST:
      withdrawlNotification.isTimebankNotification = true;
      await Firestore.instance
          .collection('timebanknew')
          .document(requestModel.timebankId)
          .collection('notifications')
          .document(withdrawlNotification.id)
          .setData(withdrawlNotification.toMap());

      QuerySnapshot snapshotQuery = await Firestore.instance
          .collection('timebanknew')
          .document(notificationsModel.timebankId)
          .collection('notifications')
          .where('type', isEqualTo: 'RequestAccept')
          .where('data.id', isEqualTo: requestModel.id)
          .where('data.email', isEqualTo: requestModel.email)
          .getDocuments();
      snapshotQuery.documents.forEach(
        (document) async {
          await Firestore.instance
              .collection('timebanknew')
              .document(notificationsModel.timebankId)
              .collection('notifications')
              .document(document.documentID)
              .delete();
        },
      );

      break;

    case RequestMode.PERSONAL_REQUEST:
      UserModel user =
          await getUserForId(sevaUserId: notificationsModel.targetUserId);

      withdrawlNotification.isTimebankNotification = false;
      await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(withdrawlNotification.id)
          .setData(withdrawlNotification.toMap());

      QuerySnapshot querySnapshot = await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .where('type', isEqualTo: 'RequestAccept')
          .where('data.id', isEqualTo: requestModel.id)
          .where('data.email', isEqualTo: requestModel.email)
          .getDocuments();
      querySnapshot.documents.forEach(
        (document) {
          Firestore.instance
              .collection('users')
              .document(user.email)
              .collection('notifications')
              .document(document.documentID)
              .delete();
        },
      );

      break;
  }
}

NotificationsModel getApprovedMemberWithdrawingNotification(
  NotificationsModel notificationsModel,
  UserModel loggedInUser,
  RequestModel requestModel,
) {
  return NotificationsModel(
    communityId: notificationsModel.communityId,
    data: {
      'fullName': loggedInUser.fullname,
      'requestTite': requestModel.title,
      'requestId': requestModel.id,
    },
    id: Utils.getUuid(),
    isRead: false,
    senderUserId: notificationsModel.senderUserId,
    targetUserId: notificationsModel.targetUserId,
    timebankId: notificationsModel.timebankId,
    type: NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST,
  );
}

Future<QuerySnapshot> _getQueryForNotification({
  RequestModel requestModel,
}) async {
  switch (requestModel.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      return await Firestore.instance
          .collection('users')
          .document(requestModel.email)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('type', isEqualTo: 'RequestCompleted')
          .where('data.id', isEqualTo: requestModel.id)
          .getDocuments();

    case RequestMode.TIMEBANK_REQUEST:
      return Firestore.instance
          .collection('timebanknew')
          .document(requestModel.timebankId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('type', isEqualTo: 'RequestCompleted')
          .where('data.id', isEqualTo: requestModel.id)
          .getDocuments();

    default:
      return null;
  }
}

Future<String> getNotificationId(
  UserModel user,
  RequestModel request,
) async {
  QuerySnapshot notifications = await _getQueryForNotification(
    requestModel: request,
  );

  var result = "";
  for (var i = 0; i < notifications.documents.length; i++) {
    var onValue = notifications.documents[i];
    var notification = NotificationsModel.fromMap(onValue.data);
    if (notification != null) {
      RequestModel _requestModel = RequestModel.fromMap(notification.data);
      if (_requestModel != null) {
        if (_requestModel.id == request.id) {
          result = notification.id;
          break;
        }
      }
    }
  }
  return result;
}

Future<void> removeAcceptRequestNotification({
  NotificationsModel model,
  String notificationId,
}) async {
  var requestModel = RequestModel.fromMap(model.data);
  switch (requestModel.requestMode) {
    case RequestMode.TIMEBANK_REQUEST:
      await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(notificationId)
          .delete();
      break;

    case RequestMode.PERSONAL_REQUEST:
      UserModel user = await getUserForId(sevaUserId: model.senderUserId);
      await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(notificationId)
          .delete();

      break;
  }
}

Future<void> createRequestApprovalNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> createApprovalNotificationForMember({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> createTaskCompletedNotification({NotificationsModel model}) async {
  var requestModel = RequestModel.fromMap(model.data);
  switch (requestModel.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      UserModel user = await getUserForId(sevaUserId: model.targetUserId);
      await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap(), merge: true);
      break;

    case RequestMode.TIMEBANK_REQUEST:
      await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap(), merge: true);
      break;
  }
}

Future<void> processLoans(
    {String timebankId, String userId, String to, num credits}) async {
  // get all previous loans of this user with in the timebank;
  var loans = await Firestore.instance
      .collection("transactions")
      .where('timebankid', isEqualTo: timebankId)
      .where('type', isEqualTo: "ADMIN_DONATE_TOUSER")
      .where('to', isEqualTo: to)
      .getDocuments()
      .then(
    (onValue) {
      return onValue.documents;
    },
  ).catchError((onError) {
    return null;
  });
  var loanamount = 0;
  if (loans != null) {
    for (var i = 0; i < loans.length; i++) {
      TransactionModel temp = TransactionModel.fromMap(loans[i].data);
      loanamount += temp.credits.toInt();
    }
  }

  // get all paid loans of this user with in the timebank;
  var paidloans = await Firestore.instance
      .collection("transactions")
      .where('timebankid', isEqualTo: timebankId)
      .where('type', isEqualTo: "USER_PAYLOAN_TOTIMEBANK")
      .where('from', isEqualTo: to)
      .getDocuments()
      .then(
    (onValue) {
      return onValue.documents;
    },
  ).catchError((onError) {
    return null;
  });
  var paidamount = 0;
  if (paidloans != null) {
    for (var i = 0; i < paidloans.length; i++) {
      TransactionModel temp = TransactionModel.fromMap(loans[i].data);
      paidamount += temp.credits.toInt();
    }
  }
  // pay the pending loan amount
  if (loanamount > paidamount) {
    var tobepaid = loanamount - paidamount;
    var paying = tobepaid > credits ? credits : tobepaid;

    await transactionBloc.createNewTransaction(
        to,
        timebankId,
        DateTime.now().millisecondsSinceEpoch,
        paidamount,
        true,
        "USER_PAYLOAN_TOTIMEBANK",
        null,
        timebankId);
  }
}

Future<void> createTaskCompletedApprovedNotification({
  NotificationsModel model,
}) async {
  var requestModel = RequestModel.fromMap(model.data);

  UserModel user = await getUserForId(sevaUserId: model.targetUserId);

  // switch (requestModel.requestMode) {
  //   case RequestMode.PERSONAL_REQUEST:
  //     break;
  //   case RequestMode.TIMEBANK_REQUEST:
  //     var timebankModel = await fetchTimebankData(model.timebankId);
  //     requestModel.fullName = timebankModel.name;
  //     requestModel.photoUrl = timebankModel.photoUrl;
  //     model.data = requestModel.toMap();
  //     break;
  // }

  await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> createTransactionNotification({
  NotificationsModel model,
}) async {
  var requestModel = RequestModel.fromMap(model.data);

  switch (requestModel.requestMode) {
    case RequestMode.TIMEBANK_REQUEST:
      await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap());
      break;
    case RequestMode.PERSONAL_REQUEST:
      UserModel user = await getUserForId(sevaUserId: model.targetUserId);
      await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap());
      break;
  }
}

Future saveRequestFinalAction({ClaimedRequestStatusModel model}) async {
  try {
    await Firestore.instance
        .collection('claimedRequestStatus')
        .document(model.id)
        .updateData({model.timestamp.toString(): model.toMap()});
  } on Exception catch (exception) {
    await Firestore.instance
        .collection('claimedRequestStatus')
        .document(model.id)
        .setData({model.timestamp.toString(): model.toMap()});
  }
}

Future<void> offerAcceptNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);

  bool isTimeBankNotification = await fetchProtectedStatus(model.timebankId);
  isTimeBankNotification
      ? await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap())
      : await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap());
}

Future<void> offerRejectNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);

  bool isTimeBankNotification = await fetchProtectedStatus(model.timebankId);
  isTimeBankNotification
      ? await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap())
      : await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap());
}

Future<void> readUserNotification(
  String notificationId,
  String userEmail,
) async {
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .document(notificationId)
      .updateData({
    'isRead': true,
  });
}

Future<void> unreadUserNotification(
    String notificationId, String userEmail) async {
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .document(notificationId)
      .updateData({
    'isRead': false,
  });
}

Future<void> readTimeBankNotification({
  String notificationId,
  String timebankId,
}) async {
  await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .collection('notifications')
      .document(notificationId)
      .updateData({
    'isRead': true,
  });
}

Stream<List<NotificationsModel>> getNotifications({
  String userEmail,
  @required String communityId,
}) async* {
  var data = Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];
        querySnapshot.documents.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data,
          );
          notifications.add(model);
        });
        notifications.sort((a, b) => b.timestamp > a.timestamp ? 1 : -1);
        notificationSink.add(notifications);
      },
    ),
  );
}

Future updateUserCommunity({
  String communityId,
  String userEmail,
}) async {
  await Firestore.instance.collection('users').document(userEmail).updateData({
    'communities': FieldValue.arrayUnion([communityId]),
  });
}

Future addMemberToTimebank({
  String timebankId,
  String newUserSevaId,
}) async {
  await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .updateData({
    'members': FieldValue.arrayUnion([newUserSevaId]),
  });
}

Stream<List<NotificationsModel>> getNotificationsForTimebank({
  String timebankId,
}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .orderBy('timestamp', descending: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];

        querySnapshot.documents.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data,
          );
          if (FlavorConfig.appFlavor != Flavor.APP) {
            if (model.type != NotificationType.TransactionDebit)
              // for other falvour of the app except
              notifications.add(model);
          } else {
            if (model.type == NotificationType.RequestAccept ||
                model.type == NotificationType.JoinRequest ||
                model.type == NotificationType.TypeMemberExitTimebank ||
                model.type == NotificationType.RequestCompleted ||
                model.type ==
                    NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED ||
                model.type ==
                    NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK ||
                model.type == NotificationType.TYPE_DELETION_REQUEST_OUTPUT ||
                model.type == NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER ||
                model.type == NotificationType.ADMIN_PROMOTED_AS_ORGANIZER ||
                model.type == NotificationType.MEMBER_PROMOTED_AS_ADMIN ||
                model.type == NotificationType.MEMBER_DEMOTED_FROM_ADMIN) {
              notifications.add(model);
            }
          }
        });
        notifications.sort((a, b) => b.timestamp > a.timestamp ? 1 : -1);

        notificationSink.add(notifications);
      },
    ),
  );
}

Future<bool> isUnreadNotification(String userEmail) async {
  bool isNotification = false;
  List<NotificationsModel> notifications = [];
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .getDocuments()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      NotificationsModel model = NotificationsModel.fromMap(
        documentSnapshot.data,
      );
      if (model.type != NotificationType.TransactionDebit)
        notifications.add(model);
    });
    if (notifications.length > 0) isNotification = true;
  });
  return isNotification;
}

Future updateNotificationStatusByAdmin(
    notificationType, timebankId, userModel) async {}

Future<List<NotificationsModel>> getCompletedNotifications(
  String userEmail,
  String communityId,
) async {
  List<NotificationsModel> res = [];
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .getDocuments()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      NotificationsModel model = NotificationsModel.fromMap(
        documentSnapshot.data,
      );
      if (model.type == NotificationType.RequestCompleted) res.add(model);
    });
  });
  return res;
}

Stream<List<NotificationsModel>> getCompletedNotificationsStream(
  String userEmail,
  String communityId,
) async* {
  var data = Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];

        querySnapshot.documents.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data,
          );
          if (model.type == NotificationType.RequestCompletedApproved) {
            notifications.add(model);
          }
        });
        notificationSink.add(notifications);
      },
    ),
  );
}
