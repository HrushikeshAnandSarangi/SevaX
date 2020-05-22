class ChatModel {
  List<String> participants;
  String lastMessage;
  Map<String, dynamic> unreadStatus;
  List<String> softDeletedBy;
  bool isTimebankMessage;
  String timebankId;
  String communityId;
  int timestamp;

  ChatModel({
    this.participants,
    this.lastMessage,
    this.unreadStatus,
    this.softDeletedBy,
    this.isTimebankMessage = false,
    this.timebankId,
    this.communityId,
    this.timestamp,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
        participants: List<String>.from(map["participants"].map((x) => x)),
        lastMessage: map["lastMessage"],
        unreadStatus: map["unreadStatus"],
        softDeletedBy: List<String>.from(map["softDeletedBy"].map((x) => x)),
        isTimebankMessage: map["isTimebankMessage"],
        timebankId: map["timebankId"],
        communityId: map["communityId"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "participants": List<dynamic>.from(participants.map((x) => x)),
        "lastMessage": lastMessage,
        "unreadStatus": unreadStatus,
        "softDeletedBy": List<dynamic>.from(softDeletedBy.map((x) => x)),
        "isTimebankMessage": isTimebankMessage,
        "timebankId": timebankId,
        "communityId": communityId,
        "timestamp": timestamp,
      };
}
