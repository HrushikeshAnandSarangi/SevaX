import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/request_model.dart';

class RequestRepository {
  static CollectionReference ref = Firestore.instance.collection('requests');
  static Future<RequestModel> getRequestFutureById(
    String requestId,
  ) async {
    DocumentSnapshot document = await ref.document(requestId).get();
    return RequestModel.fromMap(document.data);
  }

  static Future<List<RequestModel>> getAllRequestsOfCommunity(
      String communityId,
      {int limit = 10}) async {
    var result = await ref
        .where("communityId", isEqualTo: communityId)
        .limit(limit)
        .getDocuments();

    List<RequestModel> models = [];
    result.documents.forEach((element) {
      models.add(RequestModel.fromMap(element.data));
    });
    return models;
  }
}
