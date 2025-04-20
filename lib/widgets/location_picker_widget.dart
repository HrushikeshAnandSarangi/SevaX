import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerWidget extends StatelessWidget {
  final ValueChanged<LocationDataModel> onChanged;
  final String selectedAddress;
  final GeoFirePoint? location;
  final Color color;

  const LocationPickerWidget({
    Key? key,
    required this.onChanged,
    required this.selectedAddress,
    this.location,
    this.color = Colors.green,
  });
  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      textColor: Colors.black54,
      child: Container(
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width - 140, 50),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: Colors.black,
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Text(
                selectedAddress == '' || selectedAddress == null
                    ? S.of(context).add_location
                    : selectedAddress,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Europa',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      elevation: 0.0,
      shape: StadiumBorder(),
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      color: Colors.grey[200]!,
      onPressed: () async {
        logger.d(
            "$location retrieved from onTap=================================");

        await Navigator.push(
          context,
          MaterialPageRoute<LocationDataModel>(
            builder: (context) => LocationPicker(
              selectedLocation: location!,
              selectedAddress: selectedAddress,
              defaultLocation: location != null
                  ? LatLng(location!.latitude, location!.longitude)
                  : LatLng(13.0827, 80.2707), // Default to Chennai coordinates
            ),
          ),
        ).then((LocationDataModel? dataModel) {
          if (dataModel != null) {
            onChanged(dataModel);
          }
        });
      },
    );
  }
}
