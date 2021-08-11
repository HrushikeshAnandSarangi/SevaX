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
              isOffer
                  ? L.of(contextMain).borrow_request_agreement
                  : L.of(contextMain).lending_offer_agreement,
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
            Text(L.of(contextMain).lease_duration,
                style: TextStyle(fontSize: 16)),
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
            Text(L.of(contextMain).agreement_details,
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            (specificConditions != '' || specificConditions != null)
                ? Text(
                    L.of(contextMain).lenders_specific_conditions +
                        specificConditions,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isDamageLiability == true)
                ? Text(L.of(contextMain).agreement_damage_liability,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isUseDisclaimer == true)
                ? Text(L.of(contextMain).agreement_user_disclaimer,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            placeOrItem == 'PLACE'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isRefundDepositNeeded == true)
                            ? Text(L.of(contextMain).agreement_refund_deposit,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainAndclean == true)
                            ? Text(
                                L.of(contextMain).agreement_maintain_and_clean,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isDeliveryReturn == true)
                            ? Text(L.of(contextMain).agreement_delivery_return,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainRepair == true)
                            ? Text(
                                L.of(contextMain).agreement_maintain_and_repair,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ]),
          ]),

          SizedBox(height: 30),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(L.of(contextMain).terms_of_service,
                style: TextStyle(fontSize: 16)),
            //additional texts here
            SizedBox(height: 15),
            Text(L.of(contextMain).borrow_lender_dispute,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(L.of(contextMain).borrow_request_seva_disclaimer,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(L.of(contextMain).civil_code_dispute,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(L.of(contextMain).agreement_amending_disclaimer,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(L.of(contextMain).agreement_final_acknowledgement,
                style: TextStyle(fontSize: 14)),
          ]),

          SizedBox(height: 35),

          //Date and Name of both Borrower and Lender below (signature proxy)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(L.of(contextMain).lender, style: TextStyle(fontSize: 16)),
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
              Text(L.of(contextMain).borrower, style: TextStyle(fontSize: 16)),
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
            Text(L.of(contextMain).agreement_date,
                style: TextStyle(fontSize: 16)),
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
