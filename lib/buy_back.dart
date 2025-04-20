import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class BuckBatch {
  static BuckBatch instance = BuckBatch();
  static late WriteBatch _batch;

  BuckBatch() {
    _batch = CollectionRef.batch;
  }

  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    _batch.set(document, data, SetOptions(merge: merge));
  }

  void updateData(DocumentReference document, Map<String, dynamic> data) {
    _batch.update(document, data);
  }

  Future<void> commit() async => await _batch.commit();

  void delete(DocumentReference document) {
    _batch.delete(document);
  }
}
