import 'package:sevaexchange/models/data_model.dart';

class ClaimedRequestStatusModel extends DataModel {
  bool isAccepted;
  String requesterID;
  String requestID;
  num timestamp;
  num credits;
  ClaimedRequestStatusModel(
      {this.isAccepted,
      this.requesterID,
      this.requestID,
      this.timestamp,
      this.credits});

  ClaimedRequestStatusModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('isAccepted')) {
      this.isAccepted = map['isAccepted'];
    }

    if (map.containsKey('requesterID')) {
      this.requesterID = map['requesterID'];
    }

    if (map.containsKey('requestID')) {
      this.requestID = map['requestID'];
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

    if (this.requesterID != null) {
      map['requesterID'] = this.requesterID;
    }

    if (this.requestID != null) {
      map['requestID'] = this.requestID;
    }

    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
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
