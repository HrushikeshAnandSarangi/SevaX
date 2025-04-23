import 'package:universal_io/io.dart' as io;

import 'package:path_provider/path_provider.dart';

class LocalFileDownloader {
  Future<void> download(
    String fileName,
    String localFilePath, {
    String fileExtension = 'pdf', // Added explicit type
  }) async {
    late io.Directory saveDir;

    if (io.Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      //get download folder on android
      final downloadPath = '${directory?.parent.parent.parent.parent.path}'
          '${io.Platform.pathSeparator}Download';
      saveDir = io.Directory(downloadPath);
    } else if (io.Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      saveDir = io.Directory('${directory.path}'
          '${io.Platform.pathSeparator}Download');
    } else {
      //TODO: update method for web
      throw UnsupportedError('Platform not supported');
    }

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final file = io.File(localFilePath);
    await file.copy(
      '${saveDir.path}'
      '${io.Platform.pathSeparator}$fileName.$fileExtension',
    );
  }
}
