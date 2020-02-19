import 'dart:async';
import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/ui/screens/location/widgets/location_confirmation_card.dart';
import 'package:sevaexchange/views/core.dart';

import 'get_location.dart';

extension StringExtension on String {
  get notNullLocation {
    return this != '' ? ',' + this : '';
  }
}

class LocationPicker extends StatefulWidget {
  final GeoFirePoint selectedLocation;
  final Location location = new Location();
  final Geoflutterfire geo = Geoflutterfire();
  final Firestore firestore = Firestore.instance;
  final LatLng defaultLocation;

  LocationPicker({
    this.defaultLocation,
    this.selectedLocation,
  });

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController _mapController;
  LatLng target;
  Set<Marker> markers = {};
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  LocationData locationData;
  String address = 'Fetching location ...*';
  CameraPosition cameraPosition;

  CameraPosition get initialCameraPosition {
    try {
      return CameraPosition(
        target: SevaCore.of(context).loggedInUser.currentPosition == null
            ? LatLng(41.678510, -87.494080)
            : LatLng(SevaCore.of(context).loggedInUser.currentPosition.latitude,
                SevaCore.of(context).loggedInUser.currentPosition.longitude),
        zoom: 15,
      );
    } catch (e) {
      return CameraPosition(target: LatLng(41.678510, -87.494080), zoom: 15);
    }
  }

  loadCameraPosition() async {
    Position position = await Geolocator().getLastKnownPosition();
    cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 15);
  }

  @override
  void initState() {
    log('init state called for ${this.runtimeType.toString()}');
    loadCameraPosition();
    super.initState();
    loadInitialLocation();
    // _mapController.
  }

  Future<void> loadInitialAddress() async {
    address = await _getAddressFromLatLng(target);
    setState(() {});
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
        _addMarker();
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        // backgroundColor: Colors.white,
        title: Text(
          'Add Location',
          style: TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () async {
              LocationDataModel dataModel = LocationDataModel("", null, null);
              dataModel = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new CustomSearchScaffold1(),
                  fullscreenDialog: true,
                ),
              );
              this.target = LatLng(dataModel.lat, dataModel.lng);
              _mapController.animateCamera(
                CameraUpdate.newCameraPosition(CameraPosition(
                  target: target,
                  zoom: 15,
                )),
              );
              setState(() {
                this._addMarker();
              });
            },
          ),
        ],
      ),
      body: Stack(children: [
        mapWidget,
        // markLocationWidget,
        crosshair,
        LocationConfimationCard(
          address: address,
          point: point,
        ),
        // button,
      ]),
    );
  }

  Future loadInitialLocation() async {
    log('loadCurrentLocation');
    LocationData locationData;
    try {
      locationData = await widget.location.getLocation();
      if (_mapController != null) {
        if (widget.selectedLocation != null) {
          animateToLocation(
            _mapController,
            location: LatLng(
              widget.selectedLocation.latitude,
              widget.selectedLocation.longitude,
            ),
          );
        } else {
          animateToLocation(
            _mapController,
            locationData: locationData,
          );
        }
      }
      setState(() => this.locationData = locationData);
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
          title: Text('Missing Permission'),
          content: Text(
              '${FlavorConfig.values.appName} requires permission to access your location.'),
          actions: <Widget>[
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              child: Text(
                'Open Settings',
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
                'Cancel',
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
                zoom: 15)
            : initialCameraPosition,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        mapType: MapType.normal,
        compassEnabled: true,
        padding: EdgeInsets.only(bottom: 150.0),
        markers: markers,
        onCameraMove: (position) {
          setState(() {
            target = position.target;
          });
        },
        onCameraIdle: () {
          _addMarker();
        },
        // onTap: (LatLng latLng) {
        //   target = latLng;
        //   _addMarker();
        //   setState(() {

        //   });
        // },
      ),
    );
  }

  // Positioned get markLocationWidget {
  //   return Positioned(
  //     bottom: 50,
  //     right: 10,
  //     left: 0,
  //     child: Center(
  //       child: RaisedButton.icon(
  //         icon: Icon(Icons.pin_drop, color: Colors.white),
  //         shape: StadiumBorder(),
  //         label: Text(
  //           'Pick Location',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         color: Color(0xff007722),
  //         onPressed:
  //             _mapController != null && target != null ? _addMarker : null,
  //       ),
  //     ),
  //   );
  // }

  Positioned get crosshair {
    return Positioned.fill(
      child: Center(
        child: Icon(
          Icons.location_searching,
        ),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng latlng) async {
    if (latlng != null) {
      try {
        List<Placemark> p = await geolocator.placemarkFromCoordinates(
            latlng.latitude, latlng.longitude);
        Placemark place = p[0];
        print(place.toJson());
        String locality =
            place.subLocality != '' ? place.subLocality : place.locality;
        return "$locality*${place.name}${locality.notNullLocation}${place.subAdministrativeArea.notNullLocation}${place.administrativeArea.notNullLocation}${place.country.notNullLocation}";
      } catch (e) {
        print(e);
        return "Failed to fetch location*";
      }
    } else {
      return address;
    }
  }

  // Positioned get button {
  //   return Positioned(
  //     bottom: -8,
  //     left: 0,
  //     right: 0,
  //     child: Offstage(
  //       offstage: point == null,
  //       child: FlatButton(
  //         // textColor: Colors.white,
  //         // color: Theme.of(context).accentColor,
  //         shape: null,
  //         color: Theme.of(context).primaryColor,
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
  //           child: Text(
  //             'Confirm',
  //             style: TextStyle(fontSize: 16),
  //           ),
  //         ),
  //         onPressed: () {
  //           Navigator.pop(context, point);
  //         },
  //       ),
  //     ),
  //   );
  // }

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
          controller,
          location: LatLng(
            widget.selectedLocation.latitude,
            widget.selectedLocation.longitude,
          ),
        );
      } else {
        animateToLocation(
          controller,
          locationData: locationData,
        );
      }
    }
  }

  void _addMarker() {
    log('_addMarker');
    print(target);
    Marker marker = Marker(
      markerId: MarkerId('1'),
      position: target,
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: 'Marker'),
    );

    setState(() {
      loadInitialAddress();
      markers = {marker};
    });
  }

  /// Animate to location corresponding to [locationData.latitude] and [locationData.longitude]
  Future animateToLocation(
    GoogleMapController mapController, {
    LocationData locationData,
    LatLng location,
  }) async {
    if (mapController == null) {
      log('map contriller is null');
      return;
    }
    if (locationData == null && widget.selectedLocation == null) {
      log('location data is null');
      return;
    }

    log('Updating camera postion');
    CameraPosition newPosition = CameraPosition(
      target: LatLng(
        locationData?.latitude ?? location.latitude,
        locationData?.longitude ?? location.longitude,
      ),
      zoom: 15,
    );

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(newPosition),
    );
  }
}
