import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/data_model.dart';

class DBHelper {
  static var projectsRef = Firestore.instance.collection('projects');
  static var chatsRef = Firestore.instance.collection('chatsnew');
  static const MESSAGING_ROOM_PARTICIPANTS = 'messagingRoomParticipants';
  static const PARTICIPATS = 'participants';
  static const PARTICIPANTS_INFO = 'participantInfo';
  static const String NO_MESSAGE = '';
  static const String ASSOCIATED_MEMBERS = 'associatedmembers';
  static WriteBatch get batch => Firestore.instance.batch();
}

class ChatContext extends DataModel {
  final String chatContext;
  final String contextId;

  ChatContext({this.chatContext, this.contextId});
  @override
  Map<String, String> toMap() {
    return {
      'chatContext': chatContext,
      'contextId': contextId,
    };
  }

  static ChatContext fromMap(Map<String, dynamic> data) {
    return ChatContext(
      chatContext: data.containsKey('chatContext') ? data['chatContext'] : null,
      contextId: data.containsKey('contextId') ? data['contextId'] : null,
    );
  }
}
