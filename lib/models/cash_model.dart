import 'dart:convert';

CashModel cashModelFromMap(String str) => CashModel.fromMap(json.decode(str));

String cashModelToMap(CashModel data) => json.encode(data.toMap());

class CashModel {
  CashModel({
    this.amountRaised,
    this.donationInstructionLink,
    this.donors,
    this.minAmount,
    this.targetAmount,
  });

  int amountRaised;
  String donationInstructionLink;
  List<dynamic> donors;
  int minAmount;
  int targetAmount;

  factory CashModel.fromMap(Map<dynamic, dynamic> json) => CashModel(
        amountRaised:
            json["amountRaised"] == null ? null : json["amountRaised"],
        donationInstructionLink: json["donationInstructionLink"] == null
            ? null
            : json["donationInstructionLink"],
        donors: json["donors"] == null
            ? null
            : List<dynamic>.from(json["donors"].map((x) => x)),
        minAmount: json["minAmount"] == null ? null : json["minAmount"],
        targetAmount:
            json["targetAmount"] == null ? null : json["targetAmount"],
      );

  Map<String, dynamic> toMap() => {
        "amountRaised": amountRaised == null ? null : amountRaised,
        "donationInstructionLink":
            donationInstructionLink == null ? null : donationInstructionLink,
        "donors":
            donors == null ? [] : List<dynamic>.from(donors.map((x) => x)),
        "minAmount": minAmount == null ? null : minAmount,
        "targetAmount": targetAmount == null ? null : targetAmount,
      };
}
