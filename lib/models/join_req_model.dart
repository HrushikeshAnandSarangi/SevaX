import 'package:sevaexchange/models/models.dart';

class JoinRequestNotificationModel extends DataModel {
  String timebankTitle;
  String timebankId;

  JoinRequestNotificationModel({
    this.timebankId,
    this.timebankTitle,
  });

  JoinRequestNotificationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('timebankTitle')) {
      this.timebankTitle = map['timebankTitle'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.timebankTitle != null && this.timebankTitle.isNotEmpty) {
      object['timebankTitle'] = this.timebankTitle;
    }
    return object;
  }
}
