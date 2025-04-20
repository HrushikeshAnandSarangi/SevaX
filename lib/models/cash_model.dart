import 'dart:convert';

import 'package:sevaexchange/models/models.dart';

ACHModel ACHModelFromMap(Map<dynamic, dynamic> map) => ACHModel.fromMap(map);

String ACHModelToMap(ACHModel data) => json.encode(data.toMap());

class ACHModel {
  String? bank_name;
  String? bank_address;
  String? routing_number;
  String? account_number;
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
    this.venmoId,
    this.swiftId,
    this.others,
    this.other_details,
    this.requestCurrencyType,
    this.offerCurrencyType,
    this.offerDonatedCurrencyType,
    this.requestDonatedCurrency,
    this.offerCurrencyFlag,
    this.requestCurrencyFlag,
  });

  double? amountRaised = 0;
  RequestPaymentType? paymentType;
  ACHModel? achdetails = new ACHModel();
  List<String>? donors;
  int? minAmount;
  int? targetAmount;
  String? zelleId;
  String? paypalId;
  String? venmoId;
  String? swiftId;
  String? others;
  String? other_details;
  String? requestCurrencyType;
  String? offerCurrencyType;
  String? offerDonatedCurrencyType;
  String? requestDonatedCurrency;
  String? offerCurrencyFlag;
  String? requestCurrencyFlag;

  factory CashModel.fromMap(Map<dynamic, dynamic> json) => CashModel(
        paymentType: json["paymentType"] == null
            ? null
            : json["paymentType"] == 'RequestPaymentType.ACH'
                ? RequestPaymentType.ACH
                : json["paymentType"] == 'RequestPaymentType.ZELLEPAY'
                    ? RequestPaymentType.ZELLEPAY
                    : json["paymentType"] == 'RequestPaymentType.VENMO'
                        ? RequestPaymentType.VENMO
                        : json["paymentType"] == 'RequestPaymentType.SWIFT'
                            ? RequestPaymentType.SWIFT
                            : json["paymentType"] == 'RequestPaymentType.OTHER'
                                ? RequestPaymentType.OTHER
                                : RequestPaymentType.PAYPAL,
        amountRaised: json["amountRaised"] == null
            ? null
            : double.parse(json["amountRaised"].toString()),
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
        venmoId: json["venmoId"] == null ? null : json["venmoId"],
        swiftId: json["swiftId"] == null ? null : json["swiftId"],
        others: json["others"] == null ? null : json["others"],
        other_details:
            json["other_details"] == null ? null : json["other_details"],
        requestCurrencyType: json["requestCurrencyType"] == null
            ? null
            : json["requestCurrencyType"],
        offerCurrencyType: json["offerCurrencyType"] == null
            ? null
            : json["offerCurrencyType"],
        offerDonatedCurrencyType: json["offerDonatedCurrencyType"] == null
            ? null
            : json["offerDonatedCurrencyType"],
        requestDonatedCurrency: json["requestDonatedCurrency"] == null
            ? null
            : json["requestDonatedCurrency"],
        offerCurrencyFlag: json["offerCurrencyFlag"] == null
            ? null
            : json["offerCurrencyFlag"],
        requestCurrencyFlag: json["requestCurrencyFlag"] == null
            ? null
            : json["requestCurrencyFlag"],
      );

  Map<String, dynamic> toMap() => {
        "paymentType": paymentType == null ? null : paymentType.toString(),
        "amountRaised": amountRaised == null ? null : amountRaised,
        "achdetails": achdetails == null ? null : achdetails?.toMap(),
        "donors": donors == null
            ? []
            : List<String>.from(donors?.map((x) => x) ?? []),
        "minAmount": minAmount == null ? null : minAmount,
        "targetAmount": targetAmount == null ? null : targetAmount,
        'zelleId': zelleId == null ? null : zelleId,
        'paypalId': paypalId == null ? null : paypalId,
        'venmoId': venmoId == null ? null : venmoId,
        'swiftId': swiftId == null ? null : swiftId,
        'others': others == null ? null : others,
        'other_details': other_details == null ? null : other_details,
        'requestCurrencyType':
            requestCurrencyType == null ? null : requestCurrencyType,
        'offerCurrencyType':
            offerCurrencyType == null ? null : offerCurrencyType,
        'offerDonatedCurrencyType':
            offerDonatedCurrencyType == null ? null : offerDonatedCurrencyType,
        'requestDonatedCurrency':
            requestDonatedCurrency == null ? null : requestDonatedCurrency,
        'offerCurrencyFlag':
            offerCurrencyFlag == null ? null : offerCurrencyFlag,
        'requestCurrencyFlag':
            requestCurrencyFlag == null ? null : requestCurrencyFlag,
      };
}
