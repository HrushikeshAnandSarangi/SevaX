import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class RequestsCategoryModel {
  final String id;
  final String logo;
  final Map<String, String> data;

  RequestsCategoryModel({this.id, this.logo, this.data});

  factory RequestsCategoryModel.fromMap(Map<String, dynamic> map) =>
      RequestsCategoryModel(
        id: map['id'],
        data: Map<String, String>.from(map),
        logo: map.containsKey('logo') ? map['logo'] : null,
      );

  String getCategoryName(BuildContext context) {
    var key = S.of(context).localeName;
    return data.containsKey(key) ? data[key] : data['en'];
  }
}