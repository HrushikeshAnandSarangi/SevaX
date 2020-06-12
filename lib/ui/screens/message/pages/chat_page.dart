import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/image_caption_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/message/bloc/chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_app_bar.dart';
import 'package:sevaexchange/ui/screens/message/widgets/feed_shared_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/image_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_input.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/APi/feed_api.dart';
import 'package:sevaexchange/widgets/camera/camera_page.dart';

class ChatPage extends StatefulWidget {
  final ChatModel chatModel;
  final bool isFromRejectCompletion;
  final bool isFromShare;
  final String feedId;
  final String senderId;

  ChatPage({
    Key key,
    this.chatModel,
    this.isFromRejectCompletion = false,
    this.isFromShare = false,
    this.senderId,
    this.feedId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // UserModel loggedInUser;
  MessageModel messageModel = MessageModel();
  String loggedInEmail;
  final TextEditingController textcontroller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  String messageContent;
  String recieverId;
  final ChatBloc _bloc = ChatBloc();

  @override
  void initState() {
    recieverId = widget.chatModel.participants[0] != widget.senderId
        ? widget.chatModel.participants[0]
        : widget.chatModel.participants[1];

    _bloc.getAllMessages(widget.chatModel.id, widget.senderId);
    _scrollController = ScrollController();

    if (widget.isFromRejectCompletion)
      textcontroller.text =
          '${AppLocalizations.of(context).translate('chat', 'rejecting_becz')} ';

    if (widget.isFromShare) {
      pushNewMessage(
        messageContent: widget.feedId,
        type: MessageType.FEED,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ParticipantInfo recieverInfo = getUserInfo(
      recieverId,
      widget.chatModel.participantInfo,
    );

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: ChatAppBar(
        recieverInfo: recieverInfo,
        clearChat: () {
          _bloc.clearChat(widget.chatModel.id, widget.senderId);
          Navigator.pop(context);
        },
        blockUser: () {
          _bloc.blockMember(
            loggedInUserEmail: SevaCore.of(context).loggedInUser.email,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            blockedUserId: recieverId,
          );
          Navigator.pop(context);
        },
        isTimebankMessage: widget.chatModel.isTimebankMessage,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _bloc.messages,
              builder: (BuildContext context,
                  AsyncSnapshot<List<MessageModel>> snapshot) {
                if (snapshot.hasError) {
                  _scrollToBottom();
                  return Text(
                    '${AppLocalizations.of(context).translate('chat', 'error')}',
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('chat', 'no_messages'),
                    ),
                  );
                }

                if (!widget.chatModel.isTimebankMessage ||
                    widget.senderId ==
                        SevaCore.of(context).loggedInUser.sevaUserID) {
                  _bloc.markMessageAsRead(
                    chatId: widget.chatModel.id,
                    userId: SevaCore.of(context).loggedInUser.sevaUserID,
                  );
                }

                _scrollToBottom();

                return Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, int index) {
                      MessageModel messageModel = snapshot.data[index];
                      print(messageModel.type);
                      switch (messageModel.type) {
                        case MessageType.FEED:
                          return _getSharedNewDetails(
                              messageModel: messageModel);
                          break;
                        case MessageType.MESSAGE:
                          return MessageBubble(
                            message: messageModel.message,
                            isSent: messageModel.fromId == widget.senderId,
                            timestamp: messageModel.timestamp,
                          );
                          break;

                        case MessageType.IMAGE:
                          return ImageBubble(
                            messageModel: messageModel,
                            isSent: messageModel.fromId == widget.senderId,
                          );
                          break;
                        case MessageType.URL:
                          return Container(child: Text("url"));
                          break;
                        default:
                          return Container(child: Text("error"));
                          break;
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MessageInput(
              handleSubmitted: (value) {},
              textController: textcontroller,
              handleChange: (String value) {
                messageContent = value;
              },
              hintText: "Type a message",
              onCameraPressed: () async {
                List<CameraDescription> cameras = await availableCameras();
                Navigator.of(context)
                    .push<ImageCaptionModel>(
                  MaterialPageRoute(
                    builder: (context) => CameraPage(cameras: cameras),
                  ),
                )
                    .then((ImageCaptionModel model) {
                  if (model != null) {
                    log(model.caption);
                    pushNewMessage(
                      messageContent: model.caption.isEmpty
                          ? 'Shared an image'
                          : model.caption,
                      type: MessageType.IMAGE,
                      file: model.file,
                    );
                  }
                });
              },
              onSend: () {
                if (textcontroller.text != null &&
                    textcontroller.text.isNotEmpty)
                  pushNewMessage(
                    messageContent: messageContent,
                    type: MessageType.MESSAGE,
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  pushNewMessage({
    String messageContent,
    MessageType type,
    File file,
  }) {
    _bloc.pushNewMessage(
      chatModel: widget.chatModel,
      messageContent: messageContent,
      senderId: widget.senderId,
      recieverId: recieverId,
      type: type,
      file: file,
    );

    textcontroller.clear();
    _scrollToBottom();
  }

  Widget _getSharedNewDetails({MessageModel messageModel}) {
    return FutureBuilder<Object>(
      future: FeedApi.getFeedFromId(messageModel.message),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              AppLocalizations.of(context).translate('chat', 'couldnt_post'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        NewsModel news = snapshot.data;
        return FeedBubble(
          news: news,
          messageModel: messageModel,
          senderId: widget.senderId,
          isSent: messageModel.fromId == widget.senderId,
        );
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  // void blockMember() {
  //   _bloc.blockMember(
  //     loggedInUserEmail: SevaCore.of(context).loggedInUser.email,
  //     userId: SevaCore.of(context).loggedInUser.sevaUserID,
  //     blockedUserId: recieverId,
  //   )
  //       .then((_) {
  //     var updateUser = SevaCore.of(context).loggedInUser;
  //     var blockedMembers = List<String>.from(updateUser.blockedMembers);
  //     blockedMembers.add(recieverId);
  //     SevaCore.of(context).loggedInUser =
  //         updateUser.setBlockedMembers(blockedMembers);
  //     if (this.mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

}
