// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sevaexchange/base/base_service.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:meta/meta.dart';
// import 'package:flutter/services.dart';

// class GoogleAuthenticationService extends BaseService {
//   FirebaseAuth _firebaseAuth;
//   GoogleSignIn _googleSignIn;

//   GoogleAuthenticationService({
//     @required FirebaseAuth firebaseAuth,
//     @required GoogleSignIn googleSignIn,
//   })  : this._firebaseAuth = firebaseAuth,
//         this._googleSignIn = googleSignIn {
//     assert(this._firebaseAuth != null, 'Firebase Auth cannot be null');
//     assert(this._googleSignIn != null, 'Google Signin cannot be null');
//   }

//   /// Initiate a [GoogleSignIn] flow and return a [UserModel] of the User
//   Future<UserModel> login() async {
//     log.i('login');
//     try {
//       User firebaseUser = await _handleGoogleSignIn();
//       return _processUser(firebaseUser);
//     } on PlatformException catch (error) {
//       log.e('login: PlatformException { ${error.toString()} }');
//       throw error;
//     } catch (error) {
//       log.e('login: error { ${error.toString()} }');
//       throw error;
//     }
//   }

//   /// Logout the currently logged in user and clear [GoogleSignIn] and
//   /// [User] cache
//   Future<void> logout() async {
//     log.i('logout:');
//     await _googleSignIn.signOut();
//     await _firebaseAuth.signOut();
//   }

//   /// Initiate a [GoogleSignIn] flow and return the logged in user as a
//   /// [User]
//   Future<User> _handleGoogleSignIn() async {
//     log.i('handleGoogleSignIn');

//     GoogleSignInAccount googleUser;
//     try {
//       googleUser = await _googleSignIn.signIn();
//     } on PlatformException catch (error) {
//       log.e('handleGoogleSignIn: PlatformException { ${error.toString()} }');
//       throw error;
//     } catch (error) {
//       log.e('handleGoogleSignIn: error { ${error.toString()} }');
//       throw error;
//     }

//     if (googleUser == null) {
//       log.w('handleGoogleSignIn: Google user is null');
//       return null;
//     }
//     GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     AuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     User user = (await _firebaseAuth.signInWithCredential(
//       credential,
//     )) as User;

//     log.i('handleGoogleSignIn: Got Firebase user');
//     return user;
//   }

//   /// Process a [firebaseUser] to a [UserModel]
//   UserModel _processUser(User firebaseUser) {
//     log.i('_processUser: firebaseUser: ${firebaseUser?.uid}');
//     if (firebaseUser == null) {
//       log.w('_processUser. Firebase user is null');
//       return null;
//     }

//     UserModel userModel = UserModel(
//       photoURL: firebaseUser.photoUrl,
//       fullname: firebaseUser.displayName,
//       email: firebaseUser.email,
//       sevaUserID: firebaseUser.uid,
//     );

//     log.i('_processUser: Processed UserModel: ${userModel.toMap()}');
//     return userModel;
//   }
// }
