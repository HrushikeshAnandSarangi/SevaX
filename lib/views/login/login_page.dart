import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/views/login/register_page.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool _isLoading = false;

  String emailId;
  String password;
  bool _shouldObscurePassword = true;
  Color enabled = Colors.white.withAlpha(120);

  @override
  Widget build(BuildContext context) {
    UserData.shared.isFromLogin = true;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? [

//                    Color.fromARGB(255, 23, 54, 134),
//                    Color.fromARGB(255, 115, 132, 176),
//                    Color.fromARGB(255, 214, 222, 234),
                      Theme.of(context).primaryColor,
                     // Colors.white,
                      Theme.of(context).primaryColor,
                  ]
                : FlavorConfig.appFlavor == Flavor.TULSI
                    ? [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor,
                      ]
                    : FlavorConfig.appFlavor == Flavor.TOM
                        ? [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor,
                          ]
                        : [
                            Theme.of(context).primaryColor,
                            //Theme.of(context).primaryColorLight,
                            Theme.of(context).primaryColor,
                          ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlavorConfig.appFlavor == Flavor.APP
                      ? SizedBox(height: 5)
                      : SizedBox(height: 48),
                  logo,
                  SizedBox(height: 32),
                  content,
                  SizedBox(height: 16),
                  signInWithGoogle,
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                  FlavorConfig.appFlavor == Flavor.APP
                      ? Offstage()
                      : poweredBySevaLogo,
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
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
                    letterSpacing: 5,
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: textStyle,
                cursorColor: Colors.white,
                validator: _validateEmailId,
                onSaved: _saveEmail,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelText: 'EMAIL',
                  labelStyle: textStyle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: _shouldObscurePassword,
                style: textStyle,
                cursorColor: Colors.white,
                validator: _validatePassword,
                onSaved: _savePassword,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelText: 'PASSWORD',
                  labelStyle: textStyle,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _shouldObscurePassword = !_shouldObscurePassword;
                      });
                    },
                    child: Text(
                      'Show',
                      style: TextStyle(
                        fontSize: 12,
                        color: _shouldObscurePassword
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    onPressed: isLoading
                        ? null
                        : () {
                            signInWithEmailAndPassword();
                          },
                    color: Theme.of(context).accentColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isLoading)
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: Theme(
                              data: ThemeData(accentColor: Colors.white),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        SizedBox(width: 16),
                        Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: FlavorConfig.values.buttonTextColor,
                          ),
                        ),
                      ],
                    ),
                    shape: StadiumBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            FlatButton(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              padding: EdgeInsets.all(0),
              onPressed: () async {
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
                'Create an Account',
                style: TextStyle(color: Theme.of(context).accentColor,fontWeight: FontWeight.w700),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get signInWithGoogle {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 20, child: Divider(height: 3, color: enabled)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sign in with',
                style: TextStyle(color: enabled),
              ),
            ),
            SizedBox(width: 20, child: Divider(height: 3, color: enabled)),
          ],
        ),
        SizedBox(height: 16),
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
        SizedBox(
          height: 45,
          child: Image.asset(
            'lib/assets/images/sticker.webp',
          ),
        )
      ],
    );
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.white,
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
    _formKey.currentState.save();
    Auth auth = AuthProvider.of(context).auth;
    UserModel user;
    isLoading = true;
    try {
      user = await auth.signInWithEmailAndPassword(
        email: emailId,
        password: password,
      );
    } on PlatformException catch (erorr) {
      handlePlatformException(erorr);
    } on Exception catch (error) {}
    isLoading = false;
    if (user == null) {
      return;
    }

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
    if (value.isEmpty) return 'Enter Email Address';
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Enter password';
    return null;
  }

  void _saveEmail(String value) {
    this.emailId = value;
  }

  void _savePassword(String value) {
    this.password = value;
  }

  void _processLogin(UserModel userModel) {
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
}
