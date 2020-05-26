import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';

import '../../flavor_config.dart';

/// Create a [user]
Future<void> createUser({
  @required UserModel user,
}) async {
  return await Firestore.instance
      .collection('users')
      .document(user.email)
      .setData(user.toMap());
}

Future<void> updateUser({
  @required UserModel user,
}) async {
  return await Firestore.instance
      .collection('users')
      .document(user.email)
      .setData(user.toMap(), merge: true);
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

Future<UserModel> getUserForId({@required String sevaUserId}) async {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");

  UserModel userModel;
  await Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: sevaUserId)
      .getDocuments()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      userModel = UserModel.fromMap(documentSnapshot.data);
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
  DocumentSnapshot documentSnapshot =
      await Firestore.instance.collection('users').document(emailAddress).get();

  if (documentSnapshot == null || documentSnapshot.data == null) {
    return null;
  }
  userModel = UserModel.fromMap(documentSnapshot.data);
  return userModel;
}

class UserModelListMoreStatus {
  var userModelList = List<UserModel>();
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
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL + '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email&showBlockedMembers=true';

  print("==============$urlLink==============");
  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  print('res--->$res');
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    print(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList =
        rest.map<UserModel>((json) => UserModel.fromMap(json)).toList();
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
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL + '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email&showBlockedMembers=true';
  print("==============$urlLink==============");
  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  print('res--->$res');
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    print(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList =
        rest.map<UserModel>((json) => UserModel.fromMap(json)).toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Future<UserModelListMoreStatus> getUsersForTimebankId(
    String timebankId, int index, String email) async {
  var saveXLink = '';
  if (FlavorConfig.values.timebankName == "Yang 2020") {
    saveXLink = '';
  } else {
    saveXLink = 'Sevax';
  }
  print("peekaboo:${FlavorConfig.values.timebankName}");
  var urlLink = FlavorConfig.values.cloudFunctionBaseURL + '/timebankMembers$saveXLink?timebankId=$timebankId&page=$index&userId=$email';
  print("\n\n\n\n\n\n\n\nMembersListURL:$urlLink");
  var res = await http
      .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList =
        rest.map<UserModel>((json) => UserModel.fromMap(json)).toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Stream<UserModel> getUserForIdStream({@required String sevaUserId}) async* {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");
  var data = Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: sevaUserId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) async {
        DocumentSnapshot documentSnapshot = snapshot.documents[0];
        UserModel model = UserModel.fromMap(documentSnapshot.data);

        model.sevaUserID = sevaUserId;
        userSink.add(model);
      },
    ),
  );
}

Future<UserModel> getUserForIdFuture({@required String sevaUserId}) async {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");
  return Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: sevaUserId)
      .getDocuments()
      .then((snapshot) {
    DocumentSnapshot documentSnapshot = snapshot.documents[0];
    UserModel model = UserModel.fromMap(documentSnapshot.data);
    return model;
  }).catchError((onError) {
    return UserModel();
  });
}

Stream<UserModel> getUserForEmailStream(String userEmailAddress) async* {
  assert(userEmailAddress != null && userEmailAddress.isNotEmpty,
      'User Email cannot be null or empty');

  var userDataStream = Firestore.instance
      .collection('users')
      .document(userEmailAddress)
      .snapshots();

  yield* userDataStream.transform(
    StreamTransformer<DocumentSnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) {
        UserModel model = UserModel.fromMap(snapshot.data);
        // model.sevaUserID = snapshot.documentID;
        userSink.add(model);
      },
    ),
  );
}

//Future<Map<String,dynamic>> removeMemberFromTimebank({})async{
//
//}
