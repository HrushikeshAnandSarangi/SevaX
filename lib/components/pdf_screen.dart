import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:share_extend/share_extend.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  String docName = "";
  bool isFromFeeds = false;
  String pdfUrl = '';
  PDFScreen({this.pathPDF, this.docName, this.isFromFeeds, this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text(
            docName ?? "Document",
            style: TextStyle(fontFamily: 'Europa', fontSize: 16),
            //   overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            IconButton(
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
            ),
          ],
        ),
        path: pathPDF);
  }
}
