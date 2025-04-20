import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class UserDonationBloc {
  Future<int> getDonatedAmount(
      {required String sevaUserId,
      required int timeFrame,
      bool? isLifeTime}) async {
    return await FirestoreManager.getUserDonatedGoodsAndAmount(
            sevaUserId: sevaUserId,
            timeFrame: timeFrame,
            isLifeTime: isLifeTime)
        .then((value) {
      return value;
    });
  }
}
