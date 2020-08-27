import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/donation_model.dart';

import '../../flavor_config.dart';

class SevaMailer {
  static Future<bool> createAndSendEmail({
    @required MailContent mailContent,
  }) async {
    try {
      await http.post(
        "${FlavorConfig.values.cloudFunctionBaseURL}/mailForSoftDelete",
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
    } catch (_) {
      return false;
    }
  }
}

class MailContent {
  final String mailSender;
  final String mailReciever;
  final String mailSubject;
  final String mailContent;

  MailContent.createMail({
    this.mailSender,
    this.mailReciever,
    this.mailSubject,
    this.mailContent,
  });
}

class MailDonationReciept {
  Future<void> sendReciept(DonationModel donationModel) async {
    try {
      var result = await http.post(
        '${FlavorConfig.values.cloudFunctionBaseURL}/sendReceiptToDonor',
        body: jsonEncode({
          "donationModel": donationModel.toMap(),
        }),
      );
      print(result);
    } catch (e) {
      print(e);
    }
  }
}
