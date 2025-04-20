import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

class LocationUtility {
  Future<String?> getFormattedAddress(double latitude, double longitude) async {
    try {
      final placemarkList = await placemarkFromCoordinates(latitude, longitude);
      if (placemarkList.isNotEmpty) {
        final placemark = placemarkList.first;
        return _getAddress(placemark);
      }
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_GEOCODING_INVALID_COORDINATES') {
        log('getFormattedAddress: ${error.message}');
      }
      return null;
    } catch (e) {
      log('Error getting address: $e');
      return null;
    }
  }

  String _getAddress(Placemark placemark) {
    final addressComponents = <String>[];

    void addComponent(String? component) {
      if (component != null && component.isNotEmpty) {
        addressComponents.add(component);
      }
    }

    addComponent(placemark.name);
    addComponent(placemark.locality);
    addComponent(placemark.administrativeArea);

    return addressComponents.join(', ');
  }
}
