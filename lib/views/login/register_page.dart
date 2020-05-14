import 'dart:developer';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/components/newsimage/image_picker_handler.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/timezone.dart';
import 'package:sevaexchange/views/splash_view.dart' as DefaultSplashView;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with ImagePickerListener, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final emailFocus = FocusNode();
  final pwdFocus = FocusNode();
  final confirmPwdFocus = FocusNode();

  bool _shouldObscurePassword = true;
  bool _shouldObscureConfirmPassword = true;
  bool _isLoading = false;

  String fullName;
  String password;
  String email;
  String imageUrl;
  String confirmPassword;
  File selectedImage;
  String isImageSelected = 'Add Photo';

  ImagePickerHandler imagePicker;
  bool isEmailVerified = false;
  bool sentOTP = false;

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: new Text(
          'Your details',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
//        child: SingleChildScrollView(
//          child: Center(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.center,
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
                            SizedBox(height: 24),
                            registerButton,
                            SizedBox(height: 8),
                            Text('or'),
                            SizedBox(height: 8),
                            signUpWithGoogle,
                            SizedBox(height: 8),
                            Text(''),
                          ],
                        ))))
          ],
        ),
//          ),
//        ),
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

  Widget get _profileBtn {
    return SizedBox(
      height: 35,
      width: 120,
      child: Container(
        padding: EdgeInsets.only(top: 5.0),
        child: RaisedButton(
          onPressed: isLoading
              ? null
              : () {
                  imagePicker.showDialog(context);
                },
          color: Colors.grey,
          child: Text(
            this.isImageSelected,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
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
          child: selectedImage == null
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
                          image: FileImage(selectedImage), fit: BoxFit.cover),
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
                      child: IconButton(icon: Icon(Icons.add_a_photo)),
                    ),
                  )),
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
            focusNode: FocusNode(),
            onFieldSubmittedCB:(v){
              FocusScope.of(context).requestFocus(emailFocus);
            },
            shouldRestrictLength: true,
            hint: 'Full Name',
            validator: (value) => value.isEmpty ? 'Name cannot be empty' : null,
            capitalization: TextCapitalization.words,
            onSave: (value) => this.fullName = value,
          ),
          getFormField(
            focusNode: emailFocus,
            onFieldSubmittedCB:(v){
              FocusScope.of(context).requestFocus(pwdFocus);
            },
            shouldRestrictLength: false,
            hint: 'Email Address',
            validator: (value) {
              if (!isValidEmail(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
            capitalization: TextCapitalization.none,
            onSave: (value) => this.email = value.trim(),
          ),
          getFormField(
            focusNode: pwdFocus,
            onFieldSubmittedCB:(v){
              FocusScope.of(context).requestFocus(confirmPwdFocus);
            },
            shouldRestrictLength: false,
            hint: 'Password',
            shouldObscure: shouldObscurePassword,
            validator: (value) {
              this.password = '';
              if (value.length < 6) {
                return 'Password should have atleast 6 characters';
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
          getFormField(
            focusNode: confirmPwdFocus,
            onFieldSubmittedCB:(v){
              FocusScope.of(context).requestFocus(FocusNode());
            },
            shouldRestrictLength: false,
            hint: 'Confirm Password',
            shouldObscure: shouldObscureConfirmPassword,
            validator: (value) {
              if (value.length < 6) {
                return 'Password should have atleast 6 characters';
              }
              if (value != password) {
                return 'Passwords do not match';
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
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmittedCB,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: hint,
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
                if(connResult == ConnectivityResult.none){
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text("Please check your internet connection."),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                  return ;
                }

                isLoading = true;
                if (selectedImage == null) {
                  if (!_formKey.currentState.validate()) {
                    isLoading = false;
                    return;
                  }
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext viewContext) {
                      // return object of type Dialog
                      return WillPopScope(
                        onWillPop: () {},
                        child: AlertDialog(
                          title: Text('Add Photo?'),
                          content: Text('Do you want to add profile pic?'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                'Skip and register',
                                style: TextStyle(
                                    fontSize: dialogButtonSize,
                                    color: Colors.red,
                                    fontFamily: 'Europa'),
                              ),
                              onPressed: () async {
                                Navigator.pop(viewContext);
                                if (!_formKey.currentState.validate()) {
                                  isLoading = false;
                                  return;
                                }
                                _formKey.currentState.save();
                                await createUser();
                                isLoading = false;
                              },
                            ),
                            FlatButton(
                              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              color: Theme.of(context).accentColor,
                              textColor: FlavorConfig.values.buttonTextColor,
                              child: Text(
                                'Add Photo',
                                style: TextStyle(
                                    fontSize: dialogButtonSize,
                                    fontFamily: 'Europa'),
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
                  await createUser();
                  isLoading = false;
                }
              },
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            // fontSize: 16,
          ),
        ),

        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     if (isLoading)
        //       SizedBox(
        //         height: 18,
        //         width: 18,
        //         child: Theme(
        //           data: ThemeData(accentColor: Colors.white),
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         ),
        //       ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Text('Sign Up'),
        //     ),
        //   ],
        // ),)

        color: Theme.of(context).primaryColor,
        shape: StadiumBorder(),
      ),
    );
  }

  BuildContext dialogContext;

  void showDialogForAccountCreation() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text('Creating account'),
            content: LinearProgressIndicator(),
          );
        });
  }

  bool isValidEmail(String email) {
    RegExp regex =
        RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');
    return regex.hasMatch(email);
  }

  Future createUser() async {
    showDialogForAccountCreation();

    log('Called createUser');
    Auth auth = AuthProvider.of(context).auth;
    try {
      UserModel user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: fullName,
      );
      if (this.selectedImage != null) {
        String imageUrl = await uploadImage(user.email);
        user.photoURL = imageUrl;
      } else {
        user.photoURL = defaultUserImageURL;
      }
      user.timezone = new TimezoneListData().getTimeZoneByCodeData(DateTime.now().timeZoneName);
      await FirestoreManager.updateUser(user: user);

      Navigator.pop(dialogContext);
      Navigator.pop(context, user);
      // Navigator.popUntil(context, (r) => r.isFirst);
    } on PlatformException catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext);
      }
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return null;
    } catch (error) {
      if (dialogContext != null) {
        Navigator.pop(dialogContext);
      }

      log('createUser: error: ${error.toString()}');
      return null;
    }
  }

  @override
  void userImage(File _image) {
    if (_image == null) return;
    setState(() {
      this.selectedImage = _image;
      // File some = File.fromRawPath();
      isImageSelected = 'Update Photo';
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

  Widget get logo {
    return Container(
      child: Column(
        children: <Widget>[
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Text(
                  'Humanity\nFirst'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 5,
                    fontSize: 24,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Offstage(),
          SizedBox(
            height: 16,
          ),
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Image.asset(
                  'lib/assets/Y_from_Andrew_Yang_2020_logo.png',
                  height: 70,
                  fit: BoxFit.fill,
                  width: 80,
                )
              : FlavorConfig.appFlavor == Flavor.TULSI
                  ? SvgPicture.asset(
                      'lib/assets/tulsi_icons/tulsi2020_icons_tulsi2020-logo.svg',
                      height: 100,
                      fit: BoxFit.fill,
                      width: 100,
                      color: Colors.white,
                    )
                  : FlavorConfig.appFlavor == Flavor.TOM
                      ? SvgPicture.asset(
                          'lib/assets/ts2020-logo-w.svg',
                          height: 90,
                          fit: BoxFit.fill,
                          width: 90,
                        )
                      : Image.asset(
                          'lib/assets/images/seva-x-logo.png',
                          height: 30,
                          fit: BoxFit.fill,
                          width: 100,
                        )
        ],
      ),
    );
  }

  // signup with google flow
  Widget get signUpWithGoogle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            horizontalLine(),
            Text("Sign up with"),
            horizontalLine()
          ],
        ),
        SizedBox(
          height: ScreenUtil.getInstance().setHeight(20),
        ),
        socialMediaLogin,
      ],
    );
  }

  Widget get socialMediaLogin {
    if (Platform.isIOS) {
      return Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            appleLogin,
            Container(
              width: 16,
            ),
            googleLogin,
//            Container(
//              height: 10,
//            ),
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
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: appleLogIn,
        child:  SizedBox(
          height: 44,
          width: 44,
          child: Image.asset('lib/assets/images/signin_apple.png'),
        ),
      ),
    );
  }

  Widget get googleLogin {
    return Material(
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: useGoogleSignIn,
        child: SizedBox(
          height: 44,
          width: 44,
          child: Image.asset('lib/assets/google-logo-png-open-2000.png'),
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
      msg: 'Sign in with Google',
      operation: useGoogleSignIn,
    );
  }

  Widget get appleLoginiPhone {
    return signInButton(
      imageRef: 'lib/assets/images/apple-logo.png',
      msg: 'Sign in with Apple',
      operation: appleLogIn,
    );
  }

  void appleLogIn() async {
    var connResult = await Connectivity().checkConnectivity();
    if(connResult == ConnectivityResult.none){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Please check your internet connection."),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return ;
    }
    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    try {
      user = await auth.signInWithApple();
      print("User apple:$user");
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {}
    isLoading = false;
    _processLogin(user);
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  void useGoogleSignIn() async {
    var connResult = await Connectivity().checkConnectivity();
    if(connResult == ConnectivityResult.none){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Please check your internet connection."),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
      return ;
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
            content: Text("This email already registered"),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            ),
          ),
        );

        print(" ${email} already registered");
      }
      print("Platform Exception --->  $erorr");
      handlePlatformException(erorr);
    } on Exception catch (error) {
      print("Failed signing in the user with Exception :  $error");
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
    print(error.message);
    if (error.message.contains("no user record")) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: 'Dismiss',
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
            label: 'Change password',
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
          content: Text('This email is already registered'),
          action: SnackBarAction(
            label: 'Dismiss',
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
        content: Text("We\'ve sent the reset link to your email address"),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ));
    });
  }
}
