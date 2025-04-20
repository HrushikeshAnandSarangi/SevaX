// To parse this JSON data, do
//
//     final stockImageModel = stockImageModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class StockImageModel {
  StockImageModel({
    required this.image,
    required this.index,
    required this.name,
    required this.fit,
    required this.children,
  });

  final String image;
  final int index;
  final String name;
  final int fit;
  final List<StockImageModel> children;

  factory StockImageModel.fromJson(String str) =>
      StockImageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StockImageModel.fromMap(Map<String, dynamic> json) => StockImageModel(
        image: json["image"] as String,
        index: json["index"] as int,
        name: json["name"] as String,
        fit: json["fit"] as int,
        children: List<StockImageModel>.from(
            (json["children"] as List).map((x) => StockImageModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "image": image,
        "index": index,
        "name": name,
        "fit": fit,
        "children": List<dynamic>.from(children.map((x) => x.toMap())),
      };
}
