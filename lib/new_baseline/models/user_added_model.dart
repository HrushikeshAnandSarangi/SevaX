import 'package:sevaexchange/models/data_model.dart';

class UserAddedModel extends DataModel {
  String adminName;
  String timebankName;
  String timebankImage;
  // String reason;

  UserAddedModel(
      {this.adminName,
      this.timebankName,
      //    this.reason,
      this.timebankImage}); //  String userName;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.adminName != null && this.adminName.isNotEmpty) {
      object['adminName'] = this.adminName;
    }

//    if (this.reason != null && this.reason.isNotEmpty) {
//      object['reason'] = this.reason;
//    }

    if (this.timebankName != null && this.timebankName.isNotEmpty) {
      object['timebankName'] = this.timebankName;
    }
    if (this.timebankImage != null && this.timebankImage.isNotEmpty) {
      object['timebankImage'] = this.timebankImage;
    }

    return object;
  }

  UserAddedModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('adminName')) {
      this.adminName = map['adminName'];
    }

    if (map.containsKey('timebankName')) {
      this.timebankName = map['timebankName'];
    }

//    if (map.containsKey('reason')) {
//      this.timebankName = map['reason'];
//    }

    if (map.containsKey('timebankImage')) {
      this.timebankImage = map['timebankImage'];
    }
  }
}
