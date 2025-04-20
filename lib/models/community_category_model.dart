import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class CommunityCategoryModel {
  final String id;
  final String logo;
  final Map<String, String> data;

  CommunityCategoryModel(
      {required this.id, required this.logo, required this.data});

  factory CommunityCategoryModel.fromMap(Map<String, dynamic> map) =>
      CommunityCategoryModel(
        id: map['id'],
        data: Map<String, String>.from(map),
        logo: map.containsKey('logo') ? map['logo'] : null,
      );

  String getCategoryName(BuildContext context) {
    var key = S.of(context).localeName;
    return data.containsKey(key) ? data[key] ?? '' : data['en'] ?? '';
  }
}
