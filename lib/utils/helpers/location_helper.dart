import 'package:geoflutterfire/geoflutterfire.dart';

GeoFirePoint getLocation(map) {
  GeoFirePoint geoFirePoint;

  if (map.containsKey("location")) {
    if (map['location'].containsKey('geoPoint')) {
      if (map.containsKey('_latitude')) {
        geoFirePoint = GeoFirePoint(
          map["location"]["geopoint"]["_latitude"],
          map["location"]["geopoint"]["_longitude"],
        );
      } else {
        geoFirePoint = GeoFirePoint(
          map["location"]["geopoint"]["latitude"],
          map["location"]["geopoint"]["longitude"],
        );
      }
    }
  } else {
    geoFirePoint = GeoFirePoint(40.754387, -73.984291);
  }

  return geoFirePoint;
}
