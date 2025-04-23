import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart' as io;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as pathExt;
import 'package:path_drawing/path_drawing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/csv_file_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart'
    as invitation_model;
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebanks/timebank_code_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:share_plus/share_plus.dart';

class InviteAddMembers extends StatefulWidget {
  final TimebankModel timebankModel;

  InviteAddMembers(this.timebankModel);

  @override
  State<StatefulWidget> createState() => InviteAddMembersState();
}

class InviteAddMembersState extends State<InviteAddMembers> {
  TimebankCodeModel codeModel = TimebankCodeModel(
    createdOn: 0,
    timebankCode: '',
    timebankId: '',
    validUpto: 0,
    timebankCodeId: '',
    communityId: '',
  );
  TimebankCodeModel? generatedModel;
  final TextEditingController searchTextController = TextEditingController();
  Future<TimebankModel>? getTimebankDetails;
  TimebankModel? timebankModel;

  List<String> validItems = [];
  InvitationManager inivitationManager = InvitationManager();
  bool _isDocumentBeingUploaded = false;

  String? _fileName;
  String? _path;
  final int oneMegaBytes = 1048576;
  BuildContext? parentContext;
  CsvFileModel csvFileModel = CsvFileModel();
  String csvFileError = '';
  String sampleCSVLink =
      "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/csv_files%2Ftemplate.csv?alt=media&token=df33b937-1cb7-425a-862d-acafe4b93d53";
  String? _localPath;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final String samplelink =
      "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/csv_files%2Fumesha%40uipep.com15918788235481000%20Sales%20Records.csv?alt=media&token=d1919180-7e97-4f95-b2e3-6cca1c51c688";

  PageController? pageController;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);

    setup();

    _setTimebankModel();
    getMembersList();
    searchTextController.addListener(() {
      setState(() {});
    });
    initDynamicLinks(context);
    _scrollController = ScrollController()..addListener(() {});
    // setState(() {});
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankModel.id,
    ).then((onValue) {
      setState(() {
        validItems = onValue.listOfElement!;
        logger.i('validItems len ${validItems.length}');
      });
    });
  }

  @override
  void dispose() {
    _scrollController!.dispose(); // dispose the controller
    super.dispose();
  }

  // This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController!
        .animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
  }

  Future<Null> setup() async {
    //_permissionReady = await _checkPermission();
    _localPath =
        (await _findLocalPath()) + io.Platform.pathSeparator + 'Download';
    final savedDir = io.Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }
//  Future<String> _findLocalPath() async {
//    final directory = widget.platform == TargetPlatform.android
//        ? await getExternalStorageDirectory()
//        : await getApplicationDocumentsDirectory();
//    return directory.path;
//  }

  Future<String> _findLocalPath() async {
    io.Directory directory;
    if (io.Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception('Could not get external storage directory');
      }
      directory = dir;
      return directory.parent.parent.parent.parent.path;
    } else {
      directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  void _setTimebankModel() async {
    timebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.timebankModel.id,
    );
  }

  void _requestDownload(String link) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath!,
        fileName: 'template.csv',
        showNotification: true,
        openFileFromNotification: true,
      );

      if (taskId == null) {
      } else {}
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).invite_members,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: FutureBuilder(
            future: getTimebankDetails,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return LoadingIndicator();
              return inviteCodeWidget;
            },
          ),
        ),
      ),
    );
  }

  Widget get inviteCodeWidget {
    return Column(
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
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                hintText: S.of(context).invite_via_email,
                hintStyle: TextStyle(color: Colors.black45, fontSize: 13),
                floatingLabelBehavior: FloatingLabelBehavior.never),
          ),
        ),
        headingTitle(
          S.of(context).members,
        ),
        buildList(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Divider(
            color: Colors.black54,
          ),
        ),
        uploadCSVWidget(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Divider(
            color: Colors.black54,
          ),
        ),
        !widget.timebankModel.private == true
            ? Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  child: Container(
                    height: 25,
                    child: Row(
                      children: <Widget>[
                        Text(
                          S.of(context).invite_via_code,
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
                    _asyncInputDialog(
                        context, SevaCore.of(context).loggedInUser);
                  },
                ),
              )
            : Offstage(),
        !widget.timebankModel.private == true
            ? getTimebankCodesWidget
            : Offstage(),
      ],
    );
  }

  Widget headingTitle(String label) {
    return Container(
      height: 25,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget uploadCSVWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        headingTitle(
          S.of(context).bulk_invite_users_csv,
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(S.of(context).csv_message1),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TransactionsMatrixCheck(
            comingFrom: ComingFrom.Members,
            upgradeDetails: AppConfig.upgradePlanBannerModel!.csv_import_users!,
            transaction_matrix_type: "csv_import_users",
            child: ConfigurationCheck(
              actionType: 'invite_bulk_members',
              role: MemberType.CREATOR,
              child: GestureDetector(
                onTap: () {
                  _openFileExplorer();
                },
                child: Container(
                  height: csvFileModel.csvUrl == null ? 150 : 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: DashPathBorder.all(
                      dashArray:
                          CircularIntervalList<double>(<double>[5.0, 2.5]),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'images/csv_example.png',
                        width: 200,
                      ),
                      Text(
                        S.of(context).choose_csv,
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
                                  child: LoadingIndicator(),
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
                                            csvFileModel.csvTitle ??
                                                S.of(context).document_csv,
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
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            S.of(context).csv_size_limit,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // csvFileModel.csvUrl == null
        //     ? Offstage()
        // :
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            csvFileError,
            style: TextStyle(color: Colors.red),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                height: 40,
                width: 80,
                child: CustomElevatedButton(
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).check_internet),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }
                    if (csvFileModel.csvUrl == null ||
                        csvFileModel.csvUrl == '' ||
                        csvFileModel.csvTitle == '' ||
                        csvFileModel.csvTitle == null ||
                        csvFileModel.csvUrl == null &&
                            csvFileModel.csvTitle == null) {
                      logger.e(
                          'csvFileModel.csvUrl :  ${csvFileModel.csvUrl}\n csvFileModel.csvTitle : ${csvFileModel.csvTitle}');
                      setState(() {
                        this.csvFileError = S.of(context).csv_error;
                      });
                    } else {
                      showProgressDialog(S.of(context).uploading_csv);

                      csvFileModel.timebankId = widget.timebankModel.id;
                      csvFileModel.communityId =
                          SevaCore.of(context).loggedInUser.currentCommunity;
                      csvFileModel.timestamp =
                          DateTime.now().millisecondsSinceEpoch;
                      csvFileModel.sevaUserId =
                          SevaCore.of(context).loggedInUser.sevaUserID;

                      await CollectionRef.csvFiles.add(csvFileModel.toMap());

                      if (dialogContext != null) {
                        Navigator.pop(dialogContext!);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context).uploaded_successfully,
                          ),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      setState(() {
                        this.csvFileError = '';
                        csvFileModel.csvTitle = null;
                        csvFileModel.csvUrl = null;
                      });
                    }
                  },
                  child: Text(
                    S.of(context).upload,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  color: csvFileModel.csvUrl == null ||
                          csvFileModel.csvTitle == null
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2.0,
                  textColor: Colors.white,
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
    String? _fileName;
    String? _path;
    Map<String, String>? _paths;
    try {
      _paths = null;
      var data = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      if (data != null && data.isSinglePick) {
        _path = data.files.first.path;
      }
    } on PlatformException catch (e) {
      logger.e(e);
    }
    //   if (!mounted) return;
    if (_path != null) {
      _fileName = _path.split('/').last;
      String _extension = pathExt.extension(_path).split('?').first;
      if (_extension == 'csv' || _extension == '.csv') {
        userDoc(_path, _fileName);
      } else {
        getExtensionAlertDialog(
            context: context, message: S.of(context).only_csv_allowed);
      }
    }
  }

  Future<void> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    String name =
        SevaCore.of(context).loggedInUser.email! + timestampString + _fileName!;
    Reference ref =
        FirebaseStorage.instance.ref().child('csv_files').child(name);
    UploadTask uploadTask = ref.putFile(
      io.File(_path!),
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'CSV File'},
      ),
    );
    String documentURL = '';

    uploadTask.whenComplete(() async {
      documentURL = await ref.getDownloadURL();
      csvFileModel.csvUrl = documentURL;
      logger.e(
          'csvFileModel.csvUrl :  ${csvFileModel.csvUrl} \n documentURL : ${documentURL}');
    });

    csvFileModel.csvTitle = name;
    setState(() => this._isDocumentBeingUploaded = false);

    // csvFileModel.csvUrl = documentURL;
    // _setAvatarURL();
    // _updateDB();
  }

  void userDoc(String _doc, String fileName) {
    // TODO: implement userDoc
    setState(() {
      this._path = _doc;
      this._fileName = fileName;
      this._isDocumentBeingUploaded = true;
    });
    checkFileSize();
    return null;
  }

  void checkFileSize() async {
    var file = io.File(_path!);
    final bytes = await file.lengthSync();
    if (bytes > oneMegaBytes) {
      this._isDocumentBeingUploaded = false;
      getAlertDialog(parentContext!);
    } else {
      uploadDocument();
    }
  }

  void getAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).large_file_alert),
          content: Text(S.of(context).csv_large_file_message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(S.of(context).close),
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
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchUserInSevaX(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(S.of(context).try_later);
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: LoadingIndicator(),
              ),
            );
          }
          List<UserModel> userlist = snapshot.data ?? [];
          if (userlist.length > 1) {
            userlist.removeWhere((user) =>
                user.sevaUserID ==
                SevaCore.of(context).loggedInUser.sevaUserID);
          }

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
                        "${searchTextController.text} ${S.of(context).not_found}")
                    : Container(),
              ),
            );
          }
          return Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: userlist.length,
                  itemBuilder: (context, index) {
                    return userWidget(
                      user: userlist[index],
                    );
                  }));
        });
  }

  bool isvalidEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (emailPattern.hasMatch(value)) return true;
    return false;
  }
/*
  void requestPermission() async {
    _permissionStatus = await Permission.storage.status;
    if (_permissionStatus.isUndetermined) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      // it should print PermissionStatus.granted

      setState(() {
        _permissionStatus = statuses[Permission.storage];
        requestPermission();
      });
    } else if (_permissionStatus.isGranted) {
      _requestDownload(sampleCSVLink);
    } else if (_permissionStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('upload_csv', 'upload_success'),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } else if (_permissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('upload_csv', 'upload_success'),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }*/

  Widget userInviteWidget({
    String? email,
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
                  title: Text(email!,
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
                            email, timebankModel!.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<InvitationStatus> snapshot) {
                          if (!snapshot.hasData) {
                            return gettigStatus();
                          }
                          var invitationStatus = snapshot.data;
                          if (invitationStatus!.isInvited) {
                            return resendInvitation(
                              invitation: inivitationManager
                                  .getInvitationForEmailFromCache(
                                inviteeEmail: email,
                              ) as InvitationViaLink?,
                            );
                          }
                          return inviteMember(
                            inviteeEmail: email,
                            timebankModel: timebankModel!,
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
    required String? inviteeEmail,
    required TimebankModel timebankModel,
  }) {
    return CustomElevatedButton(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      onPressed: () async {
        inivitationManager.showProgress(
          title: S.of(context).sending_invitation,
        );
        await inivitationManager.inviteMemberToTimebankViaLink(
          // invitation: invitation_model.InvitationViaLink.createInvitation(
          //   timebankTitle: timebankModel!.name,
          //   timebankId: timebankModel.id,
          //   senderEmail: SevaCore.of(context).loggedInUser.email!,
          //   inviteeEmail: inviteeEmail!,
          //   communityId: SevaCore.of(context).loggedInUser.currentCommunity!,
          // ),
          context: context,
        );
        inivitationManager.hideProgress();
        setState(() {});
      },
      child: Text(S.of(context).invite),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  BuildContext? dialogContext;

  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

  Widget resendInvitation({InvitationViaLink? invitation}) {
    return CustomElevatedButton(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      onPressed: () async {
        inivitationManager.showProgress(
            title: S.of(context).sending_invitation);
        await inivitationManager.resendInvitationToMember(
          invitation: invitation,
        );
        inivitationManager.hideProgress();

        setState(() {});
      },
      child: Text(
        S.of(context).resend_invite,
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
    return CustomElevatedButton(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      onPressed: null!,
      child: Text('...'),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  Widget userWidget({
    UserModel? user,
  }) {
    bool isJoined = false;
    if (validItems.contains(user!.sevaUserID!)) {
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
                            image: user.photoURL!,
                          ),
                        )
                      : CircleAvatar(),
                  // onTap: goToNext(snapshot.data),
                  title: Text(user.fullname!,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                  // subtitle: Text(user.email),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomElevatedButton(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        shape: StadiumBorder(),
                        onPressed: !isJoined
                            ? () async {
                                await addMemberToTimebank(
                                        timebankModel: timebankModel!,
                                        sevaUserId: user.sevaUserID!,
                                        timebankId: timebankModel!.id,
                                        communityId: timebankModel!.communityId,
                                        userEmail: user.email!,
                                        userFullName: user.fullname!,
                                        userPhotoURL: user.photoURL!,
                                        timebankTitle: timebankModel!.name,
                                        parentTimebankId:
                                            timebankModel!.parentTimebankId)
                                    .commit();
                                setState(() {
                                  getMembersList();
                                });
                              }
                            : () {},
                        child: Text(
                          isJoined ? S.of(context).joined : S.of(context).add,
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
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
        stream: getTimebankCodes(timebankId: widget.timebankModel.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          List<TimebankCodeModel> codeList = snapshot.data!.reversed.toList();

          if (codeList.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(S.of(context).no_codes_generated),
              ),
            );
          }
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: codeList.length,
              itemBuilder: (context, index) {
                String length = "0";

                TimebankCodeModel timebankCode = codeList.elementAt(index);
                if (timebankCode.usersOnBoarded == null ||
                    timebankCode.usersOnBoarded!.length == 0) {
                  length = S.of(context).not_yet_redeemed;
                } else {
                  length =
                      "${S.of(context).redeemed_by} ${timebankCode.usersOnBoarded!.length} ${S.of(context).user(timebankCode.usersOnBoarded!.length)}";
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
                          Text(
                            S.of(context).timebank_code +
                                timebankCode.timebankCode!,
                          ),
                          Text(length),
                          Text(
                            DateTime.now().millisecondsSinceEpoch >
                                    timebankCode.validUpto!
                                ? S.of(context).expired
                                : S.of(context).active,
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
                                    S.of(context).share_code,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
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
                                        timebankCode.timebankCodeId!);
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
              });
        });
  }

  String shareText(TimebankCodeModel timebankCode) {
    return '''${SevaCore.of(context).loggedInUser.fullname} has invited you to join their "${timebankModel!.name}" Seva Community. Seva means "selfless service" in Sanskrit. Seva Communities are based on a mutual-reciprocity system, where community members help each other out in exchange for Seva Credits that can be redeemed for services they need. To learn more about being a part of a Seva Community, here's a short explainer video. https://youtu.be/xe56UJyQ9ws \n\nHere is what you'll need to know: \nFirst, depending on where you click the link from, whether it's your web browser or mobile phone, the link will either take you to our main https://www.sevaxapp.com web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website, you can explore Seva Communities near you. Type in the "${timebankModel!.name}" and enter code "${timebankCode.timebankCode}" when prompted.\n\nClick to Join ${SevaCore.of(context).loggedInUser.fullname} and their Seva Community via this dynamic link at https://sevaexchange.page.link/sevaxapp.\n\nThank you for being a part of our Seva Exchange movement!\n-the Seva Exchange team\n\nPlease email us at support@sevaexchange.com if you have any questions or issues joining with the link given.
    ''';
  }

  Stream<List<TimebankCodeModel>> getTimebankCodes({
    String? timebankId,
  }) async* {
    var data = CollectionRef.timebankCodes
        .where('timebankId', isEqualTo: timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<TimebankCodeModel>>.fromHandlers(
        handleData: (querySnapshot, timebankCodeSink) {
          List<TimebankCodeModel> timebankCodes = [];
          querySnapshot.docs.forEach((documentSnapshot) {
            timebankCodes.add(TimebankCodeModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>,
            ));
          });
          timebankCodeSink.add(timebankCodes);
        },
      ),
    );
  }

  Future<String?> _asyncInputDialog(
      BuildContext context, UserModel user) async {
    String timebankCode = createCryptoRandomString();

    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).code_generated),
          content: Row(
            children: <Widget>[
              Text(
                timebankCode + " " + S.of(context).is_your_code,
              ),
            ],
          ),
          actions: <Widget>[
            CustomElevatedButton(
              shape: StadiumBorder(),
              elevation: 2.0,
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).primaryColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                S.of(context).publish_code,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () async {
                var today = DateTime.now();
                var oneDayFromToday =
                    today.add(Duration(days: 30)).millisecondsSinceEpoch;
                await registerTimebankCode(
                  timebankCode: timebankCode,
                  timebankId: widget.timebankModel.id,
                  validUpto: oneDayFromToday,
                  communityId: widget.timebankModel.communityId,
                );
                Navigator.of(context).pop("completed");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builderContext) => TimebankCodeWidget(
                      Theme.of(context).primaryColor,
                      timebankCodeModel: codeModel,
                      timebankName: widget.timebankModel.name,
                      user: user,
                    ),
                  ),
                );
              },
            ),
            CustomTextButton(
              color: utils.HexColor("#d2d2d2"),
              textColor: Colors.white,
              child: Text(
                S.of(context).cancel,
                style: TextStyle(fontSize: dialogButtonSize),
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
    var code = base64Url.encode(values).substring(0, 6).toLowerCase();
    return code;
  }

  Future<void> registerTimebankCode({
    String? timebankId,
    String? timebankCode,
    int? validUpto,
    String? communityId,
  }) async {
    codeModel.createdOn = DateTime.now().millisecondsSinceEpoch;
    codeModel.timebankId = timebankId!;
    codeModel.validUpto = validUpto!;
    codeModel.timebankCodeId = utils.Utils.getUuid();
    codeModel.timebankCode = timebankCode!;
    codeModel.communityId = communityId!;

    await CollectionRef.timebankCodes
        .doc(codeModel.timebankCodeId)
        .set(codeModel.toMap());
  }

  void deleteShareCode(String timebankCodeId) {
    CollectionRef.timebankCodes.doc(timebankCodeId).delete();
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  WriteBatch addMemberToTimebank({
    required String sevaUserId,
    required String timebankId,
    required String communityId,
    required String userEmail,
    required String userFullName,
    required String userPhotoURL,
    required String timebankTitle,
    required String parentTimebankId,
    required TimebankModel timebankModel,
  }) {
    WriteBatch batch = CollectionRef.batch;

    var timebankRef = CollectionRef.timebank.doc(timebankId);

    var addToCommunityRef = CollectionRef.communities.doc(communityId);

    var newMemberDocumentReference = CollectionRef.users.doc(userEmail);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankId)
        .collection('entryExitLogs')
        .doc();

    batch.update(timebankRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    batch.update(addToCommunityRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    batch.update(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
    });

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.ADDED_MANUALLY_BY_ADMIN.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': userEmail,
        'id': sevaUserId,
        'fullName': userFullName,
        'photoUrl': userPhotoURL,
      },
      'adminDetails': {
        'email': SevaCore.of(context).loggedInUser.email,
        'id': SevaCore.of(context).loggedInUser.sevaUserID,
        'fullName': SevaCore.of(context).loggedInUser.fullname,
        'photoUrl': SevaCore.of(context).loggedInUser.photoURL,
      },
      'associatedTimebankDetails': {
        'timebankId': timebankId,
        'timebankTitle': timebankTitle,
        'missionStatement': timebankModel.missionStatement,
      },
    });

    sendNotificationToMember(
        communityId: communityId,
        timebankId: timebankId,
        sevaUserId: sevaUserId,
        userEmail: userEmail);

    return batch;
  }

  Future<void> sendNotificationToMember(
      {required String communityId,
      required String sevaUserId,
      required String timebankId,
      required String userEmail}) async {
    UserAddedModel userAddedModel = UserAddedModel(
        timebankImage: timebankModel!.photoUrl,
        timebankName: timebankModel!.name,
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

    await CollectionRef.users
        .doc(userEmail)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());
  }
}

getExtensionAlertDialog({BuildContext? context, String? message}) {
  return showDialog(
    context: context!,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text(S.of(context).extension_alert),
        content: new Text(message!),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new CustomTextButton(
            textColor: Colors.red,
            child: new Text(S.of(context).close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
