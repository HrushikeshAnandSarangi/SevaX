import 'dart:developer';
import 'package:universal_io/io.dart' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class ReportMemberBloc {
  final _file = BehaviorSubject<io.File>();
  final _message = BehaviorSubject<String>();
  final _buttonStatus = BehaviorSubject<bool>.seeded(false);
  final profanityDetector = ProfanityDetector();

  FirebaseStorage _storage = FirebaseStorage.instance;
  Function(bool) get changeButtonStatus => _buttonStatus.sink.add;
  void onMessageChanged(String value) {
    _message.sink.add(value);
    if (_message.value.length != null && _buttonStatus.value == false) {
      _buttonStatus.add(true); //enable button
      log("button enabled");
    }
    if (profanityDetector.isProfaneString(_message.value)) {
      _message.addError('profanity');
      _buttonStatus.add(false);
      log("profanity detected");
    }
    if (_message.value.length == null ||
        _message.value.isEmpty && _buttonStatus.value == true) {
      _message.addError("Enter Some Text");
      _buttonStatus.add(false); //disable button
      log("button disabled");
    }
    // if(_message.value.length < 10){

    // }
  }

  Stream<io.File> get image => _file.stream;
  Stream<String> get message => _message.stream;
  Stream<bool> get buttonStatus => _buttonStatus.stream;

  void uploadImage(io.File file) {
    if (file != null || file != _file.value) {
      _file.add(file);
    }
  }

  Future<bool> createReport({
    UserModel? reportedUserModel,
    UserModel? reportingUserModel,
    String? timebankId,
    bool? isTimebankReport,
    String? entityName,
  }) async {
    _buttonStatus.add(false);
    String filePath = DateTime.now().toString();
    String attachmentUrl = '';
    if (_file.value != null) {
      UploadTask _uploadTask =
          _storage.ref().child("reports/$filePath.png").putFile(_file.value);
      attachmentUrl = await (await _uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();
    }
    Report report = Report(
      reporterId: reportingUserModel!.sevaUserID,
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
              "${reportedUserModel!.sevaUserID}*${reportingUserModel.currentCommunity}")
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
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      _buttonStatus.add(true);
      // FirebaseCrashlytics.instance.log(e);
      return false;
    }
  }

  void clearImage() {
    _file.add(null!);
  }

  void dispose() {
    _file.close();
    _message.close();
    _buttonStatus.close();
  }
}
