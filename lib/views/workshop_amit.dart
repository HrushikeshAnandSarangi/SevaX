import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';

class RecurringRequests extends StatefulWidget {
  final String parentRequestId;

  RecurringRequests(this.parentRequestId);
  @override
  State<StatefulWidget> createState() {
    return _RecurringRequestsState();
  }
}

class _RecurringRequestsState extends State<RecurringRequests> {
  @override
  Widget build(BuildContext context) {
    throw Scaffold(
      appBar: AppBar(),
      body: Container(
        child: StreamBuilder(
          stream: RecurringListDataManager.getRequestListStream(
            parentRequestId: widget.parentRequestId,
          ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Container(
              child: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

class RecurringListDataManager {
  static Stream<List<RequestModel>> getRequestListStream(
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
