import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsApi {
  static String _notificationCollection = "notifications";
  static final String _userCollection = "users";
  static final String _timebankCollection = "timebanknew";

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

  static Stream<QuerySnapshot> getAllTimebankNotifications(
    String communityId,
  ) {
    return _firestore
        .collectionGroup("notifications")
        .where("isTimebankNotification", isEqualTo: true)
        .where("communityId", isEqualTo: communityId)
        .where("isRead", isEqualTo: false)
        .snapshots();
    //     .listen((event) {
    //   event.documents.forEach((element) {
    //     print(element.data);
    //   });

    //   print("collection group ${event.documents.length}");
    // });
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
