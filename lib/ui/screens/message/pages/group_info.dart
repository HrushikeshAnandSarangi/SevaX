import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/edit_group_info_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/create_new_chat_page.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/camera_icon.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class GroupInfoPage extends StatefulWidget {
  final ChatModel chatModel;

  GroupInfoPage({Key key, this.chatModel}) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfoPage> {
  final TextEditingController _controller = TextEditingController();
  final _bloc = EditGroupInfoBloc();
  ChatModel chatModel;

  @override
  void initState() {
    chatModel = widget.chatModel;
    _bloc.onGroupNameChanged(chatModel.groupDetails.name);
    _bloc.addParticipants(chatModel.participantInfo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = chatModel.groupDetails.admins
        .contains(SevaCore.of(context).loggedInUser.sevaUserID);
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
            child: FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('messages', 'save'),
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Text(
                        AppLocalizations.of(context).translate(
                          'messages',
                          'updating_multi_user_messaging',
                        ),
                      ),
                    );
                  },
                );
                _bloc.editGroupDetails(widget.chatModel.id).then(
                  (_) {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
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
                  child: StreamBuilder<File>(
                    stream: _bloc.image,
                    builder: (context, snapshot) {
                      return AbsorbPointer(
                        absorbing: !isAdmin,
                        child: ImagePickerWidget(
                          child: snapshot.data == null &&
                                  chatModel.groupDetails.imageUrl == null
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
                                        ? Image.file(
                                            snapshot.data,
                                            fit: BoxFit.cover,
                                          )
                                        : CustomNetworkImage(
                                            chatModel.groupDetails.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                          onChanged: _bloc.onImageChanged,
                        ),
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
                            text: snapshot.data,
                          );
                          return TextField(
                            enabled: isAdmin,
                            controller: _controller,
                            onChanged: _bloc.onGroupNameChanged,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorText: snapshot.error,
                              hintText: AppLocalizations.of(context).translate(
                                  'messages', 'multi_user_messaging_name'),
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
                "${AppLocalizations.of(context).translate('messages', 'participants')}: ${chatModel.participants.length ?? 0} OF 256",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Offstage(
              offstage: !isAdmin,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute<List<ParticipantInfo>>(
                        builder: (context) => CreateNewChatPage(
                          isSelectionEnabled: true,
                          selectedMembers: List.generate(
                              _bloc.participantsList.length,
                              (i) => _bloc.participantsList[i].id)
                            ..remove(
                              SevaCore.of(context).loggedInUser.sevaUserID,
                            ),
                          frequentContacts: [],
                        ),
                      ),
                    )
                        .then(
                      (List<ParticipantInfo> participantInfo) {
                        if (participantInfo != null)
                          _bloc.addParticipants(
                            participantInfo
                              ..add(
                                ParticipantInfo(
                                  id: SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID,
                                  name: SevaCore.of(context)
                                      .loggedInUser
                                      .fullname,
                                  photoUrl: SevaCore.of(context)
                                      .loggedInUser
                                      .photoURL,
                                ),
                              ),
                          );
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
                                AppLocalizations.of(context)
                                    .translate('messages', 'add_participants'),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
