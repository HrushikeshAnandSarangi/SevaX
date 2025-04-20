import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doseform/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

// import 'package:location/location.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/profile/edit_profile.dart';
import 'package:sevaexchange/views/profile/timezone.dart';
import 'package:sevaexchange/views/splash_view.dart' as DefaultSplashView;
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../globals.dart' as globals;
import '../image_picker_handler.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<DoseFormState> _formKey = GlobalKey();

  bool hasImage() {
    return selectedImage != null ||
        (webImageUrl != null && webImageUrl.isNotEmpty);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final fullnameFocus = FocusNode();
  final emailFocus = FocusNode();
  final pwdFocus = FocusNode();
  final confirmPwdFocus = FocusNode();
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController(),
      confirmPasswordController = TextEditingController();

  bool _shouldObscurePassword = true;
  bool _shouldObscureConfirmPassword = true;
  bool _isLoading = false;

  late String fullName;
  late String password;
  String email = '';
  late String imageUrl;
  late String webImageUrl;
  late String confirmPassword;
  late File selectedImage;
  late String isImageSelected;

  late ImagePickerHandler imagePicker;
  bool isEmailVerified = false;
  bool sentOTP = false;
  bool _isDocumentBeingUploaded = false;
  final int tenMegaBytes = 10485760;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  late String _fileName;
  late String _path;
  late String cvName;
  late String cvUrl;
  String cvFileError = '';
  late GeoFirePoint location;

  late BuildContext parentContext;
  final profanityDetector = ProfanityDetector();

  @override
  void initState() {
    logger.d("==============|||============Register page ::");

    LocationHelper.getLocation().then((value) {
      if (value != null) {
        value.fold((l) => null, (r) {
          location = GeoFirePoint(GeoPoint(r.latitude, r.longitude));
          if (mounted) setState(() {});
        });
      }
    });
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
//                            Padding(
//                              padding: const EdgeInsets.symmetric(
//                                  horizontal: 16, vertical: 16),
//                              child: cvUpload(
//                                title: S.of(context).upload_cv_resume,
//                                text: S.of(context).cv_message,
//                              ),
//                            ),
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
    String? title,
    String? text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Text(
          title!,
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
                  color: FlavorConfig.values.theme!.primaryColor,
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
                                      cvName ?? S.of(context).cv_not_available,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () => setState(() {
                                        cvName = null!;
                                        cvUrl = null!;
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
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget get _imagePicker {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
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
                          image: (webImageUrl != null && webImageUrl.isNotEmpty)
                              ? CachedNetworkImageProvider(webImageUrl)
                              : FileImage(selectedImage)
                                  as ImageProvider<Object>,
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

  // Future<void> getLastKnownPosition() async {
  //   Location templocation = Location();
  //   bool _serviceEnabled;
  //   PermissionStatus _permissionGranted;
  //   Geoflutterfire geo = Geoflutterfire();
  //   LocationData locationData;

  //   try {
  //     _serviceEnabled = await templocation.serviceEnabled();
  //     if (!_serviceEnabled) {
  //       _serviceEnabled = await templocation.requestService();
  //       logger.i("requesting location");

  //       if (!_serviceEnabled) {
  //         return;
  //       } else {
  //         locationData = await templocation.getLocation();

  //         double lat = locationData?.latitude;
  //         double lng = locationData?.longitude;
  //         location = geo.point(latitude: lat, longitude: lng);
  //         setState(() {});
  //       }
  //     }

  //     _permissionGranted = await templocation.hasPermission();
  //     if (_permissionGranted == PermissionStatus.denied) {
  //       _permissionGranted = await templocation.requestPermission();
  //       logger.i("requesting permission");
  //       if (_permissionGranted != PermissionStatus.granted) {
  //         return;
  //       } else {
  //         locationData = await templocation.getLocation();
  //         double lat = locationData?.latitude;
  //         double lng = locationData?.longitude;
  //         location = geo.point(latitude: lat, longitude: lng);

  //         setState(() {});
  //       }
  //     } else {
  //       locationData = await templocation.getLocation();

  //       double lat = locationData?.latitude;
  //       double lng = locationData?.longitude;
  //       location = geo.point(latitude: lat, longitude: lng);

  //       setState(() {});
  //     }
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       logger.e(e);
  //     } else if (e.code == 'SERVICE_STATUS_ERROR') {
  //       logger.e(e);
  //     }
  //   }
  // }

  Widget get _formFields {
    return DoseForm(
      formKey: _formKey,
      child: Column(
        children: <Widget>[
          getFormField(
            focusNode: fullnameFocus,
            controller: nameController,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            shouldRestrictLength: true,
            hint: S.of(context).full_name,
            validator: (value) {
              if (value!.isEmpty) {
                return S.of(context).validation_error_full_name;
              } else if (profanityDetector.isProfaneString(value!)) {
                return S.of(context).profanity_text_alert;
              } else {
                return null!;
              }
            },
            capitalization: TextCapitalization.words,
            onSave: (value) => this.fullName = value!,
          ),
          getFormField(
            focusNode: emailFocus,
            controller: emailController,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(pwdFocus);
            },
            shouldRestrictLength: false,
            hint: S.of(context).email.firstWordUpperCase(),
            validator: (value) {
              if (!isValidEmail(value!.trim())) {
                return S.of(context).validation_error_invalid_email;
              }
              return null!;
            },
            capitalization: TextCapitalization.none,
            onSave: (value) => this.email = value!.trim(),
          ),
          getPasswordFormField(
            focusNode: pwdFocus,
            controller: passwordController,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(confirmPwdFocus);
            },
            shouldRestrictLength: false,
            hint: S.of(context).password.firstWordUpperCase(),
            shouldObscure: shouldObscurePassword,
            validator: (value) {
              this.password = '';
              if (value!.length < 6) {
                return S.of(context).validation_error_invalid_password;
              }
              this.password = value!;
              return null!;
            },
            onSave: (value) {
              this.password = value!;
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
            controller: confirmPasswordController,
            onFieldSubmittedCB: (v) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            shouldRestrictLength: false,
            hint: S.of(context).confirm.firstWordUpperCase() +
                ' ' +
                S.of(context).password.firstWordUpperCase(),
            shouldObscure: shouldObscureConfirmPassword,
            validator: (value) {
              final strongPasswordRegex = RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~])(?!.*\s).{8,}$');
              if (value == null || value.isEmpty) {
                return S.of(context).validation_error_invalid_password;
              }
              if (value.length < 8) {
                return S.of(context).validation_error_invalid_password;
              }
              if (value.contains(' ')) {
                return 'Password must not contain spaces.';
              }
              if (!strongPasswordRegex.hasMatch(value)) {
                return 'Password must be at least 8 characters and include upper, lower, number, and special character, and no spaces.';
              }
              if (value != password) {
                return S.of(context).validation_error_password_mismatch;
              }
              return null!;
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

  Widget getFormField(
      {focusNode,
      onFieldSubmittedCB,
      bool? shouldRestrictLength,
      String? hint,
      String? Function(String?)? validator,
      void Function(String?)? onSave,
      bool shouldObscure = false,
      Widget? suffix,
      TextCapitalization capitalization = TextCapitalization.none,
      TextEditingController? controller}) {
    var size =
        (shouldRestrictLength != null && shouldRestrictLength) ? 20 : 150;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: DoseTextField(
        isRequired: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmittedCB,
        // enabled: !isLoading,
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
        formatters: [
          LengthLimitingTextInputFormatter(size),
        ],
        obscureText: shouldObscure,
      ),
    );
  }

  Widget getPasswordFormField(
      {focusNode,
      onFieldSubmittedCB,
      bool? shouldRestrictLength,
      String? hint,
      String? Function(String?)? validator,
      void Function(String?)? onSave,
      bool shouldObscure = false,
      Widget? suffix,
      TextCapitalization capitalization = TextCapitalization.none,
      TextEditingController? controller}) {
    var size =
        (shouldRestrictLength != null && shouldRestrictLength) ? 20 : 150;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: DoseTextField(
        isRequired: true,
        focusNode: focusNode,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onFieldSubmitted: onFieldSubmittedCB,
        controller: controller,
        maxLines: 1,
        // enabled: !isLoading,
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
        formatters: [
          LengthLimitingTextInputFormatter(size),
        ],
        obscureText: shouldObscure,
      ),
    );
  }

  Widget get registerButton {
    return SizedBox(
      height: 47,
      width: 134,
      child: CustomElevatedButton(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2.0,
        textColor: Colors.white,
        onPressed: isLoading
            ? null!
            : () async {
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

                isLoading = true;

                bool hasNoImage = !this.hasImage();
                if (hasNoImage) {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    isLoading = false;
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext viewContext) {
                      return WillPopScope(
                        onWillPop: () async {
                          return false;
                        },
                        child: AlertDialog(
                          title: Text(S.of(context).add_photo),
                          content: Text(S.of(context).add_photo_hint),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextButton(
                                    shape: StadiumBorder(),
                                    color: Colors.grey,
                                    padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                                    child: Text(
                                      S.of(context).skip_and_register,
                                      style: TextStyle(
                                        fontSize: dialogButtonSize,
                                        color: Colors.white,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(viewContext);
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        isLoading = false;
                                        return;
                                      }
                                      _formKey.currentState?.save();

                                      await profanityCheck();
                                      isLoading = false;
                                    },
                                  ),
                                  CustomTextButton(
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    textColor:
                                        FlavorConfig.values.buttonTextColor,
                                    child: Text(
                                      S.of(context).add_photo,
                                      style: TextStyle(
                                        fontSize: dialogButtonSize,
                                        fontFamily: 'Europa',
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(viewContext);
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      imagePicker.showDialog(context);
                                      isLoading = false;
                                      return;
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    isLoading = false;
                    return;
                  }
                  _formKey.currentState?.save();
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

  BuildContext? dialogContext;

  void showDialogForAccountCreation() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).creating_account),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
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
    if (globals.webImageUrl != null && globals.webImageUrl!.isNotEmpty) {
      webImageUrl = globals.webImageUrl!;
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
            Navigator.pop(dialogContext!);
          }
          showFailedLoadImage(context: context).then((value) {});
        } else {
          profanityStatusModel = await getProfanityStatus(
              profanityImageModel: profanityImageModel);

          if (profanityStatusModel.isProfane!) {
            if (dialogContext != null) {
              Navigator.pop(dialogContext!);
            }
            showProfanityImageAlert(
                    context: context, content: profanityStatusModel.category!)
                .then((status) {
              if (status == 'Proceed') {
                deleteFireBaseImage(imageUrl: imageUrl).then((value) {
                  if (value) {
                    setState(() {});
                  }
                }).catchError((e) => log(e));
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

  Future createUser({String? imageUrl}) async {
    var appLanguage = AppLanguage();
    log('Called createUser');
    if (cvName != null) {
      await uploadDocument();
    }
    Auth auth = AuthProvider.of(context).auth;

    try {
      UserModel user = await auth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
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
      await FirestoreManager.addCreationSourceOfUser(
          locationVal: location, userEmailId: user.email!);

      await FirestoreManager.updateUser(user: user);

      logger.i('----- START OF JOINED SEVAX GLOBAL LOG CODE -------');

      await CollectionRef.timebank
          .doc(FlavorConfig.values.timebankId)
          .collection('entryExitLogs')
          .add({
        'mode': ExitJoinType.JOIN.readable,
        'modeType': JoinMode.JOINED_SEVAX_GLOBAL.readable,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'communityId': FlavorConfig.values.timebankId,
        'isGroup': false,
        'memberDetails': {
          'email': email.toLowerCase(),
          'id': user.sevaUserID,
          'fullName': user.fullname,
          'photoUrl': user.photoURL,
        },
        // 'adminDetails': {
        //   'email': adminEmail,
        //   'id': adminId,
        //   'fullName': adminFullName,
        //   'photoUrl': adminPhotoUrl,
        // },
        'associatedTimebankDetails': {
          'timebankId': FlavorConfig.values.timebankId,
          'timebankTitle': 'SevaX Global Community',
          'missionStatement':
              'Welcome to our global community for all SevaX members. You will be able to see virtual offers and requests here that were made public within local Seva communities. Events that are made public also will be displayed within SevaX Global.',
        }
      });

      logger.d("===========|||===========");
      Navigator.pop(dialogContext!);
      // Navigator.pop(context, user);
      // Phoenix.rebirth(context);
      logger.d("===========|||====||||||||=======");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AuthRouter(),
        ),
      );
    } on PlatformException catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return null;
    } on EmailAlreadyInUseException catch (e) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              // "Email address already in use, please use a different email!"),
              e._message),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      // FirebaseCrashlytics.instance.log(error.toString());
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
      this.webImageUrl = null!;
      isImageSelected = S.of(context).update_photo;
    });
  }

  Future<String> uploadImage(String email) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(email + '.jpg');
    UploadTask uploadTask = ref.putFile(
      selectedImage,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Profile Image'},
      ),
    );

    String imageURL =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    return imageURL;
  }

  Future addUserToTimebank(UserModel loggedInUser) async {
    TimebankModel? timebankModel = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );
    if (timebankModel == null) {
      // Handle the null case appropriately, e.g., return or throw
      return;
    }
    List<String> _members = timebankModel.members;
    timebankModel.members = [..._members, loggedInUser.email!];
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
    String? _path;
    Map<String, String> _paths = {};
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        _path = result.files.single.path!;
      }
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
    Reference ref =
        FirebaseStorage.instance.ref().child('cv_files').child(name);
    UploadTask uploadTask = ref.putFile(
      File(_path),
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'CV File'},
      ),
    );
    String documentURL = '';
    documentURL =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

    cvUrl = documentURL;
    log('link  ' + documentURL);

    cvName = _fileName;
    return documentURL;
  }

  Widget get signUpWithGoogle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: horizontalLine()),
            Text(S.of(context).or),
            Expanded(child: horizontalLine()),
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
              S.of(context).sign_up_with_apple,
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
          margin: EdgeInsets.only(top: 12.0),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  child: Image.asset('lib/assets/images/g.png'),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(S.of(context).sign_up_with_google),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton(
      {String? imageRef, String? msg, VoidCallback? operation}) {
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
        onTap: operation!,
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
                  child: Image.asset(imageRef!),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 15,
                ),
                Text(
                  msg!,
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
    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    late UserModel user;
    try {
      var result = await auth.signInWithApple();
      if (result == null) {
        throw Exception('Failed to sign in with Apple');
      }
      user = result;
    } on PlatformException catch (error) {
      handlePlatformException(error);
    } on Exception catch (error) {
      logger.e(error);
    }
    await FirestoreManager.addCreationSourceOfUser(
        locationVal: location, userEmailId: user.email!);

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

    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    late UserModel user;
    try {
      var result = await auth.handleGoogleSignIn();
      if (result == null) {
        throw Exception('Failed to sign in with Google');
      }
      user = result;
    } on PlatformException catch (erorr) {
      if (erorr.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).validation_error_email_registered),
            action: SnackBarAction(
              label: S.of(context).dismiss,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      handlePlatformException(erorr);
    } on Exception catch (error) {
      logger.e(error);
    }
    await FirestoreManager.addCreationSourceOfUser(
        locationVal: location, userEmailId: user.email!);

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
    if (error.message!.contains("no user record")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else if (error.message!.contains("password")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
          action: SnackBarAction(
            label: S.of(context).change_password,
            onPressed: () {
              resetPassword(email);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else if (error.message!.contains("already")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).validation_error_email_registered),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email.toLowerCase())
        .then((onValue) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).reset_password_message),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
    });
  }
}

class EmailAlreadyInUseException implements Exception {
  final String _message;

  EmailAlreadyInUseException([String message = 'Invalid value'])
      : _message = message;

  @override
  String toString() {
    return _message;
  }
}
