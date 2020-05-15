import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/subjects.dart';

class ReportMemberBloc {
  final _file = BehaviorSubject<File>();
  final _message = BehaviorSubject<String>();
  StorageUploadTask _uploadTask;
  FirebaseStorage _storage = FirebaseStorage();

  Function(String) get onMessageChanged => _message.sink.add;

  Stream<File> get image => _file.stream;
  Stream<String> get message => _message.stream;
  Stream<StorageTaskEvent> get uploadEvent => _uploadTask?.events;

  Future<void> createReport() async {
    print("${_message.value}  ${_file.value.path}");
    String url = await (await _uploadTask.onComplete).ref.getDownloadURL();
    print(url);
  }

  void uploadImage(File file, String filePath) {
    assert(filePath != null);
    if (file != null || file != _file.value) {
      _file.add(file);
      _uploadTask =
          _storage.ref().child("reports/$filePath.png").putFile(_file.value);
    }
  }

  void clearImage() {
    _file.add(null);
  }

  dispose() {
    _file.close();
    _message.close();
  }
}
