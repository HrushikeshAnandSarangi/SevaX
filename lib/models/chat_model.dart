import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/utils/helpers/projects_helper_util.dart';

class ChatModel {
  String? id;
  List<String>? participants;
  List<ParticipantInfo>? participantInfo;
  String? lastMessage;
  Map<String, int>? unreadStatus;
  List<String>? softDeletedBy;
  Map<dynamic, dynamic>? deletedBy;
  bool? isTimebankMessage;
  // String timebankId;
  bool? interCommunity;
  bool? isParentChildCommunication;
  String? communityId;
  List<String>? showToCommunities;
  bool? isGroupMessage;
  MultiUserMessagingModel? groupDetails;
  ChatContext? chatContext;
  int? timestamp;

  ChatModel({
    this.participants,
    this.participantInfo,
    this.lastMessage,
    this.unreadStatus,
    this.softDeletedBy,
    this.deletedBy,
    this.isTimebankMessage = false,
    this.interCommunity = false,
    this.showToCommunities,
    this.communityId,
    this.timestamp,
    this.isGroupMessage,
    this.groupDetails,
    this.chatContext,
    this.isParentChildCommunication = false,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) => ChatModel(
        participants: List<String>.from(map["participants"].map((x) => x)),
        participantInfo: List<ParticipantInfo>.from(map["participantInfo"]
            .map((x) => ParticipantInfo.fromMap(Map<String, dynamic>.from(x)))),
        lastMessage: map.containsKey('lastMessage') ? map["lastMessage"] : null,
        unreadStatus: map["unreadStatus"] != null
            ? Map<String, int>.from(map["unreadStatus"])
            : {},
        softDeletedBy: map["softDeletedBy"] == null
            ? []
            : List<String>.from(map["softDeletedBy"].map((x) => x)),
        deletedBy: map.containsKey("deletedBy") ? map["deletedBy"] : {},
        isTimebankMessage: map["isTimebankMessage"] ?? false,
        isGroupMessage:
            map.containsKey("isGroupMessage") ? map["isGroupMessage"] : false,
        groupDetails:
            map.containsKey("groupDetails") && map["groupDetails"] != null
                ? MultiUserMessagingModel.fromMap(
                    Map<String, dynamic>.from(map["groupDetails"]),
                  )
                : null,

        // timebankId: map["timebankId"],
        isParentChildCommunication:
            map.containsKey('isParentChildCommunication')
                ? map['isParentChildCommunication'] ?? false
                : false,
        interCommunity: map.containsKey('interCommunity')
            ? map['interCommunity'] ?? false
            : false,
        communityId: map.containsKey("communityId") ? map["communityId"] : null,
        showToCommunities: map.containsKey('showToCommunities')
            ? List<String>.from((map["showToCommunities"] ?? []).map((x) => x))
            : [],

        timestamp: map["timestamp"],
        chatContext:
            map.containsKey('chatContext') && map['chatContext'] != null
                ? ChatContext.fromMap(
                    Map<String, dynamic>.from(
                      map['chatContext'],
                    ),
                  )
                : null,
      );

  Map<String, dynamic> toMap() => {
        "participants": List<dynamic>.from(participants?.map((x) => x) ?? []),
        "participantInfo":
            List<dynamic>.from(participantInfo?.map((x) => x.toMap()) ?? []),
        "unreadStatus": unreadStatus,
        "isTimebankMessage": isTimebankMessage,
        "communityId": communityId,
        "isGroupMessage": isGroupMessage ?? false,
        "groupDetails": groupDetails?.toMap(),
        "chatContext": chatContext != null ? chatContext?.toMap() ?? {} : {},
        "showToCommunities":
            List<dynamic>.from((showToCommunities ?? []).map((x) => x)),
        "interCommunity": interCommunity ?? false,
        "isParentChildCommunication": isParentChildCommunication ?? false,
      };

  Map<String, dynamic> shareMessage({Map<String, dynamic>? unreadStatus}) => {
        "lastMessage": lastMessage,
        "participants": List<dynamic>.from(participants?.map((x) => x) ?? []),
        "participantInfo":
            List<dynamic>.from(participantInfo?.map((x) => x.toMap()) ?? []),
        "unreadStatus": unreadStatus,
        "isTimebankMessage": isTimebankMessage,
        "communityId": communityId,
        "isGroupMessage": isGroupMessage ?? false,
        "groupDetails": groupDetails?.toMap(),
        "chatContext": chatContext?.toMap(),
        "interCommunity": interCommunity ?? false,
        "isParentChildCommunication": isParentChildCommunication ?? false,
      };
}

class ParticipantInfo {
  String? id;
  String? communityId;
  String? name;
  String? photoUrl;
  ChatType? type;
  Color? color;

  ParticipantInfo({
    this.id,
    this.communityId,
    this.name,
    this.photoUrl,
    this.type,
  });

  factory ParticipantInfo.fromMap(Map<String, dynamic> map) => ParticipantInfo(
        id: map["id"],
        communityId: map["communityId"] == null ? null : map["communityId"],
        name: map["name"],
        photoUrl: map["photoUrl"],
        type: typeMapper[map["type"]],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "communityId": communityId == null ? null : communityId,
        "name": name,
        "photoUrl": photoUrl,
        "type": type.toString().split('.')[1],
      };
}

enum ChatType {
  TYPE_PERSONAL,
  TYPE_TIMEBANK,
  TYPE_GROUP,
  TYPE_MULTI_USER_MESSAGING
}

Map<String, ChatType> typeMapper = {
  "TYPE_PERSONAL": ChatType.TYPE_PERSONAL,
  "TYPE_TIMEBANK": ChatType.TYPE_TIMEBANK,
  "TYPE_GROUP": ChatType.TYPE_GROUP,
  "TYPE_MULTI_USER_MESSAGING": ChatType.TYPE_MULTI_USER_MESSAGING,
};

class MultiUserMessagingModel {
  MultiUserMessagingModel({
    this.name,
    this.imageUrl,
    this.admins,
    this.timestamp,
  });

  String? name;
  String? imageUrl;
  List<String>? admins;
  int? timestamp;

  factory MultiUserMessagingModel.fromMap(Map<String, dynamic> map) =>
      MultiUserMessagingModel(
        name: map["name"],
        imageUrl: map["imageUrl"],
        admins: List<String>.from(map["admins"].map((x) => x)),
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "imageUrl": imageUrl,
        "admins": FieldValue.arrayUnion(admins?.toList() ?? []),
        "timestamp": timestamp ?? DateTime.now().millisecondsSinceEpoch,
      };
}

class FrequentContactsModel {
  final ChatModel chatModel;
  final ParticipantInfo participantInfo;
  final bool isGroupMessage;
  final bool isTimebankMessage;

  FrequentContactsModel(
    this.chatModel,
    this.participantInfo,
    this.isGroupMessage,
    this.isTimebankMessage,
  );
}
