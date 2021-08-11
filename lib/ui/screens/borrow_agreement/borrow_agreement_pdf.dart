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
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
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
      int startTime,
      int endTime,
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
                  ' |  For: ${placeOrItem == 'PLACE' ? L.of(contextMain).place : L.of(contextMain).items}'),

          SizedBox(height: 7),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Lease Duration: ', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              DateFormat(
                      'MMMM dd, yyyy @ h:mm a',
                      Locale(AppConfig.prefs.getString('language_code'))
                          .toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                      !isOffer ? requestModel.requestStart : startTime),
                  timezoneAbb: SevaCore.of(contextMain).loggedInUser.timezone,
                ),
              ), //start date and end date
              style: TextStyle(fontSize: 14),
            ),
            Text('  -  ', style: TextStyle(fontSize: 14)),
            Text(
              DateFormat(
                      'MMMM dd, yyyy @ h:mm a',
                      Locale(AppConfig.prefs.getString('language_code'))
                          .toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                      !isOffer ? requestModel.requestEnd : endTime),
                  timezoneAbb: SevaCore.of(contextMain).loggedInUser.timezone,
                ),
              ), //start date and end date
              style: TextStyle(fontSize: 14),
            ),
          ]),

          SizedBox(height: 10),

          Divider(thickness: 1, color: PdfColors.grey),

          SizedBox(height: 20),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Agreement Details: ', style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            (specificConditions != '' || specificConditions != null)
                ? Text("Lender's Specific Conditions: " + specificConditions,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isDamageLiability == true)
                ? Text(
                    'The Borrower is responsible for the full cost of repair or replacement of any or all of the Equipment that is damaged, lost, confiscated, or stolen from the time Borrower assumes custody until it is returned to lender. If the Equipment is lost, stolen or damaged, Borrower agrees to promptly notify the Lender Representative designated above.',
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isUseDisclaimer == true)
                ? Text(
                    'The Borrower shall be responsible for the proper use and deployment of the Equipment. The Borrower shall be responsible for training anyone using the Equipment on the proper use of the Equipment in accordance with any Equipment use procedures.',
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            placeOrItem == 'PLACE'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isRefundDepositNeeded == true)
                            ? Text(
                                'The borrower will provide a refundable deposit as defined within the agreement with the lender. The Criteria established regarding the condition of the item or property upon return will also be defined in the agreement. ',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainAndclean == true)
                            ? Text(
                                "All items and properties borrowed must be returned in a condition similar to the condition it is received by the borrower unless otherwise noted in the agreement. Specific details related to the item and the lender's requirements upon return should be noted in the contract and agreed upon prior to receipt by the borrower.",
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isDeliveryReturn == true)
                            ? Text(
                                'Title to the Equipment the subject of this Agreement shall remain with Lender. The Borrower shall be repsonsible for the safe packaging, proper import, export, shipping and receiving of the Equipment. The Equipment shall be returned within a reasonable amount of time after the Loan Period end date identified.',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainRepair == true)
                            ? Text(
                                'Equipment shall be returned to Lender in as good condition as when received by the Borrower, except for reasonable wear and tear. During the Loan Period and prior to return, the Borrower agrees to assume all responsibility for maintenance and repair.',
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ]),
          ]),

          SizedBox(height: 30),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Terms of Service: ', style: TextStyle(fontSize: 16)),
            //additional texts here
            SizedBox(height: 15),
            Text(
                'In the real world and online, communities and community members sometimes disagree. If you have a dispute with another Community member, we hope that you will be able to work it out amicably." ',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(
                'However, if you cannot, please understand that SevaExchange is not responsible for the actions of its members; each member is responsible for their own actions and behavior, whether using SevaExchange or chatting over the back fence. Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: "A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party." ',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(
                'Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: "A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party." ',
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(
                'If the lender and borrower adjust the return date of the item as defined in the agreement, it is the responsibility of the parties involved to maintain the agreement extension and it is not included in this process or the responsibility of Seva Exchange.',
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
                isOffer
                    ? SevaCore.of(contextMain).loggedInUser.fullname
                    : requestModel
                        .fullName, //need to modify according to offer model or request model
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ]),
            SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Borrower', style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text(
                ' ',
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
              DateFormat('MMMM dd, yyyy | h:mm a',
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
        '$dir/${documentName != null ? documentName + '_' + SevaCore.of(contextMain).loggedInUser.sevaUserID : 'agreement_sevax'}.pdf';

    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    borrowAgreementLinkFinal = await uploadDocument(
        isOffer
            ? SevaCore.of(contextMain).loggedInUser.sevaUserID
            : requestModel.id,
        file,
        documentName);

    progressDialog.hide();

    return borrowAgreementLinkFinal;

    //String borrowAgreementLink =
    //    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/borrow_agreement_docs%2Fsample_pdf.pdf?alt=media&token=094b13b4-dcb2-4303-ad68-3e341227bf00';

    //await openPdfViewer(borrowAgreementLinkFinal, 'test document', context);
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
  try {
    String documentURL =
        await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();

    logger.e('COMES Here 0 PDF Link:  ' + documentURL.toString());
    return documentURL;
  } catch (error) {
    logger.e('Error uploading agreement pdf: ' + error.toString());
    return documentURL;
  }
}
