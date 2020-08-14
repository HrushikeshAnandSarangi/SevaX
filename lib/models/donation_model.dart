import 'dart:convert';

import 'package:sevaexchange/models/request_model.dart';

DonationModel donationModelFromMap(String str) =>
    DonationModel.fromMap(json.decode(str));

String donationModelToMap(DonationModel data) => json.encode(data.toMap());

class DonationModel {
  DonationModel({
    this.communityId,
    this.donorSevaUserId,
    this.donatedTo,
    this.donatedToTimebank,
    this.donationInBetween,
    this.donationType,
    this.id,
    this.requestId,
    this.timebankId,
    this.timestamp,
    this.cashDetails,
  });

  String communityId;
  String donorSevaUserId;
  String donatedTo;
  bool donatedToTimebank;
  List<String> donationInBetween;
  RequestType donationType;
  String id;
  String requestId;
  String timebankId;
  int timestamp;
  CashDetails cashDetails;

  factory DonationModel.fromMap(Map<String, dynamic> json) => DonationModel(
        communityId: json["communityId"] == null ? null : json["communityId"],
        donorSevaUserId:
            json["donorSevaUserId"] == null ? null : json["donorSevaUserId"],
        donatedTo: json["donatedTo"] == null ? null : json["donatedTo"],
        donatedToTimebank: json["donatedToTimebank"] == null
            ? null
            : json["donatedToTimebank"],
        donationInBetween: json["donationInBetween"] == null
            ? null
            : List<String>.from(json["donationInBetween"].map((x) => x)),
        donationType: json["donationType"] == null
            ? null
            : json["donationType"] == "CASH"
                ? RequestType.CASH
                : json["donationType"] == "GOODS"
                    ? RequestType.GOODS
                    : RequestType.TIME,
        id: json["id"] == null ? null : json["id"],
        requestId: json["requestId"] == null ? null : json["requestId"],
        timebankId: json["timebankId"] == null ? null : json["timebankId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        cashDetails: json['cashDetails'] == null
            ? null
            : CashDetails.fromMap(json['cashDetails']),
      );

  Map<String, dynamic> toMap() => {
        "communityId": communityId == null ? null : communityId,
        "donorSevaUserId": donorSevaUserId == null ? null : donorSevaUserId,
        "donatedTo": donatedTo == null ? null : donatedTo,
        "donatedToTimebank":
            donatedToTimebank == null ? null : donatedToTimebank,
        "donationInBetween": donationInBetween == null
            ? null
            : List<dynamic>.from(donationInBetween.map((x) => x)),
        "donationType": donationType == null
            ? null
            : donationType == RequestType.CASH
                ? 'CASH'
                : donationType == RequestType.GOODS ? 'GOODS' : 'TIME',
        "id": id == null ? null : id,
        "requestId": requestId == null ? null : requestId,
        "timebankId": timebankId == null ? null : timebankId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "cashDetails": cashDetails == null ? null : cashDetails.toMap(),
      };
}

CashDetails cashDetailsFromMap(String str) =>
    CashDetails.fromMap(json.decode(str));

String cashDetailsToMap(CashDetails data) => json.encode(data.toMap());

class CashDetails {
  CashDetails({
    this.pledgedAmount,
  });

  int pledgedAmount;

  factory CashDetails.fromMap(Map<String, dynamic> json) => CashDetails(
        pledgedAmount:
            json["pledgedAmount"] == null ? null : json["pledgedAmount"],
      );

  Map<String, dynamic> toMap() => {
        "pledgedAmount": pledgedAmount == null ? null : pledgedAmount,
      };
}
