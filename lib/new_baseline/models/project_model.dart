import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class ProjectModel extends DataModel {
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
  List<String> members;
  List<String> pendingRequests;
  List<String> completedRequests;
  bool requestedSoftDelete;
  bool softDelete;
  bool saveAsTemplate;

  ProjectModel(
      {this.id,
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
      this.members,
      this.location,
      this.pendingRequests,
      this.completedRequests,
      this.softDelete,
      this.requestedSoftDelete,
      this.saveAsTemplate});

  factory ProjectModel.fromMap(Map<String, dynamic> json) => new ProjectModel(
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
        softDelete: json["softDelete"] == null ? false : json["softDelete"],
        saveAsTemplate:
            json["saveAsTemplate"] == null ? false : json["saveAsTemplate"],
        requestedSoftDelete: json["requestedSoftDelete"] == null
            ? false
            : json["requestedSoftDelete"],
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
        members: json["members"] == null
            ? null
            : new List<String>.from(json["members"].map((x) => x)),
        pendingRequests: json["pendingRequests"] == null
            ? null
            : new List<String>.from(json["pendingRequests"].map((x) => x)),
        completedRequests: json["completedRequests"] == null
            ? null
            : new List<String>.from(json["completedRequests"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "timebank_id": timebankId == null ? null : timebankId,
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
        "softDelete": softDelete ?? false,
        "requestedSoftDelete": requestedSoftDelete ?? false,
        "saveAsTemplate": saveAsTemplate ?? false,
        "location": location?.data,
        "members": members == null
            ? null
            : new List<dynamic>.from(members.map((x) => x)),
        "pendingRequests": pendingRequests == null
            ? null
            : new List<dynamic>.from(pendingRequests.map((x) => x)),
        "completedRequests": completedRequests == null
            ? null
            : new List<dynamic>.from(
                completedRequests.map((x) => x),
              ),
      };

  @override
  String toString() {
    return 'ProjectModel{id: $id, name: $name, timebankId: $timebankId, communityId: $communityId, description: $description, emailId: $emailId, phoneNumber: $phoneNumber, creatorId: $creatorId, address: $address, photoUrl: $photoUrl, mode: $mode, createdAt: $createdAt, startTime: $startTime, endTime: $endTime, members: $members, pendingRequests: $pendingRequests, completedRequests: $completedRequests, saveAsTemplate: $saveAsTemplate}';
  }
}

enum ProjectMode { PERSONAL, TIMEBANK }
