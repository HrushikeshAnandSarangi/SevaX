import 'package:sevaexchange/models/data_model.dart';

class UserExitModel extends DataModel {
  String? userName;
  String? reason;
  String? timebank;
  String? userPhotoUrl;
  UserExitModel({
    this.userName,
    this.reason,
    this.timebank,
    this.userPhotoUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.userName != null && this.userName?.isNotEmpty == true) {
      object['userName'] = this.userName;
    }
    if (this.reason != null && this.reason?.isNotEmpty == true) {
      object['reason'] = this.reason;
    }
    if (this.timebank != null && this.timebank?.isNotEmpty == true) {
      object['timebank'] = this.timebank;
    }
    if (this.userPhotoUrl != null && this.userPhotoUrl?.isNotEmpty == true) {
      object['userPhotoUrl'] = this.userPhotoUrl;
    }

    return object;
  }

  UserExitModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('userName')) {
      this.userName = map['userName'];
    }

    if (map.containsKey('reason')) {
      this.reason = map['reason'];
    }

    if (map.containsKey('timebank')) {
      this.timebank = map['timebank'];
    }

    if (map.containsKey('userPhotoUrl')) {
      this.userPhotoUrl = map['userPhotoUrl'];
    }
  }
}
