import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/device_details.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import '../../flavor_config.dart';

/// Create a [user]
Future<void> createUser({
  @required UserModel user,
}) async {
  return await CollectionRef.users.doc(user.email).set(user.toMap());
}

Future<void> updateUser({
  @required UserModel user,
}) async {
  return await CollectionRef.users
      .doc(user.email)
      .set(user.toMap(), SetOptions(merge: true));
}

Future<void> updateUserLanguage({
  @required UserModel user,
}) async {
  return await CollectionRef.users.doc(user.email).update({
    'language': user.language,
  });
}

Future<int> getUserDonatedGoodsAndAmount({
  @required String sevaUserId,
  @required int timeFrame,
  bool isLifeTime,
  bool isGoods,
}) async {
  int totalGoodsOrAmount = 0;
  try {
    await CollectionRef.donations
        .where('donationType', isEqualTo: isGoods ? 'GOODS' : 'CASH')
        .where('donorSevaUserId', isEqualTo: sevaUserId)
        .where('timestamp', isGreaterThan: isLifeTime ? 0 : timeFrame)
        .get()
        .then((data) {
      data.docs.forEach((documentSnapshot) {
        DonationModel donationModel =
            DonationModel.fromMap(documentSnapshot.data());
        if (donationModel.donationStatus == DonationStatus.ACKNOWLEDGED) {
          if (donationModel.donationType == RequestType.CASH) {
            totalGoodsOrAmount += donationModel.cashDetails.pledgedAmount;
          } else {
            totalGoodsOrAmount +=
                donationModel.goodsDetails.donatedGoods.values.length;
          }
        }
      });
    });
  } on Exception catch (e) {
    logger.e(e);
  }
  return totalGoodsOrAmount;
}

Future<int> getTimebankRaisedAmountAndGoods({
  @required String timebankId,
  @required int timeFrame,
  bool isLifeTime,
  bool isGoods,
}) async {
  int totalGoodsOrAmount = 0;
  try {
    await CollectionRef.donations
        .where('donationType', isEqualTo: isGoods ? 'GOODS' : 'CASH')
        .where('timebankId', isEqualTo: timebankId)
        .where('timestamp', isGreaterThan: isLifeTime ? 0 : timeFrame)
        .get()
        .then((data) {
      data.docs.forEach((documentSnapshot) {
        DonationModel donationModel =
            DonationModel.fromMap(documentSnapshot.data());
        if (donationModel.donatedToTimebank &&
            donationModel.donationStatus == DonationStatus.ACKNOWLEDGED) {
          if (donationModel.donationType == RequestType.CASH) {
            totalGoodsOrAmount += donationModel.cashDetails.pledgedAmount;
          } else if (donationModel.donationType == RequestType.GOODS) {
            totalGoodsOrAmount +=
                donationModel.goodsDetails.donatedGoods.length;
          }
        }
      });
    });
  } on Exception catch (e) {
    logger.e(e);
  }
  return totalGoodsOrAmount;
}

Future<DeviceDetails> getAndUpdateDeviceDetailsOfUser(
    {GeoFirePoint locationVal, String userEmailId}) async {
  GeoFirePoint location;
  Geoflutterfire geo = Geoflutterfire();

  String userEmail =
      userEmailId ?? (await FirebaseAuth.instance.currentUser)?.email;
  DeviceDetails deviceDetails = DeviceDetails();
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    deviceDetails.deviceType = 'Android';
    deviceDetails.deviceId = androidInfo.androidId;
  } else if (Platform.isIOS) {
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    deviceDetails.deviceType = 'IOS';
    deviceDetails.deviceId = iosInfo.identifierForVendor;
  }

  if (locationVal == null) {
    LocationHelper.getLocation().then((value) {
      value.fold((l) => null, (r) {
        location = geo.point(latitude: r.latitude, longitude: r.longitude);
      });
    });
  } else {
    location = locationVal;
  }

  AppConfig.loggedInEmail = userEmailId;
  deviceDetails.location = location;
  await CollectionRef.users.doc(userEmail).update({
    'deviceDetails': deviceDetails.toMap(),
  });
  return deviceDetails;
}

Future<DeviceDetails> addCreationSourceOfUser(
    {GeoFirePoint locationVal, String userEmailId}) async {
  GeoFirePoint location;
  // PermissionStatus _permissionGranted;
  Geoflutterfire geo = Geoflutterfire();

  String userEmail =
      userEmailId ?? (await FirebaseAuth.instance.currentUser)?.email;
  DeviceDetails deviceDetails = DeviceDetails();
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    deviceDetails.deviceType = 'Android';
    deviceDetails.deviceId = androidInfo.androidId;
  } else if (Platform.isIOS) {
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    deviceDetails.deviceType = 'IOS';
    deviceDetails.deviceId = iosInfo.identifierForVendor;
  }

  if (locationVal == null) {
    await LocationHelper.getLocation().then((value) {
      if (value != null) {
        value.fold((l) => null, (r) {
          location = geo.point(
            latitude: r.latitude,
            longitude: r.longitude,
          );
        });
      }
    });
  } else {
    location = locationVal;
  }
  deviceDetails.location = location;
  deviceDetails.timestamp = DateTime.now().millisecondsSinceEpoch;
  await CollectionRef.users.doc(userEmail).update({
    'creationSource': deviceDetails.toMap(),
  });
  return deviceDetails;
}

Future<int> getRequestRaisedGoods({
  @required String requestId,
}) async {
  int totalGoods = 0;
  try {
    await CollectionRef.donations
        .where('donationType', isEqualTo: 'GOODS')
        .where('donationStatus', isEqualTo: 'ACKNOWLEDGED')
        .where('requestId', isEqualTo: requestId)
        .get()
        .then((data) {
      data.docs.forEach((documentSnapshot) {
        DonationModel donationModel =
            DonationModel.fromMap(documentSnapshot.data());

        totalGoods += donationModel.goodsDetails.donatedGoods.values.length;
      });
    });
  } on Exception catch (e) {
    logger.e(e);
  }
  return totalGoods;
}

Stream<List<DonationModel>> getDonationList(
    {String userId, String timebankId, bool isGoods}) async* {
  var data;

  if (userId != null) {
    data = CollectionRef.donations
        .where('donorSevaUserId', isEqualTo: userId)
        .where('donationType', isEqualTo: isGoods ? 'GOODS' : 'CASH')
        .orderBy("timestamp", descending: true)
        .snapshots();
  } else {
    data = CollectionRef.donations
        .where('timebankId', isEqualTo: timebankId)
        .where('donationType', isEqualTo: isGoods ? 'GOODS' : 'CASH')
        .where('donatedToTimebank', isEqualTo: true)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<DonationModel>>.fromHandlers(
      handleData: (snapshot, donationSink) {
        List<DonationModel> donationsList = [];
        snapshot.docs.forEach((document) {
          DonationModel model = DonationModel.fromMap(document.data());
          if (model.donationStatus == DonationStatus.ACKNOWLEDGED)
            donationsList.add(model);
        });
        donationSink.add(donationsList);
      },
    ),
  );
}

Future<Map<String, UserModel>> getUserForUserModels(
    {@required List<String> admins}) async {
  var map = Map<String, UserModel>();
  for (int i = 0; i < admins.length; i++) {
    UserModel user = await getUserForId(sevaUserId: admins[i]);
    map[user.fullname.toLowerCase()] = user;
  }
  return map;
}

Stream<List<UserModel>> getRecommendedUsersStream(
    {@required String requestId}) async* {
  var data = CollectionRef.users
      .where('recommendedForRequestIds', arrayContains: requestId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<UserModel>>.fromHandlers(
      handleData: (snapshot, usersListSink) {
        List<UserModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            UserModel model =
                UserModel.fromMap(documentSnapshot.data(), 'user_data_manager');
            modelList.add(model);
          },
        );
        modelList.sort((a, b) =>
            a.fullname.toLowerCase().compareTo(b.fullname.toLowerCase()));
        usersListSink.add(modelList);
      },
    ),
  );
}

Future<UserModel> getUserForId({@required String sevaUserId}) async {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");

  UserModel userModel;
  await CollectionRef.users
      .where('sevauserid', isEqualTo: sevaUserId)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      userModel =
          UserModel.fromMap(documentSnapshot.data(), 'user_data_manager');
    });
  });

  return userModel;
}

Future<UserModel> getUserForEmail({
  @required String emailAddress,
}) async {
  assert(emailAddress != null && emailAddress.isNotEmpty,
      'User Email cannot be null or empty');

  UserModel userModel;
  var documentSnapshot = await CollectionRef.users.doc(emailAddress).get();

  if (documentSnapshot == null || documentSnapshot.data() == null) {
    return null;
  }
  userModel = UserModel.fromMap(documentSnapshot.data(), 'user_data_manager');
  return userModel;
}

class UserModelListMoreStatus {
  var userModelList = [];
  bool lastPage = false;
}

Future<UserModelListMoreStatus> getUsersForAdminsCoordinatorsMembersTimebankId(
    String timebankId, int index, String email) async {
  var saveXLink = '';
  if (FlavorConfig.values.timebankName == "Yang 2020") {
    saveXLink = '';
  } else {
    saveXLink = 'Sevax';
  }
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL +
      '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email&showBlockedMembers=true';

  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList = rest
        .map<UserModel>((json) => UserModel.fromMap(json, 'user_data_manager'))
        .toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Future<UserModelListMoreStatus>
    getUsersForAdminsCoordinatorsMembersTimebankIdTwo(
        String timebankId, int index, String email) async {
  var saveXLink = '';
  if (FlavorConfig.values.timebankName == "Yang 2020") {
    saveXLink = '';
  } else {
    saveXLink = 'Sevax';
  }
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL +
      '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email&showBlockedMembers=true';
  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList = rest
        .map<UserModel>((json) => UserModel.fromMap(json, 'user_data_manager'))
        .toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Future<UserModelListMoreStatus> getUsersForTimebankId(
    String timebankId, int index, String email) async {
  var saveXLink = '';
  saveXLink = 'Sevax';
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL +
      '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email';
  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList = rest
        .map<UserModel>((json) => UserModel.fromMap(json, 'user_data_manager'))
        .toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Stream<UserModel> getUserForIdStream({@required String sevaUserId}) async* {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");
  var data = CollectionRef.users
      .where('sevauserid', isEqualTo: sevaUserId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) async {
        DocumentSnapshot documentSnapshot = snapshot.docs[0];
        UserModel model =
            UserModel.fromMap(documentSnapshot.data(), 'user_data_manager');

        model.sevaUserID = sevaUserId;
        userSink.add(model);
      },
    ),
  );
}

Future<UserModel> getUserForIdFuture({@required String sevaUserId}) async {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");
  return CollectionRef.users
      .where('sevauserid', isEqualTo: sevaUserId)
      .get()
      .then((snapshot) {
    DocumentSnapshot documentSnapshot = snapshot.docs[0];
    UserModel model =
        UserModel.fromMap(documentSnapshot.data(), 'user_data_manager');
    return model;
  }).catchError((onError) {
    return UserModel();
  });
}

Stream<UserModel> getUserForEmailStream(String userEmailAddress) async* {
  assert(userEmailAddress != null && userEmailAddress.isNotEmpty,
      'User Email cannot be null or empty');

  var userDataStream = CollectionRef.users.doc(userEmailAddress).snapshots();

  yield* userDataStream.transform(
    StreamTransformer<DocumentSnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) {
        UserModel model =
            UserModel.fromMap(snapshot.data(), 'user_data_manager');
        // model.sevaUserID = snapshot.id;
        userSink.add(model);
      },
    ),
  );
}

Future<Map<String, dynamic>> removeMemberFromGroup({
  String sevauserid,
  String groupId,
}) async {
  String urlLink = FlavorConfig.values.cloudFunctionBaseURL +
      "/removeMemberFromGroup?sevauserid=$sevauserid&groupId=$groupId";

  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  var data = json.decode(res.body);
  return data;
}

Future<Map<String, dynamic>> removeMemberFromTimebank(
    {String sevauserid, String timebankId, Timebank}) async {
  String urlLink = FlavorConfig.values.cloudFunctionBaseURL +
      "/removeMemberFromTimebank?sevauserid=$sevauserid&timebankId=$timebankId";

  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  var data = json.decode(res.body);
  return data;
}

Future storeRemoveMemberLog({
  TimebankModel timebankModel,
  String communityId,
  String memberEmail,
  String memberUid,
  String memberFullName,
  String memberPhotoUrl,
  String adminEmail,
  String adminId,
  String adminFullName,
  String adminPhotoUrl,
  String timebankTitle,
}) async {
  var response = CollectionRef.timebank
      .doc(timebankModel.id)
      .collection('entryExitLogs')
      .doc()
      .set({
    'mode': ExitJoinType.EXIT.readable,
    'modeType': ExitMode.REMOVED_BY_ADMIN.readable,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'communityId': communityId,
    'isGroup': timebankModel.parentTimebankId == FlavorConfig.values.timebankId
        ? false
        : true,
    'memberDetails': {
      'email': memberEmail,
      'id': memberUid,
      'fullName': memberFullName,
      'photoUrl': memberPhotoUrl,
    },
    'adminDetails': {
      'email': adminEmail,
      'id': adminId,
      'fullName': adminFullName,
      'photoUrl': adminPhotoUrl,
    },
    'associatedTimebankDetails': {
      'timebankId': timebankModel.id,
      'timebankTitle': timebankTitle,
    },
  });
  logger.i('storeRemoveMemberLog response: ' + response.toString());
  return response;
}

Future<Map<String, dynamic>> checkChangeOwnershipStatus(
    {String timebankId, String sevauserid}) async {
  var result = await http.post(
    "${FlavorConfig.values.cloudFunctionBaseURL}/checkTasksAndPaymentsForTransferOwnership",
    body: {"timebankId": timebankId, "sevauserid": sevauserid},
  );
  var data = json.decode(result.body);
  return data;
}

Future<ProfanityImageModel> checkProfanityForImage(
    {String imageUrl, String storagePath}) async {
  log("model ${imageUrl}");

  var result = await http.post(
    "https://proxy.sevaexchange.com/" +
        "https://us-central1-sevaxproject4sevax.cloudfunctions.net/visionApi",
    headers: {
      "Content-Type": "application/json",
      "Access-Control": "Allow-Headers",
      "x-requested-with": "x-requested-by"
    },
    body: jsonEncode({
      "imageURL": imageUrl,
      "firebaseURL": imageUrl,
    }),
  );

  ProfanityImageModel profanityImageModel;
  try {
    log("model ${json.decode(result.body)}");
    Map<String, dynamic> data = json.decode(result.body);
    logger.i("data ${data}");

    if (data['safeSearchAnnotation'] == null) {
      logger.i(data['safeSearchAnnotation']);
      return null;
    }
    profanityImageModel =
        ProfanityImageModel.fromMap(data['safeSearchAnnotation']);

    log("model ${profanityImageModel.adult}");

//  } on FormatException catch (formatException) {
//    return null;
  } on Exception catch (exception) {
    //other exception
    logger.e("$imageUrl>>>>>>>>>>>>>>>>>>>>>${exception.toString()}");
    return null;
  }

  return profanityImageModel;
}

Future<String> updateChangeOwnerDetails(
    {String communityId,
    String email,
    String streetAddress1,
    String streetAddress2,
    String country,
    String city,
    String pinCode,
    String state}) async {
  var result = await http.post(
      "${FlavorConfig.values.cloudFunctionBaseURL}/updateCustomerDetailsStripe",
      body: jsonEncode(
        {
          "communityId": communityId,
          "email": email,
          "billing_address": {
            "street_address1": streetAddress1,
            "street_address2": streetAddress2,
            "country": country,
            "city": city,
            "pincode": pinCode,
            "state": state
          }
        },
      ),
      headers: {"Content-Type": "application/json"});
  //var data = json.decode(result.body);
  return result.statusCode.toString();
}
