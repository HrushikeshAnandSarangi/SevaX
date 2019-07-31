import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:flutter/services.dart';

class GoogleAuthenticationService extends BaseService {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoogleAuthenticationService() {
    assert(this._firebaseAuth != null, 'Firebase Auth cannot be null');
  }
  
  /// Initiate a [GoogleSignIn] flow and return a [UserModel] of the User
  Future<UserModel> login() async {
    log.i('login');
    FirebaseUser firebaseUser = await _handleGoogleSignIn();
    return _processUser(firebaseUser);
  }

  /// Logout the currently logged in user and clear [GoogleSignIn] and
  /// [FirebaseUser] cache
  Future<void> logout() async {
    log.i('logout:');
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  /// Initiate a [GoogleSignIn] flow and return the logged in user as a
  /// [FirebaseUser]
  Future<FirebaseUser> _handleGoogleSignIn() async {
    log.i('handleGoogleSignIn');

    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on PlatformException catch (error) {
      log.e('handleGoogleSignIn: error { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.e('handleGoogleSignIn: error { ${error.toString()} }');
      throw error;
    }

    if (googleUser == null) {
      log.w('handleGoogleSignIn: Google user is null');
      return null;
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser user = await _firebaseAuth.signInWithCredential(
      credential,
    );

    log.i('handleGoogleSignIn: Got Firebase user');
    return user;
  }

  /// Process a [firebaseUser] to a [UserModel]
  UserModel _processUser(FirebaseUser firebaseUser) {
    log.i('_processUser: firebaseUser: ${firebaseUser?.uid}');
    if (firebaseUser == null) {
      log.w('_processUser. Firebase user is null');
      return null;
    }

    UserModel userModel = UserModel(
      photoURL: firebaseUser.photoUrl,
      fullname: firebaseUser.displayName,
      email: firebaseUser.email,
      sevaUserID: firebaseUser.uid,
    );

    log.i('_processUser: Processed UserModel: ${userModel.toMap()}');
    return userModel;
  }
}
