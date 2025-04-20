// To parse this JSON data, do
//
//     final lendingPlaceModel = lendingPlaceModelFromMap(jsonString);

import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'dart:convert';

import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';

class LendingModel {
  LendingModel({
    required this.id,
    required this.creatorId,
    required this.email,
    required this.timestamp,
    required this.lendingType,
    this.lendingItemModel,
    this.lendingPlaceModel,
  });
  final String id;
  final String creatorId;
  final String email;
  final int timestamp;
  final LendingType lendingType;
  final LendingItemModel? lendingItemModel;
  final LendingPlaceModel? lendingPlaceModel;

  factory LendingModel.fromJson(String str) =>
      LendingModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LendingModel.fromMap(Map<String, dynamic> json) => LendingModel(
        id: json["id"] == null ? null : json["id"],
        creatorId: json["creatorId"] == null ? null : json["creatorId"],
        email: json["email"] == null ? null : json["email"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        lendingType: json["lendingType"] == null
            ? LendingType.ITEM
            : getLendingType(json["lendingType"]),
        lendingItemModel: json["lendingItemModel"] == null
            ? null
            : LendingItemModel.fromMap(json["lendingItemModel"]),
        lendingPlaceModel: json["lendingPlaceModel"] == null
            ? null
            : LendingPlaceModel.fromMap(json["lendingPlaceModel"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "creatorId": creatorId == null ? null : creatorId,
        "email": email == null ? null : email,
        "timestamp": timestamp == null ? null : timestamp,
        "lendingType": setLendingType(lendingType),
        "lendingItemModel":
            lendingItemModel == null ? null : lendingItemModel?.toMap(),
        "lendingPlaceModel":
            lendingPlaceModel == null ? null : lendingPlaceModel?.toMap(),
      };
}

LendingType getLendingType(String lendingType) {
  switch (lendingType) {
    case 'PLACE':
      return LendingType.PLACE;
    case 'ITEM':
      return LendingType.ITEM;
    default:
      return LendingType.ITEM; // Default case returns ITEM type
  }
}

String setLendingType(LendingType lendingType) {
  switch (lendingType) {
    case LendingType.PLACE:
      return "PLACE";
    case LendingType.ITEM:
      return "ITEM";
  }
}

Map<String, LendingType> lendingTypeMapper = {
  "PLACE": LendingType.PLACE,
  "ITEM": LendingType.ITEM,
};

enum LendingOfferStatus {
  APPROVED,
  ACCEPTED,
  REJECTED,
  CHECKED_IN,
  CHECKED_OUT,
  ITEMS_COLLECTED,
  ITEMS_RETURNED,
  REVIEWED,
}

extension ReadableLendingOfferStatus on LendingOfferStatus {
  String get readable {
    switch (this) {
      case LendingOfferStatus.APPROVED:
        return 'APPROVED';

      case LendingOfferStatus.ACCEPTED:
        return 'ACCEPTED';

      case LendingOfferStatus.REJECTED:
        return 'REJECTED';
      case LendingOfferStatus.CHECKED_IN:
        return 'CHECKED_IN';
      case LendingOfferStatus.CHECKED_OUT:
        return 'CHECKED_OUT';
      case LendingOfferStatus.ITEMS_COLLECTED:
        return 'ITEMS_COLLECTED';
      case LendingOfferStatus.ITEMS_RETURNED:
        return 'ITEMS_RETURNED';
      case LendingOfferStatus.REVIEWED:
        return 'REVIEWED';

      default:
        return 'ACCEPTED';
    }
  }

  static LendingOfferStatus getValue(String value) {
    switch (value) {
      case 'ACCEPTED':
        return LendingOfferStatus.ACCEPTED;

      case 'APPROVED':
        return LendingOfferStatus.APPROVED;

      case 'CHECKED_IN':
        return LendingOfferStatus.CHECKED_IN;
      case 'CHECKED_OUT':
        return LendingOfferStatus.CHECKED_OUT;
      case 'ITEMS_COLLECTED':
        return LendingOfferStatus.ITEMS_COLLECTED;
      case 'ITEMS_RETURNED':
        return LendingOfferStatus.ITEMS_RETURNED;
      case 'REJECTED':
        return LendingOfferStatus.REJECTED;
      case 'REVIEWED':
        return LendingOfferStatus.REVIEWED;

      default:
        return LendingOfferStatus.ACCEPTED;
    }
  }
}
