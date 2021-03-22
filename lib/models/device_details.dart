import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DeviceDetails {
  DeviceDetails({
    this.deviceId,
    this.deviceType,
    this.location,
    this.timestamp,
  });

  String deviceId;
  String deviceType;
  int timestamp;
  GeoFirePoint location;

  factory DeviceDetails.fromMap(Map<String, dynamic> json) => DeviceDetails(
    deviceId: json["deviceId"] == null ? null : json["deviceId"],
    timestamp: json["timestamp"] == null ? null : json["timestamp"],
    deviceType: json["deviceType"] == null ? null : json["deviceType"],
    location:
    json["location"] == null ? null : getLocation(json["location"]),
  );

  Map<String, dynamic> toMap() => {
    "deviceId": deviceId == null ? null : deviceId,
    "deviceType": deviceType == null ? null : deviceType,
    "location": location == null ? null : location.data,
    "timestamp": timestamp == null ? null : timestamp,
  };
}

GeoFirePoint getLocation(map) {
  GeoFirePoint geoFirePoint;
  if (map.containsKey("location") &&
      map["location"] != null &&
      map['location']['geopoint'] != null) {
    if (map['location']['geopoint'] is GeoPoint) {
      GeoPoint geoPoint = map['location']['geopoint'];
      geoFirePoint = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    } else {
      geoFirePoint = GeoFirePoint(
        map["location"]["geopoint"]["_latitude"],
        map["location"]["geopoint"]["_longitude"],
      );
    }
  }
  return geoFirePoint;
}
