import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';

class ReportMemberBloc {
  final _file = BehaviorSubject<File>();
  final _message = BehaviorSubject<String>();
  final _buttonStatus = BehaviorSubject<bool>.seeded(false);
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  FirebaseStorage _storage = FirebaseStorage();
  Function(bool) get changeButtonStatus => _buttonStatus.sink.add;
  void onMessageChanged(String value) {
    _message.sink.add(value);
    if (_message.value.length > 10 && _buttonStatus.value == false) {
      _buttonStatus.add(true); //enable button
      log("button enabled");
    }

    if (_message.value.length < 10 && _buttonStatus.value == true) {
      _buttonStatus.add(false); //disable button
      log("button disabled");
    }
  }

  Stream<File> get image => _file.stream;
  Stream<String> get message => _message.stream;
  Stream<bool> get buttonStatus => _buttonStatus.stream;

  void uploadImage(File file) {
    if (file != null || file != _file.value) {
      _file.add(file);
    }
  }

  Future<bool> createReport({
    UserModel reportedUserModel,
    UserModel reportingUserModel,
    String timebankId,
    bool isTimebankReport,
    String entityName,
    BuildContext context,
  }) async {
    _buttonStatus.add(false);
    String filePath = DateTime.now().toString();
    String attachmentUrl;
    if (_file.value != null) {
      StorageUploadTask _uploadTask =
          _storage.ref().child("reports/$filePath.png").putFile(_file.value);
      StorageTaskSnapshot snapshot = await _uploadTask.onComplete;

      attachmentUrl = await snapshot.ref.getDownloadURL();

      if (attachmentUrl == null || attachmentUrl == '') {
        return Future.value(false);
      } else {
        profanityImageModel =
            await checkProfanityForImage(imageUrl: attachmentUrl);

        profanityStatusModel =
            await getProfanityStatus(profanityImageModel: profanityImageModel);

        if (profanityStatusModel.isProfane) {
          showProfanityImageAlert(
                  context: context, content: profanityStatusModel.category)
              .then((status) {
            if (status == 'Proceed') {
              FirebaseStorage.instance
                  .getReferenceFromUrl(attachmentUrl)
                  .then((reference) {
                reference.delete();
                Navigator.of(context).pop();
              }).catchError((e) => print(e));
            } else {
              print('error');
            }
          });
        }
      }
    }
    Report report = Report(
      reporterId: reportingUserModel.sevaUserID,
      attachment: attachmentUrl,
      message: _message.value.trim(),
      reporterImage: reportingUserModel.photoURL,
      reporterName: reportingUserModel.fullname,
      entityName: entityName,
      entityId: timebankId,
      isTimebankReport: isTimebankReport,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await Firestore.instance
          .collection('reported_users_list')
          .document(
              "${reportedUserModel.sevaUserID}*${reportingUserModel.currentCommunity}")
          .setData(
        {
          "communityId": reportingUserModel.currentCommunity,
          "reportedId": reportedUserModel.sevaUserID,
          "reportedUserName": reportedUserModel.fullname,
          "reportedUserImage": reportedUserModel.photoURL,
          "reportedUserEmail": reportedUserModel.email,
          "reports": FieldValue.arrayUnion([report.toMap()]),
          "reporterIds": FieldValue.arrayUnion([reportingUserModel.sevaUserID]),
          "timebankIds": FieldValue.arrayUnion([timebankId]),
        },
        merge: true,
      );
      return true;
    } catch (e) {
      _buttonStatus.add(true);
      Crashlytics.instance.log(e);
      throw (e);
    }
  }

  void clearImage() {
    _file.add(null);
  }

  Future<void> profanityCheck({String imageURL, BuildContext context}) async {
    // _newsImageURL = imageURL;
  }
  dispose() {
    _file.close();
    _message.close();
    _buttonStatus.close();
  }
}
