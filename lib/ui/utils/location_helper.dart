import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class DistanceFilterData {
  final Location locationData;
  final int radius;

  DistanceFilterData(this.locationData, this.radius);

  bool isInRadius(GeoFirePoint entityCoordinates) {
    if (locationData == null ||
        radius == null ||
        radius == 0 ||
        entityCoordinates == null) {
      return true;
    } else {
      var result = radius >=
          LocationHelper.getDistanceBetweenPoints(
            Coordinates(
              locationData.latitude,
              locationData.longitude,
            ),
            entityCoordinates,
          );
      logger.wtf("in radius $result");
      return result;
    }
  }
}

class LocationHelper {
  static double getDistanceBetweenPoints(
      Coordinates cord1, GeoFirePoint cord2) {
    return cord2.distance(
      lat: cord1.latitude,
      lng: cord1.longitude,
    );
    // return GeoFirePoint.distanceBetween(to: cord1, from: cord2);
  }

  static Future<Location> gpsCheck() async {
    //return location over here
  }
}
