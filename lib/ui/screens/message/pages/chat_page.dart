import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/image_caption_model.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/feed_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/chat_model_sync_singleton.dart';
import 'package:sevaexchange/ui/screens/message/bloc/parent_community_message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/group_info.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_app_bar.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/feed_shared_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/image_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/chat_bubbles/message_bubble.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_input.dart';
import 'package:sevaexchange/ui/screens/projects/pages/project_chat.dart';
import 'package:sevaexchange/ui/utils/colors.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/camera/camera_page.dart';

import 'create_community_message.dart';

class ChatPage extends StatefulWidget {
  final ChatModel chatModel;
  final bool isAdminMessage;
  final bool isFromRejectCompletion;
  final bool isFromShare;
  final String feedId;
  final String timebankId;
  final String senderId;
  final bool showAppBar;
  final ChatViewContext chatViewContext;

  ChatPage({
    Key key,
    this.chatModel,
    this.isFromRejectCompletion = false,
    this.isFromShare = false,
    this.senderId,
    this.feedId,
    this.isAdminMessage,
    this.showAppBar = true,
    this.chatViewContext = ChatViewContext.UNDEFINED,
    @required this.timebankId,
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
  ChatModel chatModel = ChatModel();
  bool exitFromChatPage = false;
  final profanityDetector = ProfanityDetector();
  bool isProfane = false;
  String errorText = '';
  String timebankId;
  TimebankModel timebankModel;
  @override
  void initState() {
    chatModel = widget.chatModel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isFromRejectCompletion)
        textcontroller.text = '${S.of(context).reject_task_completion} ';
    });

    if (!chatModel.isGroupMessage) {
      recieverId = widget.chatModel.participants[0] != widget.senderId
          ? widget.chatModel.participants[0]
          : widget.chatModel.participants[1];
    }

    //set timebank id if it is timebank message
    if (widget.chatModel.isTimebankMessage) {
      //checking timebank id based on uuid, expect to contain '-';
      timebankId = widget.chatModel.participants
          .firstWhere((element) => element.contains('-'), orElse: () {
        logger.e("timebank id not found");
        return null;
      });
    }

    widget.chatModel.participantInfo.forEach((ParticipantInfo info) {
      participantsInfoById[info.id] = info
        ..color = colorGeneratorFromName(info.name);
    });
    _bloc.getAllMessages(widget.chatModel.id, widget.senderId);
    _scrollController = ScrollController();

    if (widget.isFromShare) {
      pushNewMessage(
        messageContent: widget.feedId,
        type: MessageType.FEED,
      );
    } else {}

    if (widget.chatModel.isGroupMessage) {
      ChatModelSync().chatModels.listen(
        (List<ChatModel> chats) {
          ChatModel model = chats.firstWhere(
            (element) => element.id == widget.chatModel.id,
            orElse: () => null,
          );

          if (model == null) {
            logger.e("chat model is null");
            if (!exitFromChatPage &&
                widget.chatViewContext != ChatViewContext.PROJECT) {
              Navigator.of(context).pop();
            }
          } else {
            model.participantInfo.forEach((ParticipantInfo info) {
              participantsInfoById[info.id] = info
                ..color = colorGeneratorFromName(info.name);
            });

            if (widget.chatModel.groupDetails.name != model.groupDetails.name ||
                widget.chatModel.groupDetails.imageUrl !=
                    model.groupDetails.imageUrl ||
                !listEquals(
                    model.participants, widget.chatModel.participants)) {
              chatModel = model;
              if (this.mounted) setState(() {});
            }
          }
        },
      );
    }
    getTimebank();

    super.initState();
  }

  Future<void> getTimebank() async {
    log('time id ${widget.timebankId} ');
    timebankModel =
        await FirestoreManager.getTimeBankForId(timebankId: widget.timebankId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ParticipantInfo recieverInfo = getUserInfo(
      recieverId ?? '',
      chatModel.participantInfo,
    );

    final bool isGroupMessage = chatModel.isGroupMessage;

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: widget.showAppBar
          ? ChatAppBar(
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
                      String userId =
                          SevaCore.of(context).loggedInUser.sevaUserID;
                      _bloc.removeMember(
                        chatModel.id,
                        userId,
                        chatModel.groupDetails.admins.contains(userId),
                      );
                      exitFromChatPage = true;
                      Navigator.pop(context);
                    }
                  : () {},
              isBlockEnabled:
                  chatModel.isTimebankMessage || chatModel.isGroupMessage,
              openGroupInfo: isGroupMessage ? openGroupInfo : null,
              onProfileImageTap: !isGroupMessage &&
                      timebankModel != null &&
                      !recieverInfo.id.contains('-')
                  ? () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ProfileViewer(
                          timebankId: timebankModel.id,
                          entityName: timebankModel.name,
                          isFromTimebank: isPrimaryTimebank(
                              parentTimebankId: timebankModel.parentTimebankId),
                          userId: recieverInfo.id,
                          userEmail: null,
                        );
                      }));
                    }
                  : null,
            )
          : null,
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _bloc.messages,
              builder: (BuildContext _context,
                  AsyncSnapshot<List<MessageModel>> snapshot) {
                if (snapshot.hasError) {
                  _scrollToBottom();
                  return Text(
                    '${S.of(context).general_stream_error}',
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return LoadingIndicator();
                }

                if (snapshot.data.length == 0) {
                  return Center(
                    child: Text(
                      S.of(context).no_message,
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
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 5),
            child: MessageInput(
              handleSubmitted: (value) {},
              textController: textcontroller,
              errorText: errorText,
              handleChange: (String value) {
                if (value.length < 2) {
                  setState(() {
                    isProfane = false;
                    errorText = '';
                  });
                }
                messageContent = value;
              },
              hintText: S.of(context).type_message,
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
                    textcontroller.text.isNotEmpty) {
                  if (profanityDetector.isProfaneString(textcontroller.text)) {
                    setState(() {
                      isProfane = true;
                      errorText = S.of(context).profanity_text_alert;
                    });
                  } else {
                    setState(() {
                      isProfane = false;
                      errorText = '';
                    });
                    if (widget.isFromRejectCompletion &&
                        (messageContent == null || messageContent.isEmpty)) {
                      messageContent =
                          '${S.of(context).reject_task_completion} ';
                    }
                    pushNewMessage(
                      messageContent: messageContent,
                      type: MessageType.MESSAGE,
                    );
                  }
                }
              },
            ),
          ),
          isProfane
              ? Container(
                  margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorText,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                )
              : Offstage(),
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
      timebankId: timebankId,
    );

    textcontroller.clear();
    _scrollToBottom();
  }

  Widget _getSharedNewDetails({MessageModel messageModel}) {
    var newsModel = _bloc.getNewsModel(messageModel.message);
    if (newsModel != null) {
      logger.i('picking from cache');
      return FeedBubble(
        news: newsModel,
        messageModel: messageModel,
        senderId: widget.senderId,
        isSent: messageModel.fromId == widget.senderId,
      );
    }
    return FutureBuilder<Object>(
      future: FeedsRepository.getFeedFromId(messageModel.message),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(S.of(context).failed_to_load_post);
        }
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Container();
        }

        NewsModel news = snapshot.data;
        _bloc.setNewsModel(news);
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
    if (chatModel.isParentChildCommunication) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateCommunityMessage(
            chatModel: chatModel,
            bloc: ParentCommunityMessageBloc(),
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GroupInfoPage(chatModel: chatModel),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
