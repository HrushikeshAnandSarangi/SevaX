import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class DistanceFilterData {
  final LocationData locationData;
  final int radius;

  DistanceFilterData(this.locationData, this.radius);

  bool isInRadius(GeoFirePoint entityCoordinates) {
    if (locationData == null ||
        radius == null ||
        radius == 0 ||
        entityCoordinates == null) {
      logger.wtf("passed due to null");
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

  static Future<LocationData> gpsCheck() async {
    try {
      Location templocation = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData locationData;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        logger.i("requesting location");

        if (!_serviceEnabled) {
          return null;
        } else {
          locationData = await templocation.getLocation();
          if (locationData != null) {
            return locationData;
          }
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        logger.i("requesting location");
        if (_permissionGranted != PermissionStatus.granted) {
          return null;
        } else {
          locationData = await templocation.getLocation();
          if (locationData != null) {
            return locationData;
          }
        }
      } else {
        locationData = await templocation.getLocation();
        if (locationData != null) {
          return locationData;
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        logger.e(e);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        logger.e(e);
      }
    }
    return null;
  }
}
