import 'package:geoflutterfire/geoflutterfire.dart';

class LocationDataModel {
  String location;
  double lat;
  double lng;

  LocationDataModel(this.location, this.lat, this.lng);

  GeoFirePoint get geoPoint => GeoFirePoint(lat, lng);
}
