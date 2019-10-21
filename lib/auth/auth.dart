import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/preference_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/flavor_config.dart';

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

    FirebaseUser user = await _firebaseAuth.signInWithCredential(
      credential,
    );

    return _processGoogleUser(user);
  }

  /// SignIn a User with his [email] and [password]
  Future<UserModel> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception catch (error) {
      throw error;
    } catch (error) {
      log('Auth: signInWithEmailAndPassword: $error');
    }
    return _processGoogleUser(user);
  }

  /// Register a User with [email] and [password]
  Future<UserModel> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
    @required String displayName,
  }) async {
    try {
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _processEmailPasswordUser(user, displayName);
    } on PlatformException catch (error) {
      throw error;
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
