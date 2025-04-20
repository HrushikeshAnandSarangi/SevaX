// To parse this JSON data, do
//
//     final configurationModel = configurationModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ConfigurationModel configurationModelFromMap(String str) =>
    ConfigurationModel.fromMap(json.decode(str));

String configurationModelToMap(ConfigurationModel data) =>
    json.encode(data.toMap());

class ConfigurationModel {
  ConfigurationModel({
    required this.id,
    required this.titleEn,
    required this.type,
  });

  final String id;
  final String titleEn;
  final String type;

  factory ConfigurationModel.fromMap(Map<String, dynamic> json) =>
      ConfigurationModel(
        id: json["id"] as String,
        titleEn: json["title_en"] as String,
        type: json["type"] as String,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title_en": titleEn,
        "type": type,
      };
}
