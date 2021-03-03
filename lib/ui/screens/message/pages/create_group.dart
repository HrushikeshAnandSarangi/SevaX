import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/repositories/storage_repository.dart';
import 'package:sevaexchange/ui/screens/message/bloc/create_chat_bloc.dart';
import 'package:sevaexchange/ui/screens/message/widgets/selected_member_list_builder.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/camera_icon.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class CreateGroupPage extends StatelessWidget {
  final CreateChatBloc bloc;
  final TextEditingController _controller = TextEditingController();

  CreateGroupPage({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Map validationString = {
      'profanity': S.of(context).profanity_text_alert,
      'validation_error_room_name': S.of(context).validation_error_general_text
    };
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          S.of(context).new_message_room,
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              S.of(context).create,
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
                      S.of(context).creating_messaging_room,
                    ),
                  );
                },
              );

              bloc
                  .createMultiUserMessaging(
                      SevaCore.of(context).loggedInUser, context)
                  .then((
                ChatModel model,
              ) {
                Navigator.of(context, rootNavigator: true).pop();
                if (model != null) {
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
                  child: StreamBuilder<MessageRoomImageModel>(
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
                                  child: snapshot.data.selectedImage == null
                                      ? Image.network(
                                          snapshot.data.stockImageUrl ??
                                              defaultGroupImageURL)
                                      : Image.file(
                                          snapshot.data.selectedImage,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                        onStockImageChanged: (String stockImageUrl) {
                          if (stockImageUrl != null) {
                            bloc.onImageChanged(MessageRoomImageModel(
                                stockImageUrl: stockImageUrl));
                          }
                        },
                        onChanged: (file) {
                          if (file != null) {
                            profanityCheck(
                                bloc: bloc, file: file, context: context);
                          }
                        },
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

                          return TextField(
                            controller: _controller,
                            onChanged: bloc.onGroupNameChanged,
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorText:
                                  validationString.containsKey(snapshot.error)
                                      ? validationString[snapshot.error]
                                      : null,
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
                      Text(
                        S.of(context).messaging_room_note,
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
                      "${S.of(context).participants}: ${snapshot.data?.length ?? 0} OF 256",
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

  Future<void> profanityCheck({
    File file,
    CreateChatBloc bloc,
    BuildContext context,
  }) async {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();

    if (file == null) {
      progressDialog.hide();
    }
    String imageUrl = file != null
        ? await StorageRepository.uploadFile("multiUserMessagingLogo", file)
        : null;
    var profanityImageModel = await checkProfanityForImage(imageUrl: imageUrl);
    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {});
    } else {
      var profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        progressDialog.hide();

        showProfanityImageAlert(
                context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            FirebaseStorage.instance
                .getReferenceFromUrl(imageUrl)
                .then((reference) {
              reference.delete();
            }).catchError((e) => logger.e(e));
          }
        });
      } else {
        FirebaseStorage.instance
            .getReferenceFromUrl(imageUrl)
            .then((reference) {
          reference.delete();
        }).catchError((e) => logger.e(e));
        bloc.onImageChanged(MessageRoomImageModel(selectedImage: file));
        progressDialog.hide();
      }
    }
  }
}
