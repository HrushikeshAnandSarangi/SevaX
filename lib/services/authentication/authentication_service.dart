import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/services/authentication/email_authentication_service.dart';
import 'package:sevaexchange/services/authentication/google_authentication_service.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';

class AuthenticationService extends BaseService {
  GoogleAuthenticationService _googleAuthService;
  EmailAuthenticationService _emailAuthService;

  AuthenticationService({
    @required GoogleAuthenticationService googleAuthService,
    @required EmailAuthenticationService emailAuthService,
  })  : this._googleAuthService = googleAuthService,
        this._emailAuthService = emailAuthService;

  /// Login using [_googleAuthService]
  Future<UserModel> loginWithGoogle() async {
    log.i('loginWithGoogle: ');
    UserModel userModel = await _googleAuthService.login();
    _saveSignedInUser(userModel);
    return userModel;
  }

  /// Login with [emailId] and [password]
  Future<UserModel> loginWithEmail({
    @required String emailId,
    @required String password,
  }) async {
    log.i(
      'loginWithEmail: '
      'emailId: $emailId: '
      'password: ${password.replaceRange(0, password.length - 1, '#')}',
    );
    UserModel userModel = await _emailAuthService.login(
      email: emailId,
      password: password,
    );
    _saveSignedInUser(userModel);
    return userModel;
  }

  /// Register a new user with [emailId], [password], [fullName] and [photoUrl]
  Future<UserModel> registerNewUser({
    @required String emailId,
    @required String password,
    @required String fullName,
    @required File image,
  }) async {
    log.i(
      'registerNewUser: '
      'emailId: $emailId '
      'password: ${password.replaceRange(0, password.length - 1, '#')} '
      'fullname: $fullName '
      'image: ${image.path} ',
    );

    UserModel userModel = await _emailAuthService.register(
      emailId: emailId,
      password: password,
      fullName: fullName,
      image: image,
    );

    _saveSignedInUser(userModel);
    log.i('registerNewUser: userModel: ${userModel.toMap()}');
    return userModel;
  }

  /// Logout the currently logged in [FirebaseUser]
  Future<void> logout() async {
    log.i('logout: ');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.providerId;
    // TODO: Base the logout process on the provider id
    await _googleAuthService.logout();
    await _emailAuthService.logout();
  }

  Future<bool> _saveSignedInUser(UserModel signedInUser) async {
    log.i('_saveSignedInUser: signedInUser: ${signedInUser.toMap()}');
    // TODO: Move to User service
    UserModel _userDoc = await FirestoreManager.getUserForEmail(
      emailAddress: signedInUser.email,
    );

    if (_userDoc == null) {
      await _createUserDoc(signedInUser);
    }

    // TODO: Move to TimebankService
    TimebankModel model = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.timebankId,
    );
    List<String> members = model.members;
    if (!members.contains(signedInUser.email)) {
      List<String> tbMembers = members.map((m) => m).toList();
      if (!tbMembers.contains(signedInUser.email)) {
        tbMembers.add(signedInUser.email);
      }
      model.members = tbMembers;
      // TODO: Move to timebankService
      await FirestoreManager.updateTimebank(model: model);
    }

    // TODO: Save user details using PreferenceService
    return await PreferenceManager.setLoggedInUser(
      userId: signedInUser.sevaUserID,
      emailId: signedInUser.email,
    );
  }

  Future _createUserDoc(UserModel userModel) async {
    log.i('_createUserDoc: userModel: ${userModel.toMap()}');
    // TODO: Move to User service
    await FirestoreManager.createUser(user: userModel);
  }
}
