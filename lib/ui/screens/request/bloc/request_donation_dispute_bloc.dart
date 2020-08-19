import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/repositories/donations_repository.dart';

class RequestDonationDisputeBloc {
  final DonationsRepository _donationsRepository = DonationsRepository();

  final _cashAmount = BehaviorSubject<String>();
  final _goodsRecieved = BehaviorSubject<Map<String, String>>.seeded({});

  Stream<String> get cashAmount => _cashAmount.stream;
  Stream<Map<String, String>> get goodsRecieved => _goodsRecieved.stream;

  Function(String) get onAmountChanged => _cashAmount.sink.add;

  void toggleGoodsReceived(String key, String value) {
    var map = _goodsRecieved.value;
    if (map.containsKey(key)) {
      _goodsRecieved.add(map..remove(key));
    } else {
      map[key] = value;
      _goodsRecieved.add(map);
    }
  }

  Future<bool> disputeCash(String donationId, double pledgedAmount) async {
    if (pledgedAmount == double.parse(_cashAmount.value)) {
      await _donationsRepository.acknowledgeDonation(donationId);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> disputeGoods(
      String donationId, Map<String, String> donatedGoods) async {
    if (listEquals(
      List.from(donatedGoods.keys),
      List.from(_goodsRecieved.value.keys),
    )) {
      await _donationsRepository.acknowledgeDonation(donationId);
      return true;
    } else {
      return false;
    }
  }

  void dispose() {
    _cashAmount.close();
    _goodsRecieved.close();
  }
}
