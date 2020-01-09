import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';

import 'chat_data_manager.dart';

Future<void> createJoinRequest({@required JoinRequestModel model}) async {
  Query query = Firestore.instance
      .collection('join_requests')
      .where('entity_id', isEqualTo: model.entityId)
      .where('user_id', isEqualTo: model.userId);
  QuerySnapshot snapshot = await query.getDocuments();
  DocumentSnapshot document =
      snapshot.documents?.length > 0 && snapshot.documents != null
          ? snapshot.documents.first
          : null;
  if (document != null)
    return await Firestore.instance
        .collection('join_requests')
        .document(document.documentID)
        .setData(model.toMap(), merge: true);

  //create a notification

  return await Firestore.instance
      .collection('join_requests')
      .document()
      .setData(model.toMap(), merge: true);
}

Future<List<JoinRequestModel>> getFutureTimebankJoinRequest({
@required String timebankID, }) async {
  Query query = Firestore.instance
      .collection('join_requests')
      .where('entity_type', isEqualTo: 'Timebank')
      .where('entity_id', isEqualTo: timebankID);
  QuerySnapshot snapshot = await query.getDocuments();

  if(snapshot.documents == null) {
    return [];
  }
  var requestList = List<JoinRequestModel>();
  snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
    var model = JoinRequestModel.fromMap(documentSnapshot.data);
    requestList.add(model);


  });
  return requestList;
}
////to get the user requests --umesh
Future<List<JoinRequestModel>> getFutureUserRequest({
@required String userID, }) async {
  Query query = Firestore.instance
      .collection('join_requests')
      .where('entity_type',isEqualTo: 'TimeBank')
      .where('user_id', isEqualTo: userID);
  QuerySnapshot snapshot = await query.getDocuments();
  print('hghghg ${query.getDocuments()}');
  if(snapshot.documents == null) {
    print('data null');

    return [];
  }
  var requestList = List<JoinRequestModel>();
  snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
    var model = JoinRequestModel.fromMap(documentSnapshot.data);
    if(model.userId == userID){
      requestList.add(model);
    }
  });
  return requestList;
}

Stream<List<JoinRequestModel>> getTimebankUserRequests({
  @required String userID,
}) async* {
  var data = Firestore.instance
      .collection('join_requests')
      .where('user_id', isEqualTo: userID)
  //.where('accepted', isEqualTo: null)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
      handleData: (snapshot, joinrequestSink) {
        List<JoinRequestModel> joinrequestList = [];
        snapshot.documents.forEach(
              (documentSnapshot) {
            JoinRequestModel model =
            JoinRequestModel.fromMap(documentSnapshot.data);
            print('requests data ${documentSnapshot.data}');


            if (model.accepted == null) joinrequestList.add(model);
          },
        );
        joinrequestSink.add(joinrequestList);
      },
    ),
  );
}



Stream<List<JoinRequestModel>> getTimebankJoinRequest({
  @required String timebankID,
}) async* {
  var data = Firestore.instance
      .collection('join_requests')
      .where('entity_type', isEqualTo: 'Timebank')
      .where('entity_id', isEqualTo: timebankID)
      //.where('accepted', isEqualTo: null)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
      handleData: (snapshot, joinrequestSink) {
        List<JoinRequestModel> joinrequestList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            JoinRequestModel model =
                JoinRequestModel.fromMap(documentSnapshot.data);
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
  @required String requestId,
}) async* {
  var data =
      Firestore.instance.collection('requests').document(requestId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, List<UserModel>>.fromHandlers(
      handleData: (snapshot, chatSink) async {
        var futures = <Future>[];
        List<UserModel> userModelList = [];
        userModelList.clear();

        // snapshot.da
        RequestModel model = RequestModel.fromMap(snapshot.data);
        model.acceptors.forEach((member) {
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
