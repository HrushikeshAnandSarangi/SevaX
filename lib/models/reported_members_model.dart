class ReportedMembersModel {
  List<String> reporterId;
  String reportedId;
  String timebankId;
  List<Report> reports;
  String reportedUserName;
  String reportedUserImage;

  ReportedMembersModel({
    this.reporterId,
    this.reportedId,
    this.timebankId,
    this.reports,
    this.reportedUserName,
    this.reportedUserImage,
  });

  factory ReportedMembersModel.fromMap(Map<String, dynamic> map) =>
      ReportedMembersModel(
        reporterId: List<String>.from(map["reporterId"].map((x) => x)),
        reportedId: map["reportedId"],
        timebankId: map["timebankId"],
        reports: List<Report>.from(
          map["reports"].map(
            (x) => Report.fromMap(
              Map<String, dynamic>.from(x),
            ),
          ),
        ),
        reportedUserName: map["reportedUserName"],
        reportedUserImage: map["reportedUserImage"],
      );

  Map<String, dynamic> toMap() => {
        "reporterId": List<dynamic>.from(reporterId.map((x) => x)),
        "reportedId": reportedId,
        "timebankId": timebankId,
        "reports": List<dynamic>.from(reports.map((x) => x.toMap())),
        "reportedUserName": reportedUserName,
        "reportedUserImage": reportedUserImage,
      };
}

class Report {
  String attachment;
  String message;
  String reporterId;
  String reporterName;
  String reporterImage;

  Report({
    this.attachment,
    this.message,
    this.reporterId,
    this.reporterImage,
    this.reporterName,
  });

  factory Report.fromMap(Map<String, dynamic> map) => Report(
        attachment: map["attachment"],
        message: map["message"],
        reporterId: map["reporterId"],
        reporterName: map["reporterName"],
        reporterImage: map["reporterImage"],
      );

  Map<String, dynamic> toMap() => {
        "attachment": attachment,
        "message": message,
        "reporterId": reporterId,
        "reporterName": reporterName,
        "reporterImage": reporterImage,
      };
}
