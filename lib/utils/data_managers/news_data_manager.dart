import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'package:sevaexchange/models/news_model.dart';

import '../location_utility.dart';

Location locations = new Location();
Geoflutterfire geos = Geoflutterfire();

Future<void> createNews({@required NewsModel newsObject}) async {
  await Firestore.instance
      .collection('news')
      .document(newsObject.id)
      .setData(newsObject.toMap());
}

Future<void> updateNews({@required NewsModel newsObject}) async {
  await Firestore.instance
      .collection('news')
      .document(newsObject.id)
      .updateData(
        newsObject.toMap(),
      );
}

Stream<List<NewsModel>> getNewsStream({@required String timebankID}) async* {
  var futures = <Future>[];

  var data = Firestore.instance
      .collection('news')
      .where('entity', isEqualTo: {
        'entityType': 'timebanks',
        'entityId': timebankID,
        //'entityName': FlavorConfig.timebankName,
      })
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) async {
    List<NewsModel> modelList = [];

    querySnapshot.documents.forEach((document) {
      var newsModel = NewsModel.fromMap(document.data);
      futures.add(getUserInfo(newsModel.email));
      modelList.add(newsModel);
    });

    //await process goes here

    await Future.wait(futures).then((onValue) async {
      for (var i = 0; i < modelList.length; i++) {
        modelList[i].userPhotoURL = onValue[i]['photourl'];

        if (modelList[i].placeAddress == null) {
          var data = await _getLocation(
            modelList[i].location.geoPoint.latitude,
            modelList[i].location.geoPoint.longitude,
          );
          modelList[i].placeAddress = data;
        }
      }

      newsSink.add(modelList);
    });
  }));
}

Future<DocumentSnapshot> getUserInfo(String userEmail) {
  return Firestore.instance
      .collection("users")
      .document(userEmail)
      .get()
      .then((onValue) {
    return onValue;
  });
}

Stream<List<NewsModel>> getNearNewsStream(
    {@required String timebankID}) async* {
  Geolocator geolocator = Geolocator();
  Position userLocation;
  var futures = <Future>[];

  userLocation = await geolocator.getCurrentPosition();
  double lat = userLocation.latitude;
  double lng = userLocation.longitude;

  GeoFirePoint center = geos.point(latitude: lat, longitude: lng);
  var query = Firestore.instance.collection('news').where('entity', isEqualTo: {
    'entityType': 'timebanks',
    'entityId': timebankID,
    //'entityName': FlavorConfig.timebankName,
  });

  var data = geos
      .collection(collectionRef: query)
      .within(center: center, radius: 20, field: 'location', strictMode: true);

  yield* data.transform(
      StreamTransformer<List<DocumentSnapshot>, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) async {
    List<NewsModel> modelList = [];

    querySnapshot.forEach((document) {
      var news = NewsModel.fromMap(document.data);
      futures.add(getUserInfo(news.email));
      modelList.add(news);
    });
    modelList.sort((n1, n2) {
      return n2.postTimestamp.compareTo(n1.postTimestamp);
    });

    //await process goes here
    await Future.wait(futures).then((onValue) async {
      for (var i = 0; i < modelList.length; i++) {
        modelList[i].userPhotoURL = onValue[i]['photourl'];

        // var data = await _getLocation(
        //   modelList[i].location.geoPoint.latitude,
        //   modelList[i].location.geoPoint.longitude,
        // );
        // modelList[i].placeAddress = data;
      }

      newsSink.add(modelList);
    });
  }));
}

Stream<List<NewsModel>> getAllNewsStream() async* {
  var data = Firestore.instance
      .collection('news')
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) {
    List<NewsModel> modelList = [];
    querySnapshot.documents.forEach((document) {
      modelList.add(NewsModel.fromMap(document.data));
    });
    newsSink.add(modelList);
  }));
}

Stream<List<NewsModel>> getAllNearNewsStream() async* {
  Geolocator geolocator = Geolocator();
  Position userLocation;

  userLocation = await geolocator.getCurrentPosition();
  double lat = userLocation.latitude;
  double lng = userLocation.longitude;

  GeoFirePoint center = geos.point(latitude: lat, longitude: lng);
  var query = Firestore.instance.collection('news');
  var data = geos
      .collection(collectionRef: query)
      .within(center: center, radius: 20, field: 'location', strictMode: true);

  yield* data.transform(
      StreamTransformer<List<DocumentSnapshot>, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) {
    List<NewsModel> modelList = [];
    querySnapshot.forEach((document) {
      modelList.add(NewsModel.fromMap(document.data));
    });
    modelList.sort((n1, n2) {
      return n2.postTimestamp.compareTo(n1.postTimestamp);
    });
    newsSink.add(modelList);
  }));
}

Future<NewsModel> getNewsForId(String newsId) async {
  NewsModel newsModel;
  await Firestore.instance
      .collection('news')
      .document(newsId)
      .get()
      .then((snapshot) {
    if (snapshot.data == null) return null;
    newsModel = NewsModel.fromMap(snapshot.data);
  });

  return newsModel;
}

Future deleteNews(NewsModel newsModel) async {
  await Firestore.instance.collection('news').document(newsModel.id).delete();
}

Future _getLocation(double latitude, double longitude) async {
  String address = await LocationUtility().getFormattedAddress(
    latitude,
    longitude,
  );
  return address;
}
