import 'package:sevaexchange/new_baseline/models/lending_model.dart';

class LendingOfferDetailsModel {
  LendingOfferDetailsModel({
    this.approvedStartDate,
    this.approvedEndDate,
    this.startDate,
    this.endDate,
    this.lendingModel,
    this.lendingOfferAgreementLink,
    this.lendingOfferApprovedAgreementLink,
    this.agreementId,
    this.lendingOfferAgreementName,
    List<String>? offerAcceptors,
    List<String>? offerInvites,
    List<String>? approvedUsers,
    List<String>? completedUsers,
    this.collectedItems = false,
    this.returnedItems = false,
    this.checkedIn = false,
    this.checkedOut = false,
    Map<String, dynamic>? agreementConfig,
    required this.lendingOfferTypeMode,
  })  : offerAcceptors = offerAcceptors ?? [],
        offerInvites = offerInvites ?? [],
        approvedUsers = approvedUsers ?? [],
        completedUsers = completedUsers ?? [],
        agreementConfig = agreementConfig ?? {};

  int? approvedStartDate;
  int? approvedEndDate;
  int? startDate;
  int? endDate;
  LendingModel? lendingModel;
  String? lendingOfferAgreementLink;
  String? lendingOfferApprovedAgreementLink;
  String? agreementId;
  String? lendingOfferAgreementName;
  List<String> offerAcceptors = [];
  List<String> offerInvites = [];
  List<String> approvedUsers = [];
  List<String> completedUsers = [];
  bool collectedItems;
  bool returnedItems;
  bool checkedIn;
  bool checkedOut;
  String lendingOfferTypeMode;
  Map<String, dynamic> agreementConfig = {};
  factory LendingOfferDetailsModel.fromMap(Map<String, dynamic> json) =>
      LendingOfferDetailsModel(
        approvedStartDate: json["approvedStartDate"] == null
            ? null
            : json["approvedStartDate"],
        approvedEndDate:
            json["approvedEndDate"] == null ? null : json["approvedEndDate"],
        startDate: json["startDate"] == null ? null : json["startDate"],
        endDate: json["endDate"] == null ? null : json["endDate"],
        lendingOfferAgreementLink: json["lendingOfferAgreementLink"] == null
            ? null
            : json["lendingOfferAgreementLink"],
        lendingOfferApprovedAgreementLink:
            json["lendingOfferApprovedAgreementLink"] == null
                ? null
                : json["lendingOfferApprovedAgreementLink"],
        agreementId: json["agreementId"] == null ? null : json["agreementId"],
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
        completedUsers: json["completedUsers"] == null
            ? []
            : List<String>.from(json["completedUsers"].map((x) => x)),
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
        lendingOfferTypeMode: json["lendingOfferTypeMode"] == null
            ? null
            : json["lendingOfferTypeMode"],
        agreementConfig: json["agreementConfig"] == null
            ? {}
            : Map<String, dynamic>.from(json["agreementConfig"]) ?? {},
      );

  Map<String, dynamic> toMap() => {
        "approvedStartDate":
            approvedStartDate == null ? null : approvedStartDate,
        "approvedEndDate": approvedEndDate == null ? null : approvedEndDate,
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
        "lendingOfferAgreementLink": lendingOfferAgreementLink == null
            ? null
            : lendingOfferAgreementLink,
        "lendingOfferApprovedAgreementLink":
            lendingOfferApprovedAgreementLink == null
                ? null
                : lendingOfferApprovedAgreementLink,
        "agreementId": agreementId == null ? null : agreementId,
        "lendingOfferAgreementName": lendingOfferAgreementName == null
            ? null
            : lendingOfferAgreementName,
        "lendingModel": lendingModel == null ? null : lendingModel?.toMap(),
        "offerAcceptors": offerAcceptors == null
            ? []
            : List<dynamic>.from(offerAcceptors.map((x) => x)),
        "offerInvites": offerInvites == null
            ? []
            : List<dynamic>.from(offerInvites.map((x) => x)),
        "approvedUsers": approvedUsers == null
            ? []
            : List<dynamic>.from(approvedUsers.map((x) => x)),
        "completedUsers": completedUsers == null
            ? []
            : List<dynamic>.from(completedUsers.map((x) => x)),
        "collectedItems": collectedItems == null ? false : collectedItems,
        "returnedItems": returnedItems == null ? false : returnedItems,
        "checkedIn": checkedIn == null ? false : checkedIn,
        "checkedOut": checkedOut == null ? false : checkedOut,
        "lendingOfferTypeMode":
            lendingOfferTypeMode == null ? null : lendingOfferTypeMode,
        "agreementConfig": agreementConfig == null ? null : agreementConfig,
      };
}
