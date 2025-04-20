import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import '../../flavor_config.dart';

class SevaMailer {
  static Future<bool> createAndSendEmail({
    required MailContent mailContent,
  }) async {
    try {
      await http.post(
        Uri.parse(
            "${FlavorConfig.values.cloudFunctionBaseURL}/mailForSoftDelete"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            "mailSender": mailContent.mailSender,
            'mailReceiver': mailContent.mailReciever,
            "mailSubject": mailContent.mailSubject,
            "mailBodyHtml": mailContent.mailContent,
          },
        ),
      );
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }
}

class MailContent {
  final String? mailSender;
  final String? mailReciever;
  final String? mailSubject;
  final String? mailContent;

  MailContent.createMail({
    this.mailSender,
    this.mailReciever,
    this.mailSubject,
    this.mailContent,
  });
}

class MailDonationReciept {
  static Future<void> sendReciept(DonationModel donationModel) async {
    try {
      var result = await http.post(
        Uri.parse(
            '${FlavorConfig.values.cloudFunctionBaseURL}/sendReceiptToDonor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "donationModel": donationModel.toMap(),
        }),
      );
    } catch (e) {
      logger.e(e);
    }
  }
}

class MailBorrowRequestReceipts {
  static Future<void> sendBorrowRequestReceipts(
      RequestModel requestModel) async {
    try {
      log('inside send borrow requests receipts api');
      await http.post(
        Uri.parse(
            'https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/sendBorrowRequestReceipts'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "requestModel": requestModel.toMap(),
        }),
      );
    } catch (e) {
      logger.e(e);
    }
  }
}
