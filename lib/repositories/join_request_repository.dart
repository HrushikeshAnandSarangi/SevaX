import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';

class JoinRequestRepository {
  static Stream<List<JoinRequestModel>> timebankJoinRequestStream(
    String timebankID,
  ) async* {
    Stream<QuerySnapshot> data = Firestore.instance
        .collection('join_requests')
        .where('entity_type', isEqualTo: 'Timebank')
        .where('entity_id', isEqualTo: timebankID)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
        handleData: (data, sink) {
          List<JoinRequestModel> requestList = [];
          data.documents.forEach((DocumentSnapshot documentSnapshot) {
            var model = JoinRequestModel.fromMap(documentSnapshot.data);
            if (model != null &&
                !model.operationTaken &&
                model.userId != null) {
              requestList.add(model);
            }
          });
          sink.add(requestList);
        },
      ),
    );
  }
}
