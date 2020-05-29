import 'package:sevaexchange/models/data_model.dart';

class GroupInviteUserModel extends DataModel {
  String adminName;
  String timebankName;
  String timebankImage;
  String aboutTimebank;
  String timebankId;
  String groupId;
  String invitedUserId;
  String adminId;
  int timestamp;
  String communityId;
  bool declined;
  int declinedTimestamp;
  String notificationId;

  GroupInviteUserModel(
      {this.adminName,
      this.timebankName,
      this.timebankImage,
      this.timebankId,
      this.aboutTimebank,
      this.groupId,
      this.invitedUserId,
      this.timestamp,
      this.communityId,
      this.adminId,
      this.declined,
      this.declinedTimestamp,
      this.notificationId}); //  String adminName;

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
    if (this.invitedUserId != null && this.invitedUserId.isNotEmpty) {
      object['invitedUserId'] = this.invitedUserId;
    }
    if (this.adminId != null && this.adminId.isNotEmpty) {
      object['adminId'] = this.adminId;
    }
    if (this.communityId != null) {
      object['communityId'] = this.communityId;
    }

    if (this.declined != null) {
      object['declined'] = this.declined;
    } else {
      object['declined'] = false;
    }

    if (this.declinedTimestamp != null) {
      object['declinedTimestamp'] = this.declinedTimestamp;
    }

    if (this.notificationId != null) {
      object['notificationId'] = this.notificationId;
    }

    object['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    return object;
  }

  GroupInviteUserModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('adminName')) {
      this.adminName = map['adminName'];
    }
    if (map.containsKey("communityId")) {
      this.communityId = map['senderUserId'];
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
    if (map.containsKey('invitedUserId')) {
      this.invitedUserId = map['invitedUserId'];
    }
    if (map.containsKey('adminId')) {
      this.adminId = map['adminId'];
    }

    if (map.containsKey('notificationId')) {
      this.notificationId = map['notificationId'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
    if (map.containsKey('declined')) {
      this.declined = map['declined'];
    } else {
      this.declined = false;
    }

    if (map.containsKey('declinedTimestamp')) {
      this.declinedTimestamp = map['declinedTimestamp'];
    }
  }
}
