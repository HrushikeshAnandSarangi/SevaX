import 'package:sevaexchange/new_baseline/models/lending_model.dart';

class LendingOfferDetailsModel {
  LendingOfferDetailsModel({
    this.startDate,
    this.endDate,
    this.lendingModel,
    this.lendingOfferAgreementLink,
    this.lendingOfferAgreementName,
  });
  int startDate;
  int endDate;
  LendingModel lendingModel;
  String lendingOfferAgreementLink;
  String lendingOfferAgreementName;

  factory LendingOfferDetailsModel.fromMap(Map<String, dynamic> json) =>
      LendingOfferDetailsModel(
        startDate: json["startDate"] == null ? null : json["startDate"],
        endDate: json["endDate"] == null ? null : json["endDate"],
        lendingOfferAgreementLink: json["lendingOfferAgreementLink"] == null
            ? null
            : json["lendingOfferAgreementLink"],
        lendingOfferAgreementName: json["lendingOfferAgreementName"] == null
            ? null
            : json["lendingOfferAgreementName"],
        lendingModel: json["lendingModel"] == null
            ? null
            : LendingModel.fromMap(json["lendingModel"]),
      );

  Map<String, dynamic> toMap() => {
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
        "lendingOfferAgreementLink": lendingOfferAgreementLink == null
            ? null
            : lendingOfferAgreementLink,
        "lendingOfferAgreementName": lendingOfferAgreementName == null
            ? null
            : lendingOfferAgreementName,
        "lendingModel": lendingModel == null ? null : lendingModel.toMap(),
      };
}
