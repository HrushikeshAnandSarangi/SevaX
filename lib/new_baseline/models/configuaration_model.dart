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
    @required this.id,
    @required this.title_en,
    @required this.type,
  });

  String id;
  String title_en;
  String type;

  factory ConfigurationModel.fromMap(Map<String, dynamic> json) =>
      ConfigurationModel(
        id: json["id"] == null ? null : json["id"],
        title_en: json["title_en"] == null ? null : json["title_en"],
        type: json["type"] == null ? null : json["type"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "title_en": title_en == null ? null : title_en,
        "type": type == null ? null : type,
      };
}
