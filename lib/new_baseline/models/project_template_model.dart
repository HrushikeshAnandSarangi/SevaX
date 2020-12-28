import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';

class ProjectTemplateModel extends DataModel {
  String id;
  String name;
  String templateName;
  String timebankId;
  String communityId;
  String description;
  String creatorId;
  String photoUrl;
  ProjectMode mode;
  int createdAt;
  bool softDelete;

  ProjectTemplateModel({
    this.id,
    this.name,
    this.templateName,
    this.timebankId,
    this.communityId,
    this.description,
    this.creatorId,
    this.photoUrl,
    this.mode,
    this.createdAt,
    this.softDelete,
  });

  factory ProjectTemplateModel.fromMap(Map<String, dynamic> json) =>
      ProjectTemplateModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        templateName:
            json["templateName"] == null ? null : json["templateName"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        description: json["description"] == null ? null : json["description"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        mode: json["mode"] == null
            ? null
            : json["mode"] == 'Timebank'
                ? ProjectMode.TIMEBANK_PROJECT
                : ProjectMode.MEMBER_PROJECT,
        createdAt: json["created_at"] == null ? null : json["created_at"],
        softDelete: json["softDelete"] == null ? false : json["softDelete"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "templateName": templateName == null ? null : templateName,
        "timebank_id": timebankId == null ? null : timebankId,
        "communityId": communityId == null ? null : communityId,
        "description": description == null ? null : description,
        "creator_id": creatorId == null ? null : creatorId,
        "photo_url": photoUrl == null ? null : photoUrl,
        "mode": mode == null ? null : mode.readable,
        "softDelete": softDelete ?? false,
        "created_at": createdAt == null ? null : createdAt,
      };

  @override
  String toString() {
    return 'ProjectTemplateModel{id: $id, name: $name,templateName: $templateName, timebankId: $timebankId, communityId: $communityId, description: $description, creatorId: $creatorId, photoUrl: $photoUrl, mode: $mode, createdAt: $createdAt,  softDelete: $softDelete}';
  }
}
