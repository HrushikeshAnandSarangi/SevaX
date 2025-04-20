import 'package:sevaexchange/models/data_model.dart';

class ClaimedRequestStatusModel extends DataModel {
  bool? isAccepted;
  String? id;
  num? timestamp;
  num? credits;
  String? requesterEmail;
  String? adminEmail;

  ClaimedRequestStatusModel(
      {this.isAccepted,
      this.requesterEmail,
      this.adminEmail,
      this.id,
      this.timestamp,
      this.credits});

  ClaimedRequestStatusModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('isAccepted')) {
      this.isAccepted = map['isAccepted'];
    }

    if (map.containsKey('requester_email')) {
      this.requesterEmail = map['requester_email'];
    }

    if (map.containsKey('admin_email')) {
      this.adminEmail = map['admin_email'];
    }

    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }

    if (map.containsKey('credits')) {
      this.credits = map['credits'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.isAccepted != null) {
      map['isAccepted'] = this.isAccepted;
    }

    if (this.requesterEmail != null) {
      map['requester_email'] = this.requesterEmail;
    }

    if (this.adminEmail != null) {
      map['admin_email'] = this.adminEmail;
    }

    if (this.id != null) {
      map['id'] = this.id;
    }

    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }

    if (this.credits != null) {
      map['credits'] = this.credits;
    }

    return map;
  }
}
