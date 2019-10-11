import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class LocationPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FireMap(),
    );
  }
}

class FireMap extends StatefulWidget {
  State createState() => FireMapState();
}

class FireMapState extends State<FireMap> {
  GoogleMapController mapController;
  Location location = new Location();

  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  // Stateful Data
  BehaviorSubject<double> radius = BehaviorSubject();

  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;
  LatLng target;
  Set<Marker> markers = {};
  LocationData locationData;
  GeoFirePoint point;

  @override
  void initState() {
    super.initState();
    radius.value = 100;
    location.getLocation().then((lD) {
      setState(() {
        locationData = lD;
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lD.latitude, lD.longitude),
            zoom: 15,
          ),
        ),
      );
    });
  }

  @override
  build(context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(
                    locationData != null ? locationData.latitude : 24.142,
                    locationData != null ? locationData.longitude : -110.321),
                zoom: 15),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            markers: markers,
            onCameraMove: (position) {
              setState(() {
                target = position.target;
              });
            },
          ),
        ),
        Positioned(
            bottom: 50,
            right: 30,
            child: FlatButton(
                child: Icon(Icons.pin_drop, color: Colors.white),
                color: Colors.green,
                onPressed: _addMarker)),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.location_searching,
            ),
          ),
        ),
        point != null
            ? Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Theme.of(context).accentColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, point);
                  },
                ),
              )
            : Container(),
      ]),
    );
  }

  // Map Created Lifecycle Hook
  _onMapCreated(GoogleMapController controller) {
    // _startQuery();
    setState(() {
      mapController = controller;
    });
  }

  _addMarker() {
    var marker = Marker(
        markerId: MarkerId('1'),
        position: target,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Marker'));

    setState(() {
      markers = {marker};
    });
    point = geo.point(
        latitude: marker.position.latitude,
        longitude: marker.position.longitude);
    // return firestore.collection('locations').document().setData({
    //   'position': point.data,
    //   'name': 'Yay I can be queried!'
    // });
  }

  @override
  dispose() {
    if (subscription != null) subscription.cancel();
    super.dispose();
  }
}
