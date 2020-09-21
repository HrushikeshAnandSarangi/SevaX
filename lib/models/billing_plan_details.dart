import 'dart:convert';

List<BillingPlanDetailsModel> billingPlanDetailsModelFromJson(String str) =>
    List<BillingPlanDetailsModel>.from(
        json.decode(str).map((x) => BillingPlanDetailsModel.fromJson(x)));

String billingPlanDetailsModelToJson(List<BillingPlanDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BillingPlanDetailsModel {
  bool billMeEnabled;
  bool isCardRequired;
  String id;
  bool hidden;
  String planName;
  String planDescription;
  String price;
  String currency;
  String duration;
  String note1;
  String note2;
  List<String> freeTransaction;
  List<String> billableTransaction;

  BillingPlanDetailsModel(
      {this.id,
      this.hidden,
      this.planName,
      this.planDescription,
      this.price,
      this.currency,
      this.duration,
      this.note1,
      this.note2,
      this.freeTransaction,
      this.billableTransaction,
      this.billMeEnabled,
      this.isCardRequired});

  factory BillingPlanDetailsModel.fromJson(Map<String, dynamic> json) =>
      BillingPlanDetailsModel(
        isCardRequired: json['bill_me_enabled'],
        billMeEnabled: json['is_card_required'],
        id: json["id"],
        hidden: json["hidden"] ?? false,
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
        "hidden": hidden,
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
