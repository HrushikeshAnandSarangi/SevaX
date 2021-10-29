import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:sevaexchange/utils/helpers/local_file_downloader.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:share_extend/share_extend.dart';

class InvoiceScreen extends StatelessWidget {
  final String path;
  final String pdfType;
  const InvoiceScreen({Key key, this.path, this.pdfType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
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
//              } else {
//                final text = 'this is the text file';
//
//                // prepare
//                final bytes = await Io.File(path).readAsBytes();
////                final bytes = utf8.encode(text);
//                final blob = html.Blob([bytes]);
//                final url = html.Url.createObjectUrlFromBlob(blob);
//                final anchor = html.document.createElement('a') as html.AnchorElement
//                  ..href = url
//                  ..style.display = 'none'
//                  ..download = pdfType== 'report' ? 'report.pdf' : 'invoice.pdf';
//                html.document.body.children.add(anchor);
//
//                // download
//                anchor.click();
//
//                // cleanup
//                html.document.body.children.remove(anchor);
//                html.Url.revokeObjectUrl(url);
                }
              },
            ),
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
      path: path,
    );
  }
}
