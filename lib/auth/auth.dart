import 'dart:async';
import 'dart:developer';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
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
  Future<UserModel?> handleGoogleSignIn() async {
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (error) {
      log('Google sign in exception. Error: ${error.toString()}');
      return null;
    }

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    return _processGoogleUser(result.user);
  }

  Future<UserModel?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return null;
      }

      // Request credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuthCredential
      final oAuthProvider = OAuthProvider('apple.com');
      final authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      final result = await _firebaseAuth.signInWithCredential(authCredential);

      // Build name from credential
      String? fullName;
      if (credential.givenName != null) {
        fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        fullName = fullName.isNotEmpty ? fullName : null;
      }

      return _processGoogleUser(result.user, name: fullName);
    } catch (error) {
      log('Apple sign in error: ${error.toString()}');
      return null;
    }
  }

  String? nameBuilder(String? text) {
    return text != null ? ' $text ' : null;
  }

  /// SignIn a User with his [email] and [password]
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );
      return _processGoogleUser(result.user);
    } catch (error) {
      log('Sign in error: ${error.toString()}');
      rethrow;
    }
  }

  /// Register a User with [email] and [password]
  Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );
      return _processEmailPasswordUser(result.user, displayName);
    } on FirebaseAuthException catch (error) {
      logger.i(
          "${error.code} ==================================================");
      if (error.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException(
            error.message ?? 'Email already in use');
      }
      rethrow;
    } catch (error) {
      log('createUserWithEmailAndPassword error: ${error.toString()}');
      return null;
    }
  }

  /// Sign out the logged in user and clear all user preferences
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await PreferenceManager.logout();
  }

  /// Returns the [UserModel] corresponding to the signed in user.
  Future<UserModel?> getLoggedInUser() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      UserModel? loggedInUser = await FirestoreManager.getUserForId(
        sevaUserId: user.uid,
      );
      return loggedInUser;
    } catch (error) {
      log('Error while fetching user:\n${error.toString()}');
      return null;
    }
  }

  Future<UserModel?> _processEmailPasswordUser(
    User? user,
    String displayName,
  ) async {
    if (user == null) return null;

    UserModel userModel = UserModel(
      photoURL: user.photoURL,
      email: user.email!.toLowerCase(),
      fullname: displayName,
      sevaUserID: user.uid,
    );

    await _saveSignedInUser(userModel);
    return userModel;
  }

  Future<UserModel?> _processGoogleUser(User? user, {String? name}) async {
    if (user == null) {
      return null;
    }

    if (user.email == null) {
      log('Error: User email is null');
      return null;
    }

    UserModel userModel = UserModel(
      photoURL: user.photoURL,
      fullname: (name != null && name.isNotEmpty) ? name : user.displayName,
      email: user.email!.toLowerCase(),
      sevaUserID: user.uid,
    );
    await _saveSignedInUser(userModel);
    return userModel;
  }

  Future<bool> _saveSignedInUser(UserModel signedInUser) async {
    UserModel? _userDoc = await FirestoreManager.getUserForEmail(
      emailAddress: signedInUser.email!,
    );

    if (_userDoc == null) {
      await _createUserDoc(signedInUser);
    }

    // updating the sevaX global timebank community with user Id
    CommunityModel? cmodel =
        await FirestoreManager.getCommunityDetailsByCommunityId(
      communityId: FlavorConfig.values.timebankId,
    );

    if (cmodel != null) {
      List<String> cmembers = cmodel.members;
      if (!cmembers.contains(signedInUser.sevaUserID)) {
        List<String> tbMembers = cmembers.map((m) => m).toList();
        if (!tbMembers.contains(signedInUser.sevaUserID)) {
          tbMembers.add(signedInUser.sevaUserID!);
        }
        cmodel.members = tbMembers;
        await FirestoreManager.updateCommunity(communityModel: cmodel);
      }
    }

    // updating the sevaX global timebank with user Id
    TimebankModel? model = await FirestoreManager.getTimeBankForId(
      timebankId: FlavorConfig.values.timebankId,
    );

    if (model != null) {
      List<String> members = model.members;
      if (!members.contains(signedInUser.sevaUserID)) {
        List<String> tbMembers = members.map((m) => m).toList();
        if (!tbMembers.contains(signedInUser.sevaUserID)) {
          tbMembers.add(signedInUser.sevaUserID!);
        }
        model.members = tbMembers;
        await FirestoreManager.updateTimebank(timebankModel: model);
      }
    }

    return await PreferenceManager.setLoggedInUser(
      userId: signedInUser.sevaUserID!,
      emailId: signedInUser.email!,
    );
  }

  Future<void> _createUserDoc(UserModel userModel) async {
    await FirestoreManager.createUser(user: userModel);
  }
}

class EmailAlreadyInUseException implements Exception {
  final String message;
  EmailAlreadyInUseException(this.message);

  @override
  String toString() => 'EmailAlreadyInUseException: $message';
}
