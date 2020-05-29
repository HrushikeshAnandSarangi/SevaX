import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:share_extend/share_extend.dart';

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  File pdf;
  String docName = "";
  PDFScreen({this.pathPDF, this.docName, this.pdf});

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
              icon: Icon(Icons.share),
              onPressed: () {
                ShareExtend.share(pathPDF, "file");
              },
            ),
          ],
        ),
        path: pathPDF);
  }
}
