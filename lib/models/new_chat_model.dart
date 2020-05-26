class ChatModel {
  List<String> participants;
  List<ParticipantInfo> participantInfo;
  String lastMessage;
  Map<String, int> unreadStatus;
  List<String> softDeletedBy;
  Map<dynamic, dynamic> deletedBy;
  bool isTimebankMessage;
  String timebankId;
  String communityId;
  int timestamp;

  ChatModel({
    this.participants,
    this.participantInfo,
    this.lastMessage,
    this.unreadStatus,
    this.softDeletedBy,
    this.deletedBy,
    this.isTimebankMessage = false,
    this.timebankId,
    this.communityId,
    this.timestamp,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
        participants: List<String>.from(map["participants"].map((x) => x)),
        participantInfo: List<ParticipantInfo>.from(map["participantInfo"]
            .map((x) => ParticipantInfo.fromMap(Map<String, dynamic>.from(x)))),
        lastMessage: map["lastMessage"],
        unreadStatus: map["unreadStatus"] != null
            ? Map<String, int>.from(map["unreadStatus"])
            : {},
        softDeletedBy: map["softDeletedBy"] == null
            ? []
            : List<String>.from(map["softDeletedBy"].map((x) => x)),
        isTimebankMessage: map["isTimebankMessage"],
        timebankId: map["timebankId"],
        communityId: map["communityId"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "participants": List<dynamic>.from(participants.map((x) => x)),
        "participantInfo":
            List<dynamic>.from(participantInfo.map((x) => x.toMap())),
        "lastMessage": lastMessage,
        "unreadStatus": unreadStatus,
        "softDeletedBy": softDeletedBy,
        "isTimebankMessage": isTimebankMessage,
        "timebankId": timebankId,
        "communityId": communityId,
        "timestamp": timestamp,
      };
}

class ParticipantInfo {
  String id;
  String name;
  String photoUrl;
  MessageType type;

  ParticipantInfo({
    this.id,
    this.name,
    this.photoUrl,
    this.type,
  });

  factory ParticipantInfo.fromMap(Map<String, dynamic> map) => ParticipantInfo(
        id: map["id"],
        name: map["name"],
        photoUrl: map["photoUrl"],
        type: typeMapper[map["type"]],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "type": type.toString().split('.')[1],
      };
}

enum MessageType {
  TYPE_PERSONAL,
  TYPE_TIMEBANK,
  TYPE_GROUP,
}

Map<String, MessageType> typeMapper = {
  "TYPE_PERSONAL": MessageType.TYPE_PERSONAL,
  "TYPE_TIMEBANK": MessageType.TYPE_TIMEBANK,
  "TYPE_GROUP": MessageType.TYPE_GROUP,
};
