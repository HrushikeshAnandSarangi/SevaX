import 'package:cloud_firestore/cloud_firestore.dart';

class BuckBatch {
  static BuckBatch instance = BuckBatch();
  static WriteBatch _batch;

  BuckBatch() {
    _batch = Firestore.instance.batch();
  }

  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    _batch.setData(document, data, merge: merge);
  }

  void updateData(DocumentReference document, Map<String, dynamic> data) {
    _batch.updateData(document, data);
  }

  Future<void> commit() async => await _batch.commit();

  void delete(DocumentReference document) {
    _batch.delete(document);
  }
}
