import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/widgets/empty_text_span.dart';

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
  final pwdFocus = FocusNode();
  final emailFocus = FocusNode();
  String emailId;
  String password;
  bool _shouldObscurePassword = true;
  Color enabled = Colors.white.withAlpha(120);
  BuildContext parentContext;
  GeoFirePoint location;

  void initState() {
    super.initState();

    if (Platform.isIOS) {
      AppleSignIn.onCredentialRevoked.listen((_) {});
    }
    fetchRemoteConfig();
  }

//  Future<void> delete() async {
//    await Firestore.instance
//        .collection('communities')
//        .getDocuments()
//        .then((snapshot) {
//      for (DocumentSnapshot ds in snapshot.documents) {
//        if (ds.documentID != '73d0de2c-198b-4788-be64-a804700a88a4') {
//          ds.reference.delete();
//        }
//      }
//    });
//  }

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
    parentContext = context;
    var appLanguage = Provider.of<AppLanguage>(context);
    Locale _sysLng = ui.window.locale;
    Locale _language = S.delegate.isSupported(_sysLng) ? _sysLng : Locale('en');
    appLanguage.changeLanguage(_language);
    //UserData.shared.isFromLogin = true;
    //Todo check this line
    // ScreenUtil.init(context);
    // ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    // getDynamicLinkData(context);
    fetchBulkInviteLinkData();

    bool textLengthCalculator(TextSpan span, size) {
      // Use a textpainter to determine if it will exceed max lines
      TextPainter tp = TextPainter(
        maxLines: 1,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: span,
      );
      // trigger it to layout
      tp.layout(maxWidth: size.maxWidth);
      // whether the text overflowed or not
      bool exceed = tp.didExceedMaxLines;
      return exceed;
    }

    List<Widget> signUpAndForgotPassword = <Widget>[
      Row(
        children: <Widget>[
          Text(
            S.of(context).new_user,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () async {
              isLoading = true;
              UserModel user = await Navigator.of(context).push(
                MaterialPageRoute<UserModel>(
                  builder: (context) => RegisterPage(),
                ),
              );
              isLoading = false;
              if (user != null) _processLogin(user);
            },
            child: Text(
              S.of(context).sign_up,
              style: TextStyle(
                color: Theme.of(context).accentColor,
              ),
            ),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Text(
            S.of(context).forgot_password,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          InkWell(
              onTap: () async {
                isLoading = true;
                UserModel user = await Navigator.of(context).push(
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
                      builder: (_context) {
                        return AlertDialog(
                          title: Text(
                            S.of(context).enter_email,
                          ),
                          content: Container(
                            width: 300,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Form(
                                  key: _formKeyDialog,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return S.of(context).enter_email;
                                      } else if (!validateEmail(value.trim())) {
                                        return S
                                            .of(context)
                                            .validation_error_invalid_email;
                                      }
                                      _textFieldControllerResetEmail = value;
                                      return null;
                                    },
                                    onChanged: (value) {},
                                    initialValue: "",
                                    keyboardType: TextInputType.emailAddress,
                                    controller: null,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).your_email,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    FlatButton(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 5, 10, 5),
                                      color: Theme.of(context).accentColor,
                                      textColor:
                                          FlavorConfig.values.buttonTextColor,
                                      child: Text(
                                        S.of(context).reset_password,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (!_formKeyDialog.currentState
                                            .validate()) {
                                          return;
                                        }
                                        Navigator.of(_context).pop({
                                          "sendResetLink": true,
                                          "userEmail":
                                              _textFieldControllerResetEmail
                                                  .trim()
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        S.of(context).cancel,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(_context).pop(
                                          {
                                            "sendResetLink": false,
                                            "userEmail": null
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
//                                LayoutBuilder(
//                                  builder: (context, size) {
//                                    TextSpan span = TextSpan(
//                                      text: S.of(context).reset_password +
//                                          '${Padding(padding: const EdgeInsets.only(left: 20))}' +
//                                          S.of(context).cancel,
//                                    );
//                                    return textLengthCalculator(span, size) ==
//                                            true
//                                        ? Wrap(
//                                            alignment: WrapAlignment.center,
//                                            crossAxisAlignment:
//                                                WrapCrossAlignment.center,
//                                            children:
//                                                resetPasswordAndCancelButton,
//                                          )
//                                        : Row(
//                                            children:
//                                                resetPasswordAndCancelButton,
//                                          );
//                                  },
//                                ),
                              ],
                            ),
                          ),
                        );
                      }).then((onActivityResult) {
                    if (onActivityResult != null &&
                        onActivityResult['sendResetLink'] != null &&
                        onActivityResult['sendResetLink'] &&
                        onActivityResult['userEmail'] != null &&
                        onActivityResult['userEmail'].toString().isNotEmpty) {
                      resetPassword(onActivityResult['userEmail']);
                      _scaffoldKey.currentState.hideCurrentSnackBar();
                    } else {}
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    S.of(context).reset,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ))
        ],
      ),
    ];

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
                        text: S.of(context).login_agreement_message1,
                        children: <TextSpan>[
                          emptyTextSpan(),
                          TextSpan(
                            text: S.of(context).login_agreement_terms_link,
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = showTermsPage,
                          ),
                          emptyTextSpan(),
                          TextSpan(
                            text: S.of(context).login_agreement_message2,
                          ),
                          emptyTextSpan(),
                          TextSpan(
                            text: S.of(context).login_agreement_privacy_link,
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = showPrivacyPolicyPage,
                          ),
                          emptyTextSpan(),
                          TextSpan(
                            text: S.of(context).and,
                          ),
                          emptyTextSpan(),
                          TextSpan(
                            text: S.of(context).login_agreement_payment_link,
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = showPaymentPolicyPage,
                          ),
                          emptyTextSpan(placeHolder: '.'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    LayoutBuilder(
                      builder: (context, size) {
                        TextSpan span = TextSpan(
                          text: S.of(context).new_user +
                              ' ' +
                              S.of(context).sign_up +
                              ' ' +
                              S.of(context).forgot_password +
                              ' ' +
                              S.of(context).reset,
                        );
                        return textLengthCalculator(span, size) == true
                            ? Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: signUpAndForgotPassword,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: signUpAndForgotPassword,
                              );
                      },
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: 145,
                      height: 39,
                      child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Color(0x0FF766FE0),
                        child: Text(
                          S.of(context).sign_in,
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
                                      content:
                                          Text(S.of(context).check_internet),
                                      action: SnackBarAction(
                                        label: S.of(context).dismiss,
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

  Future<void> gpsCheck() async {
    Location templocation = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    Geoflutterfire geo = Geoflutterfire();
    LocationData locationData;

    try {
      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        logger.i("requesting location");

        if (!_serviceEnabled) {
          return;
        } else {
          locationData = await templocation.getLocation();

          double lat = locationData?.latitude;
          double lng = locationData?.longitude;
          location = geo.point(latitude: lat, longitude: lng);
          setState(() {});
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        logger.i("requesting permission");
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        } else {
          locationData = await templocation.getLocation();
          double lat = locationData?.latitude;
          double lng = locationData?.longitude;
          location = geo.point(latitude: lat, longitude: lng);

          setState(() {});
        }
      } else {
        locationData = await templocation.getLocation();

        double lat = locationData?.latitude;
        double lng = locationData?.longitude;
        location = geo.point(latitude: lat, longitude: lng);

        setState(() {});
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        logger.e(e);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        logger.e(e);
      }
    }
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
      Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          height: 200,
          child: KeyboardActions(
            tapOutsideToDismiss: true,
            config: KeyboardActionsConfig(
              keyboardSeparatorColor: Colors.black38,
              keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
              actions: [KeyboardActionsItem(focusNode: emailFocus)],
            ),
            child: Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 0.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        focusNode: emailFocus,
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
                          labelText: S.of(context).email.toUpperCase(),
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
                            labelText: S.of(context).password.toUpperCase(),
                            labelStyle: textStyle,
                            suffix: GestureDetector(
                              onTap: () {
                                _shouldObscurePassword =
                                    !_shouldObscurePassword;
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
          )),
    );
  }

  String _textFieldControllerResetEmail = "";

  bool isEmailValidForReset = false;
  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
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
            Expanded(child: horizontalLine()),
            Text(S.of(context).or),
            Expanded(child: horizontalLine())
          ],
        ),
        SizedBox(
          height: 20,
        ),
        socialMediaLogin,
        FlavorConfig.appFlavor == Flavor.SEVA_DEV
            ? directDevLogin
            : Container(),
      ],
    );
  }

  List<String> emails = [
    'tony@yopmail.com',
    'robert@yopmail.com',
    'howard@yopmail.com',
    'chaman@yopmail.com',
  ];
  Widget get directDevLogin {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: emails
            .map(
              (e) => FlatButton(
                child: Text(e),
                onPressed: () {
                  emailId = e;
                  password = '123456';
                  signInWithEmailAndPassword(validate: false);
                },
              ),
            )
            .toList(),
      ),
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
      await getAndUpdateDeviceDetailsOfUser(
        locationVal: location,
      );
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {
      Crashlytics.instance.log(error.toString());
    }
    isLoading = false;
    _processLogin(user);
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
      await getAndUpdateDeviceDetailsOfUser(locationVal: location);
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {
      Crashlytics.instance.log(error.toString());
    }
    isLoading = false;
    _processLogin(user);
  }

  void signInWithEmailAndPassword({validate = true}) async {
    if (!_formKey.currentState.validate() && validate) return;
    FocusScope.of(context).unfocus();
    if (validate) _formKey.currentState.save();
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    isLoading = true;
    try {
      user = await auth.signInWithEmailAndPassword(
        email: emailId.trim(),
        password: password,
      );
      await getAndUpdateDeviceDetailsOfUser(locationVal: location)
          .timeout(Duration(seconds: 3));
      logger.i('device details fixed');
    } on TimeoutException catch (e) {
      logger.e('timeout exception $e');
    } on NoSuchMethodError catch (error) {
      logger.e(error);
      handleException();
      Crashlytics.instance.log("No Such methods error in login!");
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {
      handlePlatformException(error);
      Crashlytics.instance.log(error.toString());
    }
    isLoading = false;
    if (user == null) {
      return;
    }
    _processLogin(user);
  }

  void handleException() {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(S.of(context).no_user_found),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ),
    );
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
    if (value.isEmpty) return S.of(context).enter_email;
    if (!emailPattern.hasMatch(value))
      return S.of(context).validation_error_invalid_email;
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return S.of(context).enter_password;
    if (value.length < 6)
      return S.of(context).validation_error_invalid_password;
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

  void showTermsPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        "links_" + S.of(context).localeName,
      ),
    );

    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_terms_link,
          urlToHit: dynamicLinks['termsAndConditionsLink']),
      context: context,
    );
  }

  void showPrivacyPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        "links_" + S.of(context).localeName,
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_privacy_link,
          urlToHit: dynamicLinks['privacyPolicyLink']),
      context: context,
    );
  }

  void showPaymentPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        "links_" + S.of(context).localeName,
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_payment_link,
          urlToHit: dynamicLinks['paymentPolicyLink']),
      context: context,
    );
  }

  Future<void> fetchBulkInviteLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();

    //buildContext = context;
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    await handleBulkInviteLinkData(data: link);
    FirebaseDynamicLinks.instance.onLink(
        onError: (_) async {},
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
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

        //   String communityId = queryParams["communityId"];
        // String primaryTimebankId = queryParams["primaryTimebankId"];
        if (queryParams.containsKey("isFromBulkInvite") &&
            queryParams["isFromBulkInvite"] == 'true') {
          resetDynamicLinkPassword(invitedMemberEmail);
        }
      }
    }
    return false;
  }

  void resetDynamicLinkPassword(
    String email,
  ) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((onValue) {
      showDialog(
        context: parentContext,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(S.of(context).reset_password),
            content: Container(
              child: Text(
                S.of(context).reset_dynamic_link_message,
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text(S.of(context).close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }
}
