import 'dart:convert';

import 'package:sevaexchange/models/models.dart';

ACHModel ACHModelFromMap(Map<dynamic, dynamic> map) => ACHModel.fromMap(map);

String ACHModelToMap(ACHModel data) => json.encode(data.toMap());

class ACHModel {
  String bank_name;
  String bank_address;
  String routing_number;
  String account_number;
  ACHModel({
    this.bank_name,
    this.bank_address,
    this.routing_number,
    this.account_number,
  });

  factory ACHModel.fromMap(Map<dynamic, dynamic> json) => ACHModel(
        bank_name: json["bank_name"] == null ? null : json["bank_name"],
        bank_address:
            json["bank_address"] == null ? null : json["bank_address"],
        routing_number:
            json["routing_number"] == null ? null : json["routing_number"],
        account_number:
            json["account_number"] == null ? null : json["account_number"],
      );

  Map<String, dynamic> toMap() => {
        "bank_name": bank_name == null ? null : bank_name,
        "bank_address": bank_address == null ? null : bank_address,
        "routing_number": routing_number == null ? null : routing_number,
        "account_number": account_number == null ? null : account_number,
      };
}

CashModel cashModelFromMap(String str) => CashModel.fromMap(json.decode(str));

String cashModelToMap(CashModel data) => json.encode(data.toMap());

class CashModel {
  CashModel({
    this.amountRaised = 0,
    this.paymentType,
    this.donors,
    this.minAmount,
    this.targetAmount,
    this.achdetails,
    this.paypalId,
    this.zelleId,
  });

  int amountRaised = 0;
  RequestPaymentType paymentType;
  ACHModel achdetails = new ACHModel();
  List<String> donors;
  int minAmount;
  int targetAmount;
  String zelleId;
  String paypalId;

  factory CashModel.fromMap(Map<dynamic, dynamic> json) => CashModel(
        paymentType: json["paymentType"] == null
            ? null
            : json["paymentType"] == 'RequestPaymentType.ACH'
                ? RequestPaymentType.ACH
                : json["paymentType"] == 'RequestPaymentType.ZELLEPAY'
                    ? RequestPaymentType.ZELLEPAY
                    : RequestPaymentType.PAYPAL,
        amountRaised:
            json["amountRaised"] == null ? null : json["amountRaised"],
        donors: json["donors"] == null
            ? []
            : List<String>.from(json["donors"].map((x) => x)),
        minAmount: json["minAmount"] == null ? null : json["minAmount"],
        targetAmount:
            json["targetAmount"] == null ? null : json["targetAmount"],
        achdetails: json['achdetails'] == null
            ? null
            : ACHModelFromMap(json['achdetails']),
        paypalId: json["paypalId"] == null ? null : json["paypalId"],
        zelleId: json["zelleId"] == null ? null : json["zelleId"],
      );

  Map<String, dynamic> toMap() => {
        "paymentType": paymentType == null ? null : paymentType.toString(),
        "amountRaised": amountRaised == null ? null : amountRaised,
        "achdetails": achdetails == null ? null : achdetails.toMap(),
        "donors": donors == null ? [] : List<String>.from(donors.map((x) => x)),
        "minAmount": minAmount == null ? null : minAmount,
        "targetAmount": targetAmount == null ? null : targetAmount,
        'zelleId': zelleId == null ? null : zelleId,
        'paypalId': paypalId == null ? null : paypalId,
      };
}
