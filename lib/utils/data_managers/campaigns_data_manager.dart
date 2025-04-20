import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// Ensure that the file 'campaign_model.dart' exists and defines 'class CampaignModel'
import 'package:meta/meta.dart';

class CampaignModel {
  String id;
  // Add other fields as needed

  CampaignModel({required this.id});

  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      id: map['id'] ?? '',
      // Initialize other fields here
    );
  }
}

Stream<List<CampaignModel>> getCampaignsForUserStream(
    {required String userEmail}) async* {
  var data = FirebaseFirestore.instance
      .collection('campaigns')
      .where('membersemail', isEqualTo: userEmail)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<CampaignModel>>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        List<CampaignModel> modelList = [];
        snapshot.docs.forEach((documentSnapshot) {
          CampaignModel model = CampaignModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>);
          model.id = documentSnapshot.id;
          modelList.add(model);
        });

        campaignSink.add(modelList);
      },
    ),
  );
}

Future<List<CampaignModel>> getCampaignsForUser(
    {required String userEmail}) async {
  assert(userEmail != null && userEmail.isNotEmpty,
      'Email address cannot be null or empty');

  List<String> campaignIdList = [];
  List<CampaignModel> campaignModelList = [];

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap =
        documentSnapshot.data() as Map<String, dynamic>;
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

Future<CampaignModel> getCampaignForId({required String campaignId}) async {
  assert(campaignId != null && campaignId.isNotEmpty,
      'Campaign ID cannot be null or empty');

  final documentSnapshot = await FirebaseFirestore.instance
      .collection('campaigns')
      .doc(campaignId)
      .get();

  Map<String, dynamic> dataMap =
      documentSnapshot.data() as Map<String, dynamic>;
  CampaignModel campaignModel = CampaignModel.fromMap(dataMap);
  campaignModel.id = documentSnapshot.id;

  return campaignModel;
}

Stream<List<CampaignModel>> getCampaignsForTimebankStream(
    {required TimebankModel timebankModel}) async* {
  assert(
    timebankModel != null &&
        timebankModel.id != null &&
        timebankModel.id.isNotEmpty,
  );

  var data = FirebaseFirestore.instance
      .collection('campaigns')
      .where('parent_timebank', isEqualTo: timebankModel.id)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<CampaignModel>>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        List<CampaignModel> models = [];

        snapshot.docs.forEach((documentSnapshot) {
          CampaignModel model = CampaignModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>);
          model.id = documentSnapshot.id;
          models.add(model);
        });

        campaignSink.add(models);
      },
    ),
  );
}

Stream<CampaignModel> getCampaignForIdStream(
    {required String campaignId}) async* {
  assert(campaignId != null && campaignId.isNotEmpty);

  var data = FirebaseFirestore.instance
      .collection('campaigns')
      .doc(campaignId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
        CampaignModel>.fromHandlers(
      handleData: (snapshot, campaignSink) {
        final map = snapshot.data();
        if (map != null) {
          CampaignModel model = CampaignModel.fromMap(map);
          model.id = snapshot.id;
          campaignSink.add(model);
        }
      },
    ),
  );
}
