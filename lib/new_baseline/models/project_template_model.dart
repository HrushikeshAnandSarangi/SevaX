import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class ProjectTemplateModel extends DataModel {
  String id;
  String name;
  String timebankId;
  String communityId;
  String description;
  String emailId;
  String phoneNumber;
  String creatorId;
  String address;
  String photoUrl;
  String mode;
  int createdAt;
  int startTime;
  int endTime;
  GeoFirePoint location;

  ProjectTemplateModel({
    this.id,
    this.name,
    this.timebankId,
    this.communityId,
    this.description,
    this.emailId,
    this.phoneNumber,
    this.creatorId,
    this.address,
    this.photoUrl,
    this.mode,
    this.createdAt,
    this.startTime,
    this.endTime,
    this.location,
  });

  factory ProjectTemplateModel.fromMap(Map<String, dynamic> json) =>
      new ProjectTemplateModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        description: json["description"] == null ? null : json["description"],
        emailId: json["email_id"] == null ? null : json["email_id"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        address: json["address"] == null ? null : json["address"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        mode: json["mode"] == null ? null : json["mode"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        startTime: json["start_time"] == null ? null : json["start_time"],
        endTime: json["end_time"] == null ? null : json["end_time"],
        location: json.containsKey('location')
            ? json['location']['geopoint'] is GeoPoint
                ? GeoFirePoint(
                    json['location']['geopoint'].latitude,
                    json['location']['geopoint'].longitude,
                  )
                : GeoFirePoint(
                    json['location']['geopoint']['_latitude'],
                    json['location']['geopoint']['_longitude'],
                  )
            : null,
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "timebank_id": timebankId == null ? null : timebankId,
        "communityId": communityId == null ? null : communityId,
        "description": description == null ? null : description,
        "email_id": emailId == null ? null : emailId,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "creator_id": creatorId == null ? null : creatorId,
        "address": address == null ? null : address,
        "photo_url": photoUrl == null ? null : photoUrl,
        "mode": mode == null ? null : mode,
        "created_at": createdAt == null ? null : createdAt,
        "start_time": startTime == null ? null : startTime,
        "end_time": endTime == null ? null : endTime,
        "location": location?.data,
      };

  @override
  String toString() {
    return 'ProjectModel{id: $id, name: $name, timebankId: $timebankId, communityId: $communityId, description: $description, emailId: $emailId, phoneNumber: $phoneNumber, creatorId: $creatorId, address: $address, photoUrl: $photoUrl, mode: $mode, createdAt: $createdAt, startTime: $startTime, endTime: $endTime,}';
  }
}
