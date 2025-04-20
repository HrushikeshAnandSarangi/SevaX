import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class RecurringListDataManager {
  static Stream<List<RequestModel>> getRecurringRequestListStream(
      {required String parentRequestId}) async* {
    var query = CollectionRef.requests
        .where('parent_request_id', isEqualTo: parentRequestId)
        .where('accepted', isEqualTo: false)
        .where('softDelete', isEqualTo: false)
        .orderBy('request_start', descending: false);
    var data = query.snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.docs.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(
                  documentSnapshot.data() as Map<String, dynamic>);
              model.id = documentSnapshot.id;
              if ((model.approvedUsers?.length ?? 0) <=
                  (model.numberOfApprovals ?? 0)) {
                requestList.add(model);
              }
            },
          );
          requestSink.add(requestList);
        },
      ),
    );
  }

  static Stream<List<OfferModel>> getRecurringofferListStream(
      {required String parentOfferId}) async* {
    var query = CollectionRef.offers
        .where('softDelete', isEqualTo: false)
        .where('parent_offer_id', isEqualTo: parentOfferId)
        .where('assossiatedRequest', isNull: true)
        .orderBy('occurenceCount', descending: false);
    var data = query.snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
        handleData: (snapshot, offersSink) {
          List<OfferModel> offersList = [];
          var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
          snapshot.docs.forEach(
            (documentSnapshot) {
              OfferModel model = OfferModel.fromMap(
                  documentSnapshot.data() as Map<String, dynamic>);
              model.id = documentSnapshot.id;
              if (model.offerType == OfferType.GROUP_OFFER) {
                if ((model.groupOfferDataModel?.endDate ?? 0) >=
                    currentTimeStamp) {
                  offersList.add(model);
                }
              } else {
                offersList.add(model);
              }
            },
          );
          offersSink.add(offersList);
        },
      ),
    );
  }
}
