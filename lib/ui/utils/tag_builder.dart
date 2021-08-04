import 'package:sevaexchange/l10n/l10n.dart';

class TagBuilder {
  TagBuilder({
    this.isPublic = false,
    this.isVirtual = false,
    this.isOneToManyOffer = false,
    this.isTimeOffer = false,
    this.isMoneyOffer = false,
    this.isGoodsOffer = false,
    this.isTimeRequest = false,
    this.isMoneyRequest = false,
    this.isGoodsRequest = false,
    this.isOneToManyRequest = false,
    this.isBorrowRequest = false,
  });

  final bool isPublic;
  final bool isVirtual;
  final bool isOneToManyOffer;
  final bool isTimeOffer;
  final bool isMoneyOffer;
  final bool isGoodsOffer;
  final bool isTimeRequest;
  final bool isMoneyRequest;
  final bool isGoodsRequest;
  final bool isOneToManyRequest;
  final bool isBorrowRequest;

  List<String> getTags(context) {
    List<String> tags = [];

    if (isPublic) {
      tags.add('Public');
    }
    if (isVirtual) {
      tags.add(S.of(context).virtual);
    }
    if (isOneToManyOffer) {
      tags.add('One to many');
    }
    if (isTimeOffer) {
      tags.add('Time');
    }
    if (isMoneyOffer) {
      tags.add('Money');
    }
    if (isGoodsOffer) {
      tags.add('Goods');
    }
    if (isTimeRequest) {
      tags.add('Time');
    }
    if (isMoneyRequest) {
      tags.add('Money');
    }
    if (isGoodsRequest) {
      tags.add('Goods');
    }
    if (isOneToManyRequest) {
      tags.add('One to many');
    }
    if (isBorrowRequest) {
      tags.add('Borrow');
    }
    return tags;
  }
}
