import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'package:sevaexchange/models/user_model.dart';

class EmailAuthenticationService extends BaseService {
  FirebaseAuth _firebaseAuth;

  EmailAuthenticationService({
    @override FirebaseAuth firebaseAuth,
  }) : this._firebaseAuth = firebaseAuth {
    assert(this._firebaseAuth != null, 'Firebase Auth cannot be null');
  }

  /// Login with [email] and [password]
  Future<UserModel> login({
    @required String email,
    @required String password,
  }) async {
    log.i('login: email: $email '
        'password: ${password.replaceRange(0, password.length - 1, '#')}');

    try {
      FirebaseUser user = await _loginWithEmailAndPassword(email, password);
      return await _processUser(user);
    } on PlatformException catch (error) {
      log.e('login: PlatformException { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.e('login: error { ${error.toString()} }');
      throw error;
    }
  }

  Future<UserModel> register({
    @required String emailId,
    @required String password,
    @required String fullName,
    @required File image,
  }) async {
    log.i('register: '
        'email: $emailId '
        'password: ${password.replaceRange(0, password.length - 1, '#')}'
        'file: ${image.path}');

    FirebaseUser user;

    try {
      user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailId,
        password: password,
      )) as FirebaseUser;
    } on PlatformException catch (error) {
      log.e('register: Exception ${error.toString()}');
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        /// `foo@bar.com` has alread been registered.
        print(" ${emailId} already registered");
      }
      throw error;
    } catch (error) {
      if (error is PlatformException) {
        if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          print(" ${emailId} already registered");
        }
      }
      log.e('register: error ${error.toString()}');
      throw error;
    }

    String imageUrl = await _saveImage(image, user.email);
    UserModel userModel = UserModel(
      photoURL: imageUrl,
      fullname: emailId,
      email: user.email,
      sevaUserID: user.uid,
    );

    log.i('register: userModel: ${userModel.toMap()}');
    return userModel;
  }

  /// Logout the logged in user from [FirebaseUser]
  Future<void> logout() async {
    log.i('logout:');
    await _firebaseAuth.signOut();
  }

  /// Login with [email] and [password]
  Future<FirebaseUser> _loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    log.i('loginWithEmailAndPassword: email: $email '
        'password: ${password.replaceRange(0, password.length - 1, '#')}');

    FirebaseUser user;
    try {
//      user = (await _firebaseAuth.signInWithEmailAndPassword(
//        email: email,
//        password: password,
//      )) as FirebaseUser;

      AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = authResult.user;
    } on PlatformException catch (error) {
      log.e('loginWithEmailAndPassword: Exception { ${error.toString()} }');
      throw error;
    } catch (error) {
      log.w('loginWithEmailAndPassword: error ${error.toString()}');
      throw error;
    }
    log.i('loginWithEmailAndPassword: Got Firebase User');
    return user;
  }

  /// Process a [firebaseUser] to a [UserModel]. Fetch photo url
  /// from [Firestore]
  Future<UserModel> _processUser(FirebaseUser firebaseUser) async {
    log.i('_processUser: firebaseUser: ${firebaseUser?.uid}');
    if (firebaseUser == null) {
      log.w('_processUser. Firebase user is null');
      return null;
    }

    UserModel userModel = UserModel(
      email: firebaseUser.email,
      sevaUserID: firebaseUser.uid,
    );

    // TODO: Move to Firestore service
    userModel = await _fetchUserFromDocs(userModel.email);

    log.i('_processUser: Processed UserModel: ${userModel.toMap()}');
    return userModel;
  }

  /// Fetch the details of the user from Firestore
  Future<UserModel> _fetchUserFromDocs(String emailId) async {
    // TODO: Implement this using Firestore service

    log.i('_fetchPhotoUrl: emailId: $emailId');
    if (emailId == null || emailId.trim().isEmpty) {
      log.e('_fetchPhotoUrl: Email ID is null');
      return null;
    }
    DocumentSnapshot document =
        await Firestore.instance.collection('users').document(emailId).get();

    UserModel userModel = UserModel.fromMap(document.data);
    return userModel;
  }

  /// Save [image] to Firestore for user with [email] and returns the photoUrl
  Future<String> _saveImage(
    File image,
    String email,
  ) async {
    // TODO: Move this logic to corresponding service
    log.i('_saveImage: ' 'image: ${image.path} ' 'email: $email');
    return await uploadImage(image, email);
  }

  /// Upload [image] to Firebase storage and return the imageUrl
  Future<String> uploadImage(File image, String email) async {
    log.i('uploadImage: image: ${image.path} ' 'email: $email');
    // TODO: Move to file upload service
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(email + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Profile Image'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();
    log.i('uploadImage: imageUrl: $imageURL');
    return imageURL;
  }
}
