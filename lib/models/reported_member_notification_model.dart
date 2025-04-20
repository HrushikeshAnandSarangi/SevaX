class ReportedMemberNotificationModel {
  String? reportedUserId;
  String? reportedUserImage;
  String? reportedUserName;

  ReportedMemberNotificationModel({
    this.reportedUserId,
    this.reportedUserImage,
    this.reportedUserName,
  });

  factory ReportedMemberNotificationModel.fromMap(Map<String, dynamic> map) =>
      ReportedMemberNotificationModel(
        reportedUserId: map["reportedUserId"],
        reportedUserImage: map["reportedUserImage"],
        reportedUserName: map["reportedUserName"],
      );
}
