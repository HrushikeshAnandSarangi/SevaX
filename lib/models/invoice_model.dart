class InvoiceModel {
  InvoiceModel({this.note1, this.note2, this.tax, this.details, this.plans});

  String? note1;
  String? note2;
  int? tax;
  List<Detail>? details;
  Map<String, dynamic>? plans;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
      note1: json["note1"],
      note2: json["note2"],
      tax: json["tax"],
      details:
          List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
      plans: json["plans"]);

  Map<String, dynamic> toJson() => {
        "note1": note1,
        "note2": note2,
        "tax": tax,
        "details": List<dynamic>.from(details?.map((x) => x.toJson()) ?? []),
        "plans": plans
      };
}

class Detail {
  Detail({
    this.description,
    this.units,
    this.price,
    this.type,
  });

  String? description;
  double? units;
  double? price;
  String? type;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        description: json["description"],
        units: json["units"],
        price: json["price"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "units": units,
        "price": price,
        "type": type,
      };
}
