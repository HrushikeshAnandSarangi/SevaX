import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';


class RecurringListDataManager {

  static Stream<List<RequestModel>> getRecurringRequestListStream(
      {String parentRequestId}) async* {
    var query = Firestore.instance
        .collection('requests')
        .where('parent_request_id', isEqualTo: parentRequestId)
        .where('accepted', isEqualTo: false)
        .where('softDelete', isEqualTo: false)
        .orderBy('request_start',descending: false);
    var data = query.snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
              if (model.approvedUsers.length <= model.numberOfApprovals) {
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
      {String parentOfferId}) async* {
    var query = Firestore.instance
        .collection('offers')
        .where('softDelete', isEqualTo: false)
        .where('parent_offer_id', isEqualTo: parentOfferId)
        .where('assossiatedRequest', isNull: true)
        .orderBy('occurenceCount',descending: false);
    var data = query.snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
        handleData: (snapshot, offersSink) {
          List<OfferModel> offersList = [];
          var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
          snapshot.documents.forEach(
                (documentSnapshot) {
                  OfferModel model = OfferModel.fromMap(documentSnapshot.data);
                  model.id = documentSnapshot.documentID;
                  if(model.offerType==OfferType.GROUP_OFFER){
                    if(model.groupOfferDataModel.endDate >= currentTimeStamp) {
                      offersList.add(model);
                    }
                  }else{
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
