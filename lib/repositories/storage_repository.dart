import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

enum StoragePath {
  Sponsors,
}

extension Value on StoragePath {
  String get basePath => this.toString().split('.')[1];
}

class StorageRepository {
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

  static Stream<double> uploadWithProgress(
      File file, StoragePath path, ValueChanged<String> onUpload,
      {String fileName}) async* {
    FirebaseStorage _storage = FirebaseStorage();
    String filePath =
        "${path.basePath}/${fileName ?? DateTime.now().toString()}.${extension(file.path)}";
    logger.i(filePath);
    StorageUploadTask _uploadTask =
        _storage.ref().child(filePath).putFile(file);
    yield* _uploadTask.events.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(
            data.snapshot.bytesTransferred / data.snapshot.totalByteCount,
          );
        },
      ),
    );
    StorageTaskSnapshot snapshot = await _uploadTask.onComplete;
    String attachmentUrl = await snapshot.ref.getDownloadURL();
    if (attachmentUrl == null || attachmentUrl == '') {
      throw Exception("Upload failed");
    }
    onUpload(attachmentUrl);
  }
}
