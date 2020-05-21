import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';

class LocationPickerWidget extends StatelessWidget {
  final ValueChanged<LocationDataModel> onChanged;
  final String selectedAddress;
  final GeoFirePoint location;
  final Color color;

  const LocationPickerWidget(
      {Key key,
      this.onChanged,
      this.selectedAddress,
      this.location,
      this.color = Colors.green})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      icon: Icon(Icons.add_location),
      textColor: color,
      label: Container(
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width - 140, 50),
        ),
        child: Text(
          selectedAddress == '' || selectedAddress == null
              ? AppLocalizations.of(context).translate('shared','add_location')
              : selectedAddress,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      color: Colors.grey[200],
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<LocationDataModel>(
            builder: (context) => LocationPicker(
              selectedLocation: location,
              selectedAddress: selectedAddress,
            ),
          ),
        ).then((dataModel) {
          if (dataModel != null) {
            onChanged(dataModel);
          }
        });
      },
    );
  }
}
