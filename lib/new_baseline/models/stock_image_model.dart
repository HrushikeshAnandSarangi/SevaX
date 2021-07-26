// To parse this JSON data, do
//
//     final stockImageModel = stockImageModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class StockImageModel {
  StockImageModel({
    @required this.image,
    @required this.index,
    @required this.name,
    @required this.fit,
    @required this.children,
  });

  String image;
  int index;
  String name;
  int fit;
  List<StockImageModel> children;

  factory StockImageModel.fromJson(String str) =>
      StockImageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StockImageModel.fromMap(Map<String, dynamic> json) => StockImageModel(
        image: json["image"] == null ? null : json["image"],
        index: json["index"] == null ? null : json["index"],
        name: json["name"] == null ? null : json["name"],
        fit: json["fit"] == null ? null : json["fit"],
        children: json["children"] == null
            ? null
            : List<StockImageModel>.from(
                json["children"].map((x) => StockImageModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "image": image == null ? null : image,
        "index": index == null ? null : index,
        "name": name == null ? null : name,
        "fit": fit == null ? null : fit,
        "children": children == null
            ? null
            : List<dynamic>.from(children.map((x) => x.toMap())),
      };
}
