// To parse this JSON data, do
//
//     final lendingPlaceModel = lendingPlaceModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class LendingItemModel {
  LendingItemModel({
    this.itemName,
    this.itemImages,
  });
  String itemName;
  List<String> itemImages;

  factory LendingItemModel.fromJson(String str) =>
      LendingItemModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LendingItemModel.fromMap(Map<String, dynamic> json) =>
      LendingItemModel(
        itemName: json["itemName"] == null ? null : json["itemName"],
        itemImages: json["itemImages"] == null
            ? null
            : List<String>.from(json["itemImages"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "itemName": itemName == null ? null : itemName,
        "itemImages": itemImages == null
            ? null
            : List<dynamic>.from(itemImages.map((x) => x)),
      };
}
