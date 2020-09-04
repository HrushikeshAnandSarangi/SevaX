import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/repositories/chats_repository.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';

ParticipantInfo getUserInfo(
    String userId, List<ParticipantInfo> participantInfo) {
  return participantInfo.firstWhere((element) => element.id == userId);
}

ParticipantInfo getSenderInfo(
  String userId,
  List<ParticipantInfo> participantInfo,
) {
  return participantInfo.firstWhere((element) => element.id != userId);
}

Future<void> createAndOpenChat({
  BuildContext context,
  ParticipantInfo sender,
  ParticipantInfo reciever,
  String timebankId,
  String communityId,
  bool isFromRejectCompletion = false,
  bool isTimebankMessage = false,
  bool isFromShare = false,
  String feedId,
  VoidCallback onChatCreate,
}) async {
  List<String> participants = [sender.id, reciever.id];
  participants.sort();
  ChatModel model = ChatModel(
    participants: participants,
    communityId: communityId,
    participantInfo: [sender, reciever],
    isTimebankMessage: isTimebankMessage,
  )
    ..id = "${participants[0]}*${participants[1]}*$communityId"
    ..isGroupMessage = false;

  assert(sender.id != reciever.id);

  await ChatsRepository.createNewChat(model, documentId: model.id);
  if (onChatCreate != null) {
    onChatCreate();
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatPage(
        feedId: feedId,
        isFromShare: isFromShare,
        senderId: sender.id,
        chatModel: model,
        isFromRejectCompletion: isFromRejectCompletion,
      ),
    ),
  );
}

Future<void> sendBackgroundMessage({
  BuildContext context,
  ParticipantInfo sender,
  ParticipantInfo reciever,
  String timebankId,
  String messageContent,
  String communityId,
  bool isTimebankMessage = false,
}) async {
  List<String> participants = [sender.id, reciever.id];
  participants.sort();
  ChatModel chatModel = ChatModel(
    participants: participants,
    communityId: communityId,
    participantInfo: [sender, reciever],
    isTimebankMessage: isTimebankMessage,
  )
    ..id = "${participants[0]}*${participants[1]}*$communityId"
    ..isGroupMessage = false;

  await ChatsRepository.createNewChat(chatModel, documentId: chatModel.id);

  MessageModel messageModel = MessageModel(
    fromId: sender.id,
    toId: reciever.id,
    message: messageContent,
    type: MessageType.MESSAGE,
    timestamp: DateTime.now().toUtc().millisecondsSinceEpoch,
  );

  if (chatModel.isTimebankMessage) {}

  createNewMessage(
    chatId: chatModel.id,
    senderId: sender.id,
    messageModel: messageModel,
    timebankId: sender.id,
    isTimebankMessage: chatModel.isTimebankMessage,
    isAdmin: sender.id.contains("-"), //timebank id contains "-"
    participants: chatModel.participants,
  );
}
