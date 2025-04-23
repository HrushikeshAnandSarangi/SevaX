import 'dart:async';
import 'package:universal_io/io.dart' as io;

import 'package:firebase_storage/firebase_storage.dart';

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
    io.File file, {
    String? fileName,
  }) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    UploadTask _uploadTask = _storage
        .ref()
        .child("$directory/${fileName ?? DateTime.now().toString()}.png")
        .putFile(file);

    String attachmentUrl =
        await (await _uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    if (attachmentUrl == null || attachmentUrl == '') {
      throw Exception("Upload failed");
    }
    return attachmentUrl;
  }

  // static Stream<double> uploadWithProgress(
  //     File file, StoragePath path, ValueChanged<String> onUpload,
  //     {String fileName}) async* {
  //   FirebaseStorage _storage = FirebaseStorage.instance;
  //   String filePath =
  //       "${path.basePath}/${fileName ?? DateTime.now().toString()}.${extension(file.path)}";
  //   logger.i(filePath);
  //   UploadTask _uploadTask = _storage.ref().child(filePath).putFile(file);
  //   yield* _uploadTask.events.transform(
  //     StreamTransformer.fromHandlers(
  //       handleData: (data, sink) {
  //         sink.add(
  //           data.snapshot.bytesTransferred / data.snapshot.totalByteCount,
  //         );
  //       },
  //     ),
  //   );
  //   String attachmentUrl = '';
  //   _uploadTask.whenComplete(() async {
  //     attachmentUrl = await _storage.ref().getDownloadURL();
  //   });
  //   if (attachmentUrl == null || attachmentUrl == '') {
  //     throw Exception("Upload failed");
  //   }
  //   onUpload(attachmentUrl);
  // }
}
