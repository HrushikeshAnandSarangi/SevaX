class NotificationModel {
  String? id;
  String? dataId;
  String? targetUserId;
  String? senderUserId;
  bool? isRead;
  NotificationType? type;

  NotificationModel({
    this.id,
    this.dataId,
    this.targetUserId,
    this.senderUserId,
    this.isRead,
    this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> json) {
    NotificationModel notificationModel = NotificationModel(
      id: json["id"] == null ? null : json["id"],
      dataId: json["data_id"] == null ? null : json["data_id"],
      targetUserId:
          json["target_user_id"] == null ? null : json["target_user_id"],
      senderUserId:
          json["sender_user_id"] == null ? null : json["sender_user_id"],
      isRead: json["is_read"] == null ? null : json["is_read"],
    );
    if (json.containsKey('type')) {
      String typeString = json['type'];
      if (typeString == 'RequestAccept') {
        notificationModel.type = NotificationType.RequestAccept;
      }
      if (typeString == 'RequestApprove') {
        notificationModel.type = NotificationType.RequestApprove;
      }
      if (typeString == 'RequestReject') {
        notificationModel.type = NotificationType.RequestReject;
      }
      if (typeString == 'RequestCompleted') {
        notificationModel.type = NotificationType.RequestCompleted;
      }
      if (typeString == 'RequestCompletedApproved') {
        notificationModel.type = NotificationType.RequestCompletedApproved;
      }
      if (typeString == 'RequestCompletedRejected') {
        notificationModel.type = NotificationType.RequestCompletedRejected;
      }
      if (typeString == 'TransactionCredit') {
        notificationModel.type = NotificationType.TransactionCredit;
      }
      if (typeString == 'TransactionDebit') {
        notificationModel.type = NotificationType.TransactionDebit;
      }
      if (typeString == 'OfferAccept') {
        notificationModel.type = NotificationType.OfferAccept;
      }
      if (typeString == 'OfferReject') {
        notificationModel.type = NotificationType.OfferReject;
      }
      if (typeString == 'AcceptedOffer') {
        notificationModel.type = NotificationType.AcceptedOffer;
      }
    }
    return notificationModel;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": id == null ? null : id,
      "data_id": dataId == null ? null : dataId,
      "target_user_id": targetUserId == null ? null : targetUserId,
      "sender_user_id": senderUserId == null ? null : senderUserId,
      "is_read": isRead == null ? null : isRead,
    };

    if (this.type != null) {
      map['type'] = this.type.toString().split('.').last;
    }
    return map;
  }
}

enum NotificationType {
  RequestAccept,
  RequestApprove,
  RequestReject,
  RequestCompleted,
  RequestCompletedApproved,
  RequestCompletedRejected,
  TransactionCredit,
  TransactionDebit,
  OfferAccept,
  OfferReject,
  JoinRequest,
  AcceptedOffer
}
