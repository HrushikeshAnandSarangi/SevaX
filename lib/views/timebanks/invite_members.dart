import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/csv_file_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:share/share.dart';

class InviteAddMembers extends StatefulWidget {
  final String communityId;
  final String timebankId;
  final TimebankModel timebankModel;
  final TargetPlatform platform;
  InviteAddMembers(
      this.timebankId, this.communityId, this.timebankModel, this.platform);

  @override
  State<StatefulWidget> createState() => InviteAddMembersState();
}

class InviteAddMembersState extends State<InviteAddMembers> {
  TimebankCodeModel codeModel = TimebankCodeModel();
  final TextEditingController searchTextController =
      new TextEditingController();
  Future<TimebankModel> getTimebankDetails;
  TimebankModel timebankModel;
  final _firestore = Firestore.instance;

  var validItems = List<String>();
  InvitationManager inivitationManager = InvitationManager();
  bool _isDocumentBeingUploaded = false;
  File _file;
  List<File> _files;
  String _fileName;
  String _path;
  final int oneMegaBytes = 1048576;
  BuildContext parentContext;
  CsvFileModel csvFileModel = CsvFileModel();
  String csvFileError = '';
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  @override
  void initState() {
    super.initState();
    setup();

    _setTimebankModel();
    getMembersList();
    searchTextController.addListener(() {
      setState(() {});
    });
    initDynamicLinks(context);

    // setState(() {});
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        validItems = onValue;
      });
    });
  }

  Future<Null> setup() async {
    //_permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }
//  Future<String> _findLocalPath() async {
//    final directory = widget.platform == TargetPlatform.android
//        ? await getExternalStorageDirectory()
//        : await getApplicationDocumentsDirectory();
//    return directory.path;
//  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void _setTimebankModel() async {
    timebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );
  }

  void _requestDownload(String link) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
          url: link,
          headers: {"auth": "test_for_sql_encoding"},
          savedDir: _localPath,
          fileName: 'SampleCSV.csv',
          showNotification: true,
          openFileFromNotification: true);
      print("task id ${taskId}");

      if (taskId == null) {
        print('Task is not complete');
      } else {
        print('Task is complete');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? AppLocalizations.of(context)
                  .translate('members', 'yang_yang_codes')
              : AppLocalizations.of(context)
                  .translate('members', 'invite_members'),
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: FutureBuilder(
          future: getTimebankDetails,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            return inviteCodeWidget;
          },
        ),
      ),
    );
  }

  Widget get inviteCodeWidget {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              style: TextStyle(color: Colors.black),
              controller: searchTextController,
              decoration: InputDecoration(
                  suffixIcon: Offstage(
                    offstage: searchTextController.text.length == 0,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        //searchTextController.clear();
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => searchTextController.clear());
                      },
                    ),
                  ),
                  hasFloatingPlaceholder: false,
                  alignLabelWithHint: true,
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 3.0),
                  filled: true,
                  fillColor: Colors.grey[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white),
                    borderRadius: new BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(25.7)),
                  hintText: AppLocalizations.of(context)
                      .translate('members', 'invite_via_email'),
                  hintStyle: TextStyle(color: Colors.black45, fontSize: 13)),
            ),
          ),
          headingTitle(
              AppLocalizations.of(context).translate('members', 'members')),
          buildList(),
          !widget.timebankModel.private == true
              ? Padding(
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                    child: Container(
                      height: 25,
                      child: Row(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)
                                .translate('members', 'invite_via_code'),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Image.asset("lib/assets/images/add.png"),
                        ],
                      ),
                    ),
                    onTap: () async {
                      _asyncInputDialog(context);
                    },
                  ),
                )
              : Offstage(),
          !widget.timebankModel.private == true
              ? getTimebankCodesWidget
              : Offstage(),
        ],
      ),
    );
  }

  Widget headingTitle(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
      child: Container(
        height: 25,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget uploadCSVWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        headingTitle(
            AppLocalizations.of(context).translate('upload_csv', 'csv_title')),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                  text:
                      "${AppLocalizations.of(context).translate('upload_csv', 'csv_hint_one')}  "),
              TextSpan(
                text: AppLocalizations.of(context)
                    .translate('upload_csv', 'csv_hint_two'),
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
              TextSpan(
                  text:
                      "${AppLocalizations.of(context).translate('upload_csv', 'csv_hint_three')}  "),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        RaisedButton(
          onPressed: () async {
            _requestDownload(
                //   "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/news_documents%2Fraj%40yopmail.com1591160274804FAQ.pdf?alt=media&token=fbd08ff3-3686-4168-b3a9-daa875e68ec0");
                // 'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/profile_images%2Fbusiness@uipep.com.jpg?alt=media&token=8ba6d965-ff69-4cb2-9980-035c71d13458');
                "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/csv_files%2Fumesha%40uipep.com15918788235481000%20Sales%20Records.csv?alt=media&token=d1919180-7e97-4f95-b2e3-6cca1c51c688");
          },
          child: Text(
            AppLocalizations.of(context)
                .translate('upload_csv', 'download_csv'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          color: FlavorConfig.values.theme.primaryColor,
          textColor: Colors.white,
          shape: StadiumBorder(),
        ),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () {
            _openFileExplorer();
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: DashPathBorder.all(
                dashArray: CircularIntervalList<double>(<double>[5.0, 2.5]),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/assets/images/csv.png',
                  // color: FlavorConfig.values.theme.primaryColor,
                ),
                Text(
                  AppLocalizations.of(context)
                      .translate('upload_csv', 'choose_csv'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                _isDocumentBeingUploaded
                    ? Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : Container(
                        child: csvFileModel.csvUrl == null
                            ? Offstage()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    leading: Icon(Icons.attachment),
                                    title: Text(
                                      csvFileModel.csvTitle ?? "Document.csv",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () => setState(() {
                                        csvFileModel.csvTitle = null;
                                        csvFileModel.csvUrl = null;
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                      ),
              ],
            ),
          ),
        ),
        Text(
          AppLocalizations.of(context)
              .translate('upload_csv', 'csv_size_limit'),
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          csvFileError,
          style: TextStyle(color: Colors.red),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 30,
                child: RaisedButton(
                  onPressed: () async {
                    if (csvFileModel.csvUrl == null ||
                        csvFileModel.csvTitle == null) {
                      setState(() {
                        this.csvFileError = AppLocalizations.of(context)
                            .translate('upload_csv', 'csv_error');
                      });
                    } else {
                      csvFileModel.timebankId = widget.timebankId;
                      csvFileModel.communityId =
                          SevaCore.of(context).loggedInUser.currentCommunity;
                      csvFileModel.timestamp =
                          DateTime.now().millisecondsSinceEpoch;
                      csvFileModel.sevaUserId =
                          SevaCore.of(context).loggedInUser.sevaUserID;
                      await _firestore
                          .collection('csv_files')
                          .add(csvFileModel.toMap());
                      setState(() {
                        this.csvFileError = '';
                        csvFileModel.csvTitle = '';
                        csvFileModel.csvUrl = '';
                      });
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('upload_csv', 'upload'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  color: Colors.grey[300],
                  shape: StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  void _openFileExplorer() async {
    //  bool _isDocumentBeingUploaded = false;
    //File _file;
    //List<File> _files;
    String _fileName;
    String _path;
    Map<String, String> _paths;
    try {
      _paths = null;
      _path = await FilePicker.getFilePath(
          type: FileType.custom, allowedExtensions: ['csv']);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    //   if (!mounted) return;
    if (_path != null) {
      _fileName = _path.split('/').last;
      print("FIle  name $_fileName");

      userDoc(_path, _fileName);
    }
  }

  Future<String> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('csv_files')
        .child(SevaCore.of(context).loggedInUser.email +
            timestampString +
            _fileName);
    StorageUploadTask uploadTask = ref.putFile(
      File(_path),
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'CSV File'},
      ),
    );
    String documentURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    csvFileModel.csvTitle = _fileName;
    csvFileModel.csvUrl = documentURL;
    // _setAvatarURL();
    // _updateDB();
    return documentURL;
  }

  void userDoc(String _doc, String fileName) {
    // TODO: implement userDoc
    setState(() {
      this._path = _doc;
      this._fileName = fileName;
      this._isDocumentBeingUploaded = true;
    });
    checkPdfSize();

    return null;
  }

  void checkPdfSize() async {
    var file = File(_path);
    final bytes = await file.lengthSync();
    if (bytes > oneMegaBytes) {
      this._isDocumentBeingUploaded = false;
      getAlertDialog(parentContext);
    } else {
      uploadDocument().then((_) {
        setState(() => this._isDocumentBeingUploaded = false);
      });
    }
  }

  getAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('create_feed', 'size_alert_title')),
          content: new Text(AppLocalizations.of(context)
              .translate('upload_csv', 'csv_file_alert')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('help', 'close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildList() {
    if (searchTextController.text.trim().length < 1) {
      return Column(
        children: <Widget>[
          uploadCSVWidget(),
        ],
      );
    }
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchUserInSevaX(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(AppLocalizations.of(context)
                .translate('members', 'please_try_later'));
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            );
          }
          List<UserModel> userlist = snapshot.data;
          if (userlist.length > 1) {
            userlist.removeWhere((user) =>
                user.sevaUserID ==
                SevaCore.of(context).loggedInUser.sevaUserID);
          }

          print("user list ${snapshot.data}");
          print("user  ${userlist}");
          if (userlist.length == 0) {
            if (searchTextController.text.length > 1 &&
                isvalidEmailId(searchTextController.text)) {
              return userInviteWidget(email: searchTextController.text);
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: searchTextController.text.length > 1
                    ? Text(
                        "${searchTextController.text} ${AppLocalizations.of(context).translate('members', 'not_found')}")
                    : Container(),
              ),
            );
          }
          return Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      return userWidget(
                        user: userlist[index],
                      );
                    })),
          );
        });
  }

  bool isvalidEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (emailPattern.hasMatch(value)) return true;
    return false;
  }

  Widget userInviteWidget({
    String email,
  }) {
    inivitationManager.initDialogForProgress(context: context);
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(),
                  title: Text(email,
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w700)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 8),
                      child: FutureBuilder(
                        future: inivitationManager.checkInvitationStatus(
                            email, timebankModel.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<InvitationStatus> snapshot) {
                          if (!snapshot.hasData) {
                            return gettigStatus();
                          }
                          var invitationStatus = snapshot.data;
                          if (invitationStatus.isInvited) {
                            return resendInvitation(
                              invitation: inivitationManager
                                  .getInvitationForEmailFromCache(
                                inviteeEmail: email,
                              ),
                            );
                          }
                          return inviteMember(
                            inviteeEmail: email,
                            timebankModel: timebankModel,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inviteMember({
    String inviteeEmail,
    TimebankModel timebankModel,
  }) {
    return RaisedButton(
      onPressed: () async {
        inivitationManager.showProgress(
            title: AppLocalizations.of(context)
                .translate('members', 'sending_invitation'));
        await inivitationManager.inviteMemberToTimebankViaLink(
          invitation: InvitationViaLink.createInvitation(
            timebankTitle: timebankModel.name,
            timebankId: timebankModel.id,
            senderEmail: SevaCore.of(context).loggedInUser.email,
            inviteeEmail: inviteeEmail,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          ),
          context: context,
        );
        inivitationManager.hideProgress();
        setState(() {});
      },
      child: Text(AppLocalizations.of(context).translate('members', 'invite')),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  void showProgressDialog() {}

  Widget resendInvitation({InvitationViaLink invitation}) {
    return RaisedButton(
      onPressed: () async {
        inivitationManager.showProgress(
            title: AppLocalizations.of(context)
                .translate('members', 'sending_invitation'));
        await inivitationManager.resendInvitationToMember(
          invitation: invitation,
        );
        inivitationManager.hideProgress();

        setState(() {});
      },
      child: Text(
        AppLocalizations.of(context).translate('members', 'resend_invite'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
        ),
      ),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  Widget gettigStatus() {
    return RaisedButton(
      onPressed: null,
      child: Text(AppLocalizations.of(context).translate('members', 'dots')),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  Widget userWidget({
    UserModel user,
  }) {
    bool isJoined = false;
    if (validItems.contains(user.sevaUserID)) {
      isJoined = true;
    }

    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: user.photoURL != null
                      ? ClipOval(
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeIn,
                            fadeInDuration: Duration(milliseconds: 400),
                            fadeOutDuration: Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            placeholder: 'lib/assets/images/noimagefound.png',
                            image: user.photoURL,
                          ),
                        )
                      : CircleAvatar(),
                  // onTap: goToNext(snapshot.data),
                  title: Text(user.fullname,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                  // subtitle: Text(user.email),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: RaisedButton(
                        onPressed: !isJoined
                            ? () async {
                                await addMemberToTimebank(
                                        sevaUserId: user.sevaUserID,
                                        timebankId: timebankModel.id,
                                        communityId: timebankModel.communityId,
                                        userEmail: user.email)
                                    .commit();
                                setState(() {
                                  getMembersList();
                                });
                              }
                            : null,
                        child: Text(isJoined
                            ? AppLocalizations.of(context)
                                .translate('members', 'joined')
                            : AppLocalizations.of(context)
                                .translate('members', 'add')),
                        color: FlavorConfig.values.theme.primaryColor,
                        textColor: Colors.white,
                        shape: StadiumBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get getTimebankCodesWidget {
    return StreamBuilder<List<TimebankCodeModel>>(
        stream: getTimebankCodes(timebankId: widget.timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<TimebankCodeModel> codeList = snapshot.data.reversed.toList();

          if (codeList.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(AppLocalizations.of(context)
                    .translate('members', 'no_codes')),
              ),
            );
          }
          return Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: codeList.length,
                itemBuilder: (context, index) {
                  String length = "0";

                  TimebankCodeModel timebankCode = codeList.elementAt(index);
                  if (timebankCode.usersOnBoarded == null) {
                    length = AppLocalizations.of(context)
                        .translate('members', 'no_yet_redeemed');
                  } else {
                    if (timebankCode.usersOnBoarded.length == 1) {
                      length = AppLocalizations.of(context)
                          .translate('members', 'by_1');
                    } else if (timebankCode.usersOnBoarded.length > 1) {
                      length =
                          "${AppLocalizations.of(context).translate('members', 'by_n')} ${timebankCode.usersOnBoarded.length} ${AppLocalizations.of(context).translate('members', 'users')}";
                    } else {
                      length = AppLocalizations.of(context)
                          .translate('members', 'no_yet_redeemed');
                    }
                  }
                  return GestureDetector(
                    child: Card(
                      margin: EdgeInsets.all(5),
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(FlavorConfig.values.timebankName == "Yang 2020"
                                ? AppLocalizations.of(context)
                                        .translate('members', 'yang_code') +
                                    timebankCode.timebankCode
                                : AppLocalizations.of(context)
                                        .translate('members', 'timebank_code') +
                                    timebankCode.timebankCode),
                            Text(length),
                            Text(
                              DateTime.now().millisecondsSinceEpoch >
                                      timebankCode.validUpto
                                  ? AppLocalizations.of(context)
                                      .translate('members', 'expired')
                                  : AppLocalizations.of(context)
                                      .translate('members', 'active'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Share.share(shareText(timebankCode));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('members', 'share_code'),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    iconSize: 30,
                                    onPressed: () {
                                      deleteShareCode(
                                          timebankCode.timebankCodeId);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
  }

  String shareText(TimebankCodeModel timebankCode) {
    var text =
        "${SevaCore.of(context).loggedInUser.fullname} ${AppLocalizations.of(context).translate('members', 'invited_you')} \"${timebankModel.name}\" ${AppLocalizations.of(context).translate('members', 'invite_text')} \"${timebankCode.timebankCode}\" ${AppLocalizations.of(context).translate('members', 'prompt_text')}";
    return text;
  }

  Stream<List<TimebankCodeModel>> getTimebankCodes({
    String timebankId,
  }) async* {
    var data = Firestore.instance
        .collection('timebankCodes')
        .where('timebankId', isEqualTo: timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<TimebankCodeModel>>.fromHandlers(
        handleData: (querySnapshot, timebankCodeSink) {
          List<TimebankCodeModel> timebankCodes = [];
          querySnapshot.documents.forEach((documentSnapshot) {
            timebankCodes.add(TimebankCodeModel.fromMap(
              documentSnapshot.data,
            ));
          });
          timebankCodeSink.add(timebankCodes);
        },
      ),
    );
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String timebankCode = createCryptoRandomString();

    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('members', 'code_generated')),
          content: new Row(
            children: <Widget>[
              Text(timebankCode +
                  AppLocalizations.of(context).translate('members', 'is_code')),
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                AppLocalizations.of(context)
                    .translate('members', 'publish_code'),
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                var today = new DateTime.now();
                var oneDayFromToday =
                    today.add(new Duration(days: 30)).millisecondsSinceEpoch;
                registerTimebankCode(
                  timebankCode: timebankCode,
                  timebankId: widget.timebankId,
                  validUpto: oneDayFromToday,
                  communityId: widget.communityId,
                );
                Navigator.of(context).pop("completed");
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('shared', 'cancel'),
                style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static String createCryptoRandomString([int length = 10]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(100));
    return base64Url.encode(values).substring(0, 6).toLowerCase();
  }

  Future<void> registerTimebankCode({
    String timebankId,
    String timebankCode,
    int validUpto,
    String communityId,
  }) async {
    codeModel.createdOn = DateTime.now().millisecondsSinceEpoch;
    codeModel.timebankId = timebankId;
    codeModel.validUpto = validUpto;
    codeModel.timebankCodeId = utils.Utils.getUuid();
    codeModel.timebankCode = timebankCode;
    codeModel.communityId = communityId;

    print('codemodel ${codeModel.toString()}');
    await Firestore.instance
        .collection('timebankCodes')
        .document(codeModel.timebankCodeId)
        .setData(codeModel.toMap());
  }

  void deleteShareCode(String timebankCodeId) {
    Firestore.instance
        .collection("timebankCodes")
        .document(timebankCodeId)
        .delete();

    print('deleted');
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  WriteBatch addMemberToTimebank(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) {
    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var addToCommunityRef =
        Firestore.instance.collection('communities').document(communityId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(userEmail);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    batch.updateData(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
    });

    batch.updateData(addToCommunityRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    sendNotificationToMember(
        communityId: communityId,
        timebankId: timebankId,
        sevaUserId: sevaUserId,
        userEmail: userEmail);

    return batch;
  }

  Future<void> sendNotificationToMember(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) async {
    UserAddedModel userAddedModel = UserAddedModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        adminName: SevaCore.of(context).loggedInUser.fullname);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: userAddedModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberAdded,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: sevaUserId);

    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
  }
}
