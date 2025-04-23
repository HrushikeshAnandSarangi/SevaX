import 'dart:developer';
import 'package:universal_io/io.dart' as io;
import 'package:flutter/material.dart' as material;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/invoice/pages/invoice_screen.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class TransactionsPdf {
  Future<void> transactionsPdf(
    mainContext,
    TransactionModel transactionModel,
    DonationModel donationModel,
    RequestModel requestModel,
    CommunityModel communityModel,
  ) async {
    final Document pdf = Document();

    Widget hideWidget({bool? hide, Widget? child}) {
      return hide == true ? Container() : child!;
    }

    DateTime date = DateTime.now();
    // final font = await rootBundle.load("fonts/OpenSans-Regular.ttf");
    // final ttf = Font.ttf(font);
    // final fontBold = await rootBundle.load("fonts/OpenSans-Bold.ttf");
    // final ttfBold = Font.ttf(fontBold);
    // final fontItalic = await rootBundle.load("fonts/OpenSans-Italic.ttf");
    // final ttfItalic = Font.ttf(fontItalic);
    // final fontBoldItalic =
    //     await rootBundle.load("fonts/OpenSans-BoldItalic.ttf");
    // final ttfBoldItalic = Font.ttf(fontBoldItalic);
    // final ThemeData theme = ThemeData.withFont(
    //   base: ttf,
    //   bold: ttfBold,
    //   italic: ttfItalic,
    //   boldItalic: ttfBoldItalic,
    // );

    double totalAmount = 0.0;
    String receiptIDCash = '';
    String receiptIDGoods = '';
    String receiptID = '';
    List<String> listOFGoods = [];
    TimebankModel? transactionTimebankModel;
    UserModel? fromTransactionUserModel;
    UserModel? toTransactionUserModel;
    //fetching from and to model
    if (donationModel == null) {
      receiptID = transactionModel.typeid!
          .substring(transactionModel.typeid!.length - 8);
      if (transactionModel.from != null &&
          transactionModel.from!.contains('-')) {
        transactionTimebankModel =
            await getTimeBankForId(timebankId: transactionModel.from!);
      } else if (transactionModel.from != null) {
        fromTransactionUserModel = await Provider.of<MembersBloc>(
          mainContext,
          listen: false,
        ).getUserModel(userId: transactionModel.from!);
      }
      if (transactionModel.to != null && transactionModel.to!.contains('-')) {
        transactionTimebankModel =
            await getTimeBankForId(timebankId: transactionModel.to!);
      } else if (transactionModel.to != null) {
        toTransactionUserModel = await Provider.of<MembersBloc>(
          mainContext,
          listen: false,
        ).getUserModel(userId: transactionModel.to);
      }
    } else if (donationModel != null &&
        donationModel.donationType == RequestType.CASH) {
      totalAmount = donationModel.cashDetails!.pledgedAmount!.toDouble();
      receiptIDCash = donationModel.id!.substring(donationModel.id!.length - 8);
    } else {
      receiptIDGoods =
          donationModel.id!.substring(donationModel.id!.length - 8);
      Map<String, String> goodsList = donationModel.goodsDetails!.donatedGoods!;

      goodsList.forEach((key, value) {
        listOFGoods.add(value);
      });
    }

    final imageBytes = (await rootBundle.load('images/invoice_seva_logo.jpg'))
        .buffer
        .asUint8List();

    Widget _rowText(String text, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 30),
          Text(value),
        ],
      );
    }

    // String getDescription(String text) {
    //   String formattedValue = text;
    //   if (text.contains('×')) {
    //     formattedValue = text.split('×')[1];
    //   }
    //   if (formattedValue.contains('(')) {
    //     formattedValue = formattedValue.split('(')[0];
    //   }
    //   return formattedValue;
    // }

    void cashPdf() {
      return pdf.addPage(
        MultiPage(
          // theme: theme,
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: CrossAxisAlignment.start,
          header: (Context context) {
            if (context.pageNumber == 1) {
              return null!;
            }
            return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: PdfColors.grey),
                ),
              ),
              child: Text(
                'Transactions',
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
              width: PdfPageFormat.cm * 5,
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image(
                  MemoryImage(imageBytes),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Donated By:",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(donationModel.donorDetails!.name!),
                    Text(donationModel.donorDetails!.email!),
                    // Text(transactionModel.to.contains('-')
                    //     ? transactionTimebankModel.emailId ?? ''
                    //     : fromTransactionUserModel.email ?? ''),
                    // Text(transactionModel.to.contains('-')
                    //     ? transactionTimebankModel.phoneNumber ?? ''
                    //     : fromTransactionUserModel.otp ?? ''),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DONATION AMOUNT",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        "\$ ${donationModel.cashDetails!.pledgedAmount!.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Donated To:",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(donationModel.receiverDetails!.name!),
                        Text(donationModel.receiverDetails!.email!),
                        // Text(transactionModel.to.contains('-')
                        //     ? transactionTimebankModel.emailId ?? ''
                        //     : toTransactionUserModel.email ?? ''),
                        // Text(transactionModel.to.contains('-')
                        //     ? transactionTimebankModel.phoneNumber ?? ''
                        //     : toTransactionUserModel.otp ?? ''),
                      ]),
                  Spacer(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "RECEIPT  STATEMENT:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text("Receipt  Number: ${receiptIDCash}",
                            style: TextStyle(fontSize: 12)),
                        Text(
                            "Receipt Date: ${DateFormat('MMMM d, y').format(date)}",
                            style: TextStyle(fontSize: 12)),
                      ]),
                ]),
            SizedBox(height: 8),
            Divider(thickness: 1, color: PdfColors.grey),
            Row(children: [
              Text('DONATION INFORMATION',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Spacer(),
              Text('No',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Spacer(),
              Text('DONATION AMOUNT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
            ]),
            Divider(thickness: 1, color: PdfColors.grey),
            Column(children: [
              ListView(
                  children: List.generate(
                1,
                (index) => Column(children: [
                  Row(children: [
                    Text(donationModel.requestTitle!),
                    Spacer(),
                    Text('1'),
                    Spacer(),
                    Text(donationModel.cashDetails!.pledgedAmount!
                        .toStringAsFixed(2)),
                  ]),
                  Divider(thickness: 1, color: PdfColors.grey),
                ]),
              )),
            ]),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 12),
                    _rowText(" TOTAL", "\$${totalAmount.toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: PdfColors.grey),
          ],
        ),
      );
    }

    void goodsPdf() {
      pdf.addPage(
        MultiPage(
          // theme: theme,
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: CrossAxisAlignment.start,
          header: (Context context) {
            if (context.pageNumber == 1) {
              return null!;
            }
            return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: PdfColors.grey),
                ),
              ),
              child: Text(
                'Transactions',
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
              width: PdfPageFormat.cm * 5,
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image(
                  MemoryImage(imageBytes),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Donated By:",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(donationModel.donorDetails!.name!),
                    Text(donationModel.donorDetails!.email!),
                    // Text(transactionModel.to.contains('-')
                    //     ? transactionTimebankModel.emailId ?? ''
                    //     : fromTransactionUserModel.email ?? ''),
                    // Text(transactionModel.to.contains('-')
                    //     ? transactionTimebankModel.phoneNumber ?? ''
                    //     : fromTransactionUserModel.email ?? ''),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GOODS DONATED",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(listOFGoods.length.toString(),
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Donated To:",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(donationModel.receiverDetails!.name!),
                        Text(donationModel.receiverDetails!.email!),
                      ]),
                  Spacer(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "RECEIPT  STATEMENT:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text("Receipt  Number: ${receiptIDGoods}",
                            style: TextStyle(fontSize: 12)),
                        Text(
                            "Receipt Date: ${DateFormat('MMMM d, y').format(date)}",
                            style: TextStyle(fontSize: 12)),
                      ]),
                ]),
            SizedBox(height: 8),
            Divider(thickness: 1, color: PdfColors.grey),
            Row(children: [
              Text('DONATION INFORMATION',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
            Divider(thickness: 1, color: PdfColors.grey),
            Column(children: [
              ListView(
                  children: List.generate(
                listOFGoods.length,
                (index) => Column(children: [
                  Row(children: [
                    Text(listOFGoods[index]),
                    Spacer(),
                    // Text('here'),
                  ]),
                  Divider(thickness: 1, color: PdfColors.grey),
                ]),
              )),
            ]),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 12),
                    _rowText("TOTAL  ITEMS", "${(listOFGoods.length)}"),
                    SizedBox(height: 8),
                    // _rowText("GRAND TOTAL",
                    //     "\$ ${totalAmount - freeLimitAmount > 0 ? (totalAmount - freeLimitAmount) : 0}"),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: PdfColors.grey),
          ],
        ),
      );
    }

    void defaultPdf(contextNew) {
      pdf.addPage(
        MultiPage(
          // theme: theme,
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: CrossAxisAlignment.start,
          header: (Context context) {
            if (context.pageNumber == 1) {
              return null!;
            }
            return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: PdfColors.grey),
                ),
              ),
              child: Text(
                'Transactions',
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
              width: PdfPageFormat.cm * 5,
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image(
                  MemoryImage(imageBytes),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "From:",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(transactionModel.from!.contains('-')
                        ? (transactionTimebankModel != null
                            ? transactionTimebankModel.name ?? ''
                            : '')
                        : (fromTransactionUserModel != null
                            ? fromTransactionUserModel.fullname ?? ''
                            : '')),
                    Text(transactionModel.to!.contains('-')
                        ? (transactionTimebankModel != null
                            ? transactionTimebankModel.address ?? ''
                            : '')
                        : (fromTransactionUserModel != null
                            ? (fromTransactionUserModel != null
                                ? fromTransactionUserModel.locationName ?? ''
                                : '')
                            : '')),
                    Text(transactionModel.to!.contains('-')
                        ? (transactionTimebankModel != null
                            ? transactionTimebankModel.emailId ?? ''
                            : '')
                        : (fromTransactionUserModel != null
                            ? fromTransactionUserModel.email ?? ''
                            : '')),
                    Text(transactionModel.to!.contains('-')
                        ? (transactionTimebankModel != null
                            ? transactionTimebankModel.phoneNumber ?? ''
                            : '')
                        : ''),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(contextNew).seva_credits,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text("${transactionModel.credits!.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "To:",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(transactionModel.to!.contains('-')
                            ? (transactionTimebankModel != null
                                ? transactionTimebankModel.name ?? ''
                                : '')
                            : (toTransactionUserModel != null
                                ? toTransactionUserModel.fullname ?? ''
                                : '')),
                        Text(transactionModel.to!.contains('-')
                            ? (transactionTimebankModel != null
                                ? transactionTimebankModel.address ?? ''
                                : '')
                            : (fromTransactionUserModel != null
                                ? fromTransactionUserModel.locationName ?? ''
                                : '')),
                        Text(transactionModel.to!.contains('-')
                            ? (transactionTimebankModel != null
                                ? transactionTimebankModel.emailId ?? ''
                                : '')
                            : (toTransactionUserModel != null
                                ? toTransactionUserModel.email ?? ''
                                : '')),
                        Text(transactionModel.to!.contains('-')
                            ? (transactionTimebankModel != null
                                ? transactionTimebankModel.phoneNumber ?? ''
                                : '')
                            : ''),
                      ]),
                  Spacer(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "RECEIPT  STATEMENT:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text("Receipt  Number: ${receiptID}",
                            style: TextStyle(fontSize: 12)),
                        Text(
                            "Receipt Date: ${DateFormat('MMMM d, y').format(date)}",
                            style: TextStyle(fontSize: 12)),
                      ]),
                ]),
            SizedBox(height: 8),
            Divider(thickness: 1, color: PdfColors.grey),
            Row(children: [
              Text('DONATION INFORMATION',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
            Divider(thickness: 1, color: PdfColors.grey),
            Column(children: [
              ListView(
                  children: List.generate(
                1,
                (index) => Column(children: [
                  Row(children: [
                    Text(requestModel != null ? requestModel.title ?? '' : ''),
                    Spacer(),
                    Text(transactionModel.credits!.toStringAsFixed(2)),
                  ]),
                  Divider(thickness: 1, color: PdfColors.grey),
                ]),
              )),
            ]),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 12),
                    _rowText("TOTAL ",
                        "${(transactionModel.credits)!.toStringAsFixed(2)}"),
                    SizedBox(height: 8),
                    // _rowText("GRAND TOTAL",
                    //     "\$ ${totalAmount - freeLimitAmount > 0 ? (totalAmount - freeLimitAmount) : 0}"),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Divider(thickness: 1, color: PdfColors.grey),
          ],
        ),
      );
    }

    if (donationModel != null) {
      if (donationModel.donationType == RequestType.CASH) {
        logger
            .e("inside cash request " + donationModel.donationType.toString());
        cashPdf();
      } else {
        logger
            .e("inside goods request " + donationModel.donationType.toString());
        goodsPdf();
      }
    } else {
      logger.e("default case " + donationModel.toString());
      defaultPdf(mainContext);
    }

    final String dir = (await getApplicationDocumentsDirectory()).path;
//    final String dir = (await getExternalStorageDirectory()).path;
    final String path = '$dir/invoice.pdf';
//    final String path = 'C://invoice.pdf';

    // LocalFileDownloader()
    //     .download('report', path)
    //     .then(
    //       (_) => log('file downloaded'),
    //     )
    //     .catchError((e) => log(e));

    log("path to pdf file is " + path);
    final io.File file = io.File(path);
    await file.writeAsBytes(await pdf.save());
    material.Navigator.of(mainContext).push(
      material.MaterialPageRoute(
        builder: (_) => InvoiceScreen(
          path: path,
          pdfType: "invoice",
        ),
      ),
    );

//BELOW FROM WEB MIGRATION ------------------------------------->
    // final bytes = await pdf.save();
    // final blob = html.Blob([bytes], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = 'transactions_${DateFormat('MMMM_y').format(date)}.pdf';
    // html.document.body.children.add(anchor);

    // // download
    // anchor.click();

    // // cleanup
    // html.document.body.children.remove(anchor);
    // html.Url.revokeObjectUrl(url);
  }
}
