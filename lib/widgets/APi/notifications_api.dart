import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsApi {
  static String _notificationCollection = "notifications";
  static String _userCollection = "users";

  static Firestore _firestore = Firestore.instance;

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
