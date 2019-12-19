import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:async/async.dart' show StreamGroup;
import 'package:meta/meta.dart';

import 'package:sevaexchange/models/models.dart';

export 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/news_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/campaigns_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/transaction_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/skills_interest_data_manager.dart';

class FirestoreManager {
  static Stream<List<DataModel>> getEntityDataListStream(
      {@required String userEmail}) async* {
    var campaignSnapshotStream = Firestore.instance
        .collection('campaigns')
        .where('membersemail', arrayContains: userEmail)
        .snapshots();

    var timebankSnapshotStream = Firestore.instance
        .collection('timebanks')
        .where('membersemail', arrayContains: userEmail)
        .snapshots();

    var campaignStream = campaignSnapshotStream.transform(
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

    var timebankStream = timebankSnapshotStream.transform(
      StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
        handleData: (snapshot, timebankSink) {
          List<TimebankModel> modelList = [];
          snapshot.documents.forEach((documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            model.id = documentSnapshot.documentID;
            modelList.add(model);
          });

          timebankSink.add(modelList);
        },
      ),
    );

    yield* StreamGroup.merge([campaignStream, timebankStream]);
  }
}
