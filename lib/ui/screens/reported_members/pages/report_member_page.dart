import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/bloc/report_member_bloc.dart';
import 'package:sevaexchange/widgets/image_picker_widget.dart';

class ReportMemberPage extends StatefulWidget {
  final UserModel reportingUserModel;
  final UserModel reportedUserModel;
  final String timebankId;

  const ReportMemberPage(
      {Key key,
      this.reportingUserModel,
      this.reportedUserModel,
      this.timebankId})
      : super(key: key);

  static Route<dynamic> route(
          {Key key, reportingUserModel, reportedUserModel, timebankId}) =>
      MaterialPageRoute(
        builder: (BuildContext context) => ReportMemberPage(
          key: key,
          reportingUserModel: reportingUserModel,
          reportedUserModel: reportedUserModel,
          timebankId: timebankId,
        ),
      );

  @override
  _ReportMemberPageState createState() => _ReportMemberPageState();
}

class _ReportMemberPageState extends State<ReportMemberPage> {
  final ReportMemberBloc _bloc = ReportMemberBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report Member",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: StreamBuilder<String>(
                stream: _bloc.message,
                builder: (context, snapshot) {
                  return TextField(
                    onChanged: _bloc.onMessageChanged,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      errorText: snapshot.error,
                      hintText: "Reason",
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<File>(
              stream: _bloc.image,
              builder: (context, snapshot) {
                return StreamBuilder<StorageTaskEvent>(
                  stream: _bloc.uploadEvent,
                  builder: (context, uploadEvent) {
                    double progressPercent = uploadEvent.data != null
                        ? uploadEvent.data.snapshot.bytesTransferred /
                            uploadEvent.data.snapshot.totalByteCount
                        : 0;
                    return Container(
                      width: 200,
                      child: ImagePickerWidget(
                        isAspectRatioFixed: false,
                        child: snapshot.data == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.file_upload),
                                  Text("Upload image"),
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      // border: Border.all(color: Colors.black),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: Image.file(snapshot.data),
                                    ),
                                  ),
                                  uploadEvent.data != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          child: Container(
                                            height: 20,
                                            child: LinearProgressIndicator(
                                              backgroundColor: Colors.white,
                                              value: progressPercent,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(height: 8),
                                  FlatButton(
                                    textColor: Colors.red,
                                    child: Text("Remove Image"),
                                    onPressed: () {
                                      _bloc.clearImage();
                                    },
                                  )
                                ],
                              ),
                        onChanged: (File file) {
                          _bloc.uploadImage(
                            file,
                            "${widget.timebankId}*${widget.reportingUserModel.sevaUserID}*${widget.reportedUserModel.sevaUserID}",
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            RaisedButton(
              child: Text("Report"),
              onPressed: () {
                _bloc.createReport();
              },
            )
          ],
        ),
      ),
    );
  }
}
