import 'package:geoflutterfire/geoflutterfire.dart';

GeoFirePoint getLocation(map) {
  GeoFirePoint geoFirePoint;

  if (map.containsKey("location")) {
    if (map['location'].containsKey('geopoint')) {
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
    return null;
  }

  return geoFirePoint;
}
