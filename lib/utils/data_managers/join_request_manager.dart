import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

import 'new_chat_manager.dart';

Future<void> updateJoinRequest({required JoinRequestModel model}) async {
  Query query = CollectionRef.joinRequests
      .where('entity_id', isEqualTo: model.entityId)
      .where('user_id', isEqualTo: model.userId);
  QuerySnapshot snapshot = await query.get();
  DocumentSnapshot document = snapshot.docs != null && snapshot.docs.length > 0
      ? snapshot.docs.first
      : null!;
  if (document != null)
    return await CollectionRef.joinRequests
        .doc(document.id)
        .set(model.toMap(), SetOptions(merge: true));

  //create a notification
  return await CollectionRef.joinRequests
      .doc()
      .set(model.toMap(), SetOptions(merge: true));
}

Future<void> createJoinRequestForNewMember(
    {required JoinRequestModel model}) async {
  //create a join request for timebank
  return await CollectionRef.joinRequests
      .doc(model.id)
      .set(model.toMap(), SetOptions(merge: true));
}

Future<List<JoinRequestModel>> getFutureTimebankJoinRequest({
  required String timebankID,
}) async {
  Query query = CollectionRef.joinRequests
      .where('entity_type', isEqualTo: 'Timebank')
      .where('entity_id', isEqualTo: timebankID);
  QuerySnapshot snapshot = await query.get();

  if (snapshot.docs == null) {
    return [];
  }
  List<JoinRequestModel> requestList = [];
  snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
    var model = JoinRequestModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>);
    requestList.add(model);
  });
  return requestList;
}

////to get all the user requests
Future<List<JoinRequestModel>> getFutureUserRequest({
  required String userID,
}) async {
  Query query = CollectionRef.joinRequests
      //  .where('entity_id',isEqualTo: primaryTimebank)
      .where('user_id', isEqualTo: userID);
  QuerySnapshot snapshot = await query.get();
  if (snapshot.docs == null) {
    return [];
  }
  List<JoinRequestModel> requestList = [];
  snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
    var model = JoinRequestModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>);

    if (model.userId == userID) {
      requestList.add(model);
    }
  });
  return requestList;
}

////to get only timebankrequest for the user  --umesh
Future<List<JoinRequestModel>> getFutureUserTimeBankRequest(
    {required String userID, String? primaryTimebank}) async {
  Query query = CollectionRef.joinRequests
      .where('entity_id', isEqualTo: primaryTimebank)
      .where('user_id', isEqualTo: userID);
  QuerySnapshot snapshot = await query.get();
  if (snapshot.docs == null) {
    return [];
  }
  List<JoinRequestModel> requestList = [];
  snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
    var model = JoinRequestModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>);

    if (model.userId == userID) {
      requestList.add(model);
    }
  });
  return requestList;
}

Stream<List<JoinRequestModel>> getTimebankJoinRequest({
  required String timebankID,
}) async* {
  var data = CollectionRef.joinRequests
      .where('entity_type', isEqualTo: 'Timebank')
      .where('entity_id', isEqualTo: timebankID)
      //.where('accepted', isEqualTo: null)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
      handleData: (snapshot, joinrequestSink) {
        List<JoinRequestModel> joinrequestList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            JoinRequestModel model = JoinRequestModel.fromMap(
                documentSnapshot.data() as Map<String, dynamic>);
            if (model.accepted == null) joinrequestList.add(model);
          },
        );
        joinrequestSink.add(joinrequestList);
      },
    ),
  );
}

//Get chats for a user
Stream<List<UserModel>> getRequestDetailsStream({
  required String requestId,
}) async* {
  var data = CollectionRef.requests.doc(requestId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, List<UserModel>>.fromHandlers(
      handleData: (snapshot, chatSink) async {
        var futures = <Future>[];
        List<UserModel> userModelList = [];
        userModelList.clear();

        // snapshot.da
        RequestModel model =
            RequestModel.fromMap(snapshot.data() as Map<String, dynamic>);
        model.acceptors!.forEach((member) {
          futures.add(getUserInfo(member));
        });
        await Future.wait(futures).then((onValue) {
          var i = 0;
          while (i < userModelList.length) {
            userModelList.add(UserModel.fromDynamic(onValue[i]));
            i++;
          }

          chatSink.add(userModelList);
        });
      },
    ),
  );
}
