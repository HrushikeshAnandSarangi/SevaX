import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';

class BorrowAgreementPdf {
  Future<String> borrowAgreementPdf(
      context,
      RequestModel requestModel,
      String documentName,
      bool isRequest,
      String roomOrTool,
      String otherDetails,
      String specificConditions,
      String itemDescription,
      String additionalConditions,
      bool isFixedTerm,
      bool isQuietHoursAllowed,
      bool isPetsAllowed,
      int maximumOccupants,
      int securityDeposit,
      String contactDetails) async {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();

    final Document pdf = Document();

    final ByteData bytes =
        await rootBundle.load('images/invoice_seva_logo.jpg');
    final Uint8List byteList = bytes.buffer.asUint8List();

    String borrowAgreementLinkFinal = '';

    pdf.addPage(
      MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.5, color: PdfColors.grey)),
            ),
            child: Text(
              isRequest
                  ? 'Borrow Request Agreement'
                  : 'Lending Offer Agreement',
              style: Theme.of(context)
                  .defaultTextStyle
                  .copyWith(color: PdfColors.grey),
            ),
          );
        },
        footer: (Context context) {
          return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: Theme.of(context).defaultTextStyle.copyWith(
                    color: PdfColors.grey,
                  ),
            ),
          );
        },
        build: (Context context) => <Widget>[
          Container(
            width: PdfPageFormat.cm * 6,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Image(
                MemoryImage(
                  byteList,
                ),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: 10),
          Header(
              level: 2,
              text: documentName +
                  ' |  For: ${roomOrTool == 'ROOM' ? 'ROOM' : 'ITEM'}'),
          SizedBox(height: 10),
          Divider(thickness: 1, color: PdfColors.grey),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                'Vestibulum neque massa, scelerisque sit amet ligula eu, congue molestie mi. Praesent ut varius sem. Nullam at porttitor arcu, nec lacinia nisi. Ut ac dolor vitae odio interdum condimentum. Vivamus dapibus sodales ex, vitae malesuada ipsum cursus convallis. Maecenas sed egestas nulla, ac condimentum orci. Mauris diam felis, vulputate ac suscipit et, iaculis non est. Curabitur semper arcu ac ligula semper, nec luctus nisl blandit.')
          ]),
          SizedBox(height: 20),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Additional Form Details: ')]),
          Divider(thickness: 1, color: PdfColors.grey),
        ],
      ),
    );

//Below fields to be added under 'Additional Form Details if not empty string ''
    // String otherDetails
    // String specificConditions
    // String itemDescription
    // String additionalConditions
////ROOM specific fields variables below
    // bool isFixedTerm //if false then its long term
    // bool isQuietHoursAllowed
    // bool isPetsAllowed
    // int maximumOccupants
    // int securityDeposit
    // String contactDetails
    //save PDF

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path =
        '$dir/${documentName != null ? documentName : 'borrow_agreement_sevax'}.pdf';
    log("path to pdf file is " + path);

    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    log("requestModel check   " + requestModel.id.toString());
    borrowAgreementLinkFinal =
        await uploadDocument(requestModel.id, file, documentName);

    //await openPdfViewer(borrowAgreementLinkFinal, 'test document', context);

    progressDialog.hide();
    material.Navigator.of(context).pop();

    //String borrowAgreementLink =
    //    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/borrow_agreement_docs%2Fsample_pdf.pdf?alt=media&token=094b13b4-dcb2-4303-ad68-3e341227bf00';
    return borrowAgreementLinkFinal;
  }
}

Future openPdfViewer(
    String pdfURL, String documentName, material.BuildContext context) {
  progressDialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: true,
  );
  progressDialog.show();
  createFileOfPdfUrl(pdfURL, documentName).then((f) {
    progressDialog.hide();
    material.Navigator.push(
      context,
      material.MaterialPageRoute(
          builder: (context) => PDFScreen(
                docName: documentName,
                pathPDF: f.path,
                isFromFeeds: false,
                isDownloadable: false,
              )),
    );
  });
}

Future<String> uploadDocument(
    String requestId, File _path, String documentName) async {
  int timestamp = DateTime.now().millisecondsSinceEpoch;

  String timestampString = timestamp.toString();

  String name =
      requestId.toString() + '_' + timestampString + '_' + documentName;

  Reference ref =
      FirebaseStorage.instance.ref().child('borrow_agreement_docs').child(name);

  UploadTask uploadTask = ref.putFile(
    _path,
    SettableMetadata(
      contentLanguage: 'en',
      customMetadata: <String, String>{'activity': 'CV File'},
    ),
  );
  String documentURL = '';
  uploadTask.whenComplete(() async {
    documentURL = await ref.getDownloadURL();
    return documentURL;
  });
  return documentURL;
}
