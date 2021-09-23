
enum LendingType {
  PLACE,
  ITEM,
}

extension Label on LendingType {
  String get readable {
    switch (this) {
      case LendingType.PLACE:
        return 'PLACE';
        break;
      case LendingType.ITEM:
        return 'ITEM';
        break;
    }
    return 'ITEM';
  }
}
