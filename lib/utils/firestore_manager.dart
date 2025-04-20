import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

export 'package:sevaexchange/utils/data_managers/campaigns_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/news_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/skills_interest_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
export 'package:sevaexchange/utils/data_managers/user_data_manager.dart';

class FirestoreManager {
  static Stream<List<DataModel>> getEntityDataListStream(
      {required String userEmail}) async* {
    // var campaignSnapshotStream = CollectionRef.collection('campaigns')
    //     .where('membersemail', arrayContains: userEmail)
    //     .snapshots();

    var timebankSnapshotStream = CollectionRef.timebank
        .where('membersemail', arrayContains: userEmail)
        .snapshots();

    // var campaignStream = campaignSnapshotStream.transform(
    //   StreamTransformer<QuerySnapshot, List<CampaignModel>>.fromHandlers(
    //     handleData: (snapshot, campaignSink) {
    //       List<CampaignModel> modelList = [];
    //       snapshot.docs.forEach((documentSnapshot) {
    //         CampaignModel model =
    //             CampaignModel.fromMap(documentSnapshot.data());
    //         model.id = documentSnapshot.id;
    //         modelList.add(model);
    //       });
    //
    //       campaignSink.add(modelList);
    //     },
    //   ),
    // );

    //   var timebankStream = timebankSnapshotStream.transform(
    //     StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
    //       handleData: (snapshot, timebankSink) {
    //         List<TimebankModel> modelList = [];
    //         snapshot.docs.forEach((documentSnapshot) {
    //           TimebankModel model = TimebankModel(documentSnapshot.data());
    //           model.id = documentSnapshot.id;
    //           modelList.add(model);
    //         });
    //
    //         timebankSink.add(modelList);
    //       },
    //     ),
    //   );
    //
    //   yield* StreamGroup.merge([campaignStream, timebankStream]);
  }
}
