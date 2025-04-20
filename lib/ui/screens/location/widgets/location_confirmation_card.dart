import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';

class LocationConfimationCard extends StatelessWidget {
  final LocationDataModel locationDataModel;

  const LocationConfimationCard({Key? key, required this.locationDataModel})
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
                  Expanded(
                    child: Text(
                      isReverseGeoEncoded
                          ? locationDataModel.location.split('*')[0]
                          : locationDataModel.location.contains(',')
                              ? locationDataModel.location.split(',')[0]
                              : locationDataModel.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                child: CustomElevatedButton(
                  color: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  elevation: 2.0,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    S.of(context).confirm_location.toUpperCase(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    LocationDataModel locData = locationDataModel;

                    if (locData.lat == null || locData.lng == null) {
                      await CustomDialogs.generalDialogWithCloseButton(
                        context,
                        'Please select a valid location.',
                      );
                      return;
                    }

                    if (locData.location.contains("*")) {
                      locData.location =
                          locationDataModel.location.split('*')[1];
                    }

                    log(locationDataModel.location);

                    Navigator.pop(
                      context,
                      locData,
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
