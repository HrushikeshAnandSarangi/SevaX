import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sevaexchange/utils/app_config.dart';

enum ClaimStatus { NoAction, Approved, Rejected }

enum ManualTimeType { Project, Timebank, Group }

enum UserRole { TimebankCreator, Admin, Organizer, Creator, Member }

class ManualTimeModel {
  ManualTimeModel({
    this.id,
    required this.communityId,
    required this.typeId,
    required this.type,
    this.status = ClaimStatus.NoAction,
    this.actionBy,
    required this.reason,
    required this.claimedTime,
    required this.claimedBy,
    required this.userDetails,
    required this.relatedNotificationId,
    required this.timestamp,
    required this.timebankId,
    required this.communityName,
    required this.liveMode,
  });

  String? id;
  String? communityId;
  String? typeId;
  ManualTimeType? type;
  ClaimStatus? status;
  String? actionBy;
  String? reason;
  int? claimedTime;
  UserRole? claimedBy;
  UserDetails? userDetails;
  String? relatedNotificationId;
  int? timestamp;
  String? timebankId;
  String? communityName;
  bool? liveMode;
  factory ManualTimeModel.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return ManualTimeModel(
      id: snapshot.id,
      communityId: data!["communityId"],
      communityName: data["communityName"],
      typeId: data['typeId'],
      type: _manualTypeMap[data['type']],
      status: data!.containsKey('status')
          ? _claimStatusMap[data['status']]
          : ClaimStatus.NoAction,
      actionBy: data["actionBy"],
      reason: data["reason"],
      claimedTime: data["claimedTime"],
      userDetails: UserDetails.fromMap(data["userDetails"]),
      relatedNotificationId: data["relatedNotificationId"],
      timestamp: data["timestamp"],
      claimedBy: _claimedByMap[data['claimedBy']],
      timebankId: data['timebankId'],
      liveMode: data.containsKey('liveMode') ? data['liveMode'] : true,
    );
  }

  factory ManualTimeModel.fromMap(Map<String, dynamic> map) => ManualTimeModel(
        id: map["id"],
        communityId: map["communityId"],
        communityName: map["communityName"],
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
        timebankId: map["timebankId"],
        liveMode: map.containsKey('liveMode') ? map['liveMode'] : true,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "communityId": communityId,
        "communityName": communityName,
        "typeId": typeId,
        "type": type.toString().split('.')[1],
        "status": status.toString().split('.')[1],
        "actionBy": actionBy,
        "reason": reason,
        "claimedTime": claimedTime,
        "claimedBy": claimedBy.toString().split('.')[1],
        "userDetails": userDetails?.toMap(),
        "relatedNotificationId": relatedNotificationId,
        "timestamp": timestamp,
        "timebankId": timebankId,
        "liveMode": !AppConfig.isTestCommunity,
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
  "TimebankCreator": UserRole.TimebankCreator,
  "Member": UserRole.Member,
};

class UserDetails {
  UserDetails({
    this.id,
    this.name,
    this.photoUrl,
    @required this.email,
  });

  String? id;
  String? name;
  String? photoUrl;
  String? email;

  factory UserDetails.fromMap(Map<String, dynamic> map) => UserDetails(
        id: map["id"],
        name: map["name"],
        photoUrl: map["photoUrl"],
        email: map['email'],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "email": email,
      };
}
