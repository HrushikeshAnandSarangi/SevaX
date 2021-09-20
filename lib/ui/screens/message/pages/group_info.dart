import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/edit_group_info_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_new_chat_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/camera_icon.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class GroupInfoPage extends StatefulWidget {
  final ChatModel chatModel;
  final TimebankModel timebankModel;

  GroupInfoPage({Key key, this.chatModel, this.timebankModel}) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfoPage> {
  final TextEditingController _controller = TextEditingController();
  final _bloc = EditGroupInfoBloc();
  ChatModel chatModel;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  @override
  void initState() {
    chatModel = widget.chatModel;
    _bloc.onGroupNameChanged(chatModel.groupDetails.name);
    _bloc.addCurrentParticipants(List<String>.from(chatModel.participants.map((x) => x)));
    _bloc.addParticipants(
      chatModel.participantInfo
          .where(
            (p) => chatModel.participants.contains(p.id),
          )
          .toList(),
    );
    _bloc.onImageChanged(
      MessageRoomImageModel(
        stockImageUrl: chatModel.groupDetails.imageUrl,
      ),
    );

    log('memberslenth  ${_bloc.currentParticipantsList.length}');
    super.initState();
  }

  BuildContext dialogContext;
  @override
  Widget build(BuildContext context) {
    final bool isAdmin =
        chatModel.groupDetails.admins.contains(SevaCore.of(context).loggedInUser.sevaUserID);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          "${chatModel.groupDetails.name}",
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          Offstage(
            offstage: !isAdmin,
            child: CustomTextButton(
              child: Text(
                S.of(context).save,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext mContext) {
                    dialogContext = mContext;

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Text(
                        S.of(context).updating_messaging_room,
                      ),
                    );
                  },
                );
                _bloc
                    .editGroupDetails(
                        widget.chatModel.id, context, SevaCore.of(context).loggedInUser)
                    .then(
                  (value) {
                    if (value) {
                      Navigator.of(dialogContext).pop();

                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: StreamBuilder<MessageRoomImageModel>(
                    stream: _bloc.image,
                    builder: (context, snapshot) {
                      return AbsorbPointer(
                        absorbing: !isAdmin,
                        child: ImagePickerWidget(
                            child: snapshot.data == null && chatModel.groupDetails.imageUrl == null
                                ? CameraIcon(radius: 35)
                                : Container(
                                    width: 70,
                                    height: 70,
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(),
                                    ),
                                    child: ClipOval(
                                      child: snapshot.data != null
                                          ? snapshot.data.stockImageUrl != null
                                              ? Image.network(snapshot.data.stockImageUrl)
                                              : snapshot.data.selectedImage != null
                                                  ? Image.file(
                                                      snapshot.data.selectedImage,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CameraIcon(radius: 35)
                                          : CustomNetworkImage(
                                              chatModel.groupDetails.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                            onStockImageChanged: (String stockImageUrl) {
                              if (stockImageUrl != null) {
                                _bloc.onImageChanged(
                                    MessageRoomImageModel(stockImageUrl: stockImageUrl));
                              }
                            },
                            onChanged: (file) {
                              if (file != null) {
                                profanityCheck(file: file, bloc: _bloc);
                              }
                            }),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(),
                      StreamBuilder<String>(
                        stream: _bloc.groupName,
                        builder: (context, snapshot) {
                          _controller.value = _controller.value.copyWith(
                            composing: TextRange(start: 0, end: 0),
                            text: snapshot.data,
                          );
                          return TextField(
                            enabled: isAdmin,
                            controller: _controller,
                            onChanged: _bloc.onGroupNameChanged,
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorText: snapshot.error.toString().contains('profanity')
                                  ? S.of(context).profanity_text_alert
                                  : snapshot.error,
                              hintText: S.of(context).messaging_room_name,
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            Container(
              height: 30,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "${S.of(context).participants}: ${chatModel.participants.length ?? 0} OF 256",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Offstage(
              offstage: !isAdmin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute<List<ParticipantInfo>>(
                        builder: (context) => CreateNewChatPage(
                          isSelectionEnabled: true,
                          selectedMembers: List.generate(
                              _bloc.participantsList.length, (i) => _bloc.participantsList[i].id)
                            ..remove(
                              SevaCore.of(context).loggedInUser.sevaUserID,
                            ),
                          frequentContacts: [],
                        ),
                      ),
                    )
                        .then(
                      (List<ParticipantInfo> participantInfo) {
                        if (participantInfo != null) {
                          _bloc.addParticipants(
                            participantInfo
                              ..add(
                                ParticipantInfo(
                                  id: SevaCore.of(context).loggedInUser.sevaUserID,
                                  name: SevaCore.of(context).loggedInUser.fullname,
                                  photoUrl: SevaCore.of(context).loggedInUser.photoURL,
                                  type: ChatType.TYPE_MULTI_USER_MESSAGING,
                                ),
                              ),
                          );
                        }
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo[50],
                          foregroundColor: Theme.of(context).primaryColor,
                          child: Icon(Icons.add),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                S.of(context).add_participants,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: StreamBuilder<Object>(
                stream: _bloc.participants,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  return GroupMemberBuilder(
                    participants: snapshot.data,
                    isAdmin: chatModel.groupDetails.admins
                        .contains(SevaCore.of(context).loggedInUser.sevaUserID),
                    onRemovePressed: _bloc.removeMember,
                    timebankModel: widget.timebankModel,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> profanityCheck({
    File file,
    EditGroupInfoBloc bloc,
  }) async {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();

    // _newsImageURL = imageURL;
    String filePath = DateTime.now().toString();
    if (file == null) {
      progressDialog.hide();
    }
    String imageUrl =
        file != null ? await StorageRepository.uploadFile("multiUserMessagingLogo", file) : null;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageUrl);
    if (profanityImageModel == null) {
      progressDialog.hide();

      showFailedLoadImage(context: context).then((value) {});
    } else {
      profanityStatusModel = await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        progressDialog.hide();

        showProfanityImageAlert(context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            deleteFireBaseImage(imageUrl: imageUrl).then((value) {
              if (value) {}
            }).catchError((e) => log(e));
          }
        });
      } else {
        deleteFireBaseImage(imageUrl: imageUrl).then((value) {
          if (value) {}
        }).catchError((e) => log(e));
        bloc.onImageChanged(MessageRoomImageModel(selectedImage: file));
        progressDialog.hide();
      }
    }
  }
}
