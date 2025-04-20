import 'data_model.dart';

class ReportModel extends DataModel {
  String? reportedId;
  String? reporterId;
  String? timebankId;
  int? action;

  ReportModel({this.reportedId, this.reporterId, this.timebankId, this.action});

  ReportModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('reportedId')) {
      this.reportedId = map['reportedId'];
    }
    if (map.containsKey('action')) {
      this.action = map['action'];
    }
    if (map.containsKey('reporterId')) {
      this.reporterId = map['reporterId'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.reporterId != null && this.reporterId?.isNotEmpty == true) {
      object['reporterId'] = this.reporterId;
    }
    if (this.action != null && this.action != 0) {
      object['action'] = this.action;
    }
    if (this.timebankId != null && this.timebankId?.isNotEmpty == true) {
      object['timebankId'] = this.timebankId;
    }

    if (this.reportedId != null) {
      object['reportedId'] = this.reportedId;
    }
    return object;
  }
}
