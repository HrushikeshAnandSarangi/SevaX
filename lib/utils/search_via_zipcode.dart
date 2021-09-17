import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/zip_code_model.dart';

import 'log_printer/log_printer.dart';

class SearchCommunityViaZIPCode {
  static Future<List<CommunityModel>> getCommunitiesViaZIPCode(
    String searchTerm,
  ) async {
    return await _searchViaGeoCode(searchTerm)
        .then((location) => _getNearCommunitiesListStream(location))
        .then((nearbyCommunitiesList) => nearbyCommunitiesList)
        .catchError((onError) {
      return [] as List<CommunityModel>;
    }).whenComplete(() {
      logger.i("Completed Search for $searchTerm.");
    });
  }

  static Future<Location> _searchViaGeoCode(searchTerm) async {
    //GeoCode geoCode = GeoCode();
    try {
      //var coordinates = await geoCode.forwardGeocoding(address: searchTerm);

      var response = await http.get(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${searchTerm}&key=${FlavorConfig.values.googleMapsKey}');

      var resultsBody = jsonDecode(response.body);

      Map<String, dynamic> finalResult = resultsBody['results'][0]['geometry']['location'];

      return Location(
        lat: double.parse(finalResult['lat'].toString()), //40.7127753,
        //coordinates.latitude,
        lng: double.parse(finalResult['lng'].toString()), //-74.0059728,
        //coordinates.longitude,
      );
    } catch (e) {
      logger.e(e);
      return Future.error(NoNearByCommunitesFoundException());
    }
  }

  @Deprecated('Using Internal Library')
  static Future<Location> _searchViaZipCodeAPI(
    String zipCode,
  ) async {
    Response response = await SearchManager.makeGetRequest(url: _getZipCodeURL(zipCode));
    var latLngFromZip = latLngFromZipCodeFromJson(response.body);

    if (response.statusCode != 200 || latLngFromZip == null) {
      // FirebaseCrashlytics.instance.log('Quota Exausted');
      return Future.error(NoNearByCommunitesFoundException());
    }
    if (latLngFromZip.results != null &&
        latLngFromZip.results.length > 0 &&
        latLngFromZip.results.first.geometry != null &&
        latLngFromZip.results.first.geometry.location != null) {
      logger.i("Location found successfully");
      return Future.value(latLngFromZip.results.first.geometry.location);
    }
    return Future.error(NoNearByCommunitesFoundException());
  }

  static Future<List<CommunityModel>> _getNearCommunitiesListStream(
    Location location,
  ) async {
    log('near ');
    log('lat ${location.lat}');
    log('lon ${location.lng}');
    Geoflutterfire geo = Geoflutterfire();
    var radius = 60;
    GeoFirePoint center = geo.point(
      latitude: location.lat,
      longitude: location.lng,
    );

    var query = CollectionRef.communities;
    return await geo
        .collection(collectionRef: query)
        .within(
          center: center,
          radius: radius.toDouble(),
          field: 'location',
          strictMode: true,
        )
        .first
        .then((_) => _addToList(_))
        .catchError((onError) {
      logger.i("Error in GeoFetch");
      Future.error(NoNearByCommunitesFoundException());
    });
  }

  static List<CommunityModel> _addToList(
    List<DocumentSnapshot> communitiesMatched,
  ) {
    List<CommunityModel> communityList = [];

    logger.i(communitiesMatched.length.toString() + "  Matched");

    communitiesMatched.forEach(
      (documentSnapshot) {
        CommunityModel model = CommunityModel(documentSnapshot.data());
        if (AppConfig.isTestCommunity ?? false) {
          if (model.testCommunity && model.softDelete == false) {
            communityList.add(model);
          }
        } else {
          if ((model.softDelete == false) && (model.private == false)) communityList.add(model);
        }
      },
    );
    return communityList;
  }

  static String _getZipCodeURL(String zipCode) {
    return "https://maps.googleapis.com/maps/api/geocode/json?key=${FlavorConfig.values.googleMapsKey}&components=postal_code:" +
        zipCode;
  }
}

class NoNearByCommunitesFoundException implements Exception {
  String message;
  NoNearByCommunitesFoundException({this.message = "No Nearby communities found with ZIP."});
}
