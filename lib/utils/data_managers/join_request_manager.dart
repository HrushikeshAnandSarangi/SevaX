import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';

Future<void> createJoinRequest({@required JoinRequestModel model}) async {
  Query query = Firestore.instance
      .collection('join_requests')
      .where('entity_id', isEqualTo: model.entityId)
      .where('user_id', isEqualTo: model.userId);
  QuerySnapshot snapshot = await query.getDocuments();
  DocumentSnapshot document =
      snapshot.documents?.length > 0 && snapshot.documents != null ? snapshot.documents.first : null;
  if (document != null)
    return await Firestore.instance
        .collection('join_requests')
        .document(document.documentID)
        .setData(model.toMap(), merge: true);

  return await Firestore.instance
      .collection('join_requests')
      .document()
      .setData(model.toMap(), merge: true);
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
            JoinRequestModel model = JoinRequestModel.fromMap(documentSnapshot.data);
            if(model.accepted == null)
            joinrequestList.add(model);
          },
        );
        joinrequestSink.add(joinrequestList);
      },
    ),
  );
}
