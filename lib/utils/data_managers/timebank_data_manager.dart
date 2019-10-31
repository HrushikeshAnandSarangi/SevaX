import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/reports_model.dart';

import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

Future<void> createTimebank({@required TimebankModel timebankModel}) async {
  return await Firestore.instance
      .collection('timebanknew')
      .document(timebankModel.id)
      .setData(timebankModel.toMap());
}

/// Get all timebanknew associated with a User
Future<List<TimebankModel>> getTimeBanksForUser(
    {@required String userEmail}) async {
  assert(userEmail != null && userEmail.isNotEmpty,
      'Email address cannot be null or empty');

  List<String> timeBankIdList = [];
  List<TimebankModel> timeBankModelList = [];

  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    List timeBankList = dataMap['membership_timebanks'];
    timeBankIdList = List.castFrom(timeBankList);
  });

  for (int i = 0; i < timeBankIdList.length; i += 1) {
    TimebankModel timeBankModel = await getTimeBankForId(
      timebankId: timeBankIdList[i],
    );
    timeBankModelList.add(timeBankModel);
  }

  return timeBankModelList;
}

/// Get all timebanknew associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForUserStream (
    {@required String userId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('members', arrayContains: userId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            if (model.rootTimebankId == FlavorConfig.values.timebankId)
              modelList.add(model);
          },
        );

        timebankSink.add(modelList);
      },
    ),
  );
}

Stream<List<ReportModel>> getReportedUsersStream (
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('reported_users_list')
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ReportModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<ReportModel> modelList = [];
        snapshot.documents.forEach(
              (documentSnapshot) {
                ReportModel model = ReportModel.fromMap(documentSnapshot.data);
            if (model.timebankId == FlavorConfig.values.timebankId)
              modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

/// Update Timebanks
Future<void> updateTimebank({@required TimebankModel timebankModel}) async {
  return await Firestore.instance
      .collection('timebanknew')
      .document(timebankModel.id)
      .updateData(timebankModel.toMap());
}

/// Get a particular Timebank by it's ID
Future<TimebankModel> getTimeBankForId({@required String timebankId}) async {
  assert(timebankId != null && timebankId.isNotEmpty,
      'Time bank ID cannot be null or empty');

  TimebankModel timeBankModel;
  await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    timeBankModel = TimebankModel.fromMap(dataMap);
    timeBankModel.id = documentSnapshot.documentID;
  });

  return timeBankModel;
}

/// Get a Timebank data as a Stream
Stream<TimebankModel> getTimebankModelStream(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, TimebankModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        TimebankModel model = TimebankModel.fromMap(snapshot.data);
        model.id = snapshot.documentID;
        modelSink.add(model);
      },
    ),
  );
}
