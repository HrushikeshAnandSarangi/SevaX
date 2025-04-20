import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class DBHelper {
  static var projectsRef = CollectionRef.projects;
  static var chatsRef = CollectionRef.chats;
  static const MESSAGING_ROOM_PARTICIPANTS = 'messagingRoomParticipants';
  static const PARTICIPATS = 'participants';
  static const PARTICIPANTS_INFO = 'participantInfo';
  static const String NO_MESSAGE = '';
  static const String ASSOCIATED_MEMBERS = 'associatedmembers';
  static WriteBatch get batch => CollectionRef.batch;
}

class ChatContext extends DataModel {
  final String? chatContext;
  final String? contextId;

  ChatContext({this.chatContext, this.contextId});
  @override
  Map<String, String> toMap() {
    return {
      'chatContext': chatContext!,
      'contextId': contextId!,
    };
  }

  static ChatContext fromMap(Map<String, dynamic> data) {
    return ChatContext(
      chatContext: data.containsKey('chatContext') ? data['chatContext'] : null,
      contextId: data.containsKey('contextId') ? data['contextId'] : null,
    );
  }
}
