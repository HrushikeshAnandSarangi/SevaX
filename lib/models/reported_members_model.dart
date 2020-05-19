class ReportedMembersModel {
  List<String> reporterIds;
  List<String> timebankIds;
  String reportedId;
  List<Report> reports;
  String reportedUserName;
  String reportedUserImage;
  String communityId;

  ReportedMembersModel({
    this.reporterIds,
    this.reportedId,
    this.timebankIds,
    this.reports,
    this.reportedUserName,
    this.reportedUserImage,
    this.communityId,
  });

  factory ReportedMembersModel.fromMap(Map<String, dynamic> map) =>
      ReportedMembersModel(
        reporterIds: List<String>.from(map["reporterIds"].map((x) => x)),
        reportedId: map["reportedId"],
        timebankIds: List<String>.from(map["timebankIds"].map((x) => x)),
        reports: List<Report>.from(
          map["reports"].map(
            (x) => Report.fromMap(
              Map<String, dynamic>.from(x),
            ),
          ),
        ),
        reportedUserName: map["reportedUserName"],
        reportedUserImage: map["reportedUserImage"],
        communityId: map["communityId"],
      );

  Map<String, dynamic> toMap() => {
        "reporterId": List<dynamic>.from(reporterIds.map((x) => x)),
        "reportedId": reportedId,
        "timebankIds": timebankIds,
        "reports": List<dynamic>.from(reports.map((x) => x.toMap())),
        "reportedUserName": reportedUserName,
        "reportedUserImage": reportedUserImage,
        "communityId": communityId,
      };
}

class Report {
  String attachment;
  String message;
  String reporterId;
  String reporterName;
  String reporterImage;
  String entityName;
  bool isTimebankReport;
  int timestamp;

  Report({
    this.attachment,
    this.message,
    this.reporterId,
    this.reporterImage,
    this.reporterName,
    this.entityName,
    this.isTimebankReport,
    this.timestamp,
  });

  factory Report.fromMap(Map<String, dynamic> map) => Report(
        attachment: map["attachment"],
        message: map["message"],
        reporterId: map["reporterId"],
        reporterName: map["reporterName"],
        reporterImage: map["reporterImage"],
        entityName: map["entityName"],
        isTimebankReport: map["isTimebankReport"],
        timestamp: map["timeStamp"],
      );

  Map<String, dynamic> toMap() => {
        "attachment": attachment,
        "message": message,
        "reporterId": reporterId,
        "reporterName": reporterName,
        "reporterImage": reporterImage,
        "entityName": entityName,
        "isTimebankReport": isTimebankReport,
        "timestamp": timestamp,
      };
}
