import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class UserDonationBloc {
  Future<int> getDonatedAmount(
      {@required String sevaUserId,
      @required int timeFrame,
      bool isLifeTime}) async {
    FirestoreManager.getUserDonatedAmount(
            sevaUserId: sevaUserId,
            timeFrame: timeFrame,
            isLifeTime: isLifeTime)
        .then((value) {
      return value;
    });
  }
}
