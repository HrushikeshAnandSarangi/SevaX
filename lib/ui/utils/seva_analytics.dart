import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class Catalyst {
  static recordAccessTime({
    String communityId,
  }) {
    Firestore.instance
        .collection("communities")
        .document(communityId)
        .collection("activity")
        .document(communityId + "*activity")
        .get()
        .then((value) {
      if (value.exists) {
        try {
          var lastAccessed =
              DateTime.fromMillisecondsSinceEpoch(value['lastFetched']);
          var now = DateTime.now();

          if (now.difference(lastAccessed).inMinutes > 10) {
            Firestore.instance
                .collection("communities")
                .document(communityId)
                .collection("activity")
                .document(communityId + "*activity")
                .updateData({
              'lastFetched': DateTime.now().millisecondsSinceEpoch,
            });
          }
        } catch (e) {
          logger.d(e.toString());
        }
      } else {
        logger.d("No Document found");
        Firestore.instance
            .collection("communities")
            .document(communityId)
            .collection("activity")
            .document(communityId + "*activity")
            .setData({
          'lastFetched': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }
}
