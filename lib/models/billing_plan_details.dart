import 'dart:convert';

List<BillingPlanDetailsModel> billingPlanDetailsModelFromJson(String str) =>
    List<BillingPlanDetailsModel>.from(
        json.decode(str).map((x) => BillingPlanDetailsModel.fromJson(x)));

String billingPlanDetailsModelToJson(List<BillingPlanDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BillingPlanDetailsModel {
  String id;
  String planName;
  String planDescription;
  String price;
  String currency;
  String duration;
  String note1;
  String note2;
  List<String> freeTransaction;
  List<String> billableTransaction;

  BillingPlanDetailsModel({
    this.id,
    this.planName,
    this.planDescription,
    this.price,
    this.currency,
    this.duration,
    this.note1,
    this.note2,
    this.freeTransaction,
    this.billableTransaction,
  });

  factory BillingPlanDetailsModel.fromJson(Map<String, dynamic> json) =>
      BillingPlanDetailsModel(
        id: json["id"],
        planName: json["plan_name"],
        planDescription: json["plan_description"],
        price: json["price"],
        currency: json["currency"],
        duration: json["duration"],
        note1: json["note1"],
        note2: json["note2"],
        freeTransaction:
            List<String>.from(json["free_transaction"].map((x) => x)),
        billableTransaction:
            List<String>.from(json["billable_transaction"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "plan_name": planName,
        "plan_description": planDescription,
        "price": price,
        "currency": currency,
        "duration": duration,
        "note1": note1,
        "note2": note2,
        "free_transaction": List<dynamic>.from(freeTransaction.map((x) => x)),
        "billable_transaction":
            List<dynamic>.from(billableTransaction.map((x) => x)),
      };
}
