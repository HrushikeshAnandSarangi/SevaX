import 'dart:convert';

import 'package:sevaexchange/models/request_model.dart';

DonationModel donationModelFromMap(String str) =>
    DonationModel.fromMap(json.decode(str));

String donationModelToMap(DonationModel data) => json.encode(data.toMap());

class DonationModel {
  DonationModel({
    this.amount,
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
  });

  int amount;
  String communityId;
  String donorSevaUserId;
  String donatedTo;
  bool donatedToTimebank;
  List<String> donationInBetween;
  DonationType donationType;
  String id;
  String requestId;
  String timebankId;
  int timestamp;

  factory DonationModel.fromMap(Map<String, dynamic> json) => DonationModel(
        amount: json["amount"] == null ? null : json["amount"],
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
                ? DonationType.CASH
                : json["donationType"] == "GOODS"
                    ? DonationType.GOODS
                    : DonationType.TIME,
        id: json["id"] == null ? null : json["id"],
        requestId: json["requestId"] == null ? null : json["requestId"],
        timebankId: json["timebankId"] == null ? null : json["timebankId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "amount": amount == null ? null : amount,
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
            : donationType == DonationType.CASH
                ? 'CASH'
                : donationType == DonationType.GOODS ? 'GOODS' : 'TIME',
        "id": id == null ? null : id,
        "requestId": requestId == null ? null : requestId,
        "timebankId": timebankId == null ? null : timebankId,
        "timestamp": timestamp == null ? null : timestamp,
      };
}
