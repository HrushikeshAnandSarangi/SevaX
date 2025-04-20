import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sevaexchange/utils/helpers/local_file_downloader.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:share_extend/share_extend.dart';

class InvoiceScreen extends StatelessWidget {
  final String path;
  final String pdfType;
  const InvoiceScreen({Key? key, required this.path, required this.pdfType})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          HideWidget(
            hide: true,
            child: IconButton(
              icon: Icon(
                Icons.file_download,
              ),
              onPressed: () async {
                //TODO: show appropriate snackbar
                if (Theme.of(context).platform == TargetPlatform.android ||
                    Theme.of(context).platform == TargetPlatform.iOS) {
                  LocalFileDownloader()
                      .download('report', path)
                      .then(
                        (_) => log('file downloaded'),
                      )
                      .catchError((e) => log(e));
                }
              },
            ),
            secondChild: SizedBox.shrink(),
          ),
          Theme.of(context).platform == TargetPlatform.android ||
                  Theme.of(context).platform == TargetPlatform.iOS
              ? IconButton(
                  icon: Icon(
                    Icons.share,
                  ),
                  onPressed: () async {
                    ShareExtend.share(path, "file");
                  },
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
