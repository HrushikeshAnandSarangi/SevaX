import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flurry/flurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/internationalization/applanguage.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/screens/onboarding/email_verify_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/deep_link_manager/onboard_via_link.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/onboarding/bioview.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/eula_agreememnt.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';
import 'package:sevaexchange/views/workshop/UpdateApp.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    if (FlavorConfig.appFlavor == Flavor.APP) {
      initFlurry();
    }
    initLocaleForTimeAgoLibrary();
  }

  void initLocaleForTimeAgoLibrary() {
    timeago.setLocaleMessages('de', timeago.DeMessages());
    timeago.setLocaleMessages('dv', timeago.DvMessages());
    timeago.setLocaleMessages('dv_short', timeago.DvShortMessages());
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    timeago.setLocaleMessages('ca', timeago.CaMessages());
    timeago.setLocaleMessages('ca_short', timeago.CaShortMessages());
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    timeago.setLocaleMessages('km', timeago.KmMessages());
    timeago.setLocaleMessages('km_short', timeago.KmShortMessages());
    timeago.setLocaleMessages('id', timeago.IdMessages());
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
    timeago.setLocaleMessages('zh', timeago.ZhMessages());
    timeago.setLocaleMessages('it', timeago.ItMessages());
    timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
    timeago.setLocaleMessages('fa', timeago.FaMessages());
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('pl', timeago.PlMessages());
    timeago.setLocaleMessages('th', timeago.ThMessages());
    timeago.setLocaleMessages('th_short', timeago.ThShortMessages());
    timeago.setLocaleMessages('nb_NO', timeago.NbNoMessages());
    timeago.setLocaleMessages('nb_NO_short', timeago.NbNoShortMessages());
    timeago.setLocaleMessages('nn_NO', timeago.NnNoMessages());
    timeago.setLocaleMessages('nn_NO_short', timeago.NnNoShortMessages());
    timeago.setLocaleMessages('ku', timeago.KuMessages());
    timeago.setLocaleMessages('ku_short', timeago.KuShortMessages());
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
    timeago.setLocaleMessages('ko', timeago.KoMessages());
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
    timeago.setLocaleMessages('ta', timeago.TaMessages());
    timeago.setLocaleMessages('ro', timeago.RoMessages());
    timeago.setLocaleMessages('ro_short', timeago.RoShortMessages());
    timeago.setLocaleMessages('sv', timeago.SvMessages());
    timeago.setLocaleMessages('sv_short', timeago.SvShortMessages());
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
      Future.delayed(Duration.zero, () {
        loadingMessage =
            AppLocalizations.of(context).translate('splash', 'hang_on');
      });
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
                AppLocalizations.of(context)
                    .translate('splash', 'humanityfirst')
                    .toUpperCase(),
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
                'lib/assets/images/seva-x-logo.png',
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
            ],
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
            ],
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
    _getLoggedInUserId()
        .then(handleLoggedInUserIdResponse)
        .catchError((error) {});
  }

  Future<String> _getLoggedInUserId() async {
    String userId = await PreferenceManager.loggedInUserId;

    UserData.shared.userId = userId;

    return userId;
  }

  Future<UserModel> _getSignedInUserDocs(String userId) async {
    UserModel userModel = await fireStoreManager.getUserForId(
      sevaUserId: userId,
    );
    return userModel;
  }

  Future<void> handleLoggedInUserIdResponse(String userId) async {
    if (userId == null || userId.isEmpty) {
      loadingMessage =
          AppLocalizations.of(context).translate('splash', 'hang_on');
      _navigateToLoginPage();
      return;
    }
    await fetchLinkData();

    UserModel loggedInUser = await _getSignedInUserDocs(userId);
    var appLanguage = AppLanguage();
    appLanguage.changeLanguage(Locale(loggedInUser.language));

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

    await FCMNotificationManager.registerDeviceWithMemberForNotifications(
        loggedInUser.email);

    if (loggedInUser == null) {
      loadingMessage =
          AppLocalizations.of(context).translate('splash', 'world');
      _navigateToLoginPage();
      return;
    }

    UserData.shared.user = loggedInUser;

    await AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 3));
    await AppConfig.remoteConfig.activateFetched();

    Map<String, dynamic> versionInfo =
        json.decode(AppConfig.remoteConfig.getString('app_version'));

    if (Platform.isAndroid) {
      if (AppConfig.buildNumber < versionInfo['android']['build']) {
        if (versionInfo['android']['forceUpdate']) {
          await _navigateToUpdatePage(loggedInUser, true);
        } else {
          await _navigateToUpdatePage(loggedInUser, false);
        }
      } else {}
    } else if (Platform.isIOS) {
      if (AppConfig.buildNumber < versionInfo['ios']['build']) {
        if (versionInfo['ios']['forceUpdate']) {
          await _navigateToUpdatePage(loggedInUser, true);
        } else {
          await _navigateToUpdatePage(loggedInUser, false);
        }
      } else {}
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
    loadingMessage = AppLocalizations.of(context).translate('splash', 'we_met');

    if (loggedInUser.communities == null || loggedInUser.communities.isEmpty) {
      await _navigateToFindCommunitiesView(loggedInUser);
    } else {
      _navigateToCoreView(loggedInUser);
    }
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
            loadingMessage = AppLocalizations.of(context)
                .translate('skills', 'updating_loader');
          },
          onSkipped: () {
            Navigator.pop(context);
            AppConfig.prefs.setBool(AppConfig.skip_skill, true);
            loggedInUser.skills = [];
            loadingMessage = AppLocalizations.of(context)
                .translate('skills', 'skipping_loader');
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
            loadingMessage = AppLocalizations.of(context)
                .translate('interests', 'updating_loader');
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.interests = [];
            AppConfig.prefs.setBool(AppConfig.skip_interest, true);
            loadingMessage = AppLocalizations.of(context)
                .translate('interests', 'skipping_loader');
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
      AssetImage('lib/assets/images/seva-x-logo.png'),
      context,
    );
  }

  set loadingMessage(String loadingMessage) {
    setState(() => _loadingMessage = loadingMessage);
  }

  String get loadingMessage => this._loadingMessage;
}
