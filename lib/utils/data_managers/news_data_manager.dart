import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
// import 'package:location/location.dart';

import '../location_utility.dart';

// Create GeoFirePoint instances when needed instead of using a global variable
Future<void> createNews({required NewsModel newsObject}) async {
  await CollectionRef.feeds.doc(newsObject.id).set(newsObject.toMap());
}

Future<void> updateNews({required NewsModel newsObject}) async {
  await CollectionRef.feeds.doc(newsObject.id).update(
        newsObject.toMap(),
      );
}

Stream<List<NewsModel>> getNewsStream({required String timebankID}) async* {
  var data = CollectionRef.feeds
      .where('timebanksposted', arrayContains: timebankID)
      .where('softDelete', isEqualTo: false)
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) async {
    List<NewsModel> modelList = [];

    querySnapshot.docs.forEach((document) {
      var newsModel =
          NewsModel.fromMap(document.data() as Map<String, dynamic>);
      modelList.add(newsModel);
    });

    logger.d("Stream Updated================================== Handler" +
        modelList.length.toString() +
        " =======  " +
        DateTime.now().toString());

    newsSink.add(modelList);
  }));
}

Future<DocumentSnapshot> getUserInfo(String userEmail) {
  return CollectionRef.users.doc(userEmail).get().then((onValue) {
    return onValue;
  });
}

// Stream<List<NewsModel>> getNearNewsStream(
//     {@required String timebankID}) async* {
//   // Geolocator geolocator = Geolocator();
//   var futures = <Future>[];

// .orderBy('posttimestamp', descending: true);

//   lastLocation.fold((l) => null, (r) => null);

//   GeoFirePoint center = geos.point(latitude: lat, longitude: lng);

//   var query = Firestore.instance.collection('news').where(
//     'entity',
//     isEqualTo: {
//       'entityType': 'timebanks',
//       'entityId': timebankID,
//       //'entityName': FlavorConfig.timebankName,
//     },
//   );
//   // .orderBy('posttimestamp', descending: true);

//   var radius = 20;
//   try {
//     radius = json.decode(AppConfig.remoteConfig.getString('radius'));
//   } on Exception {
//     //
//   }

//   var data = geos.collection(collectionRef: query).within(
//         center: center,
//         radius: radius.toDouble(),
//         field: 'location',
//         strictMode: true,
//       );

//   yield* data.transform(
//       StreamTransformer<List<DocumentSnapshot>, List<NewsModel>>.fromHandlers(
//           handleData: (querySnapshot, newsSink) async {
//     List<NewsModel> modelList = [];

//     querySnapshot.forEach((document) {
//       var news = NewsModel.fromMap(document.data());
//       futures.add(getUserInfo(news.email));
//       modelList.add(news);
//     });
//     modelList.sort((n1, n2) {
//       return n2.postTimestamp.compareTo(n1.postTimestamp);
//       // return n2.postTimestamp > n2.postTimestamp ? -1 : 1;
//     });

//     //await process goes here
//     await Future.wait(futures).then((onValue) async {
//       for (var i = 0; i < modelList.length; i++) {
//         //  modelList[i].userPhotoURL = onValue[i]['photourl'];

//         // var data = await _getLocation(
//         //   modelList[i].location.geoPoint.latitude,
//         //   modelList[i].location.geoPoint.longitude,
//         // );
//         // modelList[i].placeAddress = data;
//       }

//       newsSink.add(modelList);
//     });
//   }));
// }

Stream<List<NewsModel>> getAllNewsStream() async* {
  var data = CollectionRef.feeds
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) {
    List<NewsModel> modelList = [];
    querySnapshot.docs.forEach((document) {
      modelList.add(NewsModel.fromMap(document.data() as Map<String, dynamic>));
    });
    newsSink.add(modelList);
  }));
}

//Stream<List<NewsModel>> getAllNearNewsStream() async* {
//   Position userLocation;

//   userLocation = await Geolocator.getCurrentPosition();
//   double lat = userLocation.latitude;
//   double lng = userLocation.longitude;

//   var radius = 20;
//   try {
//     radius = json.decode(AppConfig.remoteConfig.getString('radius'));
//   } on Exception {
//     //
//   }

//   GeoFirePoint center = geos.point(latitude: lat, longitude: lng);
//   var query = CollectionRef.feeds;
//   var data = geos.collection(collectionRef: query).within(
//       center: center,
//       radius: radius.toDouble(),
//       field: 'location',
//       strictMode: true);

//   yield* data.transform(
//       StreamTransformer<List<DocumentSnapshot>, List<NewsModel>>.fromHandlers(
//           handleData: (querySnapshot, newsSink) {
//     List<NewsModel> modelList = [];
//     querySnapshot.forEach((document) {
//       modelList.add(NewsModel.fromMap(document.data()));
//     });
//     modelList.sort((n1, n2) {
//       return n2.postTimestamp.compareTo(n1.postTimestamp);
//     });
//     newsSink.add(modelList);
//   }));
// }

Future<NewsModel?> getNewsForId(String newsId) async {
  NewsModel? newsModel;
  await CollectionRef.feeds.doc(newsId).get().then((snapshot) {
    if (snapshot.data == null) return null;
    newsModel = NewsModel.fromMap(snapshot.data() as Map<String, dynamic>);
  });

  return newsModel;
}

Future deleteNews(NewsModel newsModel) async {
  await CollectionRef.feeds.doc(newsModel.id).delete();
}

Future _getLocation(double latitude, double longitude) async {
  String address = (await LocationUtility().getFormattedAddress(
        latitude,
        longitude,
      )) ??
      'Unknown location';
  return address;
}

class SortOrderClass {
  static const LIKES = "Likes";
  static const LATEST = "Latest";
}
