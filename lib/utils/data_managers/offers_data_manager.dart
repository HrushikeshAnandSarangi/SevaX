import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:meta/meta.dart';
Location loc = new Location();
Geoflutterfire geoflutterfire = Geoflutterfire();

Stream<List<OfferModel>> getOffersStream({String timebankId}) async* {
  var query = timebankId == null || timebankId == 'All'
      ? Firestore.instance
          .collection('offers')
          .where('assossiatedRequest', isNull: true)
      : Firestore.instance
          .collection('offers')
          .where('timebankId', isEqualTo: timebankId)
          .where('assossiatedRequest', isNull: true);

  var data = query.snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (snapshot, offerSink) {
        List<OfferModel> offerList = [];
        snapshot.documents.forEach((snapshot) {
          OfferModel model = OfferModel.fromMap(snapshot.data);
          model.id = snapshot.documentID;
          offerList.add(model);
        });
        offerSink.add(offerList);
      },
    ),
  );
}

Stream<List<OfferModel>> getNearOffersStream({String timebankId}) async* {
  LocationData pos = await loc.getLocation();
    double lat = pos.latitude;
    double lng = pos.longitude;
    GeoFirePoint center = geoflutterfire.point(latitude: lat, longitude: lng);
  var query = timebankId == null || timebankId == 'All'
      ? Firestore.instance
          .collection('offers')
          .where('assossiatedRequest', isNull: true)
      : Firestore.instance
          .collection('offers')
          .where('timebankId', isEqualTo: timebankId)
          .where('assossiatedRequest', isNull: true);

  var data = geoflutterfire.collection(collectionRef: query).within(
        center: center, 
        radius: 20, 
        field: 'location', 
        strictMode: true
      );

  yield* data.transform(
    StreamTransformer<List<DocumentSnapshot>, List<OfferModel>>.fromHandlers(
      handleData: (snapshot, offerSink) {
        List<OfferModel> offerList = [];
        snapshot.forEach((snapshot) {
          OfferModel model = OfferModel.fromMap(snapshot.data);
          model.id = snapshot.documentID;
          offerList.add(model);
        });
        offerSink.add(offerList);
      },
    ),
  );
}

Stream<List<OfferModel>> getAllOffersStream() async* {
  var query = Firestore.instance
      .collection('offers')
      .where('assossiatedRequest', isNull: true);

  var data = query.snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (snapshot, offerSink) {
        List<OfferModel> offerList = [];
        snapshot.documents.forEach((snapshot) {
          OfferModel model = OfferModel.fromMap(snapshot.data);
          model.id = snapshot.documentID;
          offerList.add(model);
        });
        offerSink.add(offerList);
      },
    ),
  );
}

Future<void> createOffer({@required OfferModel offerModel}) async {
  await Firestore.instance
      .collection('offers')
      .document(offerModel.id)
      .setData(offerModel.toMap());
}

Stream<List<OfferModel>> getOfferNotificationStream({
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('notifications')
      .document(userId)
      .collection('offerRequest')
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (snapshot, offerSink) {
        List<OfferModel> offerList = [];
        snapshot.documents.forEach((documentSnapshot) {
          OfferModel offer = OfferModel.fromMap(documentSnapshot.data);
          offerList.add(offer);
        });
        offerSink.add(offerList);
      },
    ),
  );
}

Stream<List<RequestModel>> getOfferRequestApprovedNotificationStream({
  @required String userId,
}) async* {
  var data = Firestore.instance
      .collection('notifications')
      .document(userId)
      .collection('offerAccepted')
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
      handleData: (snapshot, requestSink) {
        List<RequestModel> requestList = [];
        snapshot.documents.forEach((document) {
          RequestModel model = RequestModel.fromMap(document.data);
          model.id = document.documentID;
          requestList.add(model);
        });
        requestSink.add(requestList);
      },
    ),
  );
}

Future<void> deleteOfferRequestApproval({
  @required RequestModel request,
}) async {
  await Firestore.instance
      .collection('notifications')
      .document(request.sevaUserId)
      .collection('offerAccepted')
      .document(request.id)
      .delete();
}

Future<void> updateOfferWithRequest({
  @required OfferModel offer,
}) async {
  await Firestore.instance
      .collection('offers')
      .document(offer.id)
      .setData(offer.toMap(), merge: true);
}

Future<void> acceptOfferRequest({
  @required OfferModel offer,
  @required RequestModel request,
}) async {
  await Firestore.instance
      .collection('notifications')
      .document(offer.sevaUserId)
      .collection('offerRequest')
      .document(offer.id)
      .delete();

  await Firestore.instance
      .collection('offers')
      .document(offer.id)
      .setData(offer.toMap());

  await FirestoreManager.acceptRequest(
      requestModel: request, senderUserId: null);

  await Firestore.instance
      .collection('notifications')
      .document(request.sevaUserId)
      .collection('offerAccepted')
      .document(request.id)
      .setData(request.toMap());
}
