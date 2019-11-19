import 'package:sevaexchange/models/data_model.dart';

class ChatModel extends DataModel {
  String user1;
  String user2;
  String lastMessage;
  String rootTimebank;
  int timestamp;

  String messagTitleUserName;
  String photoURL;

  ChatModel({this.user1, this.user2, this.lastMessage, this.rootTimebank});

  ChatModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('user1')) {
      this.user1 = map['user1'];
    }

    if (map.containsKey('user2')) {
      this.user2 = map['user2'];
    }
    if (map.containsKey('lastMessage')) {
      this.lastMessage = map['lastMessage'];
    }
    if (map.containsKey('rootTimebank')) {
      this.rootTimebank = map['rootTimebank'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
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

    if (this.rootTimebank != null) {
      map['rootTimebank'] = this.rootTimebank;
    }

    timestamp = DateTime.now().millisecondsSinceEpoch;

    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "messageTitle = ${this.messagTitleUserName} messagePhoto : ${this.photoURL} User 1 :  ${this.user1}  -- User 2 : ${this.user2} -- lastMessage ${this.lastMessage}  -- ${this.rootTimebank}";
  }
}
