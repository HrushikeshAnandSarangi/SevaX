import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flurry/flurry.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/screens/onboarding/email_verify_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/onboarding/bioview.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/eula_agreememnt.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';
import 'package:sevaexchange/views/workshop/UpdateApp.dart';

import 'onboarding/interests_view.dart';
import 'onboarding/skills_view.dart';

class UserData {
  static final UserData _singleton = UserData._internal();

  factory UserData() => _singleton;

  UserData._internal();

  bool isFromLogin = true;

  static UserData get shared => _singleton;

  UserModel user = new UserModel();
  String userId;
  String locationStr;

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
        enableLog: true);
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
    return sevaAppSplash;
  }

  Widget get sevaAppSplash {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).secondaryHeaderColor
            ],
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

    Map<String, dynamic> versionInfo =
        json.decode(AppConfig.remoteConfig.getString('app_version'));

    if (Platform.isAndroid) {
      await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
        globals.currentVersionNumber = packageInfo.version.toString();
        if (int.parse(packageInfo.buildNumber) <
            versionInfo['android']['build']) {
          if (versionInfo['android']['forceUpdate']) {
            await _navigateToUpdatePage(loggedInUser, true);
          } else {
            await _navigateToUpdatePage(loggedInUser, false);
          }
        } else {}
      });
    } else if (Platform.isIOS) {
      await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
        if (int.parse(packageInfo.buildNumber) < versionInfo['ios']['build']) {
          if (versionInfo['ios']['forceUpdate']) {
            await _navigateToUpdatePage(loggedInUser, true);
          } else {
            await _navigateToUpdatePage(loggedInUser, false);
          }
        } else {}
      });
    }

    if (widget.skipToHomePage) {
      _navigateToCoreView(loggedInUser);
    }

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
        },
      ),
    ));
  }

  Future _navigateToEULA(UserModel loggedInUser) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EulaAgreement(),
      ),
    );

    if (results != null && results['response'] == "ACCEPTED") {
      await Firestore.instance
          .collection('users')
          .document(loggedInUser.email)
          .updateData({'acceptedEULA': true})
          .then((onValue) {})
          .catchError((onError) {});
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
    userBloc.updateUserDetails(loggedInUser);

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
