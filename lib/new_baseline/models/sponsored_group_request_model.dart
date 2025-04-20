import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class SponsoredGroupModel extends DataModel {
  String? creatorId;
  String? creatorName;
  String? userPhotoUrl;
  int? timestamp;
  String id;
  String? timebankTitle;
  String? timebankId;
  String? timebankPhotUrl;
  String? timebankCoverUrl;
  String? notificationId;

  SponsoredGroupModel({
    this.creatorId,
    this.creatorName,
    this.userPhotoUrl,
    this.timestamp,
    this.timebankTitle,
    this.timebankId,
    this.timebankPhotUrl,
    this.timebankCoverUrl,
    this.notificationId,
  }) : id = utils.Utils.getUuid();

  factory SponsoredGroupModel.fromMap(Map<String, dynamic> json) {
    SponsoredGroupModel sponsoredGroupModel = SponsoredGroupModel(
      creatorId: json["user_id"] == null ? null : json["user_id"],
      creatorName: json["creatorName"] == null ? null : json["creatorName"],
      userPhotoUrl: json["userPhotoUrl"] == null ? null : json["userPhotoUrl"],
      timestamp: json["timestamp"] == null ? null : json["timestamp"],
      timebankId: json["timebankId"] == null ? null : json["timebankId"],
      timebankPhotUrl:
          json["timebankPhotUrl"] == null ? null : json["timebankPhotUrl"],
      timebankCoverUrl:
          json["timebankCoverUrl"] == null ? null : json["timebankCoverUrl"],
    );

    if (json.containsKey("timebankTitle")) {
      sponsoredGroupModel.timebankTitle = json['timebankTitle'];
    } else {
      sponsoredGroupModel.timebankTitle = "Timebank";
    }

    if (json.containsKey("id")) {
      sponsoredGroupModel.id = json['id'];
    } else {
      sponsoredGroupModel.id = "NOT_SET";
    }

    if (json.containsKey('notificationId')) {
      sponsoredGroupModel.notificationId = json['notificationId'];
    } else {
      sponsoredGroupModel.notificationId = "NO_SET";
    }

    return sponsoredGroupModel;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "creatorId": creatorId == null ? null : creatorId,
      "creatorName": creatorName == null ? null : creatorName,
      "timestamp": timestamp == null ? null : timestamp,
      "userPhotoUrl": userPhotoUrl == null ? null : userPhotoUrl,
      "timebankPhotUrl": timebankPhotUrl == null ? null : timebankPhotUrl,
      "timebankCoverUrl": timebankCoverUrl == null ? null : timebankCoverUrl,
      "timebankId": timebankId == null ? null : timebankId,
    };

    if (this.id != null) {
      map['id'] = this.id;
    }

    if (this.timebankTitle != null) {
      map['timebankTitle'] = this.timebankTitle;
    }

    if (this.notificationId != null) {
      map['notificationId'] = this.notificationId;
    }

    return map;
  }
}
