import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'
    show PDFView, PDFViewerScaffold;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:share_extend/share_extend.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  String docName = "";
  bool isFromFeeds = false;
  bool isDownloadable = true;
  String pdfUrl = '';
  PDFScreen(
      {required this.pathPDF,
      required this.docName,
      required this.isFromFeeds,
      required this.pdfUrl,
      this.isDownloadable = true});

  @override
  Widget build(BuildContext context) {
    log('isDownloadable: ' + isDownloadable.toString());
    return Scaffold(
        appBar: AppBar(
          title: Text(
            docName ?? "Document",
            style: TextStyle(fontFamily: 'Europa', fontSize: 16),
            //   overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            isDownloadable == true
                ? IconButton(
                    icon: Icon(isFromFeeds ? Icons.share : Icons.file_download),
                    onPressed: () async {
                      if (isFromFeeds) {
                        ShareExtend.share(pathPDF, "file");
                      } else {
                        if (await canLaunch(pdfUrl)) {
                          launch(pdfUrl);
                        } else {
                          logger.e("could not launch");
                        }
                      }
                    },
                  )
                : Container(),
          ],
        ),
        body: PDFView(
          filePath: pathPDF,
        ));
  }
}
