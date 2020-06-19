import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/camera_icon.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class CreateGroupPage extends StatelessWidget {
  final CreateChatBloc bloc;
  final TextEditingController _controller = TextEditingController();

  CreateGroupPage({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool showLoadingDialog = false;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          "New Multi-User Messaging",
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Create",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onPressed: () {
              BuildContext viewContext;
              if (showLoadingDialog) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    viewContext = context;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Text("Creating Multi-User Messaging..."),
                    );
                  },
                );
              }
              bloc
                  .createMultiUserMessaging(SevaCore.of(context).loggedInUser)
                  .then((ChatModel model) {
                if (model != null) {
                  Navigator.of(viewContext).pop();
                  Navigator.of(context).pop(model);
                }
              });
            },
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
                    stream: bloc.selectedImage,
                    builder: (context, snapshot) {
                      return ImagePickerWidget(
                        child: snapshot.data == null
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
                                  child: Image.file(
                                    snapshot.data,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        onChanged: bloc.onImageChanged,
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
                        stream: bloc.groupName,
                        builder: (context, snapshot) {
                          _controller.value = _controller.value.copyWith(
                            text: snapshot.data,
                          );
                          if (_controller.text != null &&
                              _controller.text.length > 0) {
                            showLoadingDialog = true;
                          }
                          return TextField(
                            controller: _controller,
                            onChanged: bloc.onGroupNameChanged,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorText: snapshot.error,
                              hintText: "Multi-User Messaging Name",
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(),
                      Text(
                        "Please provide a multi-user messaging \nsubject and optional group icon.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            StreamBuilder<List<String>>(
                stream: bloc.selectedMembers,
                builder: (context, snapshot) {
                  return Container(
                    height: 30,
                    width: double.infinity,
                    color: Colors.grey[300],
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "PARTICIPANTS: ${snapshot.data?.length ?? 0} OF 256",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SelectedMemberWrapBuilder(bloc: bloc),
            ),
          ],
        ),
      ),
    );
  }
}
