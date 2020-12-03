import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/manual_time_model.dart';

class ManualTimeRepository {
  static final _ref = Firestore.instance.collection('manualTimeClaims');

  static Future<void> createClaim(ManualTimeModel model) async {
    assert(model.id != null);
    await _ref.document(model.id).setData(model.toMap());
  }

  static Future<void> claimAction(ManualTimeModel model) async {
    assert(model.status != ClaimStatus.NoAction);
    assert(model.actionBy != null);
    await _ref.document(model.id).updateData({
      "status": model.status.toString().split('.')[1],
      "actionBy": model.actionBy,
    });
  }
}
