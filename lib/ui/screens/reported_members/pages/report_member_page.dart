import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/bloc/report_member_bloc.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class ReportMemberPage extends StatefulWidget {
  final UserModel reportingUserModel;
  final UserModel reportedUserModel;
  final String timebankId;
  final String entityName;
  final bool isFromTimebank;

  const ReportMemberPage({
    Key key,
    this.reportingUserModel,
    this.reportedUserModel,
    this.timebankId,
    this.entityName,
    this.isFromTimebank,
  })  : assert(reportedUserModel != null),
        assert(reportedUserModel != null),
        assert(timebankId != null),
        assert(entityName != null),
        assert(isFromTimebank != null),
        super(key: key);

  static Route<dynamic> route({
    Key key,
    UserModel reportingUserModel,
    UserModel reportedUserModel,
    String timebankId,
    String entityName,
    bool isFromTimebank,
  }) =>
      MaterialPageRoute(
        builder: (BuildContext context) => ReportMemberPage(
          key: key,
          reportingUserModel: reportingUserModel,
          reportedUserModel: reportedUserModel,
          timebankId: timebankId,
          entityName: entityName,
          isFromTimebank: isFromTimebank,
        ),
      );

  @override
  _ReportMemberPageState createState() => _ReportMemberPageState();
}

class _ReportMemberPageState extends State<ReportMemberPage> {
  final ReportMemberBloc _bloc = ReportMemberBloc();
  final FocusNode messageNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          S.of(context).report_members,
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20,
        ),
        child: ListView(
          children: <Widget>[
            Text(
              S.of(context).report_member_inform,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              S.of(context).report_member_provide_details,
            ),
            StreamBuilder<String>(
              stream: _bloc.message,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _bloc.onMessageChanged,
                  focusNode: messageNode,
                  decoration: InputDecoration(
                    errorMaxLines: 2,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorText: snapshot.error.toString().contains('profanity')
                        ? S.of(context).profanity_text_alert
                        : snapshot.error,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                );
              },
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder<File>(
                stream: _bloc.image,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {}
                  return snapshot.data == null
                      ? ImagePickerWidget(
                          isAspectRatioFixed: false,
                          onChanged: (File file) {
                            if (file != null) {
                              profanityCheck(file: file, bloc: _bloc);
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            color: Color(0xFF0FAFAFA),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                                Text(
                                  S.of(context).zero_one,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(snapshot.data),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    _bloc.clearImage();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                },
              ),
            ),
            SizedBox(height: 10),
            Divider(thickness: 1),
            StreamBuilder<bool>(
              stream: _bloc.buttonStatus,
              builder: (context, snapshot) {
                bool isEnabled =
                    snapshot.data ?? false; //(snapshot.data?.length ?? 0) > 10;
                return CustomElevatedButton(
                  child: Text(
                    S.of(context).report,
                  ),
                  onPressed: isEnabled
                      ? () {
                          _showSnackBar(
                            S.of(context).reporting_member,
                            isLongDuration: true,
                          );
                          _bloc
                              .createReport(
                            reportedUserModel: widget.reportedUserModel,
                            reportingUserModel: widget.reportingUserModel,
                            timebankId: widget.timebankId,
                            entityName: widget.entityName,
                            isTimebankReport: widget.isFromTimebank,
                          )
                              .then((status) {
                            _showSnackBar(S.of(context).member_reported);
                            Future.delayed(
                              Duration(seconds: 1),
                              () => Navigator.of(context).pop(),
                            );
                          }).catchError((e) {
                            _showSnackBar(
                                S.of(context).member_reporting_failed);
                          });
                        }
                      : null,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> profanityCheck({
    File file,
    ReportMemberBloc bloc,
  }) async {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    // _newsImageURL = imageURL;
    progressDialog.show();

    String filePath = DateTime.now().toString();
    if (file == null) {
      progressDialog.hide();
    }
    UploadTask _uploadTask =
        _storage.ref().child("reports/$filePath.png").putFile(file);
    String imageURL = '';
    _uploadTask.whenComplete(() async {
      imageURL = await _storage.ref().getDownloadURL();
      profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
      if (profanityImageModel == null) {
        progressDialog.hide();

        showFailedLoadImage(context: context).then((value) {});
      } else {
        profanityStatusModel =
            await getProfanityStatus(profanityImageModel: profanityImageModel);

        if (profanityStatusModel.isProfane) {
          progressDialog.hide();

          showProfanityImageAlert(
                  context: context, content: profanityStatusModel.category)
              .then((status) {
            if (status == 'Proceed') {
              deleteFireBaseImage(imageUrl: imageURL).then((value) {
                if (value) {}
              }).catchError((e) => log(e));
            }
          });
        } else {
          deleteFireBaseImage(imageUrl: imageURL).then((value) {
            if (value) {}
          }).catchError((e) => log(e));
          bloc.uploadImage(file);
          progressDialog.hide();
        }
      }
    });
  }

  void _showSnackBar(String message, {bool isLongDuration = false}) {
    ScaffoldMessenger.of(context)?.hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: isLongDuration ? Duration(minutes: 1) : Duration(seconds: 4),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(message),
            isLongDuration
                ? Container(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor,
                      ),
                    ),
                  )
                : Container(height: 0),
          ],
        ),
      ),
    );
  }
}
