import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';

import 'lending_model.dart';

class BorrowAcceptorModel {
  BorrowAcceptorModel({
    this.id,
    this.acceptorEmail,
    this.acceptorId,
    this.acceptorName,
    this.acceptorMobile,
    this.borrowAgreementLink,
    this.agreementId,
    this.selectedAddress,
    this.isApproved,
    this.borrowedItemsIds,
    this.borrowedPlaceId,
    this.notificationId,
    this.timestamp,
    this.acceptorphotoURL,
    this.status,
    this.communityId,
  });

  String? id;
  String? acceptorEmail;
  String? acceptorId;
  String? acceptorName;
  String? acceptorMobile;
  String? borrowAgreementLink;
  String? agreementId;
  String? selectedAddress;
  bool? isApproved;
  List<String>? borrowedItemsIds;
  String? borrowedPlaceId;
  String? notificationId;
  int? timestamp;
  String? acceptorphotoURL;
  LendingOfferStatus? status;
  String? communityId;

  factory BorrowAcceptorModel.fromJson(String str) =>
      BorrowAcceptorModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BorrowAcceptorModel.fromMap(Map<String, dynamic> json) =>
      BorrowAcceptorModel(
        id: json["id"] == null ? null : json["id"],
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
        agreementId: json["agreementId"] == null ? null : json["agreementId"],
        selectedAddress:
            json["selectedAddress"] == null ? null : json["selectedAddress"],
        isApproved: json["isApproved"] == null ? null : json["isApproved"],
        borrowedItemsIds: json["borrowedItemsIds"] == null
            ? []
            : List<String>.from(json["borrowedItemsIds"].map((x) => x)),
        borrowedPlaceId:
            json["borrowedPlaceId"] == null ? null : json["borrowedPlaceId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        acceptorphotoURL:
            json["acceptorphotoURL"] == null ? null : json["acceptorphotoURL"],
        notificationId:
            json["notificationId"] == null ? null : json["notificationId"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        status: json["status"] == null
            ? LendingOfferStatus.ACCEPTED
            : ReadableLendingOfferStatus.getValue(json["status"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "acceptorEmail": acceptorEmail == null ? null : acceptorEmail,
        "acceptorId": acceptorId == null ? null : acceptorId,
        "acceptorName": acceptorName == null ? null : acceptorName,
        "acceptorMobile": acceptorMobile == null ? null : acceptorMobile,
        "borrowAgreementLink":
            borrowAgreementLink == null ? null : borrowAgreementLink,
        "agreementId": agreementId == null ? null : agreementId,
        "selectedAddress": selectedAddress == null ? null : selectedAddress,
        "isApproved": isApproved == null ? null : isApproved,
        "borrowedItemsIds": borrowedItemsIds == null
            ? []
            : List<dynamic>.from(borrowedItemsIds?.map((x) => x) ?? []),
        "borrowedPlaceId": borrowedPlaceId == null ? null : borrowedPlaceId,
        "timestamp": timestamp == null ? null : timestamp,
        "acceptorphotoURL": acceptorphotoURL == null ? null : acceptorphotoURL,
        "notificationId": notificationId == null ? null : notificationId,
        "communityId": communityId == null ? null : communityId,
        "status": status == null ? null : status?.readable,
      };
}
