import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class DonationsRepository {
  static final CollectionReference _ref = Firestore.instance.collection(
    DBCollection.donations,
  );

  Stream<QuerySnapshot> getDonationsOfRequest(String requestId) {
    return _ref.where('requestId', isEqualTo: requestId).snapshots();
  }
}
