import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

class LocationUtility {
  Future<String> getFormattedAddress(double latitude, double longitude) async {
    List<Placemark> placemarkList;
    try {
      
      placemarkList = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_GEOCODING_INVALID_COORDINATES') {
        log('getFormattedAdress: ${error.message}');
        return null;
      }
      return null;
    }
    if (placemarkList != null && placemarkList.isNotEmpty) {
      Placemark placemark = placemarkList.first;
      return _getAddress(placemark);
    }
    return null;
  }

  String _getAddress(Placemark placemark) {
    String address = '';
    if (placemark.name != null && placemark.name.isNotEmpty) {
      address += placemark.name;
    }
    if (placemark.locality != null && placemark.locality.isNotEmpty) {
      if (address.isNotEmpty) address += ', ';
      address += placemark.locality;
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea.isNotEmpty) {
      if (address.isNotEmpty) address += ', ';
      address += placemark.administrativeArea;
    }
    return address;
  }
}
