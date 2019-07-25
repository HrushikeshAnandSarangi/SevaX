import 'package:sevaexchange/models/data_model.dart';

class MessageModel extends DataModel {
  String user1;
  String user2;
  String lastMessage;
  String timebank;

  MessageModel({
    this.user1,
    this.user2,
    this.lastMessage,
    this.timebank
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('user1')) {
      this.user1 = map['user1'];
    }

    if (map.containsKey('user2')) {
      this.user2 = map['user2'];
    }
    if (map.containsKey('lastMessage')) {
      this.lastMessage = map['lastMessage'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.user1 != null) {
      map['user1'] = this.user1;
    }

    if (this.user2 != null) {
      map['user2'] = this.user2;
    }

    if (this.lastMessage != null) {
      map['lastMessage'] = this.lastMessage;
    }

    return map;
  }
}
