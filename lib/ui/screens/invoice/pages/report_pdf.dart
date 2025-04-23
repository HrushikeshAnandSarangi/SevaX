import 'dart:developer';
import 'package:universal_io/io.dart' as io;
import 'dart:typed_data';

import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:sevaexchange/models/invoice_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/invoice/pages/invoice_screen.dart';

class ReportPdf {
  void reportPdf(context, InvoiceModel model, CommunityModel communityModel,
      String date, Map<String, dynamic> myPlan) async {
    final Document pdf = Document();
    List<String> monthsArr = [
      "January",
      "Febuary",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    final ByteData bytes =
        await rootBundle.load('images/invoice_seva_logo.jpg');
    final Uint8List byteList = bytes.buffer.asUint8List();

    Widget _rowText(String text, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          SizedBox(width: 30),
          Text(value),
        ],
      );
    }

    double getSubTotal() {
      double subtotal = 0;
      model.details?.forEach(
          (element) => subtotal += (element.price ?? 0) * (element.units ?? 0));
      return subtotal;
    }

    var freeLimitAmount =
        myPlan['initial_transactions_qty'] * myPlan['pro_data_bill_amount'];
    var totalAmount = getSubTotal();
    pdf.addPage(
      MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return SizedBox.shrink();
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
              'Report',
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
                MemoryImage(
                  byteList,
                ),
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
                    "Bill to Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("${communityModel.billing_address.companyname},",
                      style: TextStyle(fontSize: 14)),
                  Text(
                      "${communityModel.billing_address.street_address1 != "" ? communityModel.billing_address.street_address1 : ""}",
                      style: TextStyle(fontSize: 14)),
                  Text(
                      "${communityModel.billing_address.street_address2 != "" ? communityModel.billing_address.street_address2 + ' ' : ""}${communityModel.billing_address.city} ${communityModel.billing_address.pincode}",
                      style: TextStyle(fontSize: 14)),
                  Text(
                      "${communityModel.billing_address.state} ${communityModel.billing_address.country}",
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Account Number:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                      "${communityModel.sevaxAccountNo == null ? '' : communityModel.sevaxAccountNo}",
                      style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    "BILLING STATEMENT:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Statement Number: 142544581",
                      style: TextStyle(fontSize: 14)),
                  Text(
                      "Statement Date: 29th ${monthsArr[int.parse(date.split('_')[0]) - 1]}, ${date.split('_')[1]}",
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Header(level: 2, text: model.note1),
          SizedBox(height: 10),
          Header(level: 2, text: model.note2),
          SizedBox(height: 10),
          Divider(thickness: 1, color: PdfColors.grey),
          Table.fromTextArray(
            context: context,
            border: null,
            cellAlignments: {
              0: Alignment.centerLeft,
              1: Alignment.center,
              2: Alignment.center,
              3: Alignment.center,
            },
            columnWidths: {
              0: FlexColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth(),
              3: IntrinsicColumnWidth(),
            },
            cellHeight: 40,
            cellStyle: TextStyle(fontSize: 14),
            headerStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            headerDecoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 1, color: PdfColors.grey)),
            ),
            rowDecoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 1, color: PdfColors.grey)),
            ),
            headers: ['DETAILS', 'NO.', 'PRICE', 'TOTAL'],
            data: List.generate(
              model.details?.length ?? 0,
              (index) => [
                model.details?[index].description ?? '',
                model.details?[index].units ?? 0,
                model.details?[index].price ?? 0,
                ((model.details?[index].units ?? 0) *
                    (model.details?[index].price ?? 0)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 12),
                  _rowText("SUB TOTAL", "\$ ${totalAmount}"),
                  SizedBox(height: 8),
                  _rowText("INITIAL PAYMENT PER YEAR",
                      "\$ ${myPlan['initial_transactions_amount']}"),
                  SizedBox(height: 8),
                  _rowText(
                      "FREE LIMIT PER MONTH (FOR ${myPlan['name'].toUpperCase()})",
                      "\$ ${freeLimitAmount}"),
                  SizedBox(height: 8),
                  _rowText("GRAND TOTAL",
                      "\$ ${totalAmount - freeLimitAmount > 0 ? (totalAmount - freeLimitAmount) : 0}"),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Divider(thickness: 1, color: PdfColors.grey),
        ],
      ),
    );
    //save PDF

    final String dir = (await getApplicationDocumentsDirectory()).path;
//    final String dir = (await getExternalStorageDirectory()).path;
    final String path = '$dir/report.pdf';
//    final String path = 'C://report.pdf';
    log("path to pdf file is " + path);
    final io.File file = io.File(path);
    await file.writeAsBytes(await pdf.save());
    material.Navigator.of(context).push(
      material.MaterialPageRoute(
        builder: (_) => InvoiceScreen(path: path, pdfType: "report"),
      ),
    );
  }
}
