import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class InvitationModel extends DataModel {
  String? id;
  InvitationType? type;
  Map<String, dynamic>? data;
  String? timebankId;

  InvitationModel({
    this.id,
    this.type,
    this.data,
    this.timebankId,
  });

  InvitationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('invitationType')) {
      this.type = typeMapper[map['invitationType']];
    }
    if (map.containsKey('data')) {
      this.data = Map.castFrom(map['data']);
    }
  }

  @override
  String toString() {
    return 'InvitationModel{id: $id, type: $type, data: $data, timebankId: $timebankId,}';
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

    if (this.type != null) {
      map['invitationType'] = this.type.toString().split('.').last;
    }

    if (this.data != null) {
      map['data'] = this.data;
    }

    return map;
  }
}

enum InvitationType {
  GroupInvite,
  TimebankInvite,
}

//Check the method
InvitationType stringToNotificationType(String str) {
  return InvitationType.values.firstWhere(
    (v) => v.toString() == 'InvitationType.' + str.trim(),
  );
}

Map<String, InvitationType> typeMapper = {
  "GroupInvite": InvitationType.GroupInvite,
  "TimebankInvite": InvitationType.TimebankInvite,
};
