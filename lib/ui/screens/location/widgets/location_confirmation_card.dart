import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class LocationConfimationCard extends StatelessWidget {
  final String address;
  final GeoFirePoint point;

  const LocationConfimationCard({Key key, this.address, this.point})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 150,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),
              Row(
                children: <Widget>[
                  Icon(Icons.location_on),
                  Text(
                    address.split('*')[0],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  address.split('*')[1] ?? '',
                  maxLines: 2,
                ),
              ),
              Spacer(),
              Container(
                height: 50,
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CONFIRM LOCATION',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context, point);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
