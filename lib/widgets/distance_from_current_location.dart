import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';

class DistanceFromCurrentLocation extends StatelessWidget {
  final Coordinates coordinates;
  final Coordinates currentLocation;
  final bool isKm;
  final TextStyle textStyle = TextStyle(color: Colors.grey[800]);
  DistanceFromCurrentLocation(
      {Key key, this.coordinates, this.currentLocation, this.isKm})
      : super(key: key);

  String miles(double km) {
    return km != null ? (km / 1.609344).toStringAsFixed(3) : null;
  }

  @override
  Widget build(BuildContext context) {
    double distance =
        findDistanceBetweenToLocation(coordinates, currentLocation);
    return currentLocation != null && distance > 0
        ? Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Container(
              margin: EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: isKm
                    ? Text(
                        '${distance.toStringAsFixed(3)} km',
                        style: textStyle,
                      )
                    : Text(
                        '${miles(distance)} Miles',
                        style: textStyle,
                      ),
              ),
            ),
          )
        : Container();
  }
}
