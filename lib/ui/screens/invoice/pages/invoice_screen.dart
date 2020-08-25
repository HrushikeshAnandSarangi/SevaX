import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:sevaexchange/utils/helpers/local_file_downloader.dart';
import 'package:share_extend/share_extend.dart';

class InvoiceScreen extends StatelessWidget {
  final String path;

  const InvoiceScreen({Key key, this.path}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_download,
            ),
            onPressed: () async {
              //TODO: show appropriate snackbar
              LocalFileDownloader()
                  .download('report', path)
                  .then(
                    (_) => log('file downloaded'),
                  )
                  .catchError((e) => print(e));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
            ),
            onPressed: () async {
              ShareExtend.share(path, "file");
            },
          ),
        ],
      ),
      path: path,
    );
  }
}
