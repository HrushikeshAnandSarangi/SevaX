import 'dart:async';
import 'dart:developer';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/views/login/register_page.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Initiate the Google SignIn process and save the signed in user to
  /// the Shared Preferences
  Future<UserModel> handleGoogleSignIn() async {
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on Exception catch (error) {
      // FirebaseCrashlytics.instance.log(error.toString());
      error;
    } catch (error) {
      log('Google sign in exception. Error: ${error.toString()}');
    }

    if (googleUser == null) return null;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //UserCredential user = await _firebaseAuth.signInWithCredential(credential);

//    User user = (await _firebaseAuth.signInWithCredential(
//      credential,
//    )) as User;
//
//    return _processGoogleUser(user);
    UserCredential _result =
        await _firebaseAuth.signInWithCredential(credential);

    return _processGoogleUser(_result.user);
  }

  Future<UserModel> signInWithApple() async {
    if (await AppleSignIn.isAvailable()) {
      final AppleIdRequest request =
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName]);
      final AuthorizationResult result =
          await AppleSignIn.performRequests([request]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final AppleIdCredential _auth = result.credential;
          final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
          final AuthCredential credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(_auth.identityToken),
            accessToken: String.fromCharCodes(_auth.authorizationCode),
          );
          UserCredential _result =
              await _firebaseAuth.signInWithCredential(credential);

          return _processGoogleUser(
            _result.user,
            name: nameBuilder(_auth.fullName.givenName) +
                nameBuilder(_auth.fullName.middleName) +
                nameBuilder(_auth.fullName.familyName)?.trim(),
          );

        default:
          return null;
          break;
      }
    } else {
      return null;
    }
  }

  String nameBuilder(String text) {
    return text != null ? ' $text ' : '';
  }

  /// SignIn a User with his [email] and [password]
  Future<UserModel> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    UserCredential result;
    try {
      result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception catch (error) {
      // FirebaseCrashlytics.instance.log(error.toString());
      throw error;
    } catch (error) {
      //FirebaseCrashlytics.instance.log(error.toString());
    }
    return _processGoogleUser(result.user);
  }

  /// Register a User with [email] and [password]
  Future<UserModel> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    @required String displayName,
  }) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _processEmailPasswordUser(result.user, displayName);
    } on FirebaseAuthException catch (error) {
      logger.i(
          "${error.code} ==================================================");
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE')
        // FirebaseCrashlytics.instance.log(error.toString());
      throw EmailAlreadyInUseException(error.message);
    } catch (error) {
      log('createUserWithEmailAndPassword: error: ${error.toString()}');
      return null;
    }
  }

  /// Sign out the logged in user and clear all user preferences
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await PreferenceManager.logout();
    return;
  }

  /// Returns the [UserModel] corresponding to the signed in user.
  Future<UserModel> getLoggedInUser() async {
    User user = await _firebaseAuth.currentUser;
    try {
      UserModel loggedInUser = await FirestoreManager.getUserForId(
        sevaUserId: user.uid,
      );
      return loggedInUser;
    } catch (error) {
      log('Error while fetching user:\n${error.toString()}');
      return null;
    }
  }

  Future<UserModel> _processEmailPasswordUser(
    User user,
    String displayName,
  ) async {
    if (user == null) return null;

    UserModel userModel = UserModel(
      photoURL: user.photoURL,
      email: user.email,
      fullname: displayName,
      sevaUserID: user.uid,
    );

    await _saveSignedInUser(userModel);
    return userModel;
  }

  Future<UserModel> _processGoogleUser(User user, {String name}) async {
    if (user == null) {
      return null;
    }

    UserModel userModel = UserModel(
      photoURL: user.photoURL,
      fullname: (name != null && name.isNotEmpty) ? name : user.displayName,
      email: user.email,
      sevaUserID: user.uid,
    );
    await _saveSignedInUser(userModel);
    return userModel;
  }

  Future<bool> _saveSignedInUser(UserModel signedInUser) async {
    UserModel _userDoc = await FirestoreManager.getUserForEmail(
      emailAddress: signedInUser.email,
    );

    if (_userDoc == null) {
      await _createUserDoc(signedInUser);
    }

    // updating the sevaX global timebank community with user Id;
    CommunityModel cmodel =
        await FirestoreManager.getCommunityDetailsByCommunityId(
      communityId: FlavorConfig.values.timebankId,
    );
    List<String> cmembers = cmodel.members;
    if (!cmembers.contains(signedInUser.sevaUserID)) {
      List<String> tbMembers = cmembers.map((m) => m).toList();
      if (!tbMembers.contains(signedInUser.sevaUserID)) {
        tbMembers.add(signedInUser.sevaUserID);
      }
      cmodel.members = tbMembers;
      await FirestoreManager.updateCommunity(communityModel: cmodel);
    }

    // updating the sevaX global timebank with user Id;
    TimebankModel model = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );
    List<String> members = model.members;
    if (!members.contains(signedInUser.sevaUserID)) {
      List<String> tbMembers = members.map((m) => m).toList();
      if (!tbMembers.contains(signedInUser.sevaUserID)) {
        tbMembers.add(signedInUser.sevaUserID);
      }
      model.members = tbMembers;
      await FirestoreManager.updateTimebank(timebankModel: model);
    }

    return await PreferenceManager.setLoggedInUser(
      userId: signedInUser.sevaUserID,
      emailId: signedInUser.email,
    );
  }

  Future _createUserDoc(UserModel userModel) async {
    await FirestoreManager.createUser(user: userModel);
  }
}
