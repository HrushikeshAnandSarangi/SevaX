import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
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
    try {
      logger.i("Starting search for ZIP code: $searchTerm");
      final location = await _searchViaGeoCode(searchTerm);
      final nearbyCommunitiesList =
          await _getNearCommunitiesListStream(location);
      return nearbyCommunitiesList;
    } catch (e) {
      logger.e("Error searching communities by ZIP code: $e");
      return <CommunityModel>[];
    } finally {
      logger.i("Completed Search for $searchTerm.");
    }
  }

  static Future<Location> _searchViaGeoCode(String searchTerm) async {
    try {
      logger.i("Geocoding address: $searchTerm");
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$searchTerm&key=${FlavorConfig.values.googleMapsKey}'));

      if (response.statusCode != 200) {
        logger.e("Geocoding API returned status code: ${response.statusCode}");
        throw NoNearByCommunitesFoundException(
            message: "Failed to geocode ZIP code");
      }

      final resultsBody = jsonDecode(response.body);

      if (resultsBody['status'] != 'OK' || resultsBody['results'].isEmpty) {
        logger.e("Geocoding API returned no results: ${resultsBody['status']}");
        throw NoNearByCommunitesFoundException(
            message: "No location found for this ZIP code");
      }

      final Map<String, dynamic> finalResult =
          resultsBody['results'][0]['geometry']['location'];

      logger.i("Location found: ${finalResult['lat']}, ${finalResult['lng']}");

      return Location(
        lat: double.parse(finalResult['lat'].toString()),
        lng: double.parse(finalResult['lng'].toString()),
      );
    } catch (e) {
      logger.e("Error in geocoding: $e");
      throw NoNearByCommunitesFoundException(
          message: "Failed to find location for ZIP code");
    }
  }

  static Future<List<CommunityModel>> _getNearCommunitiesListStream(
    Location location,
  ) async {
    try {
      logger.i(
          "Searching for communities near: lat ${location.lat}, lng ${location.lng}");
      final radius = 60.0; // 60 miles radius

      // Create GeoPoint from the location coordinates
      final geoPoint = GeoPoint(location.lat, location.lng);

      // Create a center point using GeoFlutterFirePlus
      final center = GeoFirePoint(GeoPoint(location.lat, location.lng));

      // Get the Firestore collection reference
      final collectionRef = CollectionRef.communities;

      // Use GeoCollectionReference for geospatial query
      final geo = GeoCollectionReference(collectionRef);

      // Perform the geospatial query using the correct method
      final snapshots = await geo.fetchWithinWithDistance(
        center: center,
        radiusInKm: radius * 1.60934, // convert miles to kilometers
        field: 'location',
        strictMode: true,
        geopointFrom: (data) {
          // Assumes 'location' is a Map with 'geopoint' field of type GeoPoint
          if (data == null) {
            throw Exception('Data is null');
          }
          final locationData = (data as Map<String, dynamic>)['location'];
          if (locationData is GeoPoint) {
            return locationData;
          } else if (locationData is Map &&
              locationData['geopoint'] is GeoPoint) {
            return locationData['geopoint'] as GeoPoint;
          }
          throw Exception('Invalid location data');
        },
      );

      return _processDocumentSnapshots(
          snapshots.map((geoDoc) => geoDoc.documentSnapshot).toList());
    } catch (e) {
      logger.e("Error in GeoFetch: $e");
      throw NoNearByCommunitesFoundException();
    }
  }

  static List<CommunityModel> _processDocumentSnapshots(
    List<DocumentSnapshot> communitiesMatched,
  ) {
    final List<CommunityModel> communityList = [];

    logger.i("${communitiesMatched.length} communities found in radius");

    for (final doc in communitiesMatched) {
      if (!doc.exists || doc.data() == null) continue;

      try {
        final model = CommunityModel(doc.data() as Map<String, dynamic>);

        // Filter based on app configuration and community properties
        final isTestEnvironment = AppConfig.isTestCommunity ?? false;

        if (isTestEnvironment) {
          if (model.testCommunity && model.softDelete == false) {
            communityList.add(model);
          }
        } else {
          if (model.softDelete == false && model.private == false) {
            communityList.add(model);
          }
        }
      } catch (e) {
        logger.e("Error processing community document: $e");
      }
    }

    logger.i("${communityList.length} communities match filters");
    return communityList;
  }

  @Deprecated('Using Internal Library')
  static Future<Location> _searchViaZipCodeAPI(String zipCode) async {
    Response response =
        await SearchManager.makeGetRequest(url: _getZipCodeURL(zipCode));
    var latLngFromZip = latLngFromZipCodeFromJson(response.body);

    if (response.statusCode != 200 || latLngFromZip == null) {
      return Future.error(NoNearByCommunitesFoundException());
    }
    if (latLngFromZip.results != null &&
        latLngFromZip.results.isNotEmpty &&
        latLngFromZip.results.first.geometry != null &&
        latLngFromZip.results.first.geometry.location != null) {
      logger.i("Location found successfully");
      return Future.value(latLngFromZip.results.first.geometry.location);
    }
    return Future.error(NoNearByCommunitesFoundException());
  }

  static String _getZipCodeURL(String zipCode) {
    return "https://maps.googleapis.com/maps/api/geocode/json?key=${FlavorConfig.values.googleMapsKey}&components=postal_code:$zipCode";
  }
}

class NoNearByCommunitesFoundException implements Exception {
  final String message;
  NoNearByCommunitesFoundException(
      {this.message =
          "No nearby communities found with the provided ZIP code."});

  @override
  String toString() => message;
}
