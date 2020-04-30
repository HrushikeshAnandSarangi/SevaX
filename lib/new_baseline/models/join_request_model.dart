import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class JoinRequestModel extends DataModel{
  String userId;
  bool accepted;
  String reason;
  int timestamp;
  String entityId;
  EntityType entityType;
  bool operationTaken;
  String id;
  String timebankTitle;

  JoinRequestModel({
    this.userId,
    this.accepted,
    this.reason,
    this.timestamp,
    this.entityId,
    this.entityType,
    this.operationTaken,
    this.timebankTitle,
  }) {
    id = utils.Utils.getUuid();
  }

  factory JoinRequestModel.fromMap(Map<String, dynamic> json) {
    JoinRequestModel joinRequestModel = new JoinRequestModel(
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

    return joinRequestModel;
  }

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

    return map;
  }
}

enum EntityType {
  Timebank,
  Campaign,
}
