import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';

import '../app_config.dart';
import '../location_utility.dart';

Location locations = Location();
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
  var data = Firestore.instance
      .collection('news')
      .where('timebanksposted', arrayContains: timebankID)
      //Removed to support feeds in parent timebank
      // .where('entity', isEqualTo: {
      //   'entityType': 'timebanks',
      //   'entityId': timebankID,
      // })
      .where('softDelete', isEqualTo: false)
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) async {
    List<NewsModel> modelList = [];

    querySnapshot.documents.forEach((document) {
      var newsModel = NewsModel.fromMap(document.data);
      //futures.add(getUserInfo(newsModel.email));
      modelList.add(newsModel);
    });

//    //await process goes here
//    for (int i = 0; i < modelList.length; i += 1) {
//      UserModel userModel = await getUserForId(
//        sevaUserId: modelList[i].sevaUserId,
//      );
//      modelList[i].userPhotoURL=userModel.photoURL;
//      timeBankModelList.add(timeBankModel);
//    }
    // await Future.wait(futures).then((onValue) async {
    for (var i = 0; i < modelList.length; i++) {
      //  modelList[i].userPhotoURL = onValue[i]['photourl'];
      UserModel userModel = await getUserForId(
        sevaUserId: modelList[i].sevaUserId,
      );
      modelList[i].userPhotoURL = userModel?.photoURL ?? defaultUserImageURL;

      // if (modelList[i].placeAddress == null) {
      //   var data = await _getLocation(
      //     modelList[i].location.geoPoint.latitude,
      //     modelList[i].location.geoPoint.longitude,
      //   );
      //   modelList[i].placeAddress = data;
      // }
    }

    newsSink.add(modelList);
    // });
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

  var query = Firestore.instance.collection('news').where(
    'entity',
    isEqualTo: {
      'entityType': 'timebanks',
      'entityId': timebankID,
      //'entityName': FlavorConfig.timebankName,
    },
  );
  // .orderBy('posttimestamp', descending: true);

  var radius = 20;
  try {
    radius = json.decode(AppConfig.remoteConfig.getString('radius'));
  } on Exception {
    //
  }

  var data = geos.collection(collectionRef: query).within(
        center: center,
        radius: radius.toDouble(),
        field: 'location',
        strictMode: true,
      );

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
      // return n2.postTimestamp > n2.postTimestamp ? -1 : 1;
    });

    //await process goes here
    await Future.wait(futures).then((onValue) async {
      for (var i = 0; i < modelList.length; i++) {
        //  modelList[i].userPhotoURL = onValue[i]['photourl'];

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

  var radius = 20;
  try {
    radius = json.decode(AppConfig.remoteConfig.getString('radius'));
  } on Exception {
    //
  }

  GeoFirePoint center = geos.point(latitude: lat, longitude: lng);
  var query = Firestore.instance.collection('news');
  var data = geos.collection(collectionRef: query).within(
      center: center,
      radius: radius.toDouble(),
      field: 'location',
      strictMode: true);

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
