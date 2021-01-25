import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/utils/utils.dart';

class NotificationsRepository {
  static String _notificationCollection = "notifications";
  static final String _userCollection = "users";
  static final String _timebankCollection = "timebanknew";

  static Firestore _firestore = Firestore.instance;

  static Future<void> createNotification(
    NotificationsModel model,
    String userEmail,
  ) async {
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
    await ref.document(model.id).setData(model.toMap());
  }

  static Stream<QuerySnapshot> getUserNotifications(
    String userEmail,
    String communityId,
  ) {
    return _firestore
        .collection(_userCollection)
        .document(userEmail)
        .collection(_notificationCollection)
        .where('isRead', isEqualTo: false)
        .where('communityId', isEqualTo: communityId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getTimebankNotifications(
    String timebankId,
  ) {
    return _firestore
        .collection(_timebankCollection)
        .document(timebankId)
        .collection(_notificationCollection)
        .where('isRead', isEqualTo: false)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  static Stream<List<NotificationsModel>> getAllTimebankNotifications(
      String communityId) async* {
    var data = _firestore
        .collectionGroup("notifications")
        .where("isTimebankNotification", isEqualTo: true)
        .where("communityId", isEqualTo: communityId)
        .where("isRead", isEqualTo: false)
        .orderBy("timestamp", descending: true)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
        handleData: (data, sink) {
          List<NotificationsModel> notifications = [];
          data.documents.forEach((document) {
            notifications.add(NotificationsModel.fromMap(document.data));
          });
          sink.add(notifications);
        },
      ),
    );
  }

  // static Stream<QuerySnapshot> getAllTimebankNotifications(
  //   String communityId,
  // ) {
  //   return _firestore
  //       .collectionGroup("notifications")
  //       .where("isTimebankNotification", isEqualTo: true)
  //       .where("communityId", isEqualTo: communityId)
  //       .where("isRead", isEqualTo: false)
  //       .orderBy("timestamp", descending: true)
  //       .snapshots();
  // }

  static Future sendUserExitNotificationToAdmin({
    UserModel user,
    TimebankModel timebank,
    String communityId,
    String reason,
  }) async {
    UserExitModel userExitModel = UserExitModel(
      userPhotoUrl: user.photoURL,
      timebank: timebank.name,
      reason: reason,
      userName: user.fullname,
    );

    NotificationsModel notification = NotificationsModel(
      id: Utils.getUuid(),
      timebankId: timebank.id,
      data: userExitModel.toMap(),
      isRead: false,
      type: NotificationType.TypeMemberExitTimebank,
      communityId: communityId,
      senderUserId: user.sevaUserID,
      targetUserId: timebank.creatorId,
    );
    await Firestore.instance
        .collection(_timebankCollection)
        .document(timebank.id)
        .collection(_notificationCollection)
        .document(notification.id)
        .setData(
          (notification..isTimebankNotification = true).toMap(),
        );
  }

  static Future<void> readUserNotification(
    String notificationId,
    String userEmail,
  ) async {
    await _firestore
        .collection(_userCollection)
        .document(userEmail)
        .collection(_notificationCollection)
        .document(notificationId)
        .updateData({
      'isRead': true,
    });
  }
}
