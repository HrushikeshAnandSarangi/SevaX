import 'dart:convert';

CashModel cashModelFromMap(String str) => CashModel.fromMap(json.decode(str));

String cashModelToMap(CashModel data) => json.encode(data.toMap());

class CashModel {
  CashModel({
    this.amountRaised,
    this.donors,
    this.minAmount,
    this.targetAmount,
  });

  int amountRaised;
  List<String> donors;
  int minAmount;
  int targetAmount;

  factory CashModel.fromMap(Map<dynamic, dynamic> json) => CashModel(
        amountRaised:
            json["amountRaised"] == null ? null : json["amountRaised"],
        donors: json["donors"] == null
            ? []
            : List<String>.from(json["donors"].map((x) => x)),
        minAmount: json["minAmount"] == null ? null : json["minAmount"],
        targetAmount:
            json["targetAmount"] == null ? null : json["targetAmount"],
      );

  Map<String, dynamic> toMap() => {
        "amountRaised": amountRaised == null ? null : amountRaised,
        "donors": donors == null ? [] : List<String>.from(donors.map((x) => x)),
        "minAmount": minAmount == null ? null : minAmount,
        "targetAmount": targetAmount == null ? null : targetAmount,
      };
}
