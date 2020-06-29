import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class TimebankApi {
  static Future<List<TimebankModel>> getTimebanksWhichUserIsPartOf(
    String userId,
    String communityId,
  ) async {
    List<TimebankModel> timebanks = [];
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("timebanknew")
        .where("community_id", isEqualTo: communityId)
        .where("members", arrayContains: userId)
        .where("softDelete", isEqualTo: false)
        .getDocuments();

    querySnapshot.documents.forEach((DocumentSnapshot document) {
      print("timebank data ${document.data}");
      timebanks.add(TimebankModel.fromMap(document.data));
    });
    return timebanks;
  }
}
