import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/splash_view.dart';

class AuthRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  String sevaUserId;

  AuthStatus authStatus;

  UserModel signedInUser;
  UserModel fetchedUser;

  String _loadingMessage;

  @override
  void initState() {
    super.initState();
    authStatus = AuthStatus.notDetermined;
    this._loadingMessage = '';
  }

  @override
  Widget build(BuildContext context) {
    switch (this.authStatus) {
      case AuthStatus.notDetermined:
        return getMaterialApp(
          child: SplashView(),
        );
        break;
      case AuthStatus.notSignedIn:
        // TODO: Handle this case.
        break;
      case AuthStatus.notCreated:
        // TODO: Handle this case.
        break;
      case AuthStatus.skillsNotSetup:
        // TODO: Handle this case.
        break;
      case AuthStatus.interestsNotSetup:
        // TODO: Handle this case.
        break;
      case AuthStatus.bioNotSetup:
        // TODO: Handle this case.
        break;
      case AuthStatus.signedIn:
        // TODO: Handle this case.
        break;
    }
  }

  //  @override
//  initState() {
//    super.initState();
//    authStatus = AuthStatus.notDetermined;
//    docStatus = UserDocStatus.waiting;
//
//    _checkIfUserLoggedIn().then((user) {
//      if (mounted) {
//        setState(() => authStatus =
//            user != null ? AuthStatus.signedIn : AuthStatus.notSignedIn);
//        this.fetchedUser = user;
//        if (user != null) {
//          refreshDocStatus();
//        }
//      }
//    });
//  }
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    var auth = AuthProvider.of(context).auth;
//    auth.getLoggedInUser().then((user) {
//      setState(() => authStatus =
//          user == null ? AuthStatus.notSignedIn : AuthStatus.signedIn);
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (signedInUser == null) {
//      if (authStatus == AuthStatus.notDetermined) {
//        return getMaterialApp(
//          child: Loader(
//            message: 'Loading',
//          ),
//        );
//      } else if (authStatus == AuthStatus.signedIn) {
//        return SevaCore(
//          loggedInUser: fetchedUser,
//          child: CoreView(
//            sevaUserID: this.sevaUserId,
//          ),
//        );
//      } else {
//        return getMaterialApp(
//          child: LoginPage(onSignedIn: (user) {
//            if (mounted) {
//              setState(() {
//                signedInUser = user;
//                refreshDocStatus();
//              });
//            }
//          }),
//        );
//      }
//    } else {
//      switch (docStatus) {
//        case UserDocStatus.existing:
//          return SevaCore(
//            loggedInUser: signedInUser,
//            child: CoreView(
//              sevaUserID: signedInUser.sevaUserID,
//            ),
//          );
//        case UserDocStatus.skillsNotSetup:
//          return getMaterialApp(
//            child: SkillViewNew(
//              onSkipped: _skip,
//              onSelectedSkills: (skills) {
//                this.signedInUser.skills = skills;
//                updateUserData(signedInUser);
//              },
//            ),
//          );
//        case UserDocStatus.interestsNotSetup:
//          return getMaterialApp(
//            child: InterestViewNew(
//              onSkipped: _skip,
//              onSelectedInterests: (interests) {
//                this.signedInUser.interests = interests;
//                updateUserData(signedInUser);
//              },
//            ),
//          );
//          break;
//        case UserDocStatus.bioNotSetup:
//          return getMaterialApp(
//            child: BioView(
//              onSkipped: _skip,
//              onSave: (bio) {
//                this.signedInUser.bio = bio;
//                updateUserData(signedInUser);
//              },
//            ),
//          );
//          break;
//        case UserDocStatus.notCreated:
//          createUserData();
//          return getMaterialApp(
//            child: Loader(
//              message: 'Creating user documents',
//            ),
//          );
//        case UserDocStatus.waiting:
//          return getMaterialApp(
//            child: Loader(
//              message: 'Updating user data',
//            ),
//          );
//        default:
//          return getMaterialApp(
//            child: Loader(
//              message: 'Loading',
//            ),
//          );
//      }
//    }
//  }
//
//  void _skip() {
//    if (mounted) {
//      setState(() {
//        docStatus = UserDocStatus.existing;
//      });
//    }
//  }
//
//  Future createUserData() async {
//    await FirestoreManager.createUser(user: signedInUser);
//    TimebankModel model = await FirestoreManager.getTimeBankForId(
//      timebankId: HUMANITY_FIRST_TB_ID,
//    );
//    List<String> members = model.members;
//    List<String> tbMembers = members.map((m) => m).toList();
//    if (!tbMembers.contains(signedInUser.email)) {
//      tbMembers.add(signedInUser.email);
//    }
//    model.members = tbMembers;
//    await FirestoreManager.updateTimebank(model: model);
//
//    refreshDocStatus();
//  }
//
//  Future updateUserData(UserModel user) async {
//    await FirestoreManager.updateUser(user: signedInUser);
//    refreshDocStatus();
//  }
//
//  Future<UserModel> _checkIfUserLoggedIn() async {
//    String sevaUserId = await PreferenceManager.loggedInUserId;
//
//    this.sevaUserId = sevaUserId;
//
//    if (sevaUserId == null) return null;
//    UserModel user = await FirestoreManager.getUserForId(
//      sevaUserId: sevaUserId,
//    );
//
//    return user;
//  }
//
//  Future<UserModel> _checkUserDocumentExists() async {
//    String emailId = await PreferenceManager.loggedInUserEmail;
//    if (emailId != null) {
//      UserModel user = await FirestoreManager.getUserForEmail(
//        emailAddress: emailId,
//      );
//      return user;
//    } else {
//      return null;
//    }
//  }
//
//  void refreshDocStatus() {
//    UserDocStatus _status = UserDocStatus.waiting;
//    setState(() {
//      docStatus = UserDocStatus.waiting;
//    });
//
//    _checkUserDocumentExists().then((user) {
//      if (user == null) {
//        _status = UserDocStatus.notCreated;
//      } else if (user.skills == null) {
//        _status = UserDocStatus.skillsNotSetup;
//      } else if (user.interests == null) {
//        _status = UserDocStatus.interestsNotSetup;
//      } else if (user.bio == null) {
//        _status = UserDocStatus.bioNotSetup;
//      } else {
//        _status = UserDocStatus.existing;
//      }
//
//      if (mounted) {
//        setState(() {
//          docStatus = _status;
//        });
//      }
//    });
//  }

  Widget getMaterialApp({@required Widget child}) {
    return MaterialApp(
      theme: FlavorConfig.theme,
      home: child,
    );
  }
}

class Loader extends StatelessWidget {
  final String message;

  Loader({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            if (message != null)
              Container(
                padding: EdgeInsets.all(16),
                child: Text(message),
              ),
          ],
        ),
      ),
    );
  }
}

/// Use this enum to check user authentication status
/// * [AuthStatus.notDetermined] - User authentication status not verified
/// * [AuthStatus.notSignedIn] - User not logged in previously
/// * [AuthStatus.notCreated] - User has completed Authentication flow, but the user docs have not yet been created
/// * [AuthStatus.skillsNotSetup] - The user docs have not been updated with the Skills
/// * [AuthStatus.interestsNotSetup] - The user docs have not been updated with the Interests
/// * [AuthStatus.bioNotSetup] - The user docs have not been updated with the Bio
/// * [AuthStatus.signedIn] - The user is logged in
enum AuthStatus {
  notDetermined,
  notSignedIn,
  notCreated,
  skillsNotSetup,
  interestsNotSetup,
  bioNotSetup,
  signedIn,
}
