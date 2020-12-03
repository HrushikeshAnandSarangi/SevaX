import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

enum ClaimStatus { NoAction, Approved, Rejected }
enum ManualTimeType { Project, Timebank, Group }
enum UserRole { Admin, Organizer, Creator }

class ManualTimeModel {
  ManualTimeModel({
    this.id,
    @required this.communityId,
    @required this.typeId,
    @required this.type,
    this.status = ClaimStatus.NoAction,
    this.actionBy,
    @required this.reason,
    @required this.claimedTime,
    @required this.claimedBy,
    @required this.userDetails,
    @required this.relatedNotificationId,
    @required this.timestamp,
  });

  String id;
  String communityId;
  String typeId;
  ManualTimeType type;
  ClaimStatus status;
  String actionBy;
  String reason;
  int claimedTime;
  UserRole claimedBy;
  UserDetails userDetails;
  String relatedNotificationId;
  int timestamp;

  factory ManualTimeModel.fromSnapshot(DocumentSnapshot snapshot) =>
      ManualTimeModel(
        id: snapshot.documentID,
        communityId: snapshot.data["communityId"],
        typeId: snapshot.data['typeId'],
        type: _manualTypeMap[snapshot.data['type']],
        status: snapshot.data.containsKey('status')
            ? _claimStatusMap[snapshot.data['status']]
            : ClaimStatus.NoAction,
        actionBy: snapshot.data["actionBy"],
        reason: snapshot.data["reason"],
        claimedTime: snapshot.data["claimedTime"],
        userDetails: UserDetails.fromMap(snapshot.data["userDetails"]),
        relatedNotificationId: snapshot.data["relatedNotificationId"],
        timestamp: snapshot.data["timestamp"],
        claimedBy: _claimedByMap[snapshot.data['claimedBy']],
      );

  factory ManualTimeModel.fromMap(Map<String, dynamic> map) => ManualTimeModel(
        id: map["id"],
        communityId: map["communityId"],
        typeId: map["typeId"],
        type: _manualTypeMap[map['type']],
        status: map.containsKey('status')
            ? _claimStatusMap[map['status']]
            : ClaimStatus.NoAction,
        actionBy: map["actionBy"],
        reason: map["reason"],
        claimedTime: map["claimedTime"],
        userDetails: UserDetails.fromMap(
          Map<String, dynamic>.from(map["userDetails"]),
        ),
        relatedNotificationId: map["relatedNotificationId"],
        timestamp: map["timestamp"],
        claimedBy: _claimedByMap[map['claimedBy']],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "communityId": communityId,
        "typeId": typeId,
        "type": type.toString().split('.')[1],
        "status": status.toString().split('.')[1],
        "actionBy": actionBy,
        "reason": reason,
        "claimedTime": claimedTime,
        "claimedBy": claimedBy.toString().split('.')[1],
        "userDetails": userDetails.toMap(),
        "relatedNotificationId": relatedNotificationId,
        "timestamp": timestamp,
      };

  @override
  String toString() {
    return toMap().toString();
  }
}

Map<String, ClaimStatus> _claimStatusMap = {
  "NoAction": ClaimStatus.NoAction,
  "Approved": ClaimStatus.Approved,
  "Rejected ": ClaimStatus.Rejected,
};

Map<String, ManualTimeType> _manualTypeMap = {
  "Project": ManualTimeType.Project,
  "Timebank": ManualTimeType.Timebank,
  "Group": ManualTimeType.Group,
};

Map<String, UserRole> _claimedByMap = {
  "Admin": UserRole.Admin,
  "Organizer": UserRole.Organizer,
  "Creator": UserRole.Creator,
};

UserRole getClaimedBy(TimebankModel model, String userId) {
  //TODO update the method to support owner/organizer
  if (model.creatorId == userId) {
    return UserRole.Creator;
  } else if (model.admins.contains(userId)) {
    return UserRole.Admin;
  } else {
    return UserRole.Admin;
  }
}

class UserDetails {
  UserDetails({
    this.id,
    this.name,
    this.photoUrl,
  });

  String id;
  String name;
  String photoUrl;

  factory UserDetails.fromMap(Map<String, dynamic> map) => UserDetails(
        id: map["id"],
        name: map["name"],
        photoUrl: map["photoUrl"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
      };
}
