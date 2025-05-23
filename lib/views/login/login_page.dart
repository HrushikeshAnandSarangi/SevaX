import 'dart:async';
import 'dart:convert';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_screen.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_dashboard.dart';
import 'package:uni_links/uni_links.dart';
import 'package:universal_io/io.dart' as io;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doseform/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart' as seva_auth_provider;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/empty_text_span.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<DoseFormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKeyDialog = GlobalKey();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Alignment childAlignment = Alignment.center;
  bool _isLoading = false;
  final pwdFocus = FocusNode();
  final emailFocus = FocusNode();
  String? emailId;
  String? password;
  bool _shouldObscurePassword = true;
  Color enabled = Colors.white.withAlpha(120);
  BuildContext? parentContext;
  GeoFirePoint? location;
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();

  void initState() {
    super.initState();

    if (io.Platform.isIOS) {
      SignInWithApple.getCredentialState("");
    }
    fetchRemoteConfig();
  }

//  Future<void> delete() async {
//    await CollectionRef
//        .communities
//        .get()
//        .then((snapshot) {
//      for (DocumentSnapshot ds in snapshot.documents) {
//        if (ds.id != '73d0de2c-198b-4788-be64-a804700a88a4') {
//          ds.reference.delete();
//        }
//      }
//    });
//  }

  Future<void> fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.fetchAndActivate();
    AppConfig.remoteConfig = remoteConfig;
  }

  Widget horizontalLine() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: 120,
        height: 1.0,
        color: Colors.black26.withAlpha(51), // 0.2 * 255 ≈ 51
      ));
  @override
  Widget build(BuildContext context) {
    parentContext = context;
    // var appLanguage = Provider.of<AppLanguage>(context);
    // Locale _sysLng = ui.window.locale;
    // Locale _language = S.delegate.isSupported(_sysLng) ? _sysLng : Locale('en');
    // appLanguage.changeLanguage(_language);
    //UserData.shared.isFromLogin = true;
    //Todo check this line
    // Place image and email form side by side
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo/Image
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 32.0),
            child: Image.asset(
              'lib/assets/images/seva-x-logo.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
        // Email/password form
        Expanded(
          flex: 2,
          child: content,
        ),
      ],
    );
    // ScreenUtil.init(context);
    // ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    // getDynamicLinkData(context);
    handleBulkInviteLinkData();

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
              logger.d("NAVIGATING TO REGISTER!");
              UserModel? user = await Navigator.of(context).push(
                MaterialPageRoute<UserModel>(
                  builder: (context) => RegisterPage(),
                ),
              );
              isLoading = false;
              if (user != null)
                _processLogin(user);
              else
                logger.d("USER IS NULL!");
            },
            child: Text(
              S.of(context).sign_up,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
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
                UserModel? user = await Navigator.of(context).push(
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
                            width: 320,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Form(
                                  key: _formKeyDialog,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextButton(
                                      color: HexColor("#d2d2d2"),
                                      child: Text(
                                        S.of(context).cancel,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'Europa',
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
                                    SizedBox(
                                      width: 8,
                                    ),
                                    CustomTextButton(
                                      shape: StadiumBorder(),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      textColor:
                                          FlavorConfig.values.buttonTextColor,
                                      child: Text(
                                        S.of(context).reset_password,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'Europa',
                                        ),
                                      ),
                                      onPressed: () {
                                        if (!_formKeyDialog.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        Navigator.of(_context).pop(
                                          {
                                            "sendResetLink": true,
                                            "userEmail":
                                                _textFieldControllerResetEmail
                                                    .trim()
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
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    } else {}
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    S.of(context).reset,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
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
      resizeToAvoidBottomInset: true,
      // key: _scaffoldKey,
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
                padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 0.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(top: 35, bottom: 50.0),
                      child: TextButton.icon(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.secondary),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => ExplorePage(
                                  isUserSignedIn: false,
                                ),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        label: Text(
                          S.of(context).go_back,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
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
                      height: 50,
                      child: CustomElevatedButton(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 2.0,
                        textColor: Colors.white,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(S.of(context).check_internet),
                                      action: SnackBarAction(
                                        label: S.of(context).dismiss,
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
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
                    color: Colors.grey.withAlpha(128), // 0.5 * 255 ≈ 128
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
      Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        height: 200,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 0.0),
          child: DoseForm(
            formKey: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DoseTextField(
                    isRequired: true,
                    focusNode: emailFocus,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: textStyle,
                    // cursorColor: Colors.black54,
                    controller: emailController,
                    validator: (value) => _validateEmailId(value),
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
                    )),
                DoseTextField(
                  controller: passwordController,
                  isRequired: true,
                  focusNode: pwdFocus,
                  obscureText: _shouldObscurePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: textStyle,
                  maxLines: 1,
                  // cursorColor: Colors.black54,
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
                          setState(() {
                            _shouldObscurePassword = !_shouldObscurePassword;
                          });
                        },
                        child: Icon(
                          _shouldObscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      )),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
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
    'barney@yopmail.com',
    'umesha@uipep.com',
    'tony@yopmail.com',
    'robert@yopmail.com',
    'howard@yopmail.com',
    'chaman@yopmail.com',
    'adi007footballer@gmail.com',
  ];
  Widget get directDevLogin {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: emails
            .map(
              (e) => CustomTextButton(
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
    if (io.Platform.isIOS) {
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
              S.of(context).sign_in_with_apple,
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
          child: Container(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,
                  child: Image.asset('lib/assets/images/g.png'),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  S.of(context).sign_in_with_google,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Europa',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget signInButton({String? imageRef, String? msg, Function? operation}) {
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
        onTap: () => operation!(),
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
    Auth auth = seva_auth_provider.AuthProvider.of(context).auth;
    UserModel? user;
    try {
      user = await auth.signInWithApple();
      if (user != null) {
        await getAndUpdateDeviceDetailsOfUser(
            locationVal: location, userEmailId: user.email);
      }
    } on FirebaseAuthException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception {
      // Handle exception silently
    }
    isLoading = false;
    if (user != null) {
      _processLogin(user);
    }
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.black54,
    );
  }

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
    Auth auth = seva_auth_provider.AuthProvider.of(context).auth;
    UserModel? user;
    try {
      // Use same method for both web and mobile
      user = await auth.handleGoogleSignIn();
      logger.d("#user ${user}");
      if (user != null) {
        await getAndUpdateDeviceDetailsOfUser(
            locationVal: location, userEmailId: user.email);
      }
    } on FirebaseAuthException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {
      // FirebaseCrashlytics.instance.log(error.toString());
    }
    isLoading = false;
    if (user != null) {
      _processLogin(user);
    }
  }

  void signInWithEmailAndPassword({validate = true}) async {
    if (!_formKey.currentState!.validate() && validate) return;
    FocusScope.of(context).unfocus();
    if (validate) _formKey.currentState!.save();
    Auth auth = seva_auth_provider.AuthProvider.of(context).auth;
    UserModel? user;
    isLoading = true;
    try {
      if (emailId == null || password == null) {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(S.of(context).enter_email +
                  ' & ' +
                  S.of(context).enter_password)),
        );
        return;
      }
      user = await auth.signInWithEmailAndPassword(
        email: emailId!.trim().toLowerCase(),
        password: password!,
      );
      await getAndUpdateDeviceDetailsOfUser(
              locationVal: location, userEmailId: user!.email)
          .timeout(Duration(seconds: 3));
      logger.i('device details fixed');
    } on TimeoutException catch (e) {
      logger.e('timeout exception $e');
    } on NoSuchMethodError catch (error) {
      logger.e(error);
      handleException();
      // FirebaseCrashlytics.instance.log("No Such methods error in login!");
    } on FirebaseAuthException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {
      handlePlatformException(error.toString() as FirebaseAuthException);
      // FirebaseCrashlytics.instance.log(error.toString());
    }
    isLoading = false;
    if (user == null) {
      return;
    }
    _processLogin(user);
  }

  void handleException() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).no_user_found),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void handlePlatformException(FirebaseAuthException error) {
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
              resetPassword(emailId!);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  String? _validateEmailId(String? value) {
    if (value == null || value.isEmpty) return S.of(context).enter_email;
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailPattern.hasMatch(value))
      return S.of(context).validation_error_invalid_email;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return S.of(context).enter_password;
    if (value.length < 6)
      return S.of(context).validation_error_invalid_password;
    return null;
  }

  void _saveEmail(String? value) {
    if (value != null) {
      this.emailId = value.toLowerCase();
    }
  }

  void _savePassword(String? value) {
    this.password = value;
  }

  void _processLogin(UserModel userModel) {
    logger.d("INSIDE PROCESS LOGIN ====");

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeDashBoard()),
    );
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
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

  void showTermsPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
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
      AppConfig.remoteConfig!.getString(
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

  Future<void> showPaymentPolicyPage() async {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
        "links_" + S.of(context).localeName,
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_payment_link,
          urlToHit: dynamicLinks['paymentPolicyLink']),
      context: context,
    );
    // Use uni_links package for deep linking
    try {
      // Get any initial link that opened the app
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        final uri = Uri.parse(initialLink);
        await handleBulkInviteLinkData(uri: uri);
      }
    } catch (e) {
      logger.e('Error handling deep link: $e');
    }
    // final initialLink = await getInitialLink();
    // if (initialLink != null) {
    //   final uri = Uri.parse(initialLink);
    //   await handleBulkInviteLinkData(uri: uri);
    // }
  }

  Future<bool> handleBulkInviteLinkData({Uri? uri}) async {
    if (uri == null) return false;

    final queryParams = uri.queryParameters;
    final String? invitedMemberEmail = queryParams["email"];
    if (queryParams.containsKey("isFromBulkInvite") &&
        queryParams["isFromBulkInvite"] == 'true' &&
        invitedMemberEmail != null) {
      resetDynamicLinkPassword(invitedMemberEmail);
      return true;
    }
    return false;
  }

  Future<void> resetDynamicLinkPassword(String email) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((onValue) {
      showDialog(
        context: parentContext!,
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
    });
  }
}
