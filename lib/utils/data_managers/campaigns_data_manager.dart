import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:meta/meta.dart';

import 'package:sevaexchange/models/campaign_model.dart';

Stream<List<CampaignModel>> getCampaignsForUserStream(
    {@required String userEmail}) async* {
  var data = Firestore.instance
      .collection('campaigns')
      .where('membersemail', isEqualTo: userEmail)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<CampaignModel>>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        List<CampaignModel> modelList = [];
        snapshot.documents.forEach((documentSnapshot) {
          CampaignModel model = CampaignModel.fromMap(documentSnapshot.data);
          model.id = documentSnapshot.documentID;
          modelList.add(model);
        });

        campaignSink.add(modelList);
      },
    ),
  );
}

Future<List<CampaignModel>> getCampaignsForUser(
    {@required String userEmail}) async {
  assert(userEmail != null && userEmail.isNotEmpty,
      'Email address cannot be null or empty');

  List<String> campaignIdList = [];
  List<CampaignModel> campaignModelList = [];

  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    List timeBankList = dataMap['membership_campaigns'];
    campaignIdList = List.castFrom(timeBankList);
  });

  for (int i = 0; i < campaignIdList.length; i += 1) {
    CampaignModel campaignModel = await getCampaignForId(
      campaignId: campaignIdList[i],
    );
    campaignModelList.add(campaignModel);
  }

  return campaignModelList;
}

Future<CampaignModel> getCampaignForId({@required String campaignId}) async {
  assert(campaignId != null && campaignId.isNotEmpty,
      'Campaign ID cannot be null or empty');

  CampaignModel campaignModel;
  await Firestore.instance
      .collection('campaigns')
      .document(campaignId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    campaignModel = CampaignModel.fromMap(dataMap);
    campaignModel.id = documentSnapshot.documentID;
  });

  return campaignModel;
}

Stream<List<CampaignModel>> getCampaignsForTimebankStream(
    {@required TimebankModel timebankModel}) async* {
  assert(
    timebankModel != null &&
        timebankModel.id != null &&
        timebankModel.id.isNotEmpty,
  );

  var data = Firestore.instance
      .collection('campaigns')
      .where('parent_timebank', isEqualTo: timebankModel.id)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<CampaignModel>>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        List<CampaignModel> models = [];

        snapshot.documents.forEach((documentSnapshot) {
          CampaignModel model = CampaignModel.fromMap(documentSnapshot.data);
          model.id = documentSnapshot.documentID;
          models.add(model);
        });

        campaignSink.add(models);
      },
    ),
  );
}

Stream<CampaignModel> getCampaignForIdStream(
    {@required String campaignId}) async* {
  assert(campaignId != null && campaignId.isNotEmpty);

  var data = Firestore.instance
      .collection('campaigns')
      .document(campaignId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CampaignModel>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        CampaignModel model = CampaignModel.fromMap(snapshot.data);
        model.id = snapshot.documentID;
        campaignSink.add(model);
      },
    ),
  );
}
