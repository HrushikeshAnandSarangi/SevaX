import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/utils.dart';

class NotificationsRepository {
  static Future<void> createNotification(
    NotificationsModel model,
    String userEmail,
  ) async {
    CollectionReference ref;
    if (model.isTimebankNotification ?? false) {
      ref = CollectionRef.timebankNotification(model.timebankId ?? '');
    } else {
      ref = CollectionRef.userNotification(userEmail);
    }
    await ref.doc(model.id).set(model.toMap());
  }

  static Stream<QuerySnapshot> getUserNotifications(
    String userEmail,
    String communityId,
  ) {
    return CollectionRef.userNotification(userEmail)
        .where('isRead', isEqualTo: false)
        .where('communityId', isEqualTo: communityId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getTimebankNotifications(
    String timebankId,
  ) {
    return CollectionRef.timebankNotification(timebankId)
        .where('isRead', isEqualTo: false)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  static Stream<List<NotificationsModel>> getAllTimebankNotifications(
      String communityId) async* {
    var data = CollectionRef.notificationGroup
        .where("isTimebankNotification", isEqualTo: true)
        .where("communityId", isEqualTo: communityId)
        .where("isRead", isEqualTo: false)
        .orderBy("timestamp", descending: true)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NotificationsModel>>.fromHandlers(
        handleData: (data, sink) {
          List<NotificationsModel> notifications = [];
          data.docs.forEach((document) {
            notifications.add(NotificationsModel.fromMap(
                document.data() as Map<String, dynamic>));
          });
          sink.add(notifications);
        },
      ),
    );
  }

  // static Stream<QuerySnapshot> getAllTimebankNotifications(
  //   String communityId,
  // ) {
  //   return CollectionRef
  //       .collectionGroup("notifications")
  //       .where("isTimebankNotification", isEqualTo: true)
  //       .where("communityId", isEqualTo: communityId)
  //       .where("isRead", isEqualTo: false)
  //       .orderBy("timestamp", descending: true)
  //       .snapshots();
  // }

  static Future sendUserExitNotificationToAdmin({
    UserModel? user,
    TimebankModel? timebank,
    String? communityId,
    String? reason,
  }) async {
    UserExitModel userExitModel = UserExitModel(
      userPhotoUrl: user?.photoURL,
      timebank: timebank?.name,
      reason: reason,
      userName: user?.fullname,
    );

    NotificationsModel notification = NotificationsModel(
      id: Utils.getUuid(),
      timebankId: timebank?.id,
      data: userExitModel.toMap(),
      isRead: false,
      type: NotificationType.TypeMemberExitTimebank,
      communityId: communityId,
      senderUserId: user?.sevaUserID,
      targetUserId: timebank?.creatorId,
    );
    await CollectionRef.timebankNotification(timebank!.id)
        .doc(notification.id)
        .set(
          (notification..isTimebankNotification = true).toMap(),
        );
  }

  static Future<void> readUserNotification(
    String notificationId,
    String userEmail,
  ) async {
    await CollectionRef.userNotification(userEmail).doc(notificationId).update({
      'isRead': true,
    });
  }
}
