import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/internationalization/applanguage.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/deep_link_manager/onboard_via_link.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/views/profile/language.dart';
import 'package:sevaexchange/views/splash_view.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKeyDialog = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Alignment childAlignment = Alignment.center;
  bool _isLoading = false;
  final pwdFocus = FocusNode();
  String emailId;
  String password;
  bool _shouldObscurePassword = true;
  Color enabled = Colors.white.withAlpha(120);

  void initState() {
    super.initState();
    if (Platform.isIOS) {
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Credentials revoked");
      });
    }
    fetchRemoteConfig();
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: Duration.zero);
    AppConfig.remoteConfig.activateFetched();
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: 120,
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    var _sysLng = ui.window.locale.languageCode;
    var language =
        new LanguageListData().getLanguageSupported(_sysLng.toString());
    appLanguage.changeLanguage(Locale(language.code));
    UserData.shared.isFromLogin = true;
    //Todo check this line
    // ScreenUtil.init(context);
    // ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    // getDynamicLinkData(context);
    fetchBulkInviteLinkData();
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
                      height: 60,
                    ),
                    content,
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                        text: AppLocalizations.of(context)
                            .translate('login', 'by_continuing'),
                        children: <TextSpan>[
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login', 'terms'),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showTermsPage),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login', 'will_manage')),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login', 'privacy_policy'),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showPrivacyPolicyPage),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login', 'and')),
                          TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('login', 'payment_policy'),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = showPaymentPolicyPage),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                  .translate('login', 'new_user'),
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
                                AppLocalizations.of(context)
                                    .translate('login', 'signup'),
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
                              AppLocalizations.of(context)
                                  .translate('login', 'forgot_password'),
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
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'login', 'enter_email'),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Form(
                                                  key: _formKeyDialog,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        return AppLocalizations
                                                                .of(context)
                                                            .translate('login',
                                                                'enter_email_to_reset');
                                                      } else if (!validateEmail(
                                                          value.trim())) {
                                                        return AppLocalizations
                                                                .of(context)
                                                            .translate('login',
                                                                'enter_valid_email');
                                                      }
                                                      _textFieldControllerResetEmail =
                                                          value;
                                                    },
                                                    onChanged: (value) {
                                                      print("$value");
                                                    },
                                                    initialValue: "",
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    controller: null,
                                                    decoration: InputDecoration(
                                                      hintText: AppLocalizations
                                                              .of(context)
                                                          .translate('login',
                                                              "your_email_address"),
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
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate('login',
                                                                'reset_password'),
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
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate('login',
                                                                'cancel'),
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
                                      AppLocalizations.of(context)
                                          .translate('login', 'reset'),
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: 145,
                      height: 39,
                      child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Color(0x0FF766FE0),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('login', 'signin'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                var connResult =
                                    await Connectivity().checkConnectivity();
                                if (connResult == ConnectivityResult.none) {
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate(
                                              'shared', 'check_internet')),
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
                                signInWithEmailAndPassword();
                              },
                      ),
                    ),
                    SizedBox(height: 10),
                    signInWithSocialMedia,
                    SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                    ),
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
          Offstage(),
          SizedBox(
            height: 16,
          ),
          Image.asset(
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
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(pwdFocus);
                    },
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                      labelText: AppLocalizations.of(context)
                          .translate('login', 'email_label'),
                      labelStyle: textStyle,
                    ),
                  ),
                  TextFormField(
                    focusNode: pwdFocus,
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
                        labelText: AppLocalizations.of(context)
                            .translate('login', 'password_label'),
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
                ],
              ),
            )),
      ),
    );
  }

  String _textFieldControllerResetEmail = "";

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

  Widget get signInWithSocialMedia {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            horizontalLine(),
            Text(AppLocalizations.of(context).translate('shared', 'or')),
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
              'Sign in with Apple',
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
            title: Text('Sign in with Google'),
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
      width: MediaQuery.of(context).size.width - 50,
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
      msg:
          AppLocalizations.of(context).translate('login', 'signin_with_google'),
      operation: useGoogleSignIn,
    );
  }

  Widget get appleLoginiPhone {
    return signInButton(
      imageRef: 'lib/assets/images/apple-logo.png',
      msg: AppLocalizations.of(context).translate('login', 'signin_with_apple'),
      operation: appleLogIn,
    );
  }

  void appleLogIn() async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('shared', 'check_internet')),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
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
      print("User apple:$user");
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {}
    isLoading = false;
    _processLogin(user);
  }

  Widget get poweredBySevaLogo {
    return Column(
      children: <Widget>[
        Text(AppLocalizations.of(context).translate('login', 'powered_by'),
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
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('shared', 'check_internet')),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
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
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
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
            label: AppLocalizations.of(context)
                .translate('login', 'change_password'),
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
    if (value.isEmpty)
      return AppLocalizations.of(context)
          .translate('login', 'enter_email_warn');
    if (!emailPattern.hasMatch(value))
      return AppLocalizations.of(context).translate('login', 'email_not_valid');
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return AppLocalizations.of(context)
          .translate('login', 'enter_password_warn');
    if (value.length < 6)
      return AppLocalizations.of(context)
          .translate('login', 'password_warn_8char');
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
        content: Text(AppLocalizations.of(context)
            .translate('login', 'reset_link_message')),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate('shared', 'dismiss'),
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ));
    });
  }

  void showTermsPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        AppLocalizations.of(context).translate('links', 'linkToWeb'),
      ),
    );
    print('terms page clicked ' + dynamicLinks['termsAndConditionsLink']);

    navigateToWebView(
      aboutMode: AboutMode(
          title: AppLocalizations.of(context)
              .translate('login', 'terms_of_service_link'),
          urlToHit: dynamicLinks['termsAndConditionsLink']),
      context: context,
    );
  }

  void showPrivacyPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        AppLocalizations.of(context).translate('links', 'linkToWeb'),
      ),
    );
    print('privacy policy clicked ' + dynamicLinks['privacyPolicyLink']);

    navigateToWebView(
      aboutMode: AboutMode(
          title: AppLocalizations.of(context)
              .translate('login', 'privacy_policy_link'),
          urlToHit: dynamicLinks['privacyPolicyLink']),
      context: context,
    );
  }

  void showPaymentPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        AppLocalizations.of(context).translate('links', 'linkToWeb'),
      ),
    );
    print('payment clicked ' + dynamicLinks['paymentPolicyLink']);
    navigateToWebView(
      aboutMode: AboutMode(
          title: AppLocalizations.of(context)
              .translate('login', 'payment_policy_link'),
          urlToHit: dynamicLinks['paymentPolicyLink']),
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

  void getDynamicLinkData(
    BuildContext context,
  ) async {
    await fetchBulkInviteLinkData();
  }

  Future<void> fetchBulkInviteLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    //buildContext = context;
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    await handleLinkData(data: link);
    FirebaseDynamicLinks.instance.onLink(onError: (_) async {
      print("Error!!!");
    }, onSuccess: (PendingDynamicLinkData dynamicLink) async {
      return handleBulkInviteLinkData(
        data: dynamicLink,
      );
    });

    // This will handle incoming links if the application is already opened
  }

  Future<bool> handleBulkInviteLinkData({
    PendingDynamicLinkData data,
  }) async {
    final Uri uri = data?.link;
    if (uri != null) {
      final queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
        String invitedMemberEmail = queryParams["invitedMemberEmail"];
        String communityId = queryParams["communityId"];
        String primaryTimebankId = queryParams["primaryTimebankId"];
        if (queryParams.containsKey("isFromBulkInvite") &&
            queryParams["isFromBulkInvite"] == 'true') {
          resetPassword(
            invitedMemberEmail,
          );
        }
      }
    }
    return false;
  }

  Future<void> resetPasswordd(String email, BuildContext mContext) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((onValue) {
      showDialog<AlertDialog>(
        context: mContext,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(AppLocalizations.of(mContext)
                .translate('login', 'reset_password')),
            content: Container(
              height: MediaQuery.of(mContext).size.height / 10,
              width: MediaQuery.of(mContext).size.width / 12,
              child: Text(
                AppLocalizations.of(mContext)
                    .translate('login', 'reset_link_message'),
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text(
                    AppLocalizations.of(mContext).translate('shared', 'close')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

//    _scaffoldKey.currentState.showSnackBar(SnackBar(
//      content: Text(AppLocalizations.of(context)
//          .translate('login', 'reset_link_message')),
//      action: SnackBarAction(
//        label: AppLocalizations.of(context).translate('shared', 'dismiss'),
//        onPressed: () {
//          _scaffoldKey.currentState.hideCurrentSnackBar();
//        },
//      ),
//    ));
    });
  }
}
