import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageApi {
  ///[dirctory] where to store the file in cloud storage
  ///[fileName] name of the file [optional] defaults to [Timestamp] if null
  ///[Return] returns url of the uploaded image
  static Future<String> uploadFile(
    String directory,
    File file, {
    String fileName,
  }) async {
    FirebaseStorage _storage = FirebaseStorage();
    StorageUploadTask _uploadTask = _storage
        .ref()
        .child("$directory/${fileName ?? DateTime.now().toString()}.png")
        .putFile(file);
    StorageTaskSnapshot snapshot = await _uploadTask.onComplete;

    String attachmentUrl = await snapshot.ref.getDownloadURL();

    if (attachmentUrl == null || attachmentUrl == '') {
      throw Exception("Upload failed");
    }
    return attachmentUrl;
  }
}
