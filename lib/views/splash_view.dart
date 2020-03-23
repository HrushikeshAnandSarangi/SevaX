import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/user_info/utils/custom_router.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/workshop/UpdateApp.dart';

class UserData {
  // singleton
  static final UserData _singleton = UserData._internal();

  factory UserData() => _singleton;

  UserData._internal();

  bool isFromLogin = true;

  static UserData get shared => _singleton;

  // variables
  UserModel user = new UserModel();
  String userId;
  String locationStr;

  // UserModel user = await _getSignedInUserDocs(userId);

  Future updateUserData() async {
    await fireStoreManager.updateUser(user: user);
  }

  Future<String> _getLoggedInUserId() async {
    userId = await PreferenceManager.loggedInUserId;
    return userId;
  }
}

class SplashView extends StatefulWidget {
  final bool skipToHomePage;

  const SplashView({Key key, this.skipToHomePage = false}) : super(key: key);
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String _loadingMessage = '';
  bool _initialized = false;
  bool mainForced = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      loadingMessage = 'Hang on tight';
      _precacheImage().then((_) {
        initiateLogin();
      });
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (FlavorConfig.appFlavor) {
      case Flavor.APP:
        return sevaAppSplash;
        break;
      case Flavor.HUMANITY_FIRST:
        return humanitySplash;
        break;
      case Flavor.TULSI:
        return tulsiSplash;
        break;
      case Flavor.TOM:
        return tomSplash;
        break;
    }
  }

  Widget get sevaAppSplash {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Color.fromARGB(255, 9, 46, 108),
              // Color.fromARGB(255, 88, 138, 224),
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).secondaryHeaderColor
            ],
            //stops: [0, 0.6, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/assets/images/seva-x-logo.png',
                height: 140,
                width: 200,
              ),
              if (loadingMessage != null && loadingMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    loadingMessage,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  width: 150,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).splashColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get humanitySplash {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 4, 47, 110),
              Color.fromARGB(255, 4, 47, 110),
              Color.fromARGB(255, 4, 47, 110),
              //Colors.white,
            ],
            stops: [0, 0.6, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Humanity\nFirst'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 5,
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Image.asset(
                'lib/assets/images/new_yang.png',
                height: 140,
                width: 140,
              ),
              if (loadingMessage != null && loadingMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(loadingMessage,
                      style: TextStyle(color: Colors.white)),
                ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  width: 150,
                  child: LinearProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get tulsiSplash {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              // Colors.red,
              // Colors.red[400],
            ],
            //stops: [0, 0.6, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 16,
              ),
              SvgPicture.asset(
                'lib/assets/tulsi_icons/tulsi2020_icons_tulsi2020-logo.svg',
                height: 140,
                width: 140,
                color: Colors.white,
              ),
              SizedBox(
                height: 50,
              ),
              if (loadingMessage != null && loadingMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    loadingMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  width: 150,
                  child: Theme(
                      data: Theme.of(context)
                          .copyWith(accentColor: Colors.red[900]),
                      child: LinearProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get tomSplash {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              // Colors.red,
              // Colors.red[400],
            ],
            //stops: [0, 0.6, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   'Humanity\nFirst'.toUpperCase(),
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     letterSpacing: 5,
              //     fontSize: 24,
              //     color: Colors.white,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              SizedBox(
                height: 16,
              ),
              SvgPicture.asset(
                'lib/assets/ts2020-logo-w.svg',
                height: 90,
                width: 90,
                //color: Colors.white,
              ),
              SizedBox(
                height: 50,
              ),
              if (loadingMessage != null && loadingMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    loadingMessage,
                    style: TextStyle(color: Colors.white.withAlpha(120)),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  width: 150,
                  child: Theme(
                      data: Theme.of(context)
                          .copyWith(accentColor: Colors.red[900]),
                      child: LinearProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initiateLogin() {
    loadingMessage = 'Checking, if we met before';
    _getLoggedInUserId()
        .then(handleLoggedInUserIdResponse)
        .catchError((error) {});
  }

  Future<String> _getLoggedInUserId() async {
    String userId = await PreferenceManager.loggedInUserId;

    UserData.shared.userId = userId;

    return userId;
  }

  Future<void> handleLoggedInUserIdResponse(String userId) async {
    if (userId == null || userId.isEmpty) {
      loadingMessage = 'Hang on tight';
      _navigateToLoginPage();
      return;
    }

    UserModel loggedInUser = await _getSignedInUserDocs(userId);
    

    if (loggedInUser == null) {
      loadingMessage = 'Welcome to the world of communities';
      _navigateToLoginPage();
      return;
    }
    
    UserData.shared.user = loggedInUser;

    if (FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST) {
      //check app version
      bool isLatestVersion =
          await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        String appName = packageInfo.appName;
        String packageName = packageInfo.packageName;
        String version = packageInfo.version;

        String buildNumber = packageInfo.buildNumber;
        return Firestore.instance
            .collection("vitals")
            .document(Platform.isAndroid ? "vital_android" : "vital_ios")
            .get()
            .then((onValue) {
          if (Platform.isAndroid) {
            // we are on android platform
            if (onValue.data.containsKey("latest_build_number")) {
              var isForced = onValue.data['forced'];
              var latestBuildNumber = onValue.data['latest_build_number'];
              var latestVersionNumber = onValue.data['latest_version_number'];
              int result = int.parse(version.replaceAll(".", ""));
              int verionNumber =
                  int.parse(latestVersionNumber.replaceAll(".", ""));
              print(result);
              print(verionNumber);

              if (int.parse(buildNumber) < latestBuildNumber) {
                this.mainForced = isForced;
                print("App is Out of date");
                return false;
              } else {
                print("App is up to date");
                return true;
              }
            }
          } else {
            if (onValue.data.containsKey("latest_version_number")) {
              var latestVersionNumber = onValue.data['latest_version_number'];
              var isForced = onValue.data['forced'];
              int result = int.parse(version.replaceAll(".", ""));
              int verionNumber =
                  int.parse(latestVersionNumber.replaceAll(".", ""));
//            print(result);
//            print(verionNumber);

              if (result < verionNumber) {
                print("App is Out of date");
                this.mainForced = isForced;
                return false;
              } else {
                return true;
              }
            }

            return true;
            //This is an IOS PLatform data you get from here onValue.data.containsKey("latest_build_number");
          }
          return true;
        });
      });

      if (!isLatestVersion) {
        await _navigateToUpdatePage(loggedInUser, mainForced);
      }
    }
    customRouter(context: context, user: loggedInUser);
  }

  Future<UserModel> _getSignedInUserDocs(String userId) async {
    UserModel userModel = await fireStoreManager.getUserForId(
      sevaUserId: userId,
    );
    return userModel;
  }

  Future _navigateToLoginPage() async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LoginPage(),
    ));
  }

  Future _navigateToUpdatePage(UserModel loggedInUser, bool forced) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UpdateView(
        isForced: forced,
        onSkipped: () {
          Navigator.pop(context);
          updateUserData(loggedInUser);
          //this.isLatestVersion = !this.isLatestVersion;
        },
      ),
    ));
  }

  Future updateUserData(UserModel user) async {
    await fireStoreManager.updateUser(user: user);
  }

  Future<void> _precacheImage() async {
    return await precacheImage(
      AssetImage('lib/assets/images/new_yang.png'),
      context,
    );
  }

  set loadingMessage(String loadingMessage) {
    setState(() => _loadingMessage = loadingMessage);
  }

  String get loadingMessage => this._loadingMessage;
}
