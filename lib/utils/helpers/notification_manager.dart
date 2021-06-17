import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sevaexchange/models/device_details.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

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

  static Future<bool> setFirebaseTokenForMemberWithEmail({
    String email,
    String token,
  }) async {
    DeviceDetails deviceDetails = DeviceDetails();
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceDetails.deviceType = androidInfo.androidId;
      deviceDetails.deviceId = 'Android';
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceDetails.deviceType = iosInfo.identifierForVendor;
      deviceDetails.deviceId = 'IOS';
    }
    return await CollectionRef.users
        .doc(email)
        .update({
          'tokenDetails.' + deviceDetails.deviceType: token,
        })
        .then((e) => true)
        .catchError((onError) => false);
  }

//  static Future<bool> setFirebaseTokenForMemberWithEmail(
//      {String email, String token}) async {
//    return await CollectionRef
//        .users
//        .doc(email)
//        .update({
//          'tokens': token,
//        })
//        .then((e) => true)
//        .catchError((onError) => false);
//  }

  static Future<void> removeDeviceRegisterationForMember({String email}) async {
    const String UNREGISTER_DEVICE = "";
    return await setFirebaseTokenForMemberWithEmail(
      email: email,
      token: UNREGISTER_DEVICE,
    );
  }
}
