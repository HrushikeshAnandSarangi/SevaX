import 'package:universal_io/io.dart' as io;
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
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
      LendingModel lendingModel,
      List<LendingModel> lendingModelListBorrowRequest,
      String borrower,
      String documentName,
      bool isOffer,
      int startTime,
      int endTime,
      String placeOrItem,
      String specificConditions,
      bool isDamageLiability,
      bool isUseDisclaimer,
      bool isDeliveryReturn, //for borrow/lend ITEM
      bool isMaintainRepair, //for borrow/lend ITEM
      bool isRefundDepositNeeded, //for borrow/lend PLACE
      bool isMaintainAndclean, //for borrow/lend PLACE
      String agreementId) async {
    bool isLoading = false;

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
            return Container();
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
                  ? S.of(contextMain).borrow_request_agreement
                  : S.of(contextMain).lending_offer_agreement,
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
              text: documentName ??
                  'Agreement Name Not available' +
                      ' |  For: ${placeOrItem == 'PLACE' ? S.of(contextMain).place_text : S.of(contextMain).items}'),

          SizedBox(height: 7),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                endTime == 0 && isOffer
                    ? S.of(contextMain).lease_start_date
                    : S.of(contextMain).lease_duration,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(width: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                        'MMMM dd, yyyy @ h:mm a',
                        Locale(AppConfig.prefs!.getString('language_code') ??
                                'en')
                            .toLanguageTag())
                    .format(
                  getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(!isOffer
                        ? (requestModel.requestStart ?? 0)
                        : (startTime ?? 0)),
                    timezoneAbb:
                        SevaCore.of(contextMain).loggedInUser.timezone ?? 'UTC',
                  ),
                ), //start date and end date
                style: TextStyle(fontSize: 14),
              ),
              endTime == 0 && isOffer
                  ? Container()
                  : Text('  -  ', style: TextStyle(fontSize: 14)),
              endTime == 0 && isOffer
                  ? Container()
                  : Text(
                      DateFormat(
                              'MMMM dd, yyyy @ h:mm a',
                              Locale(AppConfig.prefs!
                                          .getString('language_code') ??
                                      'en')
                                  .toLanguageTag())
                          .format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(!isOffer
                              ? (requestModel.requestEnd ?? 0)
                              : endTime),
                          timezoneAbb:
                              SevaCore.of(contextMain).loggedInUser.timezone ??
                                  'UTC',
                        ),
                      ), //start date and end date
                      style: TextStyle(fontSize: 14),
                    ),
            ],
          ),

          SizedBox(height: 10),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.of(contextMain).agreement_id,
                style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              agreementId ?? 'Not available',
              style: TextStyle(fontSize: 14),
            ),
          ]),

          Divider(thickness: 1, color: PdfColors.grey),

          SizedBox(height: 20),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (specificConditions.isNotEmpty && specificConditions != null)
                ? Text(S.of(contextMain).agreement_details,
                    style: TextStyle(fontSize: 16))
                : Container(),
            specificConditions.isNotEmpty && specificConditions != null
                ? SizedBox(height: 15)
                : Container(),
            (specificConditions.isNotEmpty && specificConditions != null)
                ? Text(
                    S.of(contextMain).lenders_specific_conditions +
                        specificConditions,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isDamageLiability == true)
                ? Text(S.of(contextMain).agreement_damage_liability,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            (isUseDisclaimer == true)
                ? Text(S.of(contextMain).agreement_user_disclaimer,
                    style: TextStyle(fontSize: 14))
                : Container(),
            SizedBox(height: 10),
            placeOrItem == 'PLACE'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isRefundDepositNeeded == true)
                            ? Text(S.of(contextMain).agreement_refund_deposit,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainAndclean == true)
                            ? Text(
                                S.of(contextMain).agreement_maintain_and_clean,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        (isDeliveryReturn == true)
                            ? Text(S.of(contextMain).agreement_delivery_return,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                        SizedBox(height: 10),
                        (isMaintainRepair == true)
                            ? Text(
                                S.of(contextMain).agreement_maintain_and_repair,
                                style: TextStyle(fontSize: 14))
                            : Container(),
                      ]),
          ]),

          SizedBox(height: 25),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.of(contextMain).terms_of_service,
                style: TextStyle(fontSize: 16)),
            //additional texts here
            SizedBox(height: 15),
            Text(S.of(contextMain).borrow_lender_dispute,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(S.of(contextMain).borrow_request_seva_disclaimer,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(S.of(contextMain).civil_code_dispute,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(S.of(contextMain).agreement_amending_disclaimer,
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 15),
            Text(S.of(contextMain).agreement_final_acknowledgement,
                style: TextStyle(fontSize: 14)),
          ]),

          SizedBox(height: 35),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.of(contextMain).please_note_text,
                style: TextStyle(fontSize: 16)),
            //additional texts here
            SizedBox(height: 15),
            Text(S.of(contextMain).agreement_prior_to_signing_disclaimer,
                style: TextStyle(fontSize: 14)),
          ]),

          SizedBox(height: 35),

          //Lending Offer Estimated Value of Item(s)/Place
          (lendingModel != null && isOffer)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (lendingModel.lendingType == LendingType.PLACE
                                  ? S.of(contextMain).name_place_text
                                  : S.of(contextMain).name_item_text) +
                              ': ',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        Text(
                          lendingModel.lendingType == LendingType.PLACE
                              ? (lendingModel.lendingPlaceModel?.placeName ??
                                      'N/A')
                                  .toString()
                              : (lendingModel.lendingItemModel?.itemName ??
                                      'N/A')
                                  .toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            S
                                    .of(contextMain)
                                    .estimated_value
                                    .replaceAll('*', '') +
                                ': ',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            lendingModel.lendingType == LendingType.PLACE
                                ? "\$" +
                                    lendingModel
                                        .lendingPlaceModel!.estimatedValue
                                        .toString()
                                : "\$" +
                                    lendingModel
                                        .lendingItemModel!.estimatedValue
                                        .toString(),
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                )
              : Container(),

          //______________________________>

          //Borrow Request Estimated Value of Item(s)/Place
          (!isOffer && placeOrItem == LendingType.PLACE.readable)
              ? //FOR PLACE AGREEMENT | BORROW REQUEST
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(contextMain).name_place_text + ': ',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        Text(
                          (lendingModel.lendingPlaceModel?.placeName ?? 'N/A')
                              .toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            S
                                    .of(contextMain)
                                    .estimated_value
                                    .replaceAll('*', '') +
                                ': ',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            "\$" +
                                (lendingModel.lendingPlaceModel?.estimatedValue
                                        ?.toString() ??
                                    'N/A'),
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                )
              :
              //FOR ITEM AGREEMENT | BORROW REQUEST
              (lendingModelListBorrowRequest != null &&
                      !isOffer &&
                      placeOrItem == LendingType.ITEM.readable)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(contextMain).estimated_value_items,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        ListView(
                          // physics: NeverScrollableScrollPhysics(),
                          // shrinkWrap: true,
                          children: List.generate(
                            lendingModelListBorrowRequest.length,
                            (index) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lendingModelListBorrowRequest[index]
                                          .lendingItemModel!
                                          .itemName! +
                                      ': ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "\$" +
                                      lendingModelListBorrowRequest[index]
                                          .lendingItemModel!
                                          .estimatedValue
                                          .toString(),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),

          //______________________________>

          SizedBox(height: 25),

          //Date and Name of both Borrower and Lender below (signature proxy)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(S.of(contextMain).lender_text,
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text(
                SevaCore.of(contextMain).loggedInUser.fullname!,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ]),
            SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(S.of(contextMain).borrower_text,
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text(
                isOffer
                    ? borrower
                    : requestModel.fullName ??
                        'N/A', //need to modify according to offer model or request model
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ]),
          ]),
          SizedBox(height: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(S.of(contextMain).agreement_date,
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 15),
            Text(
              DateFormat('MMMM dd, yyyy | h:mm a',
                      Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.now(),
                    timezoneAbb:
                        SevaCore.of(contextMain).loggedInUser.timezone!),
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
        '$dir/${(documentName ?? 'agreement_sevax') + '_' + SevaCore.of(contextMain).loggedInUser.sevaUserID!}.pdf';

    final io.File file = io.File(path);
    await file.writeAsBytes(await pdf.save());

    borrowAgreementLinkFinal = await uploadDocument(
        isOffer
            ? SevaCore.of(contextMain).loggedInUser.sevaUserID!
            : requestModel.id!,
        file,
        documentName ?? 'Agreement Name Not available');

    //    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/borrow_agreement_docs%2Fsample_pdf.pdf?alt=media&token=094b13b4-dcb2-4303-ad68-3e341227bf00';
    return borrowAgreementLinkFinal;

    //await openPdfViewer(borrowAgreementLinkFinal, 'test document', context);
    // Removed ProgressDialog dismissal as progress is managed elsewhere
  }

  Future<void> openPdfViewer(
      String pdfURL, String documentName, material.BuildContext context) async {
    try {
      // Use ModalProgressHUD if available, or show a loading indicator as needed
      // If you have a ProgressHUD widget, import it and use it here.
      // For now, we'll just proceed without it.
      await material.Navigator.push(
        context,
        material.MaterialPageRoute(
          builder: (context) => PDFScreen(
            docName: documentName,
            pathPDF: pdfURL,
            pdfUrl: pdfURL,
            isFromFeeds: false,
          ),
        ),
      );
    } catch (error) {
      // Handle error or log it
      logger.e('Error opening PDF viewer: $error');
    }
  }

  Future<String> uploadDocument(
      String requestId, io.File _path, String documentName) async {
    // Generate a timestamp string for uniqueness
    String timestampString = DateTime.now().millisecondsSinceEpoch.toString();

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
      documentURL = await (await uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();

      logger.e('COMES Here 0 PDF Link:  ' + documentURL.toString());
      return documentURL;
    } catch (error) {
      logger.e('Error uploading agreement pdf: ' + error.toString());
      return documentURL;
    }
  }
}
