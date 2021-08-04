import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';

class BorrowAgreementPdf {
  Future<String> borrowAgreementPdf(
      material.BuildContext contextMain,
      RequestModel requestModel,
      //Add place model / item model from lending offers (to get details of place/item conditions ex: no of occupants, house rules, etc.. )
      String documentName,
      bool isOffer,
      String placeOrItem,
      String specificConditions,
      bool isDamageLiability,
      bool isUseDisclaimer,
      bool isDeliveryReturn, //for borrow/lend item
      bool isMaintainRepair, //for borrow/lend item
      bool isRefundDepositNeeded, //for borrow/lend place
      bool isMaintainAndclean //for borrow/lend place
      ) async {
    progressDialog = ProgressDialog(
      contextMain,
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
              isOffer ? 'Borrow Request Agreement' : 'Lending Offer Agreement',
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
                  ' |  For: ${placeOrItem == 'ROOM' ? 'ROOM' : 'ITEM(S)'}'),

          SizedBox(height: 10),

          Divider(thickness: 1, color: PdfColors.grey),

          SizedBox(height: 20),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Agreement Details: ', style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            (specificConditions != '' || specificConditions != null)
                ? Text("Lender's Specific Conditions: ",
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isDamageLiability != null)
                ? Text(
                    'The Borrower is responsible for the full cost of repair or replacement of any or all of the Equipment that is damaged, lost, confiscated, or stolen from the time Borrower assumes custody until it is returned to lender. If the Equipment is lost, stolen or damaged, Borrower agrees to promptly notify the Lender Representative designated above.',
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isUseDisclaimer != null)
                ? Text(
                    'The Borrower shall be responsible for the proper use and deployment of the Equipment. The Borrower shall be responsible for training anyone using the Equipment on the proper use of the Equipment in accordance with any Equipment use procedures.',
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            placeOrItem == 'ROOM'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isRefundDepositNeeded != null)
                            ? Text('Refund deposit legal text here.....',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainAndclean != null)
                            ? Text(
                                'Maintenance and cleanliness legal text here.....',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isDeliveryReturn != null)
                            ? Text(
                                'Title to the Equipment the subject of this Agreement shall remain with Lender. The Borrower shall be repsonsible for the safe packaging, proper import, export, shipping and receiving of the Equipment. The Equipment shall be returned within a reasonable amount of time after the Loan Period end date identified.',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainRepair != null)
                            ? Text(
                                'Equipment shall be returned to Lender in as good condition as when received by the Borrower, except for reasonable wear and tear. During the Loan Period and prior to return, the Borrower agrees to assume all responsibility for maintenance and repair.',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ]),
          ]),
          SizedBox(height: 10),

          Divider(thickness: 1, color: PdfColors.grey),

          SizedBox(height: 40),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Terms of Service: ', style: TextStyle(fontSize: 16)),
            //additional texts here
            SizedBox(height: 15),
            Text(
                'In the real world and online, communities and community members sometimes disagree. If you have a dispute with another Community member, we hope that you will be able to work it out amicably. However, if you cannot, please understand that SevaExchange is not responsible for the actions of its members; each member is responsible for their own actions and behavior, whether using SevaExchange or chatting over the back fence. Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: "A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party." ',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(
                'It is hereby acknowledged that while SevaExchange is furnishing this agreement and securely managing in their digital vault, SevaExchange is only providing this as a convenience to the two parties in this agreement. SevaExchange is indemnified from any loss or damage that occurs as a result of this transaction. Neither party will hold SevaExchange accountable and agree to completely absolve SevaExchange should there be any litigation arising from this transaction.',
                style: TextStyle(fontSize: 14)),
          ]),

          SizedBox(height: 35),

          //Date and Name of both Borrower and Lender below (signature proxy)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Lender', style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text(
                requestModel.fullName,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ]),
            SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                SevaCore.of(contextMain).loggedInUser.fullname,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ]),
          ]),
          SizedBox(height: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Agreement Date', style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text(
              DateFormat('MMMM dd, yyyy @ h:mm a',
                      Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.now(),
                    timezoneAbb:
                        SevaCore.of(contextMain).loggedInUser.timezone),
              ),
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ]),
        ],
      ),
    );

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path =
        '$dir/${documentName != null ? documentName + '_' + requestModel.sevaUserId : 'agreement_sevax'}.pdf';
    log("path to pdf file is " + path);

    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    log("requestModel check   " + requestModel.id.toString());
    borrowAgreementLinkFinal =
        await uploadDocument(requestModel.id, file, documentName);

    //await openPdfViewer(borrowAgreementLinkFinal, 'test document', context);

    progressDialog.hide();
    material.Navigator.of(contextMain).pop();

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
      FirebaseStorage.instance.ref().child('agreement_docs').child(name);

  UploadTask uploadTask = ref.putFile(
    _path,
    SettableMetadata(
      contentLanguage: 'en',
      customMetadata: <String, String>{
        'activity': 'request/offer agreement document'
      },
    ),
  );
  String documentURL = '';
  uploadTask.whenComplete(() async {
    documentURL = await ref.getDownloadURL();
    return documentURL;
  });
  return documentURL;
}
