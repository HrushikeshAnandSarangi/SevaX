// To parse this JSON data, do
//
//     final amenitiesModel = amenitiesModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class AmenitiesModel {
  AmenitiesModel({
    this.id,
    this.title_en,
  });

  String? id;
  String? title_en;

  factory AmenitiesModel.fromJson(String str) =>
      AmenitiesModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AmenitiesModel.fromMap(Map<String, dynamic> json) => AmenitiesModel(
        id: json["id"] == null ? null : json["id"],
        title_en: json["title_en"] == null ? null : json["title_en"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "title_en": title_en == null ? null : title_en,
      };
}
