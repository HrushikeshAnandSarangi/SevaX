import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalFileDownloader {
  Future<void> download(
    String fileName,
    String localFilePath, {
    fileExtension = 'pdf',
  }) async {
    Directory saveDir;
    if (Platform.isAndroid) {
      Directory directory = await getExternalStorageDirectory();
      //get download folder on android
      String downloadPath = directory.parent.parent.parent.parent.path +
          Platform.pathSeparator +
          'Download';
      saveDir = Directory(downloadPath);
    }

    //TODO: update method for web

    if (Platform.isIOS) {
      Directory directory = await getApplicationDocumentsDirectory();
      saveDir = Directory(directory.path + Platform.pathSeparator + 'Download');
    }
    if (!await saveDir.exists()) {
      await saveDir.create();
    }
    File file = File(localFilePath);
    file.copy(
      saveDir.path + Platform.pathSeparator + fileName + '.' + fileExtension,
    );
  }
}
