import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/views/splash_view.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKeyDialog = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Alignment childAlignment = Alignment.center;
  bool _isLoading = false;

  String emailId;
  String password;
  bool _shouldObscurePassword = true;
  Color enabled = Colors.white.withAlpha(120);

  void initState() {
    fetchRemoteConfig();
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarBrightness: Brightness.light,
    //   // statusBarColor: Color(0x0FF766FE0),
    // ));
    UserData.shared.isFromLogin = true;
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FadeAnimation(
            0.4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60.0),
                ),
                Expanded(
                  child: Container(),
                ),
                Image.asset("lib/assets/images/image_02.png")
              ],
            ),
          ),
          SingleChildScrollView(
            child: FadeAnimation(
              1.4,
              Padding(
                padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 100.0),
                child: Column(
                  children: <Widget>[
                    logo,
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(60),
                    ),
                    content,
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                        text: 'By continuing, you agree to SevaX',
                        children: <TextSpan>[
                          TextSpan(
                              text: ' Terms of Service',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showTermsPage),
                          TextSpan(
                              text:
                                  ' We will manage information as described in our'),
                          TextSpan(
                              text: ' Privacy Policy ',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showPrivacyPolicyPage),
                          TextSpan(text: ' and'),
                          TextSpan(
                              text: ' Payment Policy.',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showPaymentPolicyPage),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil.getInstance().setHeight(50)),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "New User? ",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                isLoading = true;
                                UserModel user =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute<UserModel>(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                                isLoading = false;
                                if (user != null) _processLogin(user);
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Text(
                              "Forgot Password? ",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            InkWell(
                                onTap: () async {
                                  isLoading = true;
                                  UserModel user =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute<UserModel>(
                                      builder: (context) => RegisterPage(),
                                    ),
                                  );
                                  isLoading = false;
                                  if (user != null) _processLogin(user);
                                },
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Enter email',
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Form(
                                                  key: _formKeyDialog,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        return 'Please enter email to reset';
                                                      } else if (!validateEmail(
                                                          value.trim())) {
                                                        return 'Please enter a valid email';
                                                      }
                                                      _textFieldControllerResetEmail =
                                                          value;
                                                    },
                                                    // validator: validateEmail,
                                                    onChanged: (value) {
                                                      print("$value");
                                                    },
                                                    initialValue: "",
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    controller: null,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Your email address",
                                                      // errorText: isEmailValidForReset
                                                      //     ? null
                                                      //     : validateEmail(
                                                      //         _textFieldControllerResetEmail.text,
                                                      //       ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    FlatButton(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 5, 10, 5),
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      textColor: FlavorConfig
                                                          .values
                                                          .buttonTextColor,
                                                      child: Text(
                                                        'Reset Password',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (!_formKeyDialog
                                                            .currentState
                                                            .validate()) {
                                                          return;
                                                        }
                                                        Navigator.of(context)
                                                            .pop({
                                                          "sendResetLink": true,
                                                          "userEmail":
                                                              _textFieldControllerResetEmail
                                                                  .trim()
                                                        });
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(
                                                          {
                                                            "sendResetLink":
                                                                false,
                                                            "userEmail": null
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }).then((onActivityResult) {
                                      if (onActivityResult != null &&
                                          onActivityResult['sendResetLink'] !=
                                              null &&
                                          onActivityResult['sendResetLink'] &&
                                          onActivityResult['userEmail'] !=
                                              null &&
                                          onActivityResult['userEmail']
                                              .toString()
                                              .isNotEmpty) {
                                        print("send reset link");
                                        resetPassword(
                                            onActivityResult['userEmail']);
                                        _scaffoldKey.currentState
                                            .hideCurrentSnackBar();
                                      } else {
                                        print("Cancelled forgot passowrd");
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      "Reset",
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 134,
                      height: 39,
                      child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Color(0x0FF766FE0),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                signInWithEmailAndPassword();
                              },
                      ),
                    ),
                    // InkWell(
                    //   child: Container(
                    //     width: ScreenUtil.getInstance().setWidth(250),
                    //     height: ScreenUtil.getInstance().setHeight(70),
                    //     decoration: BoxDecoration(
                    //         gradient: LinearGradient(colors: [
                    //           Theme.of(context).accentColor,
                    //           Theme.of(context).accentColor
                    //         ]),
                    //         borderRadius: BorderRadius.circular(50.0),
                    //         boxShadow: [
                    //           BoxShadow(
                    //               color: Theme.of(context)
                    //                   .accentColor
                    //                   .withOpacity(.3),
                    //               offset: Offset(0.0, 8.0),
                    //               blurRadius: 8.0)
                    //         ]),
                    //     child: Material(
                    //       color: Colors.transparent,
                    //       child: InkWell(
                    //         onTap: isLoading
                    //             ? null
                    //             : () {
                    //                 signInWithEmailAndPassword();
                    //               },
                    //         child: Center(
                    //           child: Text(
                    //             "Sign in",
                    //             style: TextStyle(
                    //               color: FlavorConfig.values.buttonTextColor,
                    //               fontSize: 18,
                    //               letterSpacing: 1.0,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 8),
                    Text('or'),
                    SizedBox(height: 8),
                    signInWithGoogle,
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(30),
                    ),
                    FlavorConfig.appFlavor == Flavor.APP
                        ? Offstage()
                        : poweredBySevaLogo,
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: isLoading
                ? Container(
                    color: Colors.grey.withOpacity(0.5),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        // Text('Loading ...',style: Text,)
                      ],
                    )),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  bool get isLoading => this._isLoading;

  set isLoading(bool isLoading) {
    setState(() => this._isLoading = isLoading);
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
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Colors.black45,
                    fontSize: ScreenUtil.getInstance().setSp(45),
                    letterSpacing: 5,
                  ),
                )
              : Offstage(),
          SizedBox(
            height: 16,
          ),
          FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
              ? Image.asset(
                  'lib/assets/images/new_yang.png',
                  height: 90,
                  fit: BoxFit.fill,
                  width: 180,
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
                          height: 80,
                          fit: BoxFit.fill,
                          width: 280,
                        )
        ],
      ),
    );
  }

  Widget get content {
    return FadeAnimation(
      1.5,
      new Container(
        width: double.infinity,
        // height: ScreenUtil.getInstance().setHeight(250),
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 0.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    style: textStyle,
                    cursorColor: Colors.black54,
                    validator: _validateEmailId,
                    onSaved: _saveEmail,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      labelText: 'EMAIL',
                      labelStyle: textStyle,
                    ),
                  ),
                  TextFormField(
                    obscureText: _shouldObscurePassword,
                    style: textStyle,
                    cursorColor: Colors.black54,
                    validator: _validatePassword,
                    onSaved: _savePassword,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        labelText: 'PASSWORD',
                        labelStyle: textStyle,
                        suffix: GestureDetector(
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
                  SizedBox(height: 22),
                  // SizedBox(height: 32),
                  // Column(
                  //   children: <Widget>[
                  //     Container(
                  //       margin: EdgeInsets.all(12),
                  //       child: FlatButton(
                  //         onPressed: () {
                  //           showDialog(
                  //               context: context,
                  //               builder: (context) {
                  //                 return AlertDialog(
                  //                   title: Text(
                  //                     'Enter email',
                  //                   ),
                  //                   content: Form(
                  //                     key: _formKeyDialog,
                  //                     child: TextFormField(
                  //                       validator: (value) {
                  //                         if (value.isEmpty) {
                  //                           return 'Please enter email to update';
                  //                         } else if (!validateEmail(
                  //                             value.trim())) {
                  //                           return 'Please enter a valid email';
                  //                         }
                  //                         _textFieldControllerResetEmail =
                  //                             value;
                  //                       },
                  //                       // validator: validateEmail,
                  //                       onChanged: (value) {
                  //                         print("$value");
                  //                       },
                  //                       initialValue: "",
                  //                       keyboardType:
                  //                           TextInputType.emailAddress,
                  //                       controller: null,
                  //                       decoration: InputDecoration(
                  //                         hintText: "Your email address",
                  //                         // errorText: isEmailValidForReset
                  //                         //     ? null
                  //                         //     : validateEmail(
                  //                         //         _textFieldControllerResetEmail.text,
                  //                         //       ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   actions: <Widget>[
                  //                     new FlatButton(
                  //                       child: new Text(
                  //                         'Cancel',
                  //                         style: TextStyle(
                  //                           fontSize: dialogButtonSize,
                  //                         ),
                  //                       ),
                  //                       onPressed: () {
                  //                         Navigator.of(context).pop(
                  //                           {
                  //                             "sendResetLink": false,
                  //                             "userEmail": null
                  //                           },
                  //                         );
                  //                       },
                  //                     ),
                  //                     new FlatButton(
                  //                       child: new Text(
                  //                         'Reset Password',
                  //                         style: TextStyle(
                  //                           fontSize: dialogButtonSize,
                  //                         ),
                  //                       ),
                  //                       onPressed: () {
                  //                         if (!_formKeyDialog.currentState
                  //                             .validate()) {
                  //                           return;
                  //                         }
                  //                         Navigator.of(context).pop({
                  //                           "sendResetLink": true,
                  //                           "userEmail":
                  //                               _textFieldControllerResetEmail
                  //                                   .trim()
                  //                         });
                  //                       },
                  //                     )
                  //                   ],
                  //                 );
                  //               }).then((onActivityResult) {
                  //             if (onActivityResult != null &&
                  //                 onActivityResult['sendResetLink'] != null &&
                  //                 onActivityResult['sendResetLink'] &&
                  //                 onActivityResult['userEmail'] != null &&
                  //                 onActivityResult['userEmail']
                  //                     .toString()
                  //                     .isNotEmpty) {
                  //               print("send reset link");
                  //               resetPassword(onActivityResult['userEmail']);
                  //               _scaffoldKey.currentState.hideCurrentSnackBar();
                  //             } else {
                  //               print("Cancelled forgot passowrd");
                  //             }
                  //           });
                  //         },
                  //         child: Text(
                  //           "Forgot password",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 8),
                  // FlatButton(
                  //   materialTapTargetSize: MaterialTapTargetSize.padded,
                  //   padding: EdgeInsets.all(0),
                  //   onPressed: () async {
                  //     isLoading = true;
                  //     UserModel user = await Navigator.of(context).push(
                  //       MaterialPageRoute<UserModel>(
                  //         builder: (context) => RegisterPage(),
                  //       ),
                  //     );
                  //     isLoading = false;
                  //     if (user != null) _processLogin(user);
                  //   },
                  //   child: Text(
                  //     'Create an Account',
                  //     style: TextStyle(
                  //         color: Theme.of(context).accentColor,
                  //         fontWeight: FontWeight.w700),
                  //   ),
                  // )
                  // SizedBox(height: 30),
                ],
              ),
            )),
      ),
    );
  }

  String _textFieldControllerResetEmail = "";
  // TextEditingController _textFieldControllerResetEmail =
  //     TextEditingController();

  bool isEmailValidForReset = false;
  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  Widget get signInWithGoogle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            horizontalLine(),
            Text("Sign in with"),
            horizontalLine()
          ],
        ),
        SizedBox(
          height: ScreenUtil.getInstance().setHeight(20),
        ),
        Material(
          color: Colors.white,
          shape: CircleBorder(),
          child: InkWell(
            customBorder: CircleBorder(),
            onTap: useGoogleSignIn,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: Image.asset('lib/assets/google-logo-png-open-2000.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get poweredBySevaLogo {
    return Column(
      children: <Widget>[
        Text("Powered by",
            style: TextStyle(
                color: Colors.black38, fontSize: 12, letterSpacing: 1.0)),
        SizedBox(
          height: 35,
          child: Image.asset(
            'lib/assets/images/sticker.webp',
          ),
        )
      ],
    );
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.black54,
    );
  }

  void useGoogleSignIn() async {
    isLoading = true;
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    try {
      user = await auth.handleGoogleSignIn();
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {}
    isLoading = false;
    _processLogin(user);
  }

  void signInWithEmailAndPassword() async {
    if (!_formKey.currentState.validate()) return;
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState.save();
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    isLoading = true;
    try {
      user = await auth.signInWithEmailAndPassword(
        email: emailId.trim(),
        password: password,
      );
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {}
    isLoading = false;
    if (user == null) {
      return;
    }
    print(user);
    _processLogin(user);
  }

  void handlePlatformException(PlatformException error) {
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
              resetPassword(emailId);
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  String _validateEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return 'Enter email';
    if (!emailPattern.hasMatch(value)) return 'Email is not valid';
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Enter password';
    if (value.length < 6) return 'Password must be 6 characters long';
    return null;
  }

  void _saveEmail(String value) {
    this.emailId = value;
  }

  void _savePassword(String value) {
    this.password = value;
  }

  void _processLogin(UserModel userModel) {
    if (userModel == null) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SplashView(),
      ),
    );
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

  void showTermsPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    print('terms page clicked ' + dynamicLinks['termsAndConditionsLink']);

    navigateToWebView(
      aboutMode: AboutMode(
          title: "Terms of Service",
          urlToHit: dynamicLinks['termsAndConditionsLink']),
      context: context,
    );
  }

  void showPrivacyPolicyPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    print('privacy policy clicked ' + dynamicLinks['privacyPolicyLink']);

    navigateToWebView(
      aboutMode: AboutMode(
          title: "Privacy Policy", urlToHit: dynamicLinks['privacyPolicyLink']),
      context: context,
    );
  }

  void showPaymentPolicyPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    print('payment clicked ' + dynamicLinks['paymentPolicyLink']);
    navigateToWebView(
      aboutMode: AboutMode(
          title: "Payment Policy", urlToHit: dynamicLinks['paymentPolicyLink']),
      context: context,
    );
  }

  void navigateToWebView({
    BuildContext context,
    AboutMode aboutMode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevaWebView(aboutMode),
      ),
    );
  }
}
