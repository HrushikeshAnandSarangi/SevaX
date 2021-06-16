import 'dart:async';
import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart' as prefix;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/ui/screens/location/widgets/location_confirmation_card.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import 'get_location.dart';

extension StringExtension on String {
  String get notNullLocation {
    return this != '' ? ',' + this : '';
  }
}

class LocationPicker extends StatefulWidget {
  final GeoFirePoint selectedLocation;
  final String selectedAddress;
  // final prefix.Location location = new prefix.Location();
  final Geoflutterfire geo = Geoflutterfire();
  final Firestore firestore = Firestore.instance;
  final LatLng defaultLocation;
  static const int CAMERA_STATE_UNCHANGED = 0;
  static const int CAMERA_MOVED = 1;

  LocationPicker({
    this.defaultLocation,
    this.selectedLocation,
    this.selectedAddress,
  });
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController _mapController;
  LatLng target;
  Set<Marker> markers = {};

  int currentCameraState = LocationPicker.CAMERA_STATE_UNCHANGED;
  // final Geolocator geolocator = Geolocator();
  Location locationData;
  String address;
  // CameraPosition cameraPosition;
  LatLng defaultLatLng = LatLng(41.678510, -87.494080);
  LocationDataModel locationDataFromSearch = LocationDataModel(
    null,
    null,
    null,
  );
  CameraPosition get initialCameraPosition {
    return CameraPosition(
      target: defaultLatLng,
      zoom: 15,
    );
  }

  // loadCameraPosition() async {
  //   Position position = await Geolocator().getLastKnownPosition();
  //   cameraPosition = CameraPosition(
  //       target: LatLng(position.latitude, position.longitude), zoom: 15);
  // }
  @override
  void initState() {
    super.initState();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => () => {
            address = widget.selectedAddress != null
                ? widget.selectedAddress
                : S.of(context).fetching_location,
            _addMarker(latLng: defaultLatLng, readAbleAddress: address)
          });
    }
    if (widget.selectedLocation != null) {
      locationDataFromSearch = LocationDataModel(
        widget.selectedAddress,
        widget.selectedLocation.latitude,
        widget.selectedLocation.longitude,
      );
    }
    locationDataFromSearch.location = null;

    log('init state called for ${this.runtimeType.toString()}');
    // loadCameraPosition();
    loadInitialLocation();
  }

//  GeoFirePoint point(markers) {
//    if (markers == null || markers.isEmpty) return null;
//    Marker marker = markers.first;
//    if (marker.position == null) return null;
//    return widget.geo.point(
//      latitude: marker.position.latitude,
//      longitude: marker.position.longitude,
//    );
//  }

  Future<void> loadInitialAddress(
      marker, context, String readAbleAddress) async {
    // logger.d(readAbleAddress + "========================>>>>>>>>>>");

    address = readAbleAddress == null
        ? await _getAddressFromLatLng(target, context)
        : readAbleAddress;

    logger.d(address + "<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    setState(() {
      // address;
      markers = {marker};
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.selectedLocation != null) {
      if (target == null) {
        target = LatLng(
          widget.selectedLocation.latitude,
          widget.selectedLocation.longitude,
        );
        _addMarker(readAbleAddress: null);
      }
    }
  }

  int onSearchResult = 0;
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        // backgroundColor: Colors.white,
        title: Text(
          S.of(context).add_location,
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () async {
              // LocationDataModel dataModel = LocationDataModel("", null, null);
              LocationDataModel model = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CustomSearchScaffold(
                    S.of(context).search,
                  ),
                  fullscreenDialog: true,
                ),
              );
              logger.i("Data from search => " + model.location);

              if (model?.lat != null && model?.lng != null) {
                locationDataFromSearch = model;
                onSearchResult = 1;
                target = LatLng(
                    locationDataFromSearch.lat, locationDataFromSearch.lng);
                _addMarker(latLng: target, readAbleAddress: model.location);
                var temp = point;
                if (locationDataFromSearch.lat != null &&
                    locationDataFromSearch.lng != null &&
                    temp != null) {
                  if (point.distance(
                          lat: locationDataFromSearch.lat,
                          lng: locationDataFromSearch.lng) >
                      0.005) {
                    locationDataFromSearch.location = null;
                  }
                }
                animateToLocation(
                  model.location,
                  _mapController,
                  location: target,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(children: [
        Padding(
          padding: EdgeInsets.only(bottom: 150.0),
          child: Stack(
            children: <Widget>[
              mapWidget,
              crosshair,
            ],
          ),
        ),
        LocationConfimationCard(
            locationDataModel: LocationDataModel(
          address == null ? "" : address,
          point?.latitude,
          point?.longitude,
        )),
      ]),
    );
  }

  Future loadInitialLocation() async {
    Location locationData;
    try {
      var lastLocation = await LocationHelper.getLocation();

      lastLocation.fold((l) => throw PlatformException, (r) {
        locationData = r;
      });

      if (_mapController != null) {
        if (widget.selectedLocation != null) {
          animateToLocation(
            widget.selectedAddress,
            _mapController,
            location: LatLng(
              widget.selectedLocation.latitude,
              widget.selectedLocation.longitude,
            ),
          );
        } else {
          animateToLocation(
            null,
            _mapController,
            location: LatLng(
              locationData.latitude,
              locationData.longitude,
            ),
          );
        }
      }
      // setState(() => this.locationData = locationData);
    } on PlatformException catch (exception) {
      if (exception.code == 'PERMISSION_DENIED') {
        log('Permission Denied');
        showRequirePermissionDialog();
      }
    }
  }

  void showRequirePermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).missing_permission),
          content: Text(
              '${FlavorConfig.values.appName} requires permission to access your location.'),
          actions: <Widget>[
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              child: Text(
                S.of(context).open_settings,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                AppSettings.openAppSettings();
              },
            ),
            FlatButton(
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ].reversed.toList(),
        );
      },
      barrierDismissible: false,
    );
  }

  Positioned get mapWidget {
    return Positioned.fill(
      child: GoogleMap(
        initialCameraPosition: widget.selectedLocation != null
            ? CameraPosition(
                target: LatLng(
                  widget.selectedLocation.latitude,
                  widget.selectedLocation.longitude,
                ),
                zoom: 15,
              )
            : initialCameraPosition,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        mapType: MapType.normal,
        compassEnabled: true,
        markers: markers,
        onCameraMove: (position) {
          // logger.d("CAMERA MOVED=====================");
          currentCameraState = LocationPicker.CAMERA_MOVED;
          if (mounted)
            setState(() {
              target = position.target;
            });
        },
        onCameraIdle: () {
          if (locationDataFromSearch != null &&
              target.latitude == locationDataFromSearch.lat &&
              target.longitude == locationDataFromSearch.lng) {
            logger
                .d("Locations are equal dont do anything....++++++++++++++++");
          }

          logger.d(onSearchResult.toString() +
              " CAMERA IDLE===================== " +
              (currentCameraState == LocationPicker.CAMERA_STATE_UNCHANGED &&
                      widget.selectedAddress != null
                  ? widget.selectedAddress
                  : "null"));
          if (onSearchResult == 1) {
            onSearchResult = 0;
          } else {
            _addMarker(
                readAbleAddress: currentCameraState ==
                            LocationPicker.CAMERA_STATE_UNCHANGED &&
                        widget.selectedAddress != null
                    ? widget.selectedAddress
                    : null);
          }

          var temp = point;
          if (locationDataFromSearch.lat != null &&
              locationDataFromSearch.lng != null &&
              temp != null) {
            log(point
                .distance(
                  lat: locationDataFromSearch.lat,
                  lng: locationDataFromSearch.lng,
                )
                .toString());
            if (point.distance(
                    lat: locationDataFromSearch.lat,
                    lng: locationDataFromSearch.lng) >
                0.005) {
              locationDataFromSearch.location = null;
            }
          }
        },
      ),
    );
  }

  Positioned get crosshair {
    return Positioned.fill(
      child: Center(
        child: Icon(
          Icons.location_searching,
        ),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng latlng, context) async {
    if (latlng != null) {
      try {
        List<Placemark> p =
            await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
        Placemark place = p[0];
        String locality =
            place.subLocality != '' ? place.subLocality : place.locality;
        return "$locality*${place.name}${locality.notNullLocation}${place.subAdministrativeArea.notNullLocation}${place.administrativeArea.notNullLocation}${place.country.notNullLocation}";
      } catch (e) {
        log(e.toString());
        return S.of(context).failed_to_fetch_location;
      }
    } else {
      return address;
    }
  }

  GeoFirePoint get point {
    if (markers == null || markers.isEmpty) return null;
    Marker marker = markers.first;
    if (marker.position == null) return null;
    return widget.geo.point(
      latitude: marker.position.latitude,
      longitude: marker.position.longitude,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    if (controller == null) return;
    setState(() => _mapController = controller);
    if (this.locationData != null) {
      if (widget.selectedLocation != null) {
        animateToLocation(
          null,
          controller,
          location: LatLng(
            widget.selectedLocation.latitude ?? 41.678510,
            widget.selectedLocation.longitude ?? -87.494080,
          ),
        );
      } else {
        animateToLocation(
          null,
          controller,
          location: LatLng(locationData.latitude, locationData.longitude),
        );
      }
    }
  }

  void _addMarker({LatLng latLng, @required String readAbleAddress}) async {
    log('_addMarker ${target?.latitude} ${target?.longitude}  ${latLng?.latitude}  ${latLng?.longitude}');
    Marker marker = Marker(
      markerId: MarkerId('1'),
      position: latLng ?? target,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: S.of(context).marker,
      ),
    );
    loadInitialAddress(marker, context, readAbleAddress);
  }

  /// Animate to location corresponding to [LatLng]
  Future animateToLocation(
    String readAbleAddress,
    GoogleMapController mapController, {
    LatLng location,
  }) async {
    assert(location != null);
    CameraPosition newPosition = CameraPosition(
      target: LatLng(
        location.latitude,
        location.longitude,
      ),
      zoom: 15,
    );
    await _addMarker(latLng: location, readAbleAddress: readAbleAddress);
    Future.delayed(
        Duration(milliseconds: 100),
        () => {
              mapController
                  .animateCamera(CameraUpdate.newCameraPosition(newPosition))
            });
  }
}
