import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart' as prefix0;
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/new_baseline/models/offer_model.dart';

import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/exchange/help.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';
import 'package:sevaexchange/views/timebanks/time_bank_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_admin_listview.dart';

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
Stream<List<TimebankModel>> getTimebanksForUserStream(
    {@required String userId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('members', arrayContains: userId)
      .where("parent")
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

/// Get all timebanknew associated with a User as a Stream_umesh
Future<List<TimebankModel>> getSubTimebanksForUserStream(
    {@required String communityId}) async {
  List<dynamic> timeBankIdList = [];
  List<TimebankModel> timeBankModelList = [];

   await Firestore.instance
      .collection('communities')
      .document(communityId)
      .get().then((DocumentSnapshot documentSnaphot){
        Map<String, dynamic> dataMap = documentSnaphot.data;
        print("hey ${dataMap}");
        timeBankIdList = dataMap["timebanks"];
  });
   print(timeBankIdList);
  for (int i = 0; i < timeBankIdList.length; i += 1) {
    TimebankModel timeBankModel = await getTimeBankForId(
      timebankId: timeBankIdList[i],
    );
    /*if(timeBankModel.members.contains(sevaUserId)){
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    } else if(timeBankModel.admins.contains(sevaUserId)){
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    }else{
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    }*/

    timeBankModelList.add(timeBankModel);
    print("hey ${timeBankModel.admins}");

  }
  return timeBankModelList;
}

/// Get all timebanknew associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForAdmins(
    {@required String userId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('admins', arrayContains: userId)
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

Stream<List<ReportModel>> getReportedUsersStream(
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
  if(timebankModel==null){
    return;
  }
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

Future<List<String>> getAllTimebankIdStream(
    {@required String timebankId})  async{
  return Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get()
      .then((onValue) {
    prefix0.TimebankModel model = prefix0.TimebankModel(onValue.data);

    var admins =  model.admins;
    var coordinators =  model.coordinators;
    var members =  model.members;
    var allItems = List<String>();
    allItems.addAll(admins);
    allItems.addAll(coordinators);
    allItems.addAll(members);
    return allItems;
  });
}

Stream<List<TimebankModel>> getAllMyTimebanks(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
              (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

Stream<List<TimebankModel>> getChildTimebanks(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];

        
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            // if (model.timebankId == FlavorConfig.values.timebankId)
            modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

Stream<List<prefix0.OfferModel>> getOffersApprovedByAdmin(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('offers')
      .where('offerAccepted', isEqualTo: true)
      .where('timebankId', isEqualTo: timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<prefix0.OfferModel>>.fromHandlers(
      handleData: (snapshot, offersList) {
        List<prefix0.OfferModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            prefix0.OfferModel model = prefix0.OfferModel.fromMap(documentSnapshot.data);
            modelList.add(model);
          },
        );
        offersList.add(modelList);
      },
    ),
  );
}
