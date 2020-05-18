import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class InvitationModel extends DataModel {
  String id;
  InvitationType type;
  Map<String, dynamic> data;
  String timebankId;
  String communityId;
  String invitedUserId;
  String adminId;
  int timestamp;

  InvitationModel({
    this.id,
    this.type,
    this.data,
    this.invitedUserId,
    this.adminId,
    this.timestamp,
    @required this.timebankId,
    @required this.communityId,
  });

  InvitationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey("communityId")) {
      this.communityId = map['senderUserId'];
    }

    if (map.containsKey('invitedUserId')) {
      this.invitedUserId = map['invitedUserId'];
    }
    if (map.containsKey('adminId')) {
      this.adminId = map['adminId'];
    }

    if (map.containsKey('invitationType')) {
      this.type = typeMapper[map['invitationType']];
    }
    if (map.containsKey('data')) {
      this.data = Map.castFrom(map['data']);
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
  }

  @override
  String toString() {
    return 'InvitationModel{id: $id, type: $type, data: $data, timebankId: $timebankId, communityId: $communityId, invitedUserId: $invitedUserId, adminId: $adminId, timestamp: $timestamp}';
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.id != null) {
      map['id'] = this.id;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }

    if (this.invitedUserId != null) {
      map['invitedUserId'] = this.invitedUserId;
    }
    if (this.adminId != null) {
      map['adminId'] = this.adminId;
    }

    if (this.type != null) {
      map['invitationType'] = this.type.toString().split('.').last;
    }

    if (this.data != null) {
      map['data'] = this.data;
    }

    if (this.communityId != null) {
      map['communityId'] = this.communityId;
    }

    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    return map;
  }
}

enum InvitationType {
  GroupInvite,
  TimebankInvite,
}

//Check the method
InvitationType stringToNotificationType(String str) {
  print(str);
  return InvitationType.values.firstWhere(
    (v) => v.toString() == 'InvitationType.' + str.trim(),
  );
}

Map<String, InvitationType> typeMapper = {
  "GroupInvite": InvitationType.GroupInvite,
  "TimebankInvite": InvitationType.TimebankInvite,
};
