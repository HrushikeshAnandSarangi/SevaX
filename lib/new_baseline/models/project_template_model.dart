import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';

class ProjectTemplateModel extends DataModel {
  String? id;
  String? name;
  String? templateName;
  String? timebankId;
  String? communityId;
  String? description;
  String? creatorId;
  String? photoUrl;
  String? cover_url;
  ProjectMode? mode;
  int? createdAt;
  bool? softDelete;
  String? registrationLink;
  String? emailId;
  // String phoneNumber;
  ProjectTemplateModel(
      {this.id,
      this.name,
      this.templateName,
      this.timebankId,
      this.emailId,
      // this.phoneNumber,
      this.communityId,
      this.description,
      this.creatorId,
      this.photoUrl,
      this.cover_url,
      this.mode,
      this.createdAt,
      this.softDelete,
      this.registrationLink});

  factory ProjectTemplateModel.fromMap(Map<String, dynamic> json) =>
      ProjectTemplateModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        templateName:
            json["templateName"] == null ? null : json["templateName"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        description: json["description"] == null ? null : json["description"],
        emailId: json["email_id"] == null ? null : json["email_id"],
        // phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        registrationLink:
            json["registrationLink"] == null ? null : json["registrationLink"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        cover_url: json["cover_url"] == null ? null : json["cover_url"],
        mode: json["mode"] == null
            ? null
            : json["mode"] == 'Timebank'
                ? ProjectMode.timebankProject
                : ProjectMode.memberProject,
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
        "registrationLink": registrationLink == null ? null : registrationLink,
        "creator_id": creatorId == null ? null : creatorId,
        "photo_url": photoUrl == null ? null : photoUrl,
        "cover_url": cover_url == null ? null : cover_url,
        "mode": mode == null ? null : mode?.readable,
        "softDelete": softDelete ?? false,
        "email_id": emailId == null ? null : emailId,
        // "phone_number": phoneNumber == null ? null : phoneNumber,
        "created_at": createdAt == null ? null : createdAt,
      };

  @override
  String toString() {
    return 'ProjectTemplateModel{id: $id, name: $name, templateName: $templateName, timebankId: $timebankId, communityId: $communityId, description: $description, creatorId: $creatorId, photoUrl: $photoUrl, cover_url: $cover_url, mode: $mode, createdAt: $createdAt, softDelete: $softDelete, registrationLink: $registrationLink, emailId: $emailId}'; //phoneNumber: $phoneNumber
  }
}
