import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sevaexchange/base/base_view_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as firestoreManager;
import 'package:sevaexchange/views/profile/profile.dart';

class CommonAppBarViewModel extends BaseViewModel {
  String _emailId;
  String _photoUrl;

  CommonAppBarViewModel({
    String emailId,
    String photoUrl,
  })  : this._emailId = emailId,
        this._photoUrl = photoUrl;

  String get emailId => this._emailId;
  set emailId(String emailId) {
    this._emailId = emailId;
    notifyListeners();
  }

  String get photoUrl => this._photoUrl;
  set photoUrl(String photoUrl) {
    this._photoUrl = photoUrl;
    notifyListeners();
  }

  void updateProfileImageUrl() {
    log.i('updateProfileImageUrl:');
    busy = true;
    firestoreManager.getUserForEmail(emailAddress: emailId).then((model) {
      busy = false;
      this.photoUrl = model.photoURL;
    }).catchError((error) {
      log.e('updateProfileImageUrl: error: ${error.toString()}');
      busy = false;
    });
  }

  void goToProfilePage(BuildContext context) {
    log.i('goToProfilePage:');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ProfilePage();
        },
      ),
    );
  }
}
