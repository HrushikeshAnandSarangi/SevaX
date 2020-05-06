// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sevaexchange/base/base_service.dart';
// import 'package:sevaexchange/models/offer_model.dart';
// import 'package:sevaexchange/models/request_model.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:meta/meta.dart';

// class OfferService extends BaseService {
//   /// get a stream of offers in [offerSink] for a [timebankId]
//   Stream<List<OfferModel>> getOffersStream({String timebankId}) async* {
//     log.i('getOffersStream: TimebankID: $timebankId');
//     var query = timebankId == null
//         ? Firestore.instance
//             .collection('offers')
//             .where('assossiatedRequest', isNull: true)
//         : Firestore.instance
//             .collection('offers')
//             .where('timebankId', isEqualTo: timebankId)
//             .where('assossiatedRequest', isNull: true);

//     var data = query.snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
//         handleData: (snapshot, offerSink) {
//           List<OfferModel> offerList = [];
//           snapshot.documents.forEach((snapshot) {
//             OfferModel model = OfferModel.fromMap(snapshot.data);
//             model.id = snapshot.documentID;
//             offerList.add(model);
//           });
//           offerSink.add(offerList);
//         },
//       ),
//     );
//   }

//   /// Create an offer[offerModel]
//   Future<void> createOffer({@required OfferModel offerModel}) async {
//     log.i('createOffer: OfferModel: ${offerModel.toMap()}');
//     await Firestore.instance
//         .collection('offers')
//         .document(offerModel.id)
//         .setData(offerModel.toMap());
//   }

//   /// update [offer] with request
//   Future<void> updateOfferWithRequest({
//     @required OfferModel offer,
//   }) async {
//     log.i('updateOfferWithRequest: OfferModel: ${offer.toMap()}');
//     await Firestore.instance
//         .collection('offers')
//         .document(offer.id)
//         .setData(offer.toMap(), merge: true);
//   }
// }
