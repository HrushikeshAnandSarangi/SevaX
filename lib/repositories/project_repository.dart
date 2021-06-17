import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class ProjectRepository {
  static CollectionReference ref = CollectionRef.projects;

  static Future<List<ProjectModel>> getAllProjectsOfCommunity(
      String communityId,
      {int limit = 10}) async {
    var data = await ref
        .where("communityId", isEqualTo: communityId)
        .limit(limit)
        .get();

    List<ProjectModel> models = [];
    data.docs.forEach((element) {
      models.add(ProjectModel.fromMap(element.data()));
    });
    return models;
  }
}
