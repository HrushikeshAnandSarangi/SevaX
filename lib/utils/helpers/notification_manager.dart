import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMNotificationManager {
  static Future<bool> registerDeviceWithMemberForNotifications(
    String email,
  ) async {
    await _getFCMTokenForEmail(
      email: email,
    ).then(
      (token) => setFirebaseTokenForMemberWithEmail(
        email: email,
        token: token,
      ),
    );
  }

  static Future<String> _getFCMTokenForEmail({
    String email,
  }) async {
    const String FAILED_GETTING_TOKEN = "";
    return await FirebaseMessaging().getToken().then((token) {
      return token;
    }).catchError((e) {
      return FAILED_GETTING_TOKEN;
    });
  }

  static Future<bool> setFirebaseTokenForMemberWithEmail(
      {String email, String token}) async {
    return await Firestore.instance
        .collection('users')
        .document(email)
        .updateData({
          'tokens': token,
        })
        .then((e) => true)
        .catchError((onError) => false);
  }

  static Future<void> removeDeviceRegisterationForMember({String email}) async {
    const String UNREGISTER_DEVICE = "";
    return await setFirebaseTokenForMemberWithEmail(
      email: email,
      token: UNREGISTER_DEVICE,
    );
  }
}
