import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class Catalyst {
  static recordAccessTime({
    String? communityId,
  }) {
    CollectionRef.communities
        .doc(communityId)
        .collection("activity")
        .doc(communityId! + "*activity")
        .get()
        .then((value) {
      if (value.exists) {
        try {
          var lastAccessed =
              DateTime.fromMillisecondsSinceEpoch(value['lastFetched']);
          var now = DateTime.now();

          if (now.difference(lastAccessed).inMinutes > 10) {
            CollectionRef.communities
                .doc(communityId)
                .collection("activity")
                .doc(communityId + "*activity")
                .update({
              'lastFetched': DateTime.now().millisecondsSinceEpoch,
            });
          }
        } catch (e) {
          logger.d(e.toString());
        }
      } else {
        logger.d("No Document found");
        CollectionRef.communities
            .doc(communityId)
            .collection("activity")
            .doc(communityId + "*activity")
            .set({
          'lastFetched': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }
}
