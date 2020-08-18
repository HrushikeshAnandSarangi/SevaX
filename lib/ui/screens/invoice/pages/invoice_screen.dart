import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
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
