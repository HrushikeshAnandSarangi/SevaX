import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/request_model.dart';


class RecurringListDataManager {

  static Stream<List<RequestModel>> getRecurringRequestListStream(
      {String parentRequestId}) async* {
    var query = Firestore.instance
        .collection('requests')
        .where('softDelete', isEqualTo: false)
        .where('accepted', isEqualTo: false)
        .where('parent_request_id', isEqualTo: parentRequestId);
    var data = query.snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
              if (model.approvedUsers.length <= model.numberOfApprovals) {
                requestList.add(model);
              }
            },
          );
          requestSink.add(requestList);
        },
      ),
    );
  }
}
