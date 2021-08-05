// To parse this JSON data, do
//
//     final lendingPlaceModel = lendingPlaceModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';

class LendingModel {
  LendingModel({
    this.id,
    this.creatorId,
    this.email,
    this.timestamp,
    this.lendingType,
    this.lendingItemModel,
    this.lendingPlaceModel,
  });
  String id;
  String creatorId;
  String email;
  int timestamp;
  LendingType lendingType;
  LendingItemModel lendingItemModel;
  LendingPlaceModel lendingPlaceModel;

  factory LendingModel.fromJson(String str) =>
      LendingModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LendingModel.fromMap(Map<String, dynamic> json) => LendingModel(
        id: json["id"] == null ? null : json["id"],
        creatorId: json["creatorId"] == null ? null : json["creatorId"],
        email: json["email"] == null ? null : json["email"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        lendingType: json["lendingType"] == null
            ? null
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
            lendingItemModel == null ? null : lendingItemModel.toMap(),
        "lendingPlaceModel":
            lendingPlaceModel == null ? null : lendingPlaceModel.toMap(),
      };
}

LendingType getLendingType(String lendingType) {
  switch (lendingType) {
    case 'PLACE':
      return LendingType.PLACE;
    case 'ITEM':
      return LendingType.ITEM;
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

enum LendingType { PLACE, ITEM }
