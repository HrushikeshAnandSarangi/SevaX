import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/services/authentication/email_authentication_service.dart';
import 'package:sevaexchange/new_baseline/services/authentication/google_authentication_service.dart';
import 'package:sevaexchange/new_baseline/services/local_storage/local_storage_service.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class AuthenticationService extends BaseService {
  GoogleAuthenticationService _googleAuthService;
  EmailAuthenticationService _emailAuthService;
  LocalStorageService _localStorageService;

  // ignore: close_sinks
  StreamController<UserModel> _loggedInUserStream =
      StreamController<UserModel>.broadcast();

  AuthenticationService({
    @required GoogleAuthenticationService googleAuthService,
    @required EmailAuthenticationService emailAuthService,
    @required LocalStorageService localStorageService,
  })  : this._googleAuthService = googleAuthService,
        this._emailAuthService = emailAuthService,
        this._localStorageService = localStorageService;

  /// Login using [_googleAuthService]
  Future<UserModel> loginWithGoogle() async {
    log.i('loginWithGoogle: ');
    try {
      UserModel userModel = await _googleAuthService.login();
      _saveSignedInUser(userModel);
      return userModel;
    } on PlatformException catch (error) {
      log.e('loginWithGoogle: PlatformException { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.e('loginWithGoogle: error { ${error.toString()} }');
      throw error;
    }
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

    try {
      UserModel userModel = await _emailAuthService.login(
        email: emailId,
        password: password,
      );
      _saveSignedInUser(userModel);
      return userModel;
    } on PlatformException catch (error) {
      log.e('loginWithEmail: PlatformException { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.e('loginWithEmail: error { ${error.toString()} }');
      throw error;
    }
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

    try {
      UserModel userModel = await _emailAuthService.register(
        emailId: emailId,
        password: password,
        fullName: fullName,
        image: image,
      );

      _saveSignedInUser(userModel);
      log.i('registerNewUser: userModel: ${userModel.toMap()}');
      return userModel;
    } on PlatformException catch (error) {
      log.e('registerNewUser: PlatformException { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.e('registerNewUser: error { ${error.toString()} }');
      throw error;
    }
  }

  /// Logout the currently logged in [FirebaseUser]
  Future<void> logout() async {
    log.i('logout: ');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.providerId;
    // TODO: Base the logout process on the provider id
    await _googleAuthService.logout();
    await _emailAuthService.logout();
    await _localStorageService.logout();
  }

  Stream<UserModel> get loggedInUserStream => _loggedInUserStream.stream;

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
      await FirestoreManager.updateTimebank(timebankModel: model);
    }

    return await _localStorageService.saveLoggedInUser(
      emailId: signedInUser.email,
      userId: signedInUser.sevaUserID,
    );
  }

  Future _createUserDoc(UserModel userModel) async {
    log.i('_createUserDoc: userModel: ${userModel.toMap()}');
    // TODO: Move to User service
    await FirestoreManager.createUser(user: userModel);
  }
}
