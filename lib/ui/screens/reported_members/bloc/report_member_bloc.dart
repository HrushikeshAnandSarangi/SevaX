import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class ReportMemberBloc {
  final _file = BehaviorSubject<File>();
  final _message = BehaviorSubject<String>();
  final _buttonStatus = BehaviorSubject<bool>.seeded(false);
  final profanityDetector = ProfanityDetector();

  FirebaseStorage _storage = FirebaseStorage();
  Function(bool) get changeButtonStatus => _buttonStatus.sink.add;
  void onMessageChanged(String value) {
    _message.sink.add(value);
    if (_message.value.length > 10 && _buttonStatus.value == false) {
      _buttonStatus.add(true); //enable button
      log("button enabled");
    }
    if (profanityDetector.isProfaneString(_message.value)) {
      _message.addError('profanity');
      _buttonStatus.add(false);
      log("profanity detected");
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
      await CollectionRef.reportedUsersList
          .doc(
              "${reportedUserModel.sevaUserID}*${reportingUserModel.currentCommunity}")
          .set(
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
      FirebaseCrashlytics.instance.log(e);
    }
  }

  void clearImage() {
    _file.add(null);
  }

  void dispose() {
    _file.close();
    _message.close();
    _buttonStatus.close();
  }
}
