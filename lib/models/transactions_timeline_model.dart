import 'package:flutter/material.dart';

class TransacationsTimelineModel {
  TransacationsTimelineModel({
    this.from,
    this.timestamp,
    this.to,
    this.type,
    this.typeId,
    this.visible,
  });

  String? from;
  int? timestamp;
  String? to;
  String? type;
  String? typeId;
  List<String>? visible;

  factory TransacationsTimelineModel.fromJson(Map<String, dynamic> json) =>
      TransacationsTimelineModel(
        from: json["from"],
        timestamp: json["timestamp"],
        to: json["to"],
        type: json["type"],
        typeId: json["typeId"],
        visible: List<String>.from(json["visible"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "from": from != null ? from : null,
        "timestamp": timestamp != null ? timestamp : null,
        "to": to != null ? to : null,
        "type": type != null ? type : null,
        "typeId": typeId != null ? typeId : null,
        "visible": visible?.isNotEmpty == true
            ? List<String>.from(visible?.map((x) => x) ?? [])
            : [],
      };
}
