import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

GeoFirePoint? getLocation(Map<String, dynamic> map) {
  try {
    final locationData = map['location'];
    if (locationData == null) return null;
    if (locationData is GeoFirePoint) {
      return locationData;
    }

    double? latitude;
    double? longitude;

    if (locationData is Map<String, dynamic>) {
      final dynamic geoPointData = locationData['geopoint'];
      if (geoPointData is GeoPoint) {
        latitude = geoPointData.latitude;
        longitude = geoPointData.longitude;
      } else if (geoPointData is Map<String, dynamic>) {
        latitude =
            _parseDouble(geoPointData['_latitude'] ?? geoPointData['latitude']);
        longitude = _parseDouble(
            geoPointData['_longitude'] ?? geoPointData['longitude']);
      }

      if (latitude == null || longitude == null) {
        latitude =
            _parseDouble(locationData['latitude'] ?? locationData['lat']);
        longitude =
            _parseDouble(locationData['longitude'] ?? locationData['lng']);
      }
    } else if (locationData is GeoPoint) {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    }

    if (latitude != null && longitude != null) {
      return GeoFirePoint(GeoPoint(latitude, longitude));
    }

    logger.d("Unexpected location format: ${locationData.runtimeType}");
    return null;
  } catch (e, stackTrace) {
    logger.d("GeoPoint conversion error", error: e, stackTrace: stackTrace);
    return null;
  }
}
