import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';

import 'package:sevaexchange/models/timebank_model.dart';

/// Get all timebanks associated with a User
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

/// Get all timebanks associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForUserStream(
    {@required String userEmail}) async* {
  var data = Firestore.instance
      .collection('timebanks')
      .where('membersemail', isEqualTo: userEmail)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            modelList.add(model);
          },
        );

        timebankSink.add(modelList);
      },
    ),
  );
}

/// Update Timebanks
Future updateTimebank({TimebankModel model}) async {
  await Firestore.instance
      .collection('timebanks')
      .document(model.id)
      .updateData(model.toMap());
}

/// Get a particular Timebank by it's ID
Future<TimebankModel> getTimeBankForId({@required String timebankId}) async {
  assert(timebankId != null && timebankId.isNotEmpty,
      'Time bank ID cannot be null or empty');

  TimebankModel timeBankModel;
  await Firestore.instance
      .collection('timebanks')
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
      .collection('timebanks')
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
