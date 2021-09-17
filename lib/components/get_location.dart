import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/location_model.dart';

final searchScaffoldKey = GlobalKey<ScaffoldState>();
final kGoogleApiKey = FlavorConfig.values.googleMapsKey;
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  final String hint;

  CustomSearchScaffold(this.hint)
      : super(
          hint: hint,
          apiKey: kGoogleApiKey,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [],
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) => value.toRadixString(16).padLeft(count, '0');
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  String locationText;
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      // backgroundColor: Colors.white,
      title: AppBarPlacesAutoCompleteTextField(),
    );
    final body = PlacesAutocompleteResult(
      onTap: (p) async {
        await displayPrediction(p);
      },
      // logo: Row(
      //   children: [FlutterLogo()],
      //   mainAxisAlignment: MainAxisAlignment.center,
      // ),
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId, fields: ["geometry"]);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      LocationDataModel data = LocationDataModel(
        p.description,
        lat,
        lng,
      );
      Navigator.pop(context, data);
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
      //ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Got answer")),
      // );
    }
  }
}
