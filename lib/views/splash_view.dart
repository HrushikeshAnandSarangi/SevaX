import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flurry/flurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/screens/onboarding/email_verify_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/deep_link_manager/onboard_via_link.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/IntroSlideForHumanityFirst.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/onboarding/bioview.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/eula_agreememnt.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';
import 'package:sevaexchange/views/workshop/UpdateApp.dart';

import 'onboarding/interests_view.dart';
import 'onboarding/skills_view.dart';

//class UserData {
//  static UserModel user;
//
//  UserData({
//   this.user;
//  });
//
//  Future updateUserData(UserModel user) async {
//    await fireStoreManager.updateUser(user: user);
//  }
//  Future<UserModel> _getSignedInUserDocs(String userId) async {
//    UserModel userModel = await fireStoreManager.getUserForId(
//      sevaUserId: userId,
//    );
//    user = userModel;
//    return user;
//  }
//}
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

  Future _getSignedInUserDocs(String userId) async {
    UserModel userModel = await fireStoreManager.getUserForId(
      sevaUserId: userId,
    );
    user = userModel;
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
  final _firestore = Firestore();

  @override
  void initState() {
    super.initState();
    initFlurry();
  }

  void initFlurry() async {
    await Flurry.initialize(
      androidKey: "NZN3QTYM42M6ZQXV3GJ8",
      iosKey: "H9RX59248T458TDZGX3Y",
      enableLog: true,
    );
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
      case Flavor.SEVA_DEV:
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
              // Text(
              //   'Seva\nExchange'.toUpperCase(),
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     letterSpacing: 5,
              //     fontSize: 24,
              //     color: Colors.white,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // SizedBox(
              //   height: 16,
              // ),
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
    _getLoggedInUserId().then(handleLoggedInUserIdResponse).catchError((error) {
      print("Inside -> Error $error");
    });
  }

  Future<String> _getLoggedInUserId() async {
    String userId = await PreferenceManager.loggedInUserId;

    UserData.shared.userId = userId;

    return userId;
  }

//  Future checkVersion() async {
//    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
//      String appName = packageInfo.appName;
//      String packageName = packageInfo.packageName;
//      String version = packageInfo.version;
//
//      String buildNumber = packageInfo.buildNumber;
//
//      Firestore.instance
//          .collection("vitals")
//          .document(Platform.isAndroid ? "vital_android" : "vital_ios")
//          .get()
//          .then((onValue) {
//        if (Platform.isAndroid) {
//          // we are on android platform
//          if (onValue.data.containsKey("latest_build_number")) {
//            var latestBuildNumber = onValue.data['latest_build_number'];
//            if (int.parse(buildNumber) < latestBuildNumber) {
//              print("App is Out of date");
//              _navigateToUpdatePage();
//            } else {
//              print("App is up to date");
//            }
//          }
//        } else {
//          //This is an IOS PLatform data you get from here onValue.data.containsKey("latest_build_number")
//
//          if (onValue.data.containsKey("latest_version_number")) {
//            var latestBuildNumber = onValue.data['latest_version_number'];
//            if (int.parse(buildNumber) < latestBuildNumber) {
//              print("App is Out of date");
//              _navigateToUpdatePage();
//            } else {
//              print("App is up to date");
//            }
//          }
//
////          _navigateToUpdatePage();
////          onValue.data.containsKey("latest_build_number");
////          print(onValue.data.containsKey("latest_build_number"));
//        }
//      });
//    });
//  }

  Future<void> handleLoggedInUserIdResponse(String userId) async {
    if (userId == null || userId.isEmpty) {
      loadingMessage = 'Hang on tight';
      _navigateToLoginPage();
      return;
    }
    await fetchLinkData();

    UserModel loggedInUser = await _getSignedInUserDocs(userId);

    print("---> ${loggedInUser.currentCommunity}");
    if ((loggedInUser.currentCommunity == " " ||
            loggedInUser.currentCommunity == "" ||
            loggedInUser.currentCommunity == null) &&
        loggedInUser.communities.length != 0) {
      loggedInUser.currentCommunity = loggedInUser.communities.elementAt(0);
      await Firestore.instance
          .collection("users")
          .document(loggedInUser.email)
          .updateData({
        'currentCommunity': loggedInUser.communities[0],
      });
    }

    if (loggedInUser == null) {
      loadingMessage = 'Welcome to the world of communities';
      _navigateToLoginPage();
      return;
    }
    UserData.shared.user = loggedInUser;

    await AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 3));
    await AppConfig.remoteConfig.activateFetched();

    //// ################################    TEST ################################# /////
    // var sampleJson =
    //     '{"android":{"build":70,"version_name":"7.0.0","forceUpdate":false},"ios":{"build":70,"version_name":"7.0.0","forceUpdate":false}}';
    // Map<String, dynamic> versionInfo = json.decode(sampleJson);

    Map<String, dynamic> versionInfo =
        json.decode(AppConfig.remoteConfig.getString('app_version'));

    if (Platform.isAndroid) {
      await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
        // print("version details ${packageInfo.version}");
        globals.currentVersionNumber = packageInfo.version.toString();
        if (int.parse(packageInfo.buildNumber) <
            versionInfo['android']['build']) {
          print("New version available");

          if (versionInfo['android']['forceUpdate']) {
            print("User must update the app");
            await _navigateToUpdatePage(loggedInUser, true);
          } else {
            await _navigateToUpdatePage(loggedInUser, false);
          }
        } else {
          print("You are using the latest version of the application");
        }
      });
    } else if (Platform.isIOS) {
      await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
        if (int.parse(packageInfo.buildNumber) < versionInfo['ios']['build']) {
          print("New version available");
          if (versionInfo['ios']['forceUpdate']) {
            await _navigateToUpdatePage(loggedInUser, true);
          } else {
            await _navigateToUpdatePage(loggedInUser, false);
          }
        } else {
          print("You are using the latest version of the application");
        }
      });
    }

    if (widget.skipToHomePage) {
      print('Navigating to home page');
      _navigateToCoreView(loggedInUser);
    }

    if (FlavorConfig.appFlavor != Flavor.SEVA_DEV)
      await FirebaseAuth.instance
          .currentUser()
          .then((FirebaseUser firebaseUser) async {
        if (firebaseUser != null) {
          if (!firebaseUser.isEmailVerified) {
            await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => VerifyEmail(
                    firebaseUser: firebaseUser,
                    email: loggedInUser.email,
                    emailSent: loggedInUser.emailSent,
                  ),
                ),
                (Route<dynamic> route) => false);
          }
        }
      });

    if (!loggedInUser.acceptedEULA) {
      await _navigateToEULA(loggedInUser);
    }

    if (!(AppConfig.prefs.getBool(AppConfig.skip_skill) ?? false) &&
        loggedInUser.skills == null) {
      await _navigateToSkillsView(loggedInUser);
    }

    if (!(AppConfig.prefs.getBool(AppConfig.skip_interest) ?? false) &&
        loggedInUser.interests == null) {
      await _navigateToInterestsView(loggedInUser);
    }

    if (!(AppConfig.prefs.getBool(AppConfig.skip_bio) ?? false) &&
        loggedInUser.bio == null) {
      await _navigateToBioView(loggedInUser);
    }
    loadingMessage = 'We met before';

    if (loggedInUser.communities == null || loggedInUser.communities.isEmpty) {
      await _navigateToFindCommunitiesView(loggedInUser);
    } else {
      _navigateToCoreView(loggedInUser);
    }
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

  Future _navigateToEULA(UserModel loggedInUser) async {
    print("EULA -> ${loggedInUser.toString()}");

    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EulaAgreement(),
      ),
    );

    if (results != null && results['response'] == "ACCEPTED") {
      //UPDATE THE DB HERE
      //print("${SevaCore.of(context).loggedInUser.email} User has agreed to EULA");

      await Firestore.instance
          .collection('users')
          .document(loggedInUser.email)
          .updateData({'acceptedEULA': true}).then((onValue) {
        print("Updating completed");
      }).catchError((onError) {
        print("Error Updating introduction");
      });
    }
  }

  Future _addMemberToCommunity(UserModel loggedInUser) async {
    // await Firestore.instance.collection('users').document(loggedInUser.email);
    print("Here we go we found the member from match");
  }

  Future _navogateToIntro(UserModel loggedInUser) async {
    print("Intro -> ${loggedInUser.toString()}");

    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IntroScreenHukanityFirst(),
      ),
    );

    if (results != null &&
        (results['response'] == "ACCEPTED" ||
            results['response'] == "SKIPPED")) {
      await Firestore.instance
          .collection('users')
          .document(loggedInUser.email)
          .updateData({'completedIntro': true}).then((onValue) {
        print("Updating Introcuction part");
      }).catchError((onError) {
        print("Error in introdution part");
      });
    }
  }

  Future _navigateToSkillsView(UserModel loggedInUser) async {
    AppConfig.prefs.setBool(AppConfig.skip_skill, null);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SkillViewNew(
          automaticallyImplyLeading: false,
          userModel: loggedInUser,
          isFromProfile: false,
          onSelectedSkills: (skills) {
            Navigator.pop(context);
            loggedInUser.skills = skills;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating skills';
          },
          onSkipped: () {
            Navigator.pop(context);
            AppConfig.prefs.setBool(AppConfig.skip_skill, true);
            loggedInUser.skills = [];
            loadingMessage = 'Skipping skills';
          },
        ),
      ),
    );
  }

  Future _navigateToWaitingView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WaitingView(),
      ),
    );
  }

  Future _navigateToInterestsView(UserModel loggedInUser) async {
    AppConfig.prefs.setBool(AppConfig.skip_interest, null);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterestViewNew(
          automaticallyImplyLeading: false,
          userModel: loggedInUser,
          isFromProfile: false,
          onSelectedInterests: (interests) {
            Navigator.pop(context);
            loggedInUser.interests = interests;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating interests';
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.interests = [];
            AppConfig.prefs.setBool(AppConfig.skip_interest, true);
            loadingMessage = 'Skipping interests';
          },
          onBacked: () {
            AppConfig.prefs.setBool(AppConfig.skip_skill, null);
            _navigateToSkillsView(loggedInUser);
          },
        ),
      ),
    );
  }

  Future _navigateToBioView(UserModel loggedInUser) async {
    AppConfig.prefs.setBool(AppConfig.skip_bio, null);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BioView(onSave: (bio) {
          Navigator.pop(context);
          loggedInUser.bio = bio;
          updateUserData(loggedInUser);
          loadingMessage = 'Updating bio';
        }, onSkipped: () {
          Navigator.pop(context);
          loggedInUser.bio = '';
          AppConfig.prefs.setBool(AppConfig.skip_bio, true);
          loadingMessage = 'Skipping bio';
        }, onBacked: () {
          AppConfig.prefs.setBool(AppConfig.skip_interest, null);
          _navigateToInterestsView(loggedInUser);
        }),
      ),
    );
  }

  Future _navigateToFindCommunitiesView(UserModel loggedInUser) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SevaCore(
          loggedInUser: loggedInUser,
          child: FindCommunitiesView(
            keepOnBackPress: false,
            loggedInUser: loggedInUser,
            showBackBtn: false,
            isFromHome: false,
          ),
        ),
      ),
    );
  }

  Future _navigateToHome_DashBoardView(UserModel loggedInUser) async {
    print('hai');
    userBloc.updateUserDetails(loggedInUser);
    print('hey');
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              SevaCore(loggedInUser: loggedInUser, child: HomePageRouter())),
    );
  }

  Future updateUserData(UserModel user) async {
    await fireStoreManager.updateUser(user: user);
  }

  void _navigateToCoreView(UserModel loggedInUser) {
    assert(loggedInUser != null, 'Logged in User cannot be empty');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SevaCore(
          loggedInUser: loggedInUser,
          child: HomePageRouter(),
        ),
      ),
    );
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
