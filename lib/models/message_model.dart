import 'package:sevaexchange/models/data_model.dart';

class MessageModel extends DataModel {
  String message;
  String fromId;
  String toId;
  int timestamp;
  bool isRead;

  MessageModel({
    this.message,
    this.fromId,
    this.toId,
    this.timestamp,
    this.isRead = false,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('message')) {
      this.message = map['message'];
    }

    if (map.containsKey('fromId')) {
      this.fromId = map['fromId'];
    }

    if (map.containsKey('toId')) {
      this.toId = map['toId'];
    }
    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];

      if (map.containsKey('isRead')) {
        this.isRead = map['isRead'];
      }
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.message != null) {
      map['message'] = this.message;
    }

    if (this.fromId != null) {
      map['fromId'] = this.fromId;
    }

    if (this.toId != null) {
      map['toId'] = this.toId;
    }

    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }

    if (this.isRead != null) {
      map['isRead'] = this.isRead;
    }
    return map;
  }
}
