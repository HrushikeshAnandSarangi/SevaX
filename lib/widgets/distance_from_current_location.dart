import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';

class DistanceFromCurrentLocation extends StatelessWidget {
  final Coordinates coordinates;
  final bool isKm;
  const DistanceFromCurrentLocation({Key key, this.coordinates, this.isKm})
      : super(key: key);

  String miles(double km) {
    return km != null ? (km / 1.609344).toStringAsFixed(3) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: FutureBuilder<double>(
        future: findDistance(coordinates),
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          return isKm
              ? Text(
                  'Distance ${snapshot.data != null ? snapshot.data.toStringAsFixed(3) : 'Loading...'} Km')
              : Text('Distance ${miles(snapshot.data) ?? 'Loading...'} Miles*');
        },
      ),
    );
  }
}
