// To parse this JSON data, do
//
//     final skillAndInterestModel = skillAndInterestModelFromMap(jsonString);

import 'dart:convert';

SkillAndInterestModel skillAndInterestModelFromMap(String str) =>
    SkillAndInterestModel.fromMap(json.decode(str));

String skillAndInterestModelToMap(SkillAndInterestModel data) =>
    json.encode(data.toMap());

class SkillAndInterestModel {
  SkillAndInterestModel({
    this.id,
    this.title,
    this.name,
  });

  String id;
  String title;
  String name;

  factory SkillAndInterestModel.fromMap(Map<String, dynamic> json) =>
      SkillAndInterestModel(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "name": name == null ? null : name,
      };
}
