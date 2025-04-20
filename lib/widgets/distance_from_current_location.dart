import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';

import '../l10n/l10n.dart';
import 'package:geolocator/geolocator.dart';

class DistanceFromCurrentLocation extends StatelessWidget {
  final GeoPoint coordinates;
  final GeoPoint? currentLocation;
  final bool isKm;
  final TextStyle textStyle;

  DistanceFromCurrentLocation({
    Key? key,
    required this.coordinates,
    required this.currentLocation,
    required this.isKm,
    TextStyle? textStyle,
  }) : textStyle = textStyle ?? TextStyle(color: Colors.grey[800]);

  String miles(double km) {
    return (km / 1.609344).toStringAsFixed(2);
  }

  String distanceConvertorForKm(double distance) {
    if (distance < 1) {
      return "${(distance * 1000).toInt()} m";
    } else {
      return "${distance.toStringAsFixed(distance < 10 ? 1 : 0)} km";
    }
  }

  double findDistanceBetweenToLocation(
    GeoPoint coordinates,
    GeoPoint? currentLocationCoordinates,
  ) {
    if (currentLocationCoordinates == null) {
      return 0;
    }
    return Geolocator.distanceBetween(
      coordinates.latitude,
      coordinates.longitude,
      currentLocationCoordinates.latitude,
      currentLocationCoordinates.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final distance =
        findDistanceBetweenToLocation(coordinates, currentLocation);

    if (currentLocation == null || distance <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: isKm
              ? Text(
                  distanceConvertorForKm(distance),
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                )
              : Text(
                  '${miles(distance)} ${S.of(context).miles}',
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
        ),
      ),
    );
  }
}
