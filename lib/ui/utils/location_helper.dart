import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sevaexchange/core/error/failures.dart';
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

  // static Future<Either<Failure,Location>> getLastKnownPosition() async {
  //   //return location over here
  //   var isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!isLocationServiceEnabled) {
  //     await Geolocator.requestPermission();
  //     var isLocationServiceEnabled =
  //         await Geolocator.isLocationServiceEnabled();
  //     if (isLocationServiceEnabled) {
  //       return getLocation();
  //     } else {
  //       return null;
  //     }
  //   } else {
  //     return getLocation();
  //   }
  // }

  static Future<Either<Failure,Location>> getLocation() {
    return Geolocator.getLastKnownPosition().then((currentPostion) {
      return right(Location(
        latitude: currentPostion.latitude,
        longitude: currentPostion.longitude,
      ));
    }).catchError((e) {
      return left(Failure(e.toString()));
    });
  }

  static Future<Coordinates> getCoordinates() {
    return Geolocator.getLastKnownPosition().then((currentPostion) {
      if (currentPostion != null) {
        return Coordinates(
          currentPostion.latitude,
          currentPostion.longitude,
        );
      } else {
        return null;
      }
    }).catchError((e) {
      return null;
    });
  }
}
