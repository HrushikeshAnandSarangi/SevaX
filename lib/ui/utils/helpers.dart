import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/models.dart';

///[Function] clear all notification
///
///Pass list of all notifications that are allowed to be cleared
void clearAllNotification(List<NotificationsModel> notifications,
    List<NotificationType> allowedNotifications, String userEmail) {
  WriteBatch batch = Firestore.instance.batch();
  notifications.forEach((NotificationsModel notification) {
    if (allowedNotifications.contains(notification.type)) {
      batch.updateData(
          Firestore.instance
              .collection("users")
              .document(userEmail)
              .collection("notifications")
              .document(notification.id),
          {"isRead": true});
    }
  });
  batch.commit();
}
