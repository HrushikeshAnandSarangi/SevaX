import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class JoinRequestModel extends DataModel {
  String? userId;
  bool? accepted;
  String? reason;
  int? timestamp;
  String? entityId;
  EntityType? entityType;
  bool operationTaken;
  late String id;
  String timebankTitle;
  bool isFromGroup;
  String notificationId;

  JoinRequestModel({
    this.userId,
    this.accepted,
    this.reason,
    this.timestamp,
    this.entityId,
    this.entityType,
    this.operationTaken = false,
    this.timebankTitle = "your timebank",
    this.isFromGroup = false,
    this.notificationId = "NO_SET",
  }) {
    id = utils.Utils.getUuid();
  }

  factory JoinRequestModel.fromMap(Map<String, dynamic> json) {
    JoinRequestModel joinRequestModel = JoinRequestModel(
      userId: json["user_id"] == null ? null : json["user_id"],
      accepted: json["accepted"] == null ? null : json["accepted"],
      reason: json["reason"] == null ? null : json["reason"],
      timestamp: json["timestamp"] == null ? null : json["timestamp"],
      entityId: json["entity_id"] == null ? null : json["entity_id"],
      operationTaken:
          json["operation_taken"] == null ? false : json["operation_taken"],
    );

    if (json.containsKey('entity_type')) {
      String typeString = json['type'];
      if (typeString == 'Timebank') {
        joinRequestModel.entityType = EntityType.Timebank;
      }
      if (typeString == 'Campaign') {
        joinRequestModel.entityType = EntityType.Campaign;
      }
    }

    if (json.containsKey("timebankTitle")) {
      joinRequestModel.timebankTitle = json['timebankTitle'];
    } else {
      joinRequestModel.timebankTitle = "your timebank";
    }

    if (json.containsKey("id")) {
      joinRequestModel.id = json['id'];
    } else {
      joinRequestModel.id = "NOT_SET";
    }

    if (json.containsKey('isFromGroup')) {
      joinRequestModel.isFromGroup = json['isFromGroup'];
    } else {
      joinRequestModel.isFromGroup = false;
    }

    if (json.containsKey('notificationId')) {
      joinRequestModel.notificationId = json['notificationId'];
    } else {
      joinRequestModel.notificationId = "NO_SET";
    }

    return joinRequestModel;
  }

  @override
  bool operator ==(Object other) =>
      other is JoinRequestModel && other.entityId == entityId;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "user_id": userId == null ? null : userId,
      "accepted": accepted == null ? null : accepted,
      "reason": reason == null ? null : reason,
      "timestamp": timestamp == null ? null : timestamp,
      "entity_id": entityId == null ? null : entityId,
      "operation_taken": operationTaken == null ? false : operationTaken,
    };
    if (this.entityType != null) {
      map['entity_type'] = this.entityType.toString().split('.').last;
    }

    if (this.id != null) {
      map['id'] = this.id;
    }

    if (this.timebankTitle != null) {
      map['timebankTitle'] = this.timebankTitle;
    }

    if (this.isFromGroup != null) {
      map['isFromGroup'] = this.isFromGroup;
    }

    if (this.notificationId != null) {
      map['notificationId'] = this.notificationId;
    }

    return map;
  }
}

enum EntityType {
  Timebank,
  Campaign,
}
