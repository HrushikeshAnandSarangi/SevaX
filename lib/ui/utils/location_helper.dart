import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart' as loc;
// import 'package:geolocator/geolocator.dart';
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

class LocationMetaData {
  bool canAccess;
  String accessDetail;
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

  static Future<Either<Failure, Location>> getLocation() async {
    if (await _hasPermissions()) {
      logger.i("Permission seems to be granted for location!", "Location");
      try {
        var lastKnownLocation = await new loc.Location().getLocation();
        logger.i(
            "Successfully retrieved location========" +
                lastKnownLocation.toString(),
            "Location");

        return right(Location(
          latitude: lastKnownLocation.latitude,
          longitude: lastKnownLocation.longitude,
        ));
      } catch (e) {
        logger.i("Failed to retrieve location", "Location");
        return left(Failure(e.toString()));
      }
    } else {
      logger.i("Permission denied!===================", "Location");
      return left(Failure("Permission Denied."));
    }
  }

  static Future<bool> _hasPermissions({bool firstTime = true}) async {
    var locationInstace = new loc.Location();
    locationInstace.enableBackgroundMode(enable: false);

    // var permission = await Geolocator.checkPermission();
    var permission = await locationInstace.hasPermission();

    if (permission == loc.PermissionStatus.denied ||
        permission == loc.PermissionStatus.deniedForever) {
      if (firstTime) {
        await locationInstace.requestPermission();
        return _hasPermissions(firstTime: false);
      } else
        return false;
    } else {
      var isLocationServiceEnabled = await locationInstace.serviceEnabled();
      if (!isLocationServiceEnabled) {
        logger.d(
            "Location permission is not enabled! requesting permission from user!",
            "Location");

        return await locationInstace.serviceEnabled();
      } else {
        logger.d("Location permission allowed from user!!", "Location");
        return true;
      }
    }
  }

  static Future<Coordinates> getCoordinates() async {
    var result = await getLocation();
    Coordinates coordinates;

    result.fold((l) {
      coordinates = null;
    }, (r) {
      coordinates = Coordinates(r.latitude, r.longitude);
      logger.d([coordinates?.latitude, coordinates?.longitude],
          "Coordinates in fold");
    });
    logger.d(
        [coordinates?.latitude, coordinates?.longitude], "Coordinates return");
    return coordinates;
  }
}
