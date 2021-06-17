//import 'dart:async';
//
//import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:meta/meta.dart';
//import 'package:sevaexchange/models/timebank_model.dart';
//
//class TimebanksService {
//  /// Get all timebanks associated with a [userEmail] as a future
//  Future<List<TimebankModel>> getTimeBanksForUser(
//      {@required String userEmail}) async {
//    // log.i('getTimeBanksForUser: UserEmail: $userEmail');
//    assert(userEmail != null && userEmail.isNotEmpty,
//        'Email address cannot be null or empty');
//
//    List<String> timeBankIdList = [];
//    List<TimebankModel> timeBankModelList = [];
//
//    await CollectionRef
//        .users
//        .doc(userEmail)
//        .get()
//        .then((DocumentSnapshot documentSnapshot) {
//      Map<String, dynamic> dataMap = documentSnapshot.data;
//      List timeBankList = dataMap['membershipTimebanks'];
//      timeBankIdList = List.castFrom(timeBankList);
//    });
//
//    for (int i = 0; i < timeBankIdList.length; i += 1) {
//      TimebankModel timeBankModel = await getTimeBankForId(
//        timebankId: timeBankIdList[i],
//      );
//      timeBankModelList.add(timeBankModel);
//    }
//
//    return timeBankModelList;
//  }
//
//  /// Get all timebanks associated with a [userEmail] as a Stream
//  Stream<List<TimebankModel>> getTimebanksForUserStream(
//      {@required String userEmail}) async* {
//    // log.i('getTimebanksForUserStream: UserEmail: $userEmail');
//    var data = CollectionRef
//        .collection('timebanks')
//        .where('membersemail', isEqualTo: userEmail)
//        .snapshots();
//
//    yield* data.transform(
//      StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
//        handleData: (snapshot, timebankSink) {
//          List<TimebankModel> modelList = [];
//          snapshot.docs.forEach(
//            (documentSnapshot) {
//              TimebankModel model = TimebankModel(documentSnapshot.data);
//              model.id = documentSnapshot.id;
//              modelList.add(model);
//            },
//          );
//
//          timebankSink.add(modelList);
//        },
//      ),
//    );
//  }
//
//  /// Update Timebank [model]
//  Future updateTimebank({TimebankModel model}) async {
//    // log.i('updateTimebank: TimebankModel: $model');
//    await CollectionRef
//        .collection('timebanks')
//        .doc(model.id)
//        .update(model.toMap());
//  }
//
//  /// Get a particular Timebank by it's ID[timebankId]
//  Future<TimebankModel> getTimeBankForId({@required String timebankId}) async {
//    // log.i('getTimeBankForId: TimebankID: $timebankId');
//    assert(timebankId != null && timebankId.isNotEmpty,
//        'Time bank ID cannot be null or empty');
//
//    TimebankModel timeBankModel;
//    await CollectionRef
//        .collection('timebanks')
//        .doc(timebankId)
//        .get()
//        .then((DocumentSnapshot documentSnapshot) {
//      Map<String, dynamic> dataMap = documentSnapshot.data;
//      timeBankModel = TimebankModel(dataMap);
//      timeBankModel.id = documentSnapshot.id;
//    });
//
//    return timeBankModel;
//  }
//
//  /// Get a Timebank data as a Stream using [timebankId]
//  Stream<TimebankModel> getTimebankModelStream(
//      {@required String timebankId}) async* {
//    // log.i('getTimebankModelStream: TimebankID: $timebankId');
//    var data = CollectionRef
//        .collection('timebanks')
//        .doc(timebankId)
//        .snapshots();
//
//    yield* data.transform(
//      StreamTransformer<DocumentSnapshot, TimebankModel>.fromHandlers(
//        handleData: (snapshot, modelSink) {
//          TimebankModel model = TimebankModel(snapshot.data);
//          model.id = snapshot.id;
//          modelSink.add(model);
//        },
//      ),
//    );
//  }
//}
