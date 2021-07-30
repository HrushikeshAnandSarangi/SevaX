import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

GeoFirePoint getLocation(map) {
  GeoFirePoint geoFirePoint;

  try {
    if (map.containsKey("location")) {
      if (map['location'].containsKey('geopoint')) {
        if (map['location']['geopoint'].containsKey('_latitude')) {
          geoFirePoint = GeoFirePoint(
            map["location"]["geopoint"]["_latitude"],
            map["location"]["geopoint"]["_longitude"],
          );
        } else {
          GeoPoint d = map["location"]["geopoint"];
          geoFirePoint = GeoFirePoint(
            d.latitude,
            d.longitude,
          );
        }
      }
    } else {
      return null;
    }
  } catch (e) {
    logger.d("Failed to do the location conversion!");
    e.toString();
  }

  return geoFirePoint;
}
