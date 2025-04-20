import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sevaexchange/core/error/failures.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationHelper {
  static double getDistanceBetweenPoints(Location cord1, GeoFirePoint cord2) {
    // GeoFirePoint does not have a 'distance' method, use distanceBetween from Geolocator
    return Geolocator.distanceBetween(
      cord1.latitude,
      cord1.longitude,
      cord2.latitude,
      cord2.longitude,
    );
  }

  static Future<Location?> getCoordinates() async {
    var result = await getLocation();
    Location? coordinates;

    result.fold((l) {
      coordinates = null;
    }, (r) {
      coordinates = Location(
        latitude: r.latitude,
        longitude: r.longitude,
        timestamp: r.timestamp,
      );
      logger.d([coordinates!.latitude, coordinates!.longitude]);
    });
    logger.d([coordinates?.latitude, coordinates?.longitude]);
    return coordinates;
  }

  static Future<Either<Failure, Location>> getLocation() async {
    try {
      logger.i("Checking location permissions...");
      if (await _hasPermissions()) {
        logger.i("Permission seems to be granted for location!");
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        logger.i("Successfully retrieved location: ${position.toString()}");
        return right(Location(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: position.timestamp,
        ));
      } else {
        logger.i("Permission denied for location!");
        return left(Failure("Permission Denied."));
      }
    } catch (e) {
      logger.i("Failed to retrieve location: $e");
      return left(Failure(e.toString()));
    }
  }

  static Future<bool> _hasPermissions({bool firstTime = true}) async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (firstTime) {
        await Geolocator.requestPermission();
        return _hasPermissions(firstTime: false);
      } else {
        return false;
      }
    } else {
      logger.d(
          "Location permission is not enabled! requesting permission from user!");
      return await Geolocator.isLocationServiceEnabled();
    }
  }
}

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
            Location(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
              timestamp: locationData.timestamp,
            ),
            entityCoordinates,
          );
      logger.wtf("in radius $result");
      return result;
    }
  }
}

class LocationMetaData {
  bool? canAccess;
  String? accessDetail;
}
