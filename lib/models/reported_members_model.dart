class ReportedMembersModel {
  List<String>? reporterIds;
  List<String>? timebankIds;
  String? reportedId;
  List<Report>? reports;
  String? reportedUserName;
  String? reportedUserImage;
  String? communityId;
  String? reportedUserEmail;

  ReportedMembersModel({
    this.reporterIds,
    this.reportedId,
    this.timebankIds,
    this.reports,
    this.reportedUserName,
    this.reportedUserImage,
    this.communityId,
    this.reportedUserEmail,
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
        reportedUserEmail: map["reportedUserEmail"],
        communityId: map["communityId"],
      );

  Map<String, dynamic> toMap() => {
        "reporterId": List<dynamic>.from(reporterIds!.map((x) => x)),
        "reportedId": reportedId,
        "timebankIds": timebankIds,
        "reports": List<dynamic>.from(reports!.map((x) => x.toMap())),
        "reportedUserName": reportedUserName,
        "reportedUserImage": reportedUserImage,
        "communityId": communityId,
        "reportedUserEmail": reportedUserEmail,
      };
}

class Report {
  String? attachment;
  String? message;
  String? reporterId;
  String? reporterName;
  String? reporterImage;
  String? entityName;
  String? entityId;
  bool? isTimebankReport;
  int? timestamp;

  Report({
    this.attachment,
    this.message,
    this.reporterId,
    this.reporterImage,
    this.reporterName,
    this.entityName,
    this.isTimebankReport,
    this.timestamp,
    this.entityId,
  });

  factory Report.fromMap(Map<String, dynamic> map) => Report(
        attachment: map["attachment"],
        message: map["message"],
        reporterId: map["reporterId"],
        reporterName: map["reporterName"],
        reporterImage: map["reporterImage"],
        entityName: map["entityName"],
        entityId: map["entityId"],
        isTimebankReport: map["isTimebankReport"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "attachment": attachment,
        "message": message,
        "reporterId": reporterId,
        "reporterName": reporterName,
        "reporterImage": reporterImage,
        "entityName": entityName,
        "entityId": entityId,
        "isTimebankReport": isTimebankReport,
        "timestamp": timestamp,
        "isNotified": false, //for backend notification check//do not change
      };
}
