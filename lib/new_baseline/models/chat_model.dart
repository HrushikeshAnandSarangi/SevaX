class ChatModel {
    String user1;
    String user2;
    String lastMessage;
    String rootTimebankId;

    ChatModel({
        this.user1,
        this.user2,
        this.lastMessage,
        this.rootTimebankId,
    });

    factory ChatModel.fromMap(Map<String, dynamic> json) => new ChatModel(
        user1: json["user1"] == null ? null : json["user1"],
        user2: json["user2"] == null ? null : json["user2"],
        lastMessage: json["last_message"] == null ? null : json["last_message"],
        rootTimebankId: json["root_timebank_id"] == null ? null : json["root_timebank_id"],
    );

    Map<String, dynamic> toMap() => {
        "user1": user1 == null ? null : user1,
        "user2": user2 == null ? null : user2,
        "last_message": lastMessage == null ? null : lastMessage,
        "root_timebank_id": rootTimebankId == null ? null : rootTimebankId,
    };
}
