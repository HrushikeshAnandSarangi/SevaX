import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/model/share_feed_models.dart';
import 'package:sevaexchange/utils/helpers/projects_helper_util.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ShareMessageManager {
  Future<void> assembleMembersDataForSharingFeed({
    UserModel? sender,
    List<UserModel>? selectedMembers,
    String? communityId,
    String? messageContent,
  }) async {
    WriteBatch shareMessagesBatch = CollectionRef.batch;
    var chatsReference = CollectionRef.chats;
    selectedMembers?.forEach((receiver) {
      var individualMessage = _getChatModelForShare(
        communityId: communityId ?? '',
        messageContent: messageContent ?? '',
        sender: ParticipantInfo(
          id: sender!.sevaUserID,
          name: sender.fullname,
          photoUrl: sender.photoURL,
          type: ChatType.TYPE_PERSONAL,
        ),
        reciever: ParticipantInfo(
          id: receiver.sevaUserID,
          name: receiver.fullname,
          photoUrl: receiver.photoURL,
          type: ChatType.TYPE_PERSONAL,
        ),
      );

      shareMessagesBatch.set(
        chatsReference.doc(individualMessage.chatModel!.id),
        individualMessage.chatModel!.shareMessage(
          unreadStatus: {
            receiver.sevaUserID ?? '': FieldValue.increment(1),
          },
        ),
      );

      shareMessagesBatch.set(
        chatsReference
            .doc(individualMessage.chatModel!.id)
            .collection('messages')
            .doc(), //removed uuid // autogenerated by firebase
        individualMessage.messageModel!.toMap(),
      );

      logger.i(
          "Successfully created messages with id as -> ${individualMessage.chatModel!.id}");
    });

    await shareMessagesBatch
        .commit()
        .then((value) => logger.i("Successfully created messages with"))
        .catchError((onError) => logger
            .i("CAUSE DEFEATED =========== ISSUE ===== ${onError.toString()}"));
  }

  ShareFeedModel _getChatModelForShare({
    required ParticipantInfo sender,
    required ParticipantInfo reciever,
    required String communityId,
    required String messageContent,
  }) {
    List<String> participants = [sender.id ?? '', reciever.id ?? ''];
    participants.sort();
    var chatModel = ChatModel(
      lastMessage: messageContent,
      participants: participants,
      communityId: communityId,
      participantInfo: [sender, reciever],
      isTimebankMessage: false,
      chatContext: ChatContext(
        chatContext: 'Feed',
        contextId: messageContent,
      ),
    )
      ..id = "${participants[0]}*${participants[1]}*$communityId"
      ..isGroupMessage = false;

    var messageModel = MessageModel(
      type: MessageType.FEED,
      fromId: sender.id,
      toId: reciever.id,
      message: messageContent,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    return ShareFeedModel(
      chatModel: chatModel,
      messageModel: messageModel,
    );
  }
}
