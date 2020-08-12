import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/onboarding/skills_view.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globals.dart' as globals;
import '../core.dart';

class EditProfilePage extends StatefulWidget {
  UserModel userModel;

  EditProfilePage({this.userModel});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _firestore = Firestore.instance;

  bool _shouldObscure = true;
  bool _isLoading = false;

  String fullName;
  String password;
  String email;
  String imageUrl;
  String confirmPassword;
  File selectedImage;
  String isImageSelected = 'Add Photo';
  ImagePickerHandler imagePicker;
  UserModel usermodel;
  bool _saving = false;
  bool _isDocumentBeingUploaded = false;
  final int tenMegaBytes = 10485760;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  String _fileName;
  String _path;
  String cvName;
  String cvUrl;
  String cvFileError = '';
  bool canuploadCV = false;

  BuildContext parentContext;
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    this.usermodel = widget.userModel;
    if (usermodel.cvUrl == null) {
      setState(() {
        this.canuploadCV = true;
      });
    }
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('profile', 'title'),
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: ListView(
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),

                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.zero,
                        child: _imagePicker,
                      ),
                      Positioned(
                        width: 50,
                        height: 50,
                        right: 5.0,
                        bottom: 5.0,
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: () {
                            imagePicker.showDialog(context);
                            isLoading = false;
                          },
                        ),
                      ),
                    ],
                  ),
                  //registerButton,
                ],
              ),
            ),
            SizedBox(height: 50),
            detailsBuilder(
              title: AppLocalizations.of(context).translate('profile', 'name'),
              text: widget.userModel.fullname,
              onTap: _updateName,
            ),
            detailsBuilder(
              title: AppLocalizations.of(context).translate('profile', 'bio'),
              text: widget.userModel.bio ??
                  AppLocalizations.of(context).translate('profile', 'add_bio'),
              onTap: _updateBio,
            ),
            detailsBuilder(
              title: AppLocalizations.of(context)
                  .translate('profile', 'interests'),
              text: AppLocalizations.of(context)
                  .translate('profile', 'add_interests'),
              onTap: () => _navigateToInterestsView(usermodel),
            ),
            detailsBuilder(
              title:
                  AppLocalizations.of(context).translate('profile', 'skills'),
              text: AppLocalizations.of(context)
                  .translate('profile', 'add_skills'),
              onTap: () => _navigateToSkillsView(usermodel),
            ),
            cvBuilder(
              title: AppLocalizations.of(context).translate('cv', 'cv'),
              text: AppLocalizations.of(context).translate('cv', 'cv_info'),
              onTap: () => _openFileExplorer(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3.5,
                vertical: 20,
              ),
              child: Container(
                width: 134,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                    AppLocalizations.of(context).translate('profile', 'logout'),
                  ),
                  onPressed: logOut,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding detailsBuilder({String title, String text, Function onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(text ?? ""),
            SizedBox(height: 5),
            Divider(
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Padding cvBuilder({String title, String text, Function onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              text ?? "",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            canuploadCV
                ? cvUpload()
                : Row(
                    children: [
                      Container(
                        decoration: ShapeDecoration(
                          color: Colors.grey[200],
                          shape: StadiumBorder(),
                        ),
                        height: 40,
                        width: 180,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  usermodel.cvName ?? 'CV not available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  var connResult =
                                      await Connectivity().checkConnectivity();
                                  if (connResult == ConnectivityResult.none) {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)
                                                .translate('shared',
                                                    'check_internet')),
                                        action: SnackBarAction(
                                          label: AppLocalizations.of(context)
                                              .translate('shared', 'dismiss'),
                                          onPressed: () => _scaffoldKey
                                              .currentState
                                              .hideCurrentSnackBar(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (await canLaunch(usermodel.cvUrl)) {
                                    launch(usermodel.cvUrl);
                                  } else {
                                    print('could not launch url');
                                  }
                                },
                                icon: Icon(
                                  Icons.save_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        height: 35,
                        width: 105,
                        child: Center(
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('cv', 'replace_cv'),
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              setState(() {
                                this.canuploadCV = true;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Widget cvUpload({String title, String text, Function onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
                  'lib/assets/images/cv.png',
                  height: 50,
                  width: 50,
                  color: FlavorConfig.values.theme.primaryColor,
                ),
                Text(
                  AppLocalizations.of(context).translate('cv', 'choose_pdf'),
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
                        child: cvUrl == null
                            ? Offstage()
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    leading: Icon(Icons.attachment),
                                    title: Text(
                                      cvName ?? "cv not available",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () => setState(() {
                                        cvName = null;
                                        cvUrl = null;
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
          AppLocalizations.of(context).translate('cv', 'size_limit'),
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          cvFileError,
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
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)
                              .translate('shared', 'check_internet')),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)
                                .translate('shared', 'dismiss'),
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }
                    if (cvUrl == null ||
                        cvUrl == '' ||
                        cvName == '' ||
                        cvName == null) {
                      setState(() {
                        this.cvFileError = AppLocalizations.of(context)
                            .translate('cv', 'cv_error');
                      });
                    } else {
                      await updateCV();
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)
                                .translate('upload_csv', 'upload_success'),
                          ),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)
                                .translate('shared', 'dismiss'),
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      setState(() {
                        this.cvFileError = '';
                        this.canuploadCV = false;
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

  Future _navigateToInterestsView(UserModel loggedInUser) async {
    AppConfig.prefs.setBool(AppConfig.skip_interest, true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterestViewNew(
          automaticallyImplyLeading: true,
          userModel: loggedInUser,
          isFromProfile: true,
          onSelectedInterests: (interests) async {
            Navigator.pop(context);
            loggedInUser.interests = interests.length > 0 ? interests : [];
            await updateUserData(loggedInUser);
          },
          onSkipped: () {
            Navigator.pop(context);
//            loggedInUser.interests = [];
//            updateUserData(loggedInUser);
          },
        ),
      ),
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
          type: FileType.custom, allowedExtensions: ['pdf']);
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

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl

    if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
      print('${globals.webImageUrl}');
      setState(() {
        SevaCore.of(context).loggedInUser.photoURL = globals.webImageUrl;
        widget.userModel.photoURL = globals.webImageUrl;
        this._saving = true;
      });
      globals.webImageUrl = null;

      updateUserPic();
    }
  }

  Future<void> updateUserPic() async {
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
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
    var file = File(_path);
    final bytes = await file.lengthSync();
    if (bytes > tenMegaBytes) {
      this._isDocumentBeingUploaded = false;
      getAlertDialog(parentContext);
    } else {
      uploadDocument().then((_) {
        setState(() {
          this._isDocumentBeingUploaded = false;
          this.cvFileError = '';
        });
      });
    }
  }

  Future<String> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    String name =
        SevaCore.of(context).loggedInUser.email + timestampString + _fileName;
    StorageReference ref =
        FirebaseStorage.instance.ref().child('cv_files').child(name);
    StorageUploadTask uploadTask = ref.putFile(
      File(_path),
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'CV File'},
      ),
    );
    String documentURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    cvName = _fileName;
    cvUrl = documentURL;
    // _setAvatarURL();
    // _updateDB();
    return documentURL;
  }

  BuildContext dialogContext;

  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  Future _navigateToSkillsView(UserModel loggedInUser) async {
    AppConfig.prefs.setBool(AppConfig.skip_skill, true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SkillViewNew(
          automaticallyImplyLeading: true,
          isFromProfile: true,
          userModel: loggedInUser,
          onSelectedSkills: (skills) async {
            Navigator.pop(context);
            loggedInUser.skills = skills.length > 0 ? skills : [];
            await updateUserData(loggedInUser);
          },
          onSkipped: () {
            Navigator.pop(context);
//            loggedInUser.skills = [];
//            updateUserData(loggedInUser);
          },
        ),
      ),
    );
  }

  Future updateUserData(UserModel user) async {
    print("inside updateUserData------------");
    await FirestoreManager.updateUser(user: user);
  }

  Future updateProfilePic() async {
    if (this.selectedImage != null) {
      setState(() {
        this._saving = true;
      });
      String imageUrl =
          await uploadImage(SevaCore.of(context).loggedInUser.email);

      await profanityCheck(imageURL: imageUrl);
    }
  }

  Future<void> profanityCheck({String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);

    profanityStatusModel =
        await getProfanityStatus(profanityImageModel: profanityImageModel);

    if (profanityStatusModel.isProfane) {
      showProfanityImageAlert(
              context: context, content: profanityStatusModel.category)
          .then((status) {
        if (status == 'Proceed') {
          FirebaseStorage.instance
              .getReferenceFromUrl(imageURL)
              .then((reference) {
            reference.delete();
            setState(() {
              this._saving = false;
            });
          }).catchError((e) => print(e));
        } else {
          print('error');
        }
      });
    } else {
      setState(() {
        SevaCore.of(context).loggedInUser.photoURL = imageURL;
        widget.userModel.photoURL = imageURL;
      });
      print("image url ${imageURL}");
      await updateUserPic();
    }
  }

  Future updateName() async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.fullname = widget.userModel.fullname;
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  Future updateBio() async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.bio = widget.userModel.bio;
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  Future updateCV() async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.cvName = cvName;
    SevaCore.of(context).loggedInUser.cvUrl = cvUrl;
    usermodel.cvUrl = cvUrl;
    usermodel.cvName = cvName;
    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
      cvName = null;
      cvUrl = null;
    });
  }

  bool get shouldObscure => this._shouldObscure;

  set shouldObscure(bool shouldObscure) {
    setState(() => this._shouldObscure = shouldObscure);
  }

  bool get isLoading => this._isLoading;

  set isLoading(bool isLoading) {
    setState(() => this._isLoading = isLoading);
  }

  Widget get _imagePicker {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.45,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Container(
        child: Hero(
          tag: "ProfileImage",
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userModel.photoURL ?? defaultUserImageURL,
              ),
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.width / 4.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void userImage(File _image) {
    if (_image == null) return;
    setState(() {
      this.selectedImage = _image;
      this.updateProfilePic();
      // File some = File.fromRawPath();
      //isImageSelected = 'Update Photo';
    });
  }

  void _updateName() {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
              AppLocalizations.of(context).translate('profile', 'update_name'),
              style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  autovalidate: autoValidateText,
                  onChanged: (value) {
                    print("name ------ $value");
                    if (value.length > 1) {
                      setState(() {
                        autoValidateText = true;
                      });
                    } else {
                      setState(() {
                        autoValidateText = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                      errorMaxLines: 2,
                      hintText: AppLocalizations.of(context)
                          .translate('profile', 'add_name')),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.fullname,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('profile', 'enter_name');
                    } else if (profanityDetector.isProfaneString(value)) {
                      return AppLocalizations.of(context)
                          .translate('profanity', 'alert');
                    } else {
                      widget.userModel.fullname = value;
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('profile', 'update'),
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)
                                .translate('shared', 'check_internet')),
                            action: SnackBarAction(
                              label: AppLocalizations.of(context)
                                  .translate('shared', 'dismiss'),
                              onPressed: () => _scaffoldKey.currentState
                                  .hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);
                      updateName();
                      isLoading = false;
                    },
                  ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(
                          fontSize: dialogButtonSize, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateBio() {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
              AppLocalizations.of(context).translate('profile', 'update_bio'),
              style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  autovalidate: autoValidateText,
                  //key: _formKey,
                  onChanged: (value) {
                    print("name ------ $value");
                    if (value.length > 1) {
                      setState(() {
                        autoValidateText = true;
                      });
                    } else {
                      setState(() {
                        autoValidateText = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                      errorMaxLines: 2,
                      hintText: AppLocalizations.of(context)
                          .translate('profile', 'enter_bio')),
                  maxLength: 150,
                  maxLengthEnforced: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.bio,

                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('profile', 'please_enter_bio');
                    } else if (profanityDetector.isProfaneString(value)) {
                      return AppLocalizations.of(context)
                          .translate('profanity', 'alert');
                    } else if (value.length < 50) {
                      return AppLocalizations.of(context)
                          .translate('profile', 'bio_50');
                    } else {
                      widget.userModel.bio = value;
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('profile', 'update'),
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)
                                .translate('shared', 'check_internet')),
                            action: SnackBarAction(
                              label: AppLocalizations.of(context)
                                  .translate('shared', 'dismiss'),
                              onPressed: () => _scaffoldKey.currentState
                                  .hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);
                      updateBio();
                      isLoading = false;
//                            setState(() {
//                              widget.userModel.bio = this.usermodel.bio;
//                            });
                    },
                  ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(
                          fontSize: dialogButtonSize, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<String> uploadImage(String email) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(email + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      selectedImage,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Image'},
      ),
    );
    // StorageUploadTask uploadTask = ref.putFile(File.)
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    return imageURL;
  }

  Future addUserToTimebank(UserModel loggedInUser) async {
    TimebankModel timebankModel = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );
    List<String> _members = timebankModel.members;
    timebankModel.members = [..._members, loggedInUser.email];
    await FirestoreManager.updateTimebank(timebankModel: timebankModel);
  }

  void logOut() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).translate('profile', 'logout')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)
                  .translate('profile', 'sure_logout')),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('profile', 'logout'),
                      style: TextStyle(fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)
                                .translate('shared', 'check_internet')),
                            action: SnackBarAction(
                              label: AppLocalizations.of(context)
                                  .translate('shared', 'dismiss'),
                              onPressed: () => _scaffoldKey.currentState
                                  .hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      await FCMNotificationManager
                          .removeDeviceRegisterationForMember(
                              email: SevaCore.of(context).loggedInUser.email);

                      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      //   statusBarBrightness: Brightness.light,
                      //   statusBarColor: Colors.white,
                      // ));
                      try {
                        Navigator.of(_context).pop();
                      } catch (e) {
                        print(e);
                      }

                      _signOut(
                          _context, SevaCore.of(context).loggedInUser.email);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(color: Colors.red, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      Navigator.of(_context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(
    BuildContext context,
    String email,
  ) async {
    // Navigator.pop(context);
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SplashView(),
      ),
    );
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
            .translate('create_feed', 'size_alert')),
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
