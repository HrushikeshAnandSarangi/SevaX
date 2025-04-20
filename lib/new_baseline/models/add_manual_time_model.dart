import 'package:sevaexchange/models/data_model.dart';
//import 'package:collection/ lib\views\timebank_content_holder.dart';

class AddManualTimeModel extends DataModel {
  String? id;
  String? communityId;
  double? noOfHours;
  String? timebankId;
  int? timestamp;
  bool? seen;
  bool? approved;
  String? email;
  String? sevauserid;

  AddManualTimeModel({
    this.id,
    this.communityId,
    this.timebankId,
    this.timestamp,
    this.seen,
    this.approved,
    this.noOfHours,
    this.email,
    this.sevauserid,
  });

  AddManualTimeModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey("id")) {
      this.id = map['id'];
    }
    if (map.containsKey("communityId")) {
      this.communityId = map['communityId'];
    }
    if (map.containsKey("timebankId")) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey("timestamp")) {
      this.timestamp = map['timestamp'];
    }
    if (map.containsKey("seen")) {
      this.seen = map['seen'];
    }
    if (map.containsKey("approved")) {
      this.approved = map['approved'];
    }
    if (map.containsKey("noOfHours")) {
      this.noOfHours = map['noOfHours'].toDouble();
    }
    if (map.containsKey("email")) {
      this.email = map['email'];
    }
    if (map.containsKey("sevauserid")) {
      this.sevauserid = map['sevauserid'];
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> obj = {};
    if (this.id != null) obj['id'] = this.id;
    if (this.communityId != null) obj['communityId'] = this.communityId;
    if (this.timebankId != null) obj['timebankId'] = this.timebankId;
    if (this.timestamp != null) obj['timestamp'] = this.timestamp;
    if (this.seen != null) obj['seen'] = this.seen;
    if (this.approved != null) obj['approved'] = this.approved;
    if (this.noOfHours != null) obj['noOfHours'] = this.noOfHours;
    if (this.email != null) obj['email'] = this.email;
    if (this.sevauserid != null) obj['sevauserid'] = this.sevauserid;

    return obj;
  }
}
