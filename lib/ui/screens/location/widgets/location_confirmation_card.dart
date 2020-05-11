import 'package:flutter/material.dart';
import 'package:sevaexchange/models/location_model.dart';

class LocationConfimationCard extends StatelessWidget {
  final LocationDataModel locationDataModel;

  const LocationConfimationCard({Key key, this.locationDataModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bool isReverseGeoEncoded = locationDataModel.location.contains('*');

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
                    isReverseGeoEncoded
                        ? locationDataModel.location.split('*')[0]
                        : locationDataModel.location.contains(',')
                            ? locationDataModel.location.split(',')[0]
                            : locationDataModel.location,
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
                  isReverseGeoEncoded
                      ? locationDataModel.location.split('*')[1] ?? ''
                      : locationDataModel.location,
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
                    Navigator.pop(
                      context,
                      locationDataModel,
                    );
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
