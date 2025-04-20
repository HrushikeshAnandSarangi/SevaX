import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class CustomLocation {
  final GeoFirePoint location;
  final String address;

  CustomLocation(this.location, this.address);
}

enum Status { LOADING, COMPLETE, IDLE, ERROR }
