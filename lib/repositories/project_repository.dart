import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ProjectRepository {
  static CollectionReference ref = Firestore.instance.collection('projects');

  static Future<List<ProjectModel>> getAllProjectsOfCommunity(
      String communityId,
      {int limit = 10}) async {
    var data = await ref
        .where("communityId", isEqualTo: communityId)
        .limit(limit)
        .getDocuments();

    List<ProjectModel> models = [];
    data.documents.forEach((element) {
      models.add(ProjectModel.fromMap(element.data));
    });
    logger.d("_________________________");
    return models;
  }
}
