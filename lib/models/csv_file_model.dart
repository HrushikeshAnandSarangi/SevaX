import 'package:sevaexchange/models/data_model.dart';

class CsvFileModel extends DataModel {
  String? csvTitle;
  String? timebankId;
  String? csvUrl;
  String? sevaUserId;
  String? communityId;
  int? timestamp;

  CsvFileModel(
      {this.timebankId,
      this.csvTitle,
      this.csvUrl,
      this.sevaUserId,
      this.communityId,
      this.timestamp});

  CsvFileModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('csvTitle')) {
      this.csvTitle = map['csvTitle'];
    }

    if (map.containsKey('csvUrl')) {
      this.csvUrl = map['csvUrl'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }

    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.timebankId != null && this.timebankId?.isNotEmpty == true) {
      object['timebankId'] = this.timebankId;
    }

    if (this.csvTitle != null && this.csvTitle?.isNotEmpty == true) {
      object['csvTitle'] = this.csvTitle;
    }

    if (this.csvUrl != null && this.csvUrl?.isNotEmpty == true) {
      object['csvUrl'] = this.csvUrl;
    }

    if (this.sevaUserId != null && this.sevaUserId?.isNotEmpty == true) {
      object['sevaUserId'] = this.sevaUserId;
    }

    if (this.communityId != null && this.communityId?.isNotEmpty == true) {
      object['communityId'] = this.communityId;
    }

    if (this.timestamp != null) {
      object['timestamp'] = this.timestamp;
    }

    return object;
  }
}
