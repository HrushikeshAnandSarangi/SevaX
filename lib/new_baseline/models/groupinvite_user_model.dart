import 'package:sevaexchange/models/data_model.dart';

class GroupInviteUserModel extends DataModel {
  String adminName;
  String timebankName;
  String timebankImage;
  String aboutTimebank;
  String timebankId;
  String groupId;

  GroupInviteUserModel(
      {this.adminName,
      this.timebankName,
      this.timebankImage,
      this.timebankId,
      this.aboutTimebank,
      this.groupId}); //  String adminName;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.adminName != null && this.adminName.isNotEmpty) {
      object['adminName'] = this.adminName;
    }

    if (this.timebankName != null && this.timebankName.isNotEmpty) {
      object['timebankName'] = this.timebankName;
    }
    if (this.timebankImage != null && this.timebankImage.isNotEmpty) {
      object['timebankImage'] = this.timebankImage;
    }
    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.groupId != null && this.groupId.isNotEmpty) {
      object['groupId'] = this.groupId;
    }
    if (this.aboutTimebank != null && this.aboutTimebank.isNotEmpty) {
      object['aboutTimebank'] = this.aboutTimebank;
    }

    return object;
  }

  GroupInviteUserModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('adminName')) {
      this.adminName = map['adminName'];
    }

    if (map.containsKey('timebankName')) {
      this.timebankName = map['timebankName'];
    }

    if (map.containsKey('timebankImage')) {
      this.timebankImage = map['timebankImage'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('groupId')) {
      this.groupId = map['groupId'];
    }

    if (map.containsKey('aboutTimebank')) {
      this.aboutTimebank = map['aboutTimebank'];
    }
  }
}
