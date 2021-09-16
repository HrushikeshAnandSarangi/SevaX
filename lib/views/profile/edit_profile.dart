import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart' as pathExt;
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/auth/bloc/user_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/image_picker_handler.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/onboarding/skills_view.dart';
import 'package:sevaexchange/views/timebanks/invite_members.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globals.dart' as globals;
import '../../labels.dart';
import '../core.dart';
import '../splash_view.dart';

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
  final _firestore = CollectionRef;

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
          S.of(context).bottom_nav_profile,
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
                            FocusScope.of(context).requestFocus(new FocusNode());
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
              title: S.of(context).name,
              text: widget.userModel.fullname,
              onTap: () => _updateName(),
            ),
            detailsBuilder(
              title: S.of(context).bio,
              text: widget.userModel.bio ?? S.of(context).add_bio,
              onTap: _updateBio,
            ),
            detailsBuilder(
              title: S.of(context).your_interests,
              //  title: S.of(context).interests.firstWordUpperCase(),
              text: S.of(context).click_to_see_interests,
              onTap: () => _navigateToInterestsView(usermodel),
            ),
            detailsBuilder(
              title: S.of(context).your_skills,
              // title: S.of(context).skills.firstWordUpperCase(),
              text: S.of(context).click_to_see_skills,
              onTap: () => _navigateToSkillsView(usermodel),
            ),
            cvBuilder(
              title: S.of(context).upload_cv_resume,
              text: S.of(context).cv_message,
              onTap: () => _openFileExplorer(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3.5,
                vertical: 20,
              ),
              child: Container(
                width: 134,
                child: CustomElevatedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                    S.of(context).log_out,
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
                                  usermodel.cvName ?? S.of(context).cv_not_available,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  var connResult = await Connectivity().checkConnectivity();
                                  if (connResult == ConnectivityResult.none) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(S.of(context).check_internet),
                                        action: SnackBarAction(
                                          label: S.of(context).dismiss,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (await canLaunch(usermodel.cvUrl)) {
                                    launch(usermodel.cvUrl);
                                  } else {}
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
                          child: CustomElevatedButton(
                            shape: StadiumBorder(),
                            child: Text(
                              S.of(context).replace_cv,
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
        TransactionsMatrixCheck(
          comingFrom: ComingFrom.Profile,
          upgradeDetails: AppConfig.upgradePlanBannerModel.upload_cv,
          transaction_matrix_type: "upload_cv",
          child: GestureDetector(
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
                    S.of(context).choose_pdf_file,
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
                                        cvName ?? S.of(context).cv_not_available,
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
        ),
        Text(
          S.of(context).validation_error_cv_size,
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
                child: CustomElevatedButton(
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).check_internet),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }
                    if (cvUrl == null || cvUrl == '' || cvName == '' || cvName == null) {
                      setState(() {
                        this.cvFileError = S.of(context).validation_error_cv_not_selected;
                      });
                    } else {
                      await updateCV();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context).uploaded_successfully,
                          ),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      setState(() {
                        this.cvFileError = '';
                        this.canuploadCV = false;
                      });
                    }
                  },
                  padding: EdgeInsets.all(3),
                  child: Text(
                    S.of(context).upload,
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
          languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
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
      FilePickerResult result =
          await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        _path = result.files.single.path;
      }
    } on PlatformException catch (e) {
      throw e;
    }
    //   if (!mounted) return;
    if (_path != null) {
      _fileName = _path.split('/').last;

      userDoc(_path, _fileName);
    }
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl

    if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
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
    String _extension = pathExt.extension(_doc).split('?').first;
    if (_extension == 'pdf' || _extension == '.pdf') {
      setState(() {
        this._path = _doc;
        this._fileName = fileName;
        this._isDocumentBeingUploaded = true;
      });
      checkFileSize();
    } else {
      getExtensionAlertDialog(context: context, message: S.of(context).only_pdf_files_allowed);
    }

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
    String name = SevaCore.of(context).loggedInUser.email + timestampString + _fileName;
    Reference ref = FirebaseStorage.instance.ref().child('cv_files').child(name);
    UploadTask uploadTask = ref.putFile(
      File(_path),
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'CV File'},
      ),
    );
    String documentURL = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

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
          languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
        ),
      ),
    );
  }

  Future updateUserData(UserModel user) async {
    await FirestoreManager.updateUser(user: user);
  }

  Future updateProfilePic() async {
    if (this.selectedImage != null) {
      setState(() {
        this._saving = true;
      });
      String imageUrl = await uploadImage(SevaCore.of(context).loggedInUser.email);
      log("link ${imageUrl.toString()}");

      await profanityCheck(imageURL: imageUrl, storagePath: imageUrl);
    }
  }

  Future<void> profanityCheck({String imageURL, String storagePath}) async {
    // _newsImageURL = imageURL;
    log("inside profanity");

    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL, storagePath: imageUrl);
    log("model ${profanityImageModel.toString()}");
    if (profanityImageModel == null) {
      setState(() {
        this._saving = false;
      });
      showFailedLoadImage(context: context).then((value) {});
    } else {
      profanityStatusModel = await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        showProfanityImageAlert(context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            deleteFireBaseImage(imageUrl: imageUrl).then((value) {
              if (value) {
                setState(() {
                  this._saving = false;
                });
              }
            }).catchError((e) => log(e));
          } else {}
        });
      } else {
        setState(() {
          SevaCore.of(context).loggedInUser.photoURL = imageURL;
          widget.userModel.photoURL = imageURL;
        });
        await updateUserPic();
      }
    }
  }

  Future updateName(String name) async {
    setState(() {
      this._saving = true;
    });
    SevaCore.of(context).loggedInUser.fullname = name;

    await FirestoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    setState(() {
      this._saving = false;
    });
  }

  Future updateBio(String bio) async {
    setState(() {
      this._saving = true;
    });
    widget.userModel.bio = bio;
    SevaCore.of(context).loggedInUser.bio = bio;
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
    String name = widget.userModel.fullname;
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(S.of(context).update_name, style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: S.of(context).enter_name,
                    errorMaxLines: 2,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.fullname,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  onChanged: (value) => name = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).enter_name_hint;
                    } else if (profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else {
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
                  CustomTextButton(
                    color: HexColor("#d2d2d2"),
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(fontSize: dialogButtonSize),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTextButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).update,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).check_internet),
                            action: SnackBarAction(
                              label: S.of(context).dismiss,
                              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      widget.userModel.fullname = name;
                      updateName(name);
                      Navigator.pop(viewContext);
                      isLoading = false;
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
    String bio = '';
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(S.of(context).update_bio, style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    errorMaxLines: 2,
                    hintText: S.of(context).enter_bio,
                  ),
                  maxLength: 5000,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  initialValue: widget.userModel.bio,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).update_bio_hint;
                    } else if (profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else if (value.length < 50) {
                      return S.of(context).validation_error_bio_min_characters;
                    } else if (value.length > 250) {
                      return S.of(context).max_250_characters;
                    } else {
                      bio = value;
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomTextButton(
                    color: HexColor("#d2d2d2"),
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(fontSize: dialogButtonSize),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                  SizedBox(width: 10),
                  CustomTextButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).update,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).check_internet),
                            action: SnackBarAction(
                              label: S.of(context).dismiss,
                              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);
                      updateBio(bio);
                      isLoading = false;
//                            setState(() {
//                              widget.userModel.bio = this.usermodel.bio;
//                            });
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
    Reference ref = FirebaseStorage.instance.ref().child('profile_images').child(email + '.jpg');
    UploadTask uploadTask = ref.putFile(
      selectedImage,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Image'},
      ),
    );
    // UploadTask uploadTask = ref.putFile(File.)
    String imageURL = '';

    imageURL = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
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

  Future<void> logOut() async {
    var result = await showDialog<bool>(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).log_out),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(S.of(context).log_out_confirmation),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomTextButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    shape: StadiumBorder(),
                    color: HexColor("#d2d2d2"),
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Europa',
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(_context).pop(false);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    child: Text(
                      S.of(context).log_out,
                      style: TextStyle(
                        fontFamily: 'Europa',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      FCMNotificationManager.removeDeviceRegisterationForMember(
                          email: SevaCore.of(context).loggedInUser.email);

                      Navigator.of(_context).pop(true);

                      _signOut(
                        context,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );

    if (result ?? false) {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
      Provider.of<UserBloc>(context, listen: false).clearUserData;

      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ExplorePage(isUserSignedIn: false),
        ),
        (Route<dynamic> route) => false,
      );
      await Phoenix.rebirth(context);
    }
  }

  Future<void> _signOut(
    BuildContext context,
  ) async {
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Provider.of<UserBloc>(context, listen: false).clearUserData;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthRouter()),
      ((Route<dynamic> route) => false),
    );

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (BuildContext context) => AuthRouter(),
    //   ),
    // );
  }
}

getAlertDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text(S.of(context).large_file_size),
        content: Text(S.of(context).validation_error_file_size),
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
