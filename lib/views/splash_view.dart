import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as fireStoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/bioview.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/skillsview.dart';

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

  void initiateLogin() {
    loadingMessage = 'Finding user docs';
    _getLoggedInUserId().then(handleLoggedInUserIdResponse).catchError((error) {
      print('Error checking login status: $error');
    });
  }

  Future<String> _getLoggedInUserId() async {
    String userId = await PreferenceManager.loggedInUserId;
    return userId;
  }

  Future<void> handleLoggedInUserIdResponse(String userId) async {
    if (userId == null || userId.isEmpty) {
      loadingMessage = 'Initializing Login';
      _navigateToLoginPage();
      return;
    }

    UserModel loggedInUser = await _getSignedInUserDocs(userId);
    if (loggedInUser == null) {
      // TODO: Fix this
      loadingMessage = 'Creating user documents';
      _navigateToLoginPage();
      return;
    }

    if (loggedInUser.skills == null) {
      await _navigateToSkillsView(loggedInUser);
    }

    if (loggedInUser.interests == null) {
      await _navigateToInterestsView(loggedInUser);
    }

    if (loggedInUser.bio == null) {
      await _navigateToBioView(loggedInUser);
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
