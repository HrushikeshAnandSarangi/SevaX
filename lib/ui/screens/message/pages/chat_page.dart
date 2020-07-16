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
import 'package:sevaexchange/ui/screens/message/bloc/chat_model_sync_singleton.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_info.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_app_bar.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/feed_shared_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/image_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/message_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_input.dart';
import 'package:sevaexchange/ui/utils/colors.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/APi/feed_api.dart';
import 'package:sevaexchange/widgets/camera/camera_page.dart';

class ChatPage extends StatefulWidget {
  final ChatModel chatModel;
  final bool isAdminMessage;
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
    this.isAdminMessage,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  MessageModel messageModel = MessageModel();
  String loggedInEmail;
  final TextEditingController textcontroller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String messageContent;
  String recieverId;
  final ChatBloc _bloc = ChatBloc();
  Map<String, ParticipantInfo> participantsInfoById = {};
  ChatModel chatModel;
  bool exitFromChatPage = false;

  @override
  void initState() {
    chatModel = widget.chatModel;
    recieverId = chatModel.participants[0] != widget.senderId
        ? chatModel.participants[0]
        : chatModel.participants[1];

    chatModel.participantInfo.forEach((ParticipantInfo info) {
      participantsInfoById[info.id] = info
        ..color = colorGeneratorFromName(info.name);
    });

    _bloc.getAllMessages(chatModel.id, widget.senderId);
    _scrollController = ScrollController();

    if (widget.isFromRejectCompletion)
      textcontroller.text =
          '${AppLocalizations.of(context).translate('chat', 'rejecting_becz')} ';

    if (widget.isFromShare) {
      print("Pushing new message from share");
      pushNewMessage(
        messageContent: widget.feedId,
        type: MessageType.FEED,
      );
    } else {
      print("NOT Pushing new message from share");
    }

    if (widget.chatModel.isGroupMessage) {
      ChatModelSync().chatModels.listen(
        (List<ChatModel> chats) {
          ChatModel model = chats.firstWhere(
            (element) => element.id == widget.chatModel.id,
            orElse: () => null,
          );

          if (model == null) {
            if (!exitFromChatPage) {
              print("called  $exitFromChatPage");
              Navigator.of(context).pop();
            }
          } else {
            model.participantInfo.forEach((ParticipantInfo info) {
              participantsInfoById[info.id] = info
                ..color = colorGeneratorFromName(info.name);
            });

            if (chatModel.groupDetails.name != model.groupDetails.name ||
                chatModel.groupDetails.imageUrl !=
                    model.groupDetails.imageUrl) {
              chatModel = model;
              if (this.mounted) setState(() {});
            }
          }
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ParticipantInfo recieverInfo = getUserInfo(
      recieverId,
      chatModel.participantInfo,
    );

    final bool isGroupMessage = chatModel.isGroupMessage;

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: ChatAppBar(
        isGroupMessage: isGroupMessage,
        recieverInfo: isGroupMessage ? null : recieverInfo,
        groupDetails: isGroupMessage ? chatModel.groupDetails : null,
        clearChat: () {
          exitFromChatPage = true;
          _bloc.clearChat(chatModel.id, widget.senderId);
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
        exitGroup: isGroupMessage
            ? () {
                String userId = SevaCore.of(context).loggedInUser.sevaUserID;
                _bloc.removeMember(
                  chatModel.id,
                  userId,
                  chatModel.groupDetails.admins.contains(userId),
                );
                Navigator.pop(context);
              }
            : () {},
        isBlockEnabled: chatModel.isTimebankMessage || chatModel.isGroupMessage,
        openGroupInfo: isGroupMessage ? openGroupInfo : null,
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

                if (!chatModel.isTimebankMessage ||
                    widget.senderId ==
                        SevaCore.of(context).loggedInUser.sevaUserID) {
                  _bloc.markMessageAsRead(
                    chatId: chatModel.id,
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
                            isGroupMessage: chatModel.isGroupMessage,
                            info: chatModel.isGroupMessage
                                ? participantsInfoById[messageModel.fromId]
                                : null,
                          );
                          break;

                        case MessageType.IMAGE:
                          return ImageBubble(
                            messageModel: messageModel,
                            isSent: messageModel.fromId == widget.senderId,
                            isGroupMessage: chatModel.isGroupMessage,
                            info: chatModel.isGroupMessage
                                ? participantsInfoById[messageModel.fromId]
                                : null,
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
              hintText: AppLocalizations.of(context)
                  .translate('messages', 'type_message'),
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

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController?.position?.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void pushNewMessage({
    String messageContent,
    MessageType type,
    File file,
  }) {
    _bloc.pushNewMessage(
      chatModel: chatModel,
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

  void openGroupInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupInfoPage(chatModel: chatModel),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
