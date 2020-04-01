import 'dart:async';
import 'dart:developer';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/preference_manager.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AppleSignIn _appleSignIn = AppleSignIn();

  /// Initiate the Google SignIn process and save the signed in user to
  /// the Shared Preferences
  Future<UserModel> handleGoogleSignIn() async {
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on Exception catch (error) {
      throw error;
    } catch (error) {
      log('Google sign in exception. Error: ${error.toString()}');
    }

    if (googleUser == null) return null;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //AuthResult user = await _firebaseAuth.signInWithCredential(credential);

//    FirebaseUser user = (await _firebaseAuth.signInWithCredential(
//      credential,
//    )) as FirebaseUser;
//
//    return _processGoogleUser(user);
    AuthResult _result = await _firebaseAuth.signInWithCredential(credential);

    return _processGoogleUser(_result.user);
  }

  Future<UserModel> signInWithApple() async {
    if (await AppleSignIn.isAvailable()) {
      final AppleIdRequest request =
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName]);
      final AuthorizationResult result =
          await AppleSignIn.performRequests([request]);
      print("Result:${AuthorizationStatus.error}");
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final AppleIdCredential _auth = result.credential;
          final OAuthProvider oAuthProvider =
              new OAuthProvider(providerId: "apple.com");
          final AuthCredential credential = oAuthProvider.getCredential(
            idToken: String.fromCharCodes(_auth.identityToken),
            accessToken: String.fromCharCodes(_auth.authorizationCode),
          );
          AuthResult _result =
              await _firebaseAuth.signInWithCredential(credential);

          return _processGoogleUser(_result.user);
        case AuthorizationStatus.error:
          print("Sign in failed");
          break;
        case AuthorizationStatus.cancelled:
          print("Sign in cancelled");
          break;
        default:
          break;
      }
    } else {
      print("AppleSignIn.isNotAvailable");
    }
  }

  /// SignIn a User with his [email] and [password]
  Future<UserModel> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    AuthResult user;
    try {
      result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception catch (error) {
      throw error;
    } catch (error) {
      print(error);
      log('Auth: signInWithEmailAndPassword: $error');
    }
    return _processGoogleUser(result.user.user);
  }

  /// Register a User with [email] and [password]
  Future<UserModel> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    @required String displayName,
  }) async {
    try {
      FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ) as FirebaseUser);
      return _processEmailPasswordUser(user, displayName);
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        print(" ${email} already registered");
      }
      print("signup error $error");
      throw error;
    } catch (error) {
      log('createUserWithEmailAndPassword: error: ${error.toString()}');
      print(" ${email} already registered");
      print("signup error $error");

      return null;
    }
  }

  // /// Register a User with [email] and [password]
  // Future<UserModel> createUserWithEmailAndPassword({
  //   @required String email,
  //   @required String password,
  //   @required String displayName,
  // }) async {
  //   try {
  //     await _firebaseAuth
  //         .createUserWithEmailAndPassword(
  //           email: email,
  //           password: password,
  //         )
  //         .then((onValue) {})
  //         .catchError((onError) {
  //       print("sign up error $onError");
  //     });
  //     //return _processEmailPasswordUser(user, displayName);
  //   } on PlatformException catch (error) {
  //     if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
  //       print(" ${email} already registered");
  //     }
  //     print("signup error $error");
  //     throw error;
  //   } catch (error) {
  //     log('createUserWithEmailAndPassword: error: ${error.toString()}');
  //     print(" ${email} already registered");
  //     print("signup error $error");

  //     return null;
  //   }
  // }

  /// Sign out the logged in user and clear all user preferences
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await PreferenceManager.logout();
    return;
  }

  /// Returns the [UserModel] corresponding to the signed in user.
  Future<UserModel> getLoggedInUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
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
    FirebaseUser user,
    String displayName,
  ) async {
    if (user == null) return null;

    UserModel userModel = UserModel(
      photoURL: user.photoUrl,
      email: user.email,
      fullname: displayName,
      sevaUserID: user.uid,
    );

    await _saveSignedInUser(userModel);
    return userModel;
  }

  Future<UserModel> _processGoogleUser(FirebaseUser user) async {
    if (user == null) {
      return null;
    }

    UserModel userModel = UserModel(
      photoURL: user.photoUrl,
      fullname: user.displayName,
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
