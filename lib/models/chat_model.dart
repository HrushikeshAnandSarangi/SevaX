import 'dart:ui';

class ChatModel {
  String id;
  List<String> participants;
  List<ParticipantInfo> participantInfo;
  String lastMessage;
  Map<String, int> unreadStatus;
  List<String> softDeletedBy;
  Map<dynamic, dynamic> deletedBy;
  bool isTimebankMessage;
  String timebankId;
  String communityId;
  bool isGroupMessage;

  int timestamp;

  ChatModel(
      {this.participants,
      this.participantInfo,
      this.lastMessage,
      this.unreadStatus,
      this.softDeletedBy,
      this.deletedBy,
      this.isTimebankMessage = false,
      this.timebankId,
      this.communityId,
      this.timestamp,
      this.isGroupMessage});

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
        participants: List<String>.from(map["participants"].map((x) => x)),
        participantInfo: List<ParticipantInfo>.from(map["participantInfo"]
            .map((x) => ParticipantInfo.fromMap(Map<String, dynamic>.from(x)))),
        lastMessage: map.containsKey('lastMessage') ? map["lastMessage"] : null,
        unreadStatus: map["unreadStatus"] != null
            ? Map<String, int>.from(map["unreadStatus"])
            : {},
        softDeletedBy: map["softDeletedBy"] == null
            ? []
            : List<String>.from(map["softDeletedBy"].map((x) => x)),
        deletedBy: map.containsKey("deletedBy") ? map["deletedBy"] : {},
        isTimebankMessage: map["isTimebankMessage"],
        isGroupMessage:
            map.containsKey("isGroupMessage") ? map["isGroupMessage"] : false,
        timebankId: map["timebankId"],
        communityId: map["communityId"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "participants": List<dynamic>.from(participants.map((x) => x)),
        "participantInfo":
            List<dynamic>.from(participantInfo.map((x) => x.toMap())),
        "unreadStatus": unreadStatus,
        "isTimebankMessage": isTimebankMessage,
        "timebankId": timebankId,
        "communityId": communityId,
        "isGroupMessage": isGroupMessage ?? false,
      };
}

class ParticipantInfo {
  String id;
  String name;
  String photoUrl;
  ChatType type;
  Color color;

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

enum ChatType {
  TYPE_PERSONAL,
  TYPE_TIMEBANK,
  TYPE_GROUP,
}

Map<String, ChatType> typeMapper = {
  "TYPE_PERSONAL": ChatType.TYPE_PERSONAL,
  "TYPE_TIMEBANK": ChatType.TYPE_TIMEBANK,
  "TYPE_GROUP": ChatType.TYPE_GROUP,
};
