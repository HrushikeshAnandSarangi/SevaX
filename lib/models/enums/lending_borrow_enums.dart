import 'package:flutter/material.dart';

enum LendingType {
  PLACE,
  ITEM,
}

extension Label on LendingType {
  String get readable {
    switch (this) {
      case LendingType.PLACE:
        return 'ROOM';
        break;
      case LendingType.ITEM:
        return 'ITEM';
        break;
    }
    return 'ITEM';
  }
}
