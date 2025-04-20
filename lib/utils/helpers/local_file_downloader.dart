import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalFileDownloader {
  Future<void> download(
    String fileName,
    String localFilePath, {
    String fileExtension = 'pdf', // Added explicit type
  }) async {
    late Directory saveDir;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      //get download folder on android
      final downloadPath = '${directory?.parent.parent.parent.parent.path}'
          '${Platform.pathSeparator}Download';
      saveDir = Directory(downloadPath);
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      saveDir = Directory('${directory.path}'
          '${Platform.pathSeparator}Download');
    } else {
      //TODO: update method for web
      throw UnsupportedError('Platform not supported');
    }

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final file = File(localFilePath);
    await file.copy(
      '${saveDir.path}'
      '${Platform.pathSeparator}$fileName.$fileExtension',
    );
  }
}
