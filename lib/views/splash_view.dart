import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/bioview.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/register_location.dart';
import 'package:sevaexchange/views/skillsview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sevaexchange/views/timebanks/timebank_pinView.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';


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
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String _loadingMessage = '';
  bool _initialized = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      loadingMessage = 'Loading Assets';
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
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor
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
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 2,
                  width: 150,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
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
              Color.fromARGB(255, 9, 46, 108),
              Color.fromARGB(255, 88, 138, 224),
              Colors.white,
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
                'lib/assets/Y_from_Andrew_Yang_2020_logo.png',
                height: 140,
                width: 140,
              ),
              if (loadingMessage != null && loadingMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(loadingMessage),
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
    loadingMessage = 'Finding user docs';
    _getLoggedInUserId().then(handleLoggedInUserIdResponse).catchError((error) {
      print('Error checking login status: $error');
    });
  }

  Future<String> _getLoggedInUserId() async {
    String userId = await PreferenceManager.loggedInUserId;
    UserData.shared.userId = userId;
    print(userId);
    return userId;
  }

  Future<void> handleLoggedInUserIdResponse(String userId) async {
    if (userId == null || userId.isEmpty) {
      loadingMessage = 'Initializing Login';
      _navigateToLoginPage();
      return;
    }
   // UserData.shared._getSignedInUserDocs(userId);

    UserModel loggedInUser = await _getSignedInUserDocs(userId);
    if (loggedInUser == null) {
      // TODO: Fix this
      loadingMessage = 'Creating user documents';
      _navigateToLoginPage();
      return;
    }
    UserData.shared.user = loggedInUser;
//    print(loggedInUser.requestStatus);
    print(loggedInUser.calendar);

    if (loggedInUser.skills == null) {
      await _navigateToSkillsView(loggedInUser);
    }

    if (loggedInUser.interests == null) {
      await _navigateToInterestsView(loggedInUser);
    }

    if (loggedInUser.bio == null) {
      await _navigateToBioView(loggedInUser);
    }

    if (loggedInUser.calendar == null) {
      await _navigateToCalendarView(loggedInUser);
    }
    if (loggedInUser.requestStatus == "pending") {
      await _navigateToWaitingView(loggedInUser);
    }



    loadingMessage = 'Finalizing';
    _navigateToCoreView(loggedInUser);
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

  Future _navigateToSkillsView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SkillViewNew(
          onSelectedSkills: (skills) {
            Navigator.pop(context);
            loggedInUser.skills = skills;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating skills';
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.skills = [];
            updateUserData(loggedInUser);
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

  Future _navigateToCalendarView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationView(
          onSelectedCalendar: (calendar) {
            Navigator.pop(context);
            loggedInUser.calendar = calendar;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating Calendar';
          },
          onSkipped: () {
            Navigator.pop(context);
            //loggedInUser.calendar = null;
            updateUserData(loggedInUser);
            loadingMessage = 'Skipping Calendar';
          },
        ),
      ),
    );
  }

  Future _navigateToPinView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PinView(
          onSelectedOtp: (otp) {
//            Navigator.pop(context);
//            loggedInUser.otp = otp;
//            updateUserData(loggedInUser);
//            loadingMessage = 'Checking Otp';
          },
          onSkipped: () {
//            Navigator.pop(context);
//            loggedInUser.otp = null;
//            updateUserData(loggedInUser);
//            loadingMessage = 'Skipping Otp';
          },
        ),
      ),
    );
  }

  Future _navigateToInterestsView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterestViewNew(
          onSelectedInterests: (interests) {
            Navigator.pop(context);
            loggedInUser.interests = interests;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating interests';
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.interests = [];
            updateUserData(loggedInUser);
            loadingMessage = 'Skipping interests';
          },
        ),
      ),
    );
  }

  Future _navigateToBioView(UserModel loggedInUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BioView(
          onSave: (bio) {
            Navigator.pop(context);
            loggedInUser.bio = bio;
            updateUserData(loggedInUser);
            loadingMessage = 'Updating bio';
          },
          onSkipped: () {
            Navigator.pop(context);
            loggedInUser.bio = '';
            updateUserData(loggedInUser);
            loadingMessage = 'Skipping bio';
          },
        ),
      ),
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
          child: CoreView(
            sevaUserID: loggedInUser.sevaUserID,
          ),
        ),
      ),
    );
  }

  Future<void> _precacheImage() async {
    return await precacheImage(
      AssetImage('lib/assets/Y_from_Andrew_Yang_2020_logo.png'),
      context,
    );
  }

  set loadingMessage(String loadingMessage) {
    setState(() => _loadingMessage = loadingMessage);
  }

  String get loadingMessage => this._loadingMessage;
}
