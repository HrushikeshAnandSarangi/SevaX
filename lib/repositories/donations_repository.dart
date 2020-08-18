import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class DonationsRepository {
  static final CollectionReference _ref = Firestore.instance.collection(
    DBCollection.donations,
  );

  Stream<QuerySnapshot> getDonationsOfRequest(String requestId) {
    return _ref.where('requestId', isEqualTo: requestId).snapshots();
  }

  Future<void> acknowledgeDonation(String donationId) async {
    await _ref.document(donationId).setData({
      'donationStatus': DonationStatus.ACKNOWLEDGED.toString().split('.')[1],
    }, merge: true);
  }
}
