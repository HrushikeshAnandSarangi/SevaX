import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';

Future<void> createAcceptRequestNotification({
  NotificationsModel notificationsModel,
}) async {
  UserModel user =
      await getUserForId(sevaUserId: notificationsModel.targetUserId);
      notificationsModel.timebankId = FlavorConfig.values.timebankId;

  Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(notificationsModel.id)
      .setData(notificationsModel.toMap());
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

  QuerySnapshot data = await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .where('data', isEqualTo: dataMap)
      .getDocuments();

  data.documents.forEach((document) {
    Firestore.instance
        .collection('users')
        .document(user.email)
        .collection('notifications')
        .document(document.documentID)
        .delete();
  });
}

Future<void> removeAcceptRequestNotification({
  NotificationsModel model,
  String notificationId,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.senderUserId);
  await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(notificationId)
      .delete();
}

Future<void> createRequestApprovalNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(
    sevaUserId: model.targetUserId,
  );
  model.timebankId = FlavorConfig.values.timebankId;

  Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> createTaskCompletedNotification({NotificationsModel model}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  model.timebankId = FlavorConfig.values.timebankId;
  await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap(), merge: true);
}

Future<void> createTaskCompletedApprovedNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  model.timebankId = FlavorConfig.values.timebankId;
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
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  model.timebankId = FlavorConfig.values.timebankId;
  await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> offerAcceptNotification({
  NotificationsModel model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model.targetUserId);
  model.timebankId = FlavorConfig.values.timebankId;
  await Firestore.instance
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
  model.timebankId = FlavorConfig.values.timebankId;
  await Firestore.instance
      .collection('users')
      .document(user.email)
      .collection('notifications')
      .document(model.id)
      .setData(model.toMap());
}

Future<void> readNotification(String notificationId, String userEmail) async {
  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .document(notificationId)
      .setData(
        NotificationsModel(isRead: true).toMap(),
        merge: true,
      );
}

Stream<List<NotificationsModel>> getNotifications({
  String userEmail,
}) async* {
  var data = Firestore.instance
      .collection('users')
      .document(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
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
