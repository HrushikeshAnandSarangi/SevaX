class JoinRequestModel {
  String userId;
  bool accepted;
  String reason;
  int timestamp;
  String entityId;
  EntityType entityType;

  JoinRequestModel({
    this.userId,
    this.accepted,
    this.reason,
    this.timestamp,
    this.entityId,
    this.entityType,
  });

  factory JoinRequestModel.fromMap(Map<String, dynamic> json) {
    JoinRequestModel joinRequestModel = new JoinRequestModel(
      userId: json["user_id"] == null ? null : json["user_id"],
      accepted: json["accepted"] == null ? null : json["accepted"],
      reason: json["reason"] == null ? null : json["reason"],
      timestamp: json["timestamp"] == null ? null : json["timestamp"],
      entityId: json["entity_id"] == null ? null : json["entity_id"],
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
    return joinRequestModel;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "user_id": userId == null ? null : userId,
      "accepted": accepted == null ? null : accepted,
      "reason": reason == null ? null : reason,
      "timestamp": timestamp == null ? null : timestamp,
      "entity_id": entityId == null ? null : entityId,
    };
    if (this.entityType != null) {
      map['entity_type'] = this.entityType.toString().split('.').last;
    }
    return map;
  }
}

enum EntityType {
  Timebank,
  Campaign,
}
