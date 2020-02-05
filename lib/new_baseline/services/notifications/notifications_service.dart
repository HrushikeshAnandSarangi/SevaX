// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sevaexchange/base/base_service.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart';

// class NotificationsService extends BaseService {
//   CollectionReference userNotificationCollection =
//       Firestore.instance.collection('users');
//   CollectionReference timebankNotificationCollection =
//       Firestore.instance.collection('timebanknew');

//   /// create notification for accept request using [notificationsModel]
//   Future<void> createAcceptRequestNotification({
//     NotificationsModel notificationsModel,
//   }) async {
//     log.i(
//         'createAcceptRequestNotification: NotificationModel: ${notificationsModel.toMap()}');
//     UserModel user =
//         await getUserForId(sevaUserId: notificationsModel.targetUserId);

//     notificationsModel.isTimeBankNotification
//         ? timebankNotificationCollection
//             .document(notificationsModel.timebankId)
//             .collection('notifications')
//             .document(notificationsModel.id)
//             .setData(notificationsModel.toMap())
//         : userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(notificationsModel.id)
//             .setData(notificationsModel.toMap());
//   }

//   /// delete notification after accept-request is withdrawn using [notificationsModel]
//   Future<void> withdrawAcceptRequestNotification({
//     NotificationsModel notificationsModel,
//   }) async {
//     log.i(
//         'withdrawAcceptRequestNotification: NotificationModel: ${notificationsModel.toMap()}');
//     UserModel user =
//         await getUserForId(sevaUserId: notificationsModel.targetUserId);
//     UserModel senderUser =
//         await getUserForId(sevaUserId: notificationsModel.senderUserId);

//     // This is a Minor hack
//     Map<String, dynamic> dataMap = notificationsModel.data;
//     List<String> acceptorList = List.castFrom(dataMap['acceptors']);

//     acceptorList.add(senderUser.email);

//     dataMap['acceptors'] = acceptorList;

//     QuerySnapshot data = await Firestore.instance
//         .collection('users')
//         .document(user.email)
//         .collection('notifications')
//         .where('data', isEqualTo: dataMap)
//         .getDocuments();

//     data.documents.forEach((document) {
//       Firestore.instance
//           .collection('users')
//           .document(user.email)
//           .collection('notifications')
//           .document(document.documentID)
//           .delete();
//     });
//   }

//   /// Delete the acceptRequestNotification[model] on approve-acceptRequest or reject- acceptRequest using [notificationId]
//   Future<void> removeAcceptRequestNotification({
//     NotificationsModel model,
//     String notificationId,
//   }) async {
//     log.i(
//         'removeAcceptRequestNotification: NotificationModel: ${model.toMap()} \n NotificationId: $notificationId');
//     UserModel user = await getUserForId(sevaUserId: model.senderUserId);
//     await Firestore.instance
//         .collection('users')
//         .document(user.email)
//         .collection('notifications')
//         .document(notificationId)
//         .delete();
//   }

//   /// Create RequestApproval Notification[model]
//   Future<void> createRequestApprovalNotification({
//     NotificationsModel model,
//   }) async {
//     log.i(
//         'createRequestApprovalNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(
//       sevaUserId: model.targetUserId,
//     );

//     model.isTimeBankNotification
//         ? timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap())
//         : userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap());
//   }

//   /// create TaskCompleted Notification[model]
//   Future<void> createTaskCompletedNotification(
//       {NotificationsModel model}) async {
//     log.i(
//         'createTaskCompletedNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//     model.isTimeBankNotification
//         ? await timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap(), merge: true)
//         : await userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap(), merge: true);
//   }

//   /// create TaskCompletedApproved Notification[model]
//   Future<void> createTaskCompletedApprovedNotification({
//     NotificationsModel model,
//   }) async {
//     log.i(
//         'createTaskCompletedApprovedNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//     model.isTimeBankNotification
//         ? await timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap())
//         : await userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap());
//   }

//   /// create Transaction Notification[model]
//   Future<void> createTransactionNotification({
//     NotificationsModel model,
//   }) async {
//     log.i('createTransactionNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//     model.isTimeBankNotification
//         ? await timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap())
//         : await userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap());
//   }

//   /// create offerAccept Notification[model]
//   Future<void> offerAcceptNotification({
//     NotificationsModel model,
//   }) async {
//     log.i('offerAcceptNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//     model.isTimeBankNotification
//         ? await timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap())
//         : await userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap());
//   }

//   /// create offerReject Notification[model]
//   Future<void> offerRejectNotification({
//     NotificationsModel model,
//   }) async {
//     log.i('offerRejectNotification: NotificationModel: ${model.toMap()}');
//     UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//     model.isTimeBankNotification
//         ? await timebankNotificationCollection
//             .document(model.timebankId)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap())
//         : await userNotificationCollection
//             .document(user.email)
//             .collection('notifications')
//             .document(model.id)
//             .setData(model.toMap());
//   }

//   /// update a notification as read using[notificationId] and [userEmail]
//   //check once
//   Future<void> readNotification(String notificationId, String userEmail,
//       {String timebankId}) async {
//     log.i(
//         'readNotification: NotificationId: $notificationId \n UserEmail: $userEmail');
//     timebankId == null
//         ? await userNotificationCollection
//             .document(userEmail)
//             .collection('notifications')
//             .document(notificationId)
//             .updateData({
//             'isRead': true,
//           })
//         : await timebankNotificationCollection
//             .document(timebankId)
//             .collection('notifications')
//             .document(notificationId)
//             .updateData({
//             'isRead': true,
//           });
//   }

//   /// get a stream of unread notifications for an [userEmail]
//   Stream<List<NotificationsModel>> getNotifications({
//     String userEmail,
//   }) async* {
//     log.i('getNotifications: String: $userEmail');
//     var data = Firestore.instance
//         .collection('users')
//         .document(userEmail)
//         .collection('notifications')
//         .where('isRead', isEqualTo: false)
//         .snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
//         handleData: (querySnapshot, notificationSink) {
//           List<NotificationsModel> notifications = [];

//           querySnapshot.documents.forEach((documentSnapshot) {
//             NotificationsModel model = NotificationsModel.fromMap(
//               documentSnapshot.data,
//             );
//             if (model.type != NotificationType.TransactionDebit)
//               notifications.add(model);
//           });

//           notificationSink.add(notifications);
//         },
//       ),
//     );
//   }


//   /// get a stream of unread notifications for an [TimebankID]
//   Stream<List<NotificationsModel>> getTimebankNotifications({
//     String timeankId,
//   }) async* {
//     log.i('getNotifications: String: $timeankId');
//     var data = Firestore.instance
//         .collection('timebanknew')
//         .document(timeankId)
//         .collection('notifications')
//         .where('isRead', isEqualTo: false)
//         .snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
//         handleData: (querySnapshot, notificationSink) {
//           List<NotificationsModel> notifications = [];
//           querySnapshot.documents.forEach((documentSnapshot) {
//             NotificationsModel model = NotificationsModel.fromMap(
//               documentSnapshot.data,
//             );
//             if (model.type != NotificationType.TransactionDebit)
//               notifications.add(model);
//           });
//           notificationSink.add(notifications);
//         },
//       ),
//     );
//   }
// }
