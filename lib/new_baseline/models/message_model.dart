class MessageModel {
    String message;
    String fromUserId;
    String toUserId;
    String createdAt;
    bool isRead;

    MessageModel({
        this.message,
        this.fromUserId,
        this.toUserId,
        this.createdAt,
        this.isRead,
    });

    factory MessageModel.fromMap(Map<String, dynamic> json) => new MessageModel(
        message: json["message"] == null ? null : json["message"],
        fromUserId: json["from_user_id"] == null ? null : json["from_user_id"],
        toUserId: json["to_user_id"] == null ? null : json["to_user_id"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        isRead: json["is_read"] == null ? null : json["is_read"],
    );

    Map<String, dynamic> toMap() => {
        "message": message == null ? null : message,
        "from_user_id": fromUserId == null ? null : fromUserId,
        "to_user_id": toUserId == null ? null : toUserId,
        "created_at": createdAt == null ? null : createdAt,
        "is_read": isRead == null ? null : isRead,
    };
}