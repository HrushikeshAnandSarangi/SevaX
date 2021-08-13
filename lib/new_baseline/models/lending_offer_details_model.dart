import 'package:sevaexchange/new_baseline/models/lending_model.dart';

class LendingOfferDetailsModel {
  LendingOfferDetailsModel({
    this.startDate,
    this.endDate,
    this.lendingModel,
    this.lendingOfferAgreementLink,
    this.lendingOfferApprovedAgreementLink,
    this.lendingOfferAgreementName,
    this.offerAcceptors,
    this.offerInvites,
    this.approvedUsers,
    this.collectedItems,
    this.returnedItems,
    this.checkedIn,
    this.checkedOut,
  });
  int startDate;
  int endDate;
  LendingModel lendingModel;
  String lendingOfferAgreementLink;
  String lendingOfferApprovedAgreementLink;
  String lendingOfferAgreementName;
  List<String> offerAcceptors = [];
  List<String> offerInvites = [];
  List<String> approvedUsers = [];
  bool collectedItems;
  bool returnedItems;
  bool checkedIn;
  bool checkedOut;
  factory LendingOfferDetailsModel.fromMap(Map<String, dynamic> json) =>
      LendingOfferDetailsModel(
        startDate: json["startDate"] == null ? null : json["startDate"],
        endDate: json["endDate"] == null ? null : json["endDate"],
        lendingOfferAgreementLink: json["lendingOfferAgreementLink"] == null
            ? null
            : json["lendingOfferAgreementLink"],
        lendingOfferApprovedAgreementLink:
            json["lendingOfferApprovedAgreementLink"] == null
                ? null
                : json["lendingOfferApprovedAgreementLink"],
        lendingOfferAgreementName: json["lendingOfferAgreementName"] == null
            ? null
            : json["lendingOfferAgreementName"],
        lendingModel: json["lendingModel"] == null
            ? null
            : LendingModel.fromMap(json["lendingModel"]),
        offerAcceptors: json["offerAcceptors"] == null
            ? []
            : List<String>.from(json["offerAcceptors"].map((x) => x)),
        offerInvites: json["offerInvites"] == null
            ? []
            : List<String>.from(json["offerInvites"].map((x) => x)),
        approvedUsers: json["approvedUsers"] == null
            ? []
            : List<String>.from(json["approvedUsers"].map((x) => x)),
        collectedItems: json["collectedItems"] == null
            ? false
            : json["collectedItems"] ?? false,
        returnedItems: json["returnedItems"] == null
            ? false
            : json["returnedItems"] ?? false,
        checkedIn:
            json["checkedIn"] == null ? false : json["checkedIn"] ?? false,
        checkedOut:
            json["checkedOut"] == null ? false : json["checkedOut"] ?? false,
      );

  Map<String, dynamic> toMap() => {
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
        "lendingOfferAgreementLink": lendingOfferAgreementLink == null
            ? null
            : lendingOfferAgreementLink,
        "lendingOfferApprovedAgreementLink":
            lendingOfferApprovedAgreementLink == null
                ? null
                : lendingOfferApprovedAgreementLink,
        "lendingOfferAgreementName": lendingOfferAgreementName == null
            ? null
            : lendingOfferAgreementName,
        "lendingModel": lendingModel == null ? null : lendingModel.toMap(),
        "offerAcceptors": offerAcceptors == null
            ? []
            : List<dynamic>.from(offerAcceptors.map((x) => x)),
        "offerInvites": offerInvites == null
            ? []
            : List<dynamic>.from(offerInvites.map((x) => x)),
        "approvedUsers": approvedUsers == null
            ? []
            : List<dynamic>.from(approvedUsers.map((x) => x)),
        "collectedItems": collectedItems == null ? false : collectedItems,
        "returnedItems": returnedItems == null ? false : returnedItems,
        "checkedIn": checkedIn == null ? false : checkedIn,
        "checkedOut": checkedOut == null ? false : checkedOut,
      };
}
