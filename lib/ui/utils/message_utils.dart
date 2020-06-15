import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/pages/chat_page.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';

ParticipantInfo getUserInfo(
    String userId, List<ParticipantInfo> participantInfo) {
  return participantInfo.firstWhere((element) => element.id == userId);
}

ParticipantInfo getSenderInfo(
    String userId, List<ParticipantInfo> participantInfo) {
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
  print(
      "-------------------------------------$isFromShare--------------------------------------------");

  List<String> participants = [sender.id, reciever.id];
  participants.sort();
  ChatModel model = ChatModel(
    participants: participants,
    timebankId: timebankId,
    communityId: communityId,
    participantInfo: [sender, reciever],
    isTimebankMessage: isTimebankMessage,
  )
    ..id = "${participants[0]}*${participants[1]}*$communityId"
    ..isGroupMessage = false;

  await createNewChat(chat: model);
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
