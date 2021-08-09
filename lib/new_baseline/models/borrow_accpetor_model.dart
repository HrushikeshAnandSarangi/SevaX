import 'package:meta/meta.dart';
import 'dart:convert';

class BorrowAcceptorModel {
  BorrowAcceptorModel({
    this.acceptorEmail,
    this.acceptorId,
    this.acceptorName,
    this.acceptorMobile,
    this.borrowAgreementLink,
    this.selectedAddress,
    this.isApproved,
    this.borrowedItemsIds,
    this.borrowedPlaceId,
    this.timestamp,
  });

  String acceptorEmail;
  String acceptorId;
  String acceptorName;
  String acceptorMobile;
  String borrowAgreementLink;
  String selectedAddress;
  bool isApproved;
  List<String> borrowedItemsIds;
  String borrowedPlaceId;
  int timestamp;

  factory BorrowAcceptorModel.fromJson(String str) =>
      BorrowAcceptorModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BorrowAcceptorModel.fromMap(Map<String, dynamic> json) =>
      BorrowAcceptorModel(
        acceptorEmail:
            json["acceptorEmail"] == null ? null : json["acceptorEmail"],
        acceptorId: json["acceptorId"] == null ? null : json["acceptorId"],
        acceptorName:
            json["acceptorName"] == null ? null : json["acceptorName"],
        acceptorMobile:
            json["acceptorMobile"] == null ? null : json["acceptorMobile"],
        borrowAgreementLink: json["borrowAgreementLink"] == null
            ? null
            : json["borrowAgreementLink"],
        selectedAddress:
            json["selectedAddress"] == null ? null : json["selectedAddress"],
        isApproved: json["isApproved"] == null ? null : json["isApproved"],
        borrowedItemsIds: json["borrowedItemsIds"] == null
            ? null
            : List<String>.from(json["borrowedItemsIds"].map((x) => x)),
        borrowedPlaceId:
            json["borrowedPlaceId"] == null ? null : json["borrowedPlaceId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "acceptorEmail": acceptorEmail == null ? null : acceptorEmail,
        "acceptorId": acceptorId == null ? null : acceptorId,
        "acceptorName": acceptorName == null ? null : acceptorName,
        "acceptorMobile": acceptorMobile == null ? null : acceptorMobile,
        "borrowAgreementLink":
            borrowAgreementLink == null ? null : borrowAgreementLink,
        "selectedAddress": selectedAddress == null ? null : selectedAddress,
        "isApproved": isApproved == null ? null : isApproved,
        "borrowedItemsIds": borrowedItemsIds == null
            ? null
            : List<dynamic>.from(borrowedItemsIds.map((x) => x)),
        "borrowedPlaceId": borrowedPlaceId == null ? null : borrowedPlaceId,
        "timestamp": timestamp == null ? null : timestamp,
      };
}
