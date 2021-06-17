// import 'dart:async';


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
//         ? CollectionRef
//             .offers
//             .where('assossiatedRequest', isNull: true)
//         : CollectionRef
//             .offers
//             .where('timebankId', isEqualTo: timebankId)
//             .where('assossiatedRequest', isNull: true);

//     var data = query.snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
//         handleData: (snapshot, offerSink) {
//           List<OfferModel> offerList = [];
//           snapshot.docs.forEach((snapshot) {
//             OfferModel model = OfferModel.fromMap(snapshot.data);
//             model.id = snapshot.id;
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
//     await CollectionRef
//         .offers
//         .doc(offerModel.id)
//         .set(offerModel.toMap());
//   }

//   /// update [offer] with request
//   Future<void> updateOfferWithRequest({
//     @required OfferModel offer,
//   }) async {
//     log.i('updateOfferWithRequest: OfferModel: ${offer.toMap()}');
//     await CollectionRef
//         .offers
//         .doc(offer.id)
//         .set(offer.toMap(), merge: true);
//   }
// }
