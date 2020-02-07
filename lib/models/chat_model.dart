import 'dart:collection';

import 'package:sevaexchange/models/data_model.dart';

class ChatModel extends DataModel {
  String user1;
  String user2;
  String lastMessage;
  String rootTimebank;
  int timestamp;
  String timebankId;

  String messagTitleUserName;
  String photoURL;

  Map<dynamic, dynamic> deletedBy;
  Map<dynamic, dynamic> unreadStatus;
  List<String> softDeletedBy;

  bool isBlocked = false;
  String communityId;

  ChatModel({
    this.user1,
    this.user2,
    this.lastMessage,
    this.rootTimebank,
    this.timebankId,
  });

  ChatModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('softDeletedBy')) {
      List<String> softDeletedBy = List.castFrom(map['softDeletedBy']);
      this.softDeletedBy = softDeletedBy;
    } else {
      softDeletedBy = [];
    }

    if (map.containsKey('deletedBy') && map['deletedBy'] != null) {
      try {
        Map<dynamic, dynamic> deletedByMap = map['deletedBy'];
        this.deletedBy = deletedByMap;
      } catch (e) {
        this.deletedBy = HashMap();
      }
    } else {
      // print("Chat has not been deleted yet");

      deletedBy = HashMap();
    }

    if (map.containsKey('softDeletedBy')) {
      List<String> softDeletedBy = List.castFrom(map['softDeletedBy']);
      this.softDeletedBy = softDeletedBy;
    } else {
      softDeletedBy = [];
    }

    if (map.containsKey('unread_status') && map['unread_status'] != null) {
      try {
        Map<dynamic, dynamic> unreadStatus = map['unread_status'];
        this.unreadStatus = unreadStatus;
        // print("unread_seen set to $deletedBy");
      } catch (e) {
        // print("Exception caught while parding unseen notifications $e");
        this.unreadStatus = HashMap();
      }
    } else {
      // print("Unread property not defined");
      unreadStatus = HashMap();
    }

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

    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
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

    if (this.deletedBy != null) {
      map['deletedBy'] = this.deletedBy;
    }

    if (this.timebankId != null) {
      map['timebankId'] = timebankId;
    }
    
    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    map['unread_status'] = this.unreadStatus;

    map['communityId'] = this.communityId;

    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "messageTitle = ${this.messagTitleUserName} messagePhoto : ${this.photoURL} User 1 :  ${this.user1}  -- User 2 : ${this.user2} -- lastMessage ${this.lastMessage}  -- ${this.rootTimebank} deletedBy -> $deletedBy --communityId $communityId";
  }
}
