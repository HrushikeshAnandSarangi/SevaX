import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/bloc/report_member_bloc.dart';
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
          AppLocalizations.of(context).translate('reported_members', 'reported_member'),
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
              AppLocalizations.of(context).translate('reported_members', 'inform'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('reported_members', 'details'),
            ),
            StreamBuilder<String>(
              stream: _bloc.message,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _bloc.onMessageChanged,
                  focusNode: messageNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorText: snapshot.error,
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
                  return snapshot.data == null
                      ? ImagePickerWidget(
                          isAspectRatioFixed: false,
                          onChanged: (File file) {
                            _bloc.uploadImage(file);
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
                                  "0/1",
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
                return RaisedButton(
                  child: Text(AppLocalizations.of(context).translate('reported_members', 'report'),
                  ),
                  onPressed: isEnabled
                      ? () {
                          _showSnackBar(
                            AppLocalizations.of(context).translate('reported_members', 'reporting_member'),
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
                            _showSnackBar(AppLocalizations.of(context).translate('reported_members', 'success'));
                            Future.delayed(
                              Duration(seconds: 1),
                              () => Navigator.of(context).pop(),
                            );
                          }).catchError((e) {
                            _showSnackBar(AppLocalizations.of(context).translate('reported_members', 'failed'));
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

  void _showSnackBar(String message, {bool isLongDuration = false}) {
    _scaffoldKey.currentState?.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
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
