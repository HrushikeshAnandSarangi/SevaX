import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/utils/data_managers/new_chat_manager.dart';
import 'package:sevaexchange/views/messages/chatview.dart';

ParticipantInfo getSenderInfo(
    String senderId, List<ParticipantInfo> participantInfo) {
  return participantInfo.firstWhere((element) => element.id == senderId);
}

Future<void> createAndOpenChat({
  BuildContext context,
  ParticipantInfo sender,
  ParticipantInfo reciever,
  String timebankId,
  String communityId,
  bool isFromRejectCompletion = false,
  bool isTimebankMessage = false,
  bool isFromShare,
  NewsModel news,
  IsFromNewChat isFromNewChat,
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
  );

  await createNewChat(chat: model);
  if (onChatCreate != null) {
    onChatCreate();
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatView(
        news: news,
        isFromShare: isFromShare,
        senderId: sender.id,
        chatModel: model,
        isFromRejectCompletion: isFromRejectCompletion,
        isFromNewChat: isFromNewChat,
      ),
    ),
  );
}

// Future<void> createAndOpenTimebankChat({
//   BuildContext context,
//   String sender,
//   UserModel reciever,
//   String communityId,
//   bool isFromRejectCompletion = false,
//   MessageType type = MessageType.TYPE_PERSONAL,
// }) async {
//   List<String> participants = [sender, reciever.sevaUserID];
//   participants.sort();
//   ChatModel model = ChatModel(
//     participants: participants,
//     timebankId: sender,
//     communityId: communityId,
//     participantInfo: [
//       ParticipantInfo(
//         id: reciever.sevaUserID,
//         name: reciever.fullname,
//         photoUrl: reciever.photoURL,
//         type: MessageType.TYPE_TIMEBANK,
//       ),
//       ParticipantInfo(
//         id: sender,
//         // name: sender.name,
//         // photoUrl: sender.photoUrl,
//         type: MessageType.TYPE_TIMEBANK,
//       ),
//     ],
//   );

//   await createNewChat(chat: model);

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ChatView(
//         senderId: sender,
//         chatModel: model,
//         isFromRejectCompletion: isFromRejectCompletion,
//       ),
//     ),
//   );
// }
