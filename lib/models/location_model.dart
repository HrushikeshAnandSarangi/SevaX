import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationDataModel {
  String location;
  double lat;
  double lng;

  LocationDataModel(this.location, this.lat, this.lng);

  GeoFirePoint get geoPoint => GeoFirePoint(GeoPoint(lat, lng));
}
