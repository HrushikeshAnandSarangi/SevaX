import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class TimebankRepository {
  static final CollectionReference _ref =
      Firestore.instance.collection("timebanknew");
  static Future<List<TimebankModel>> getTimebanksWhichUserIsPartOf(
    String userId,
    String communityId,
  ) async {
    List<TimebankModel> timebanks = [];
    QuerySnapshot querySnapshot = await _ref
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

  static Stream<QuerySnapshot> getAllTimebanksOfCommunity(String communityId) {
    return _ref.where("community_id", isEqualTo: communityId).snapshots();
  }

  static Stream<QuerySnapshot> getAllTimebanksUserIsAdminOf(
      String userId, String communityId) {
    return _ref
        .where("community_id", isEqualTo: communityId)
        .where("admins", arrayContains: userId)
        .snapshots();
  }
}
