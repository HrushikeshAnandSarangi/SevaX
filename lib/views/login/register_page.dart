import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/profile/edit_profile.dart';
import 'package:sevaexchange/views/profile/timezone.dart';
import 'package:sevaexchange/views/splash_view.dart' as DefaultSplashView;

import '../../globals.dart' as globals;
import '../image_picker_handler.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final fullnameFocus = FocusNode();
  final emailFocus = FocusNode();
  final pwdFocus = FocusNode();
  final confirmPwdFocus = FocusNode();

  bool _shouldObscurePassword = true;
  bool _shouldObscureConfirmPassword = true;
  bool _isLoading = false;

  String fullName;
  String password;
  String email = '';
  String imageUrl;
  String webImageUrl;
  String confirmPassword;
  File selectedImage;
  String isImageSelected;

  ImagePickerHandler imagePicker;
  bool isEmailVerified = false;
  bool sentOTP = false;
  bool _isDocumentBeingUploaded = false;
  final int tenMegaBytes = 10485760;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  String _fileName;
  String _path;
  String cvName;
  String cvUrl;
  String cvFileError = '';

  BuildContext parentContext;
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  List<bool> autoValidateTexts = [true, true, false, false];

  @override
  void initState() {
    super.initState();
    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  Widget build(BuildContext context) {
    isImageSelected = S.of(context).add_photo;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: Text(
          S.of(context).your_details,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: <Widget>[
            SingleChildScrollView(
                child: FadeAnimation(
                    1.4,
                    Padding(
                        padding:
                            EdgeInsets.only(left: 28.0, right: 28.0, top: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 16),
                            _imagePicker,
                            _formFields,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: cvUpload(
                                title: S.of(context).upload_cv_resume,
                                text: S.of(context).cv_message,
                              ),
                            ),
                            SizedBox(height: 24),
                            registerButton,
                            SizedBox(height: 8),
                            signUpWithGoogle,
                            SizedBox(height: 8),
                            Text(''),
                          ],
                        ))))
          ],
        ),
      ),
    );
  }

  bool get shouldObscurePassword => this._shouldObscurePassword;
  bool get shouldObscureConfirmPassword => this._shouldObscureConfirmPassword;

  set shouldObscurePassword(bool shouldObscure) {
    setState(() => this.shouldObscurePassword = shouldObscure);
  }

  set shouldObscureConfirmPassword(bool shouldObscure) {
    setState(() => this.shouldObscureConfirmPassword = shouldObscure);
  }

  bool get isLoading => this._isLoading;

  set isLoading(bool isLoading) {
    setState(() => this._isLoading = isLoading);
  }

  Widget cvUpload({
    String title,
    String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
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
                  height: 40,
                  width: 40,
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
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : Container(
                        child: cvName == null
                            ? Offstage()
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
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
          S.of(context).validation_error_cv_size,
          style: TextStyle(color: Colors.grey),
        ),
//        Text(
//          cvFileError,
//          style: TextStyle(color: Colors.red),
//        ),
//        Row(
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(top: 5),
//              child: Container(
//                height: 30,
//                child: RaisedButton(
//                  onPressed: () async {
//                    var connResult = await Connectivity().checkConnectivity();
//                    if (connResult == ConnectivityResult.none) {
//                      _scaffoldKey.currentState.showSnackBar(
//                        SnackBar(
//                          content: Text(AppLocalizations.of(context)
//                              .translate('shared', 'check_internet')),
//                          action: SnackBarAction(
//                            label: AppLocalizations.of(context)
//                                .translate('shared', 'dismiss'),
//                            onPressed: () =>
//                                _scaffoldKey.currentState.hideCurrentSnackBar(),
//                          ),
//                        ),
//                      );
//                      return;
//                    }
//                    if (cvUrl == null ||
//                        cvUrl == '' ||
//                        cvName == '' ||
//                        cvName == null) {
//                      setState(() {
//                        this.cvFileError = AppLocalizations.of(context)
//                            .translate('cv', 'cv_error');
//                      });
//                    } else {
//                      await updateCV();
//                      _scaffoldKey.currentState.showSnackBar(
//                        SnackBar(
//                          content: Text(
//                            AppLocalizations.of(context)
//                                .translate('upload_csv', 'upload_success'),
//                          ),
//                          action: SnackBarAction(
//                            label: AppLocalizations.of(context)
//                                .translate('shared', 'dismiss'),
//                            onPressed: () =>
//                                _scaffoldKey.currentState.hideCurrentSnackBar(),
//                          ),
//                        ),
//                      );
//                      setState(() {
//                        this.cvFileError = '';
//                        this.canuploadCV = false;
//                      });
//                    }
//                  },
//                  child: Text(
//                    AppLocalizations.of(context)
//                        .translate('upload_csv', 'upload'),
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      fontSize: 12,
//                    ),
//                  ),
//                  color: Colors.grey[300],
//                  shape: StadiumBorder(),
//                ),
//              ),
//            ),
//          ],
//        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget get _imagePicker {
    return GestureDetector(
      onTap: () {
        imagePicker.showDialog(context);
      },
      child: SizedBox(
        height: 150,
        width: 150,
        child: Container(
          child: selectedImage == null && webImageUrl == null
              ? Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(defaultCameraImageURL),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(75.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 7.0, color: Colors.black12)
                      ]))
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: webImageUrl == null
                              ? FileImage(selectedImage)
                              : CachedNetworkImageProvider(webImageUrl),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(75.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 7.0, color: Colors.black12)
                      ]),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.0))),
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget get _formFields {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          getFormField(
            focusNode: fullnameFocus,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            shouldRestrictLength: true,
            hint: S.of(context).full_name,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_full_name;
              } else if (profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              } else {
                return null;
              }
            },
            capitalization: TextCapitalization.words,
            onSave: (value) => this.fullName = value,
          ),
          getFormField(
            focusNode: emailFocus,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(pwdFocus);
            },
            shouldRestrictLength: false,
            hint: S.of(context).email.firstWordUpperCase(),
            validator: (value) {
              if (!isValidEmail(value.trim())) {
                return S.of(context).validation_error_invalid_email;
              }
              return null;
            },
            capitalization: TextCapitalization.none,
            onSave: (value) => this.email = value.trim(),
          ),
          getPasswordFormField(
            focusNode: pwdFocus,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(confirmPwdFocus);
            },
            shouldRestrictLength: false,
            hint: S.of(context).password.firstWordUpperCase(),
            shouldObscure: shouldObscurePassword,
            validator: (value) {
              this.password = '';
              if (value.length < 6) {
                return S.of(context).validation_error_invalid_password;
              }
              this.password = value;
              return null;
            },
            onSave: (value) {
              this.password = value;
            },
            suffix: Container(
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    _shouldObscurePassword = !_shouldObscurePassword;
                    setState(() {});
                  },
                  child: Icon(
                    _shouldObscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                )),
          ),
          getPasswordFormField(
            focusNode: confirmPwdFocus,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            shouldRestrictLength: false,
            hint: S.of(context).confirm.firstWordUpperCase() +
                ' ' +
                S.of(context).password.firstWordUpperCase(),
            shouldObscure: shouldObscureConfirmPassword,
            validator: (value) {
              if (value.length < 6) {
                return S.of(context).validation_error_invalid_password;
              }
              if (value != password) {
                return S.of(context).validation_error_password_mismatch;
              }
              return null;
            },
            suffix: Container(
                height: 30,
                child: GestureDetector(
                  onTap: () {
                    _shouldObscureConfirmPassword =
                        !_shouldObscureConfirmPassword;
                    setState(() {});
                  },
                  child: Icon(
                    shouldObscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Widget getFormField({
    focusNode,
    onFieldSubmittedCB,
    bool shouldRestrictLength,
    String hint,
    String Function(String value) validator,
    Function(String value) onSave,
    bool shouldObscure = false,
    Widget suffix,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    var size = shouldRestrictLength ? 20 : 150;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        autovalidate: focusNode == emailFocus ? false : autoValidateText,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmittedCB,
        enabled: !isLoading,
        onChanged: (value) {
          if (value.length > 1 && !autoValidateText) {
            setState(() {
              autoValidateText = true;
            });
          }
          if (value.length <= 1 && autoValidateText) {
            setState(() {
              autoValidateText = false;
            });
          }
        },
        decoration: InputDecoration(
          labelText: hint,
          errorMaxLines: 2,
          suffix: suffix,
          labelStyle: TextStyle(color: Colors.black),
          suffixStyle: TextStyle(color: Colors.black),
          counterStyle:
              TextStyle(height: double.minPositive, color: Colors.black),
          counterText: "",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textCapitalization: capitalization,
        validator: validator,
        onSaved: onSave,
        inputFormatters: [
          LengthLimitingTextInputFormatter(size),
        ],
        obscureText: shouldObscure,
      ),
    );
  }

  Widget getPasswordFormField({
    focusNode,
    onFieldSubmittedCB,
    bool shouldRestrictLength,
    String hint,
    String Function(String value) validator,
    Function(String value) onSave,
    bool shouldObscure = false,
    Widget suffix,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    var size = shouldRestrictLength ? 20 : 150;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TextFormField(
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmittedCB,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: hint,
          errorMaxLines: 2,
          suffix: suffix,
          labelStyle: TextStyle(color: Colors.black),
          suffixStyle: TextStyle(color: Colors.black),
          counterStyle:
              TextStyle(height: double.minPositive, color: Colors.black),
          counterText: "",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textCapitalization: capitalization,
        validator: validator,
        onSaved: onSave,
        inputFormatters: [
          LengthLimitingTextInputFormatter(size),
        ],
        obscureText: shouldObscure,
      ),
    );
  }

  Widget get registerButton {
    return SizedBox(
      height: 39,
      width: 134,
      child: RaisedButton(
        onPressed: isLoading
            ? null
            : () async {
                var connResult = await Connectivity().checkConnectivity();
                if (connResult == ConnectivityResult.none) {
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).check_internet),
                      action: SnackBarAction(
                        label: S.of(context).dismiss,
                        onPressed: () =>
                            _scaffoldKey.currentState.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                  return;
                }

                isLoading = true;

                if (selectedImage == null && webImageUrl == null) {
                  if (!_formKey.currentState.validate()) {
                    isLoading = false;
                    return;
                  }
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext viewContext) {
                      return WillPopScope(
                        onWillPop: () {},
                        child: AlertDialog(
                          title: Text(S.of(context).add_photo),
                          content: Text(S.of(context).add_photo_hint),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                S.of(context).skip_and_register,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                  color: Colors.red,
                                  fontFamily: 'Europa',
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(viewContext);
                                if (!_formKey.currentState.validate()) {
                                  isLoading = false;
                                  return;
                                }
                                _formKey.currentState.save();

                                await profanityCheck();
                                isLoading = false;
                              },
                            ),
                            FlatButton(
                              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              color: Theme.of(context).accentColor,
                              textColor: FlavorConfig.values.buttonTextColor,
                              child: Text(
                                S.of(context).add_photo,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                  fontFamily: 'Europa',
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(viewContext);
                                imagePicker.showDialog(context);
                                isLoading = false;
                                return;
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  if (!_formKey.currentState.validate()) {
                    isLoading = false;
                    return;
                  }
                  _formKey.currentState.save();
                  await profanityCheck();
                  isLoading = false;
                }
              },
        child: Text(
          S.of(context).sign_up,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        color: Theme.of(context).primaryColor,
        shape: StadiumBorder(),
      ),
    );
  }

  BuildContext dialogContext;

  void showDialogForAccountCreation() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).creating_account),
            content: LinearProgressIndicator(),
          );
        });
  }

  bool isValidEmail(String email) {
    RegExp regex =
        RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
    return regex.hasMatch(email);
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
      webImageUrl = globals.webImageUrl;
      setState(() {});
    }
  }

  Future<void> profanityCheck() async {
    // _newsImageURL = imageURL;
    showDialogForAccountCreation();
    if (webImageUrl != null && webImageUrl.isNotEmpty) {
      createUser(imageUrl: webImageUrl);
    } else {
      if (this.selectedImage != null) {
        String imageUrl = await uploadImage(email);
        profanityImageModel = await checkProfanityForImage(imageUrl: imageUrl);
        if (profanityImageModel == null) {
          if (dialogContext != null) {
            Navigator.pop(dialogContext);
          }
          showFailedLoadImage().then((value) {});
        } else {
          profanityStatusModel = await getProfanityStatus(
              profanityImageModel: profanityImageModel);

          if (profanityStatusModel.isProfane) {
            if (dialogContext != null) {
              Navigator.pop(dialogContext);
            }
            showProfanityImageAlert(
                    context: context, content: profanityStatusModel.category)
                .then((status) {
              if (status == 'Proceed') {
                FirebaseStorage.instance
                    .getReferenceFromUrl(imageUrl)
                    .then((reference) {
                  reference.delete();

                  setState(() {});
                });
              }
            });
          } else {
            createUser(imageUrl: imageUrl);
          }
        }
      } else {
        createUser(imageUrl: defaultUserImageURL);
      }
    }
  }

  Future createUser({String imageUrl}) async {
    var appLanguage = AppLanguage();
    log('Called createUser');
    if (cvName != null) {
      await uploadDocument();
    }
    Auth auth = AuthProvider.of(context).auth;

    try {
      UserModel user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: fullName,
      );

      user.photoURL = imageUrl;

      user.timezone =
          TimezoneListData().getTimeZoneByCodeData(DateTime.now().timeZoneName);
      Locale _sysLng = ui.window.locale;
      Locale _language =
          S.delegate.isSupported(_sysLng) ? _sysLng : Locale('en');
      appLanguage.changeLanguage(_language);
      user.language = _language.languageCode;

      if (cvName != null) {
        user.cvName = cvName;
        user.cvUrl = cvUrl;
      }
      await FirestoreManager.updateUser(user: user);

      Navigator.pop(dialogContext);
      Navigator.pop(context, user);
    } on PlatformException catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext);
      }
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return null;
    } catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext);
      }
      Crashlytics.instance.log(error.toString());
      error;
      log('createUser: error: ${error.toString()}');
      return null;
    }
  }

  @override
  void userImage(File _image) {
    if (_image == null) return;
    setState(() {
      this.selectedImage = _image;
      this.webImageUrl = null;
      isImageSelected = S.of(context).update_photo;
    });
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

  Widget get logo {
    return Container(
      child: Column(
        children: <Widget>[
          Offstage(),
          SizedBox(
            height: 16,
          ),
          Image.asset(
            'lib/assets/images/seva-x-logo.png',
            height: 30,
            fit: BoxFit.fill,
            width: 100,
          )
        ],
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
      logger.e(e);
    }
    //   if (!mounted) return;
    if (_path != null) {
      _fileName = _path.split('/').last;

      userDoc(_path, _fileName);
    }
  }

  void userDoc(String _doc, String fileName) {
    // TODO: implement userDoc
    setState(() {
      this._path = _doc;
      this._fileName = fileName;
      this.cvName = _fileName;
      // this._isDocumentBeingUploaded = true;
    });
    checkFileSize();
    return null;
  }

  void checkFileSize() async {
    var file = File(_path);
    final bytes = await file.lengthSync();
    if (bytes > tenMegaBytes) {
      getAlertDialog(parentContext);
    }
  }

  Future<String> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    String name = email + timestampString + _fileName;
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
    return documentURL;
  }

  Widget get signUpWithGoogle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            horizontalLine(),
            Text(S.of(context).or),
            horizontalLine()
          ],
        ),
        SizedBox(
          height: 20,
        ),
        socialMediaLogin,
      ],
    );
  }

  Widget get socialMediaLogin {
    if (Platform.isIOS) {
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            googleLogin,
            SizedBox(
              height: 10,
            ),
            Container(
              width: 16,
            ),
            appleLogin,
          ],
        ),
      );
    }
    return Center(
      child: googleLogin,
    );
  }

  Widget get appleLogin {
    return Material(
      child: InkWell(
        onTap: appleLogIn,
        child: Card(
          color: Colors.black,
          child: ListTile(
            leading: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset(
                'lib/assets/images/apple-logo.png',
                color: Colors.white,
              ),
            ),
            title: Text(
              'Sign up with Apple',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget get googleLogin {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: useGoogleSignIn,
        child: Card(
          child: ListTile(
            leading: SizedBox(
              height: 30,
              width: 30,
              child: Image.asset('lib/assets/images/g.png'),
            ),
            title: Text('Sign up with Google'),
          ),
        ),
      ),
    );
  }

  Widget signInButton({String imageRef, String msg, Function operation}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      width: 220,
      height: 56,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: operation,
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 18,
                ),
                Container(
                  width: 17,
                  height: 17,
                  margin: EdgeInsets.only(
                    left: 12,
                    right: 12,
                  ),
                  child: Image.asset(imageRef),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 15,
                ),
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get googleLoginiPhone {
    return signInButton(
      imageRef: 'lib/assets/google-logo-png-open-2000.png',
      msg: S.of(context).sign_in_with_google,
      operation: useGoogleSignIn,
    );
  }

  Widget get appleLoginiPhone {
    return signInButton(
      imageRef: 'lib/assets/images/apple-logo.png',
      msg: S.of(context).sign_in_with_apple,
      operation: appleLogIn,
    );
  }

  void appleLogIn() async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }
    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    try {
      user = await auth.signInWithApple();
    } on PlatformException catch (error) {
      handlePlatformException(error);
    } on Exception catch (error) {
      logger.e(error);
    }
    isLoading = false;
    _processLogin(user);
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: 120,
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  void useGoogleSignIn() async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    try {
      user = await auth.handleGoogleSignIn();
    } on PlatformException catch (erorr) {
      if (erorr.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(S.of(context).validation_error_email_registered),
            action: SnackBarAction(
              label: S.of(context).dismiss,
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      handlePlatformException(erorr);
    } on Exception catch (error) {
      logger.e(error);
    }
    isLoading = false;
    _processLogin(user);
  }

  void _processLogin(UserModel userModel) {
    if (userModel == null) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => DefaultSplashView.SplashView(),
        ),
        (Route<dynamic> route) => false);
  }

  void handlePlatformException(PlatformException error) {
    if (error.message.contains("no user record")) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else if (error.message.contains("password")) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: S.of(context).change_password,
            onPressed: () {
              resetPassword(email);
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else if (error.message.contains("already")) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(S.of(context).validation_error_email_registered),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((onValue) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.of(context).reset_password_message),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ));
    });
  }
}
