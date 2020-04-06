import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/claimedRequestStatus.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';

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
  print("Notification model---------------------${notificationsModel}");

  var requestModel = RequestModel.fromMap(notificationsModel.data);

  print("Request mode---------------------${requestModel}");

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
}) async {
  UserModel user =
      await getUserForId(sevaUserId: notificationsModel.targetUserId);
  UserModel senderUser =
      await getUserForId(sevaUserId: notificationsModel.senderUserId);

  // This is a Minor hack
  Map<String, dynamic> dataMap = notificationsModel.data;
  List<String> acceptorList = List.castFrom(dataMap['acceptors']);

  acceptorList.add(senderUser.email);

  dataMap['acceptors'] = acceptorList;
  bool isTimeBankNotification =
      await fetchProtectedStatus(notificationsModel.timebankId);
  QuerySnapshot data = isTimeBankNotification
      ? await Firestore.instance
          .collection('timebanknew')
          .document(notificationsModel.timebankId)
          .collection('notifications')
          .where('data', isEqualTo: dataMap)
          .getDocuments()
      : await Firestore.instance
          .collection('users')
          .document(user.email)
          .collection('notifications')
          .where('data', isEqualTo: dataMap)
          .getDocuments();
  //error: The name 'dynamic' isn't a type so it can't be used as a type argument. (non_type_as_type_argument at [sevaexchange] lib/utils/search_manager.dart:21)

  isTimeBankNotification
      ? data.documents.forEach(
          (document) {
            Firestore.instance
                .collection('timebanknew')
                .document(notificationsModel.timebankId)
                .collection('notifications')
                .document(document.documentID)
                .delete();
          },
        )
      : data.documents.forEach(
          (document) {
            Firestore.instance
                .collection('users')
                .document(user.email)
                .collection('notifications')
                .document(document.documentID)
                .delete();
          },
        );
}

Future<String> getNotificationId(
  UserModel user,
  RequestModel request,
) async {
  var notifications = await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .getDocuments();

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
    case RequestMode.PERSONAL_REQUEST:
      await Firestore.instance
          .collection('timebanknew')
          .document(model.timebankId)
          .collection('notifications')
          .document(model.id)
          .setData(model.toMap());
      break;
    case RequestMode.TIMEBANK_REQUEST:
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
    String notificationId, String userEmail) async {
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .document(notificationId)
      .updateData({
    'isRead': true,
  });
}

Future<void> readTimeBankNotification(
    {String notificationId, String timebankId}) async {
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
  print("userEmail " + userEmail);
  print("communityId " + communityId);

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
          if (FlavorConfig.appFlavor != Flavor.APP) {
            if (model.type != NotificationType.TransactionDebit)
              notifications.add(model);
          } else
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
                model.type == NotificationType.RequestCompleted) {
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
        print(
            "${notifications.length}----------------------------------------");
      },
    ),
  );
}
