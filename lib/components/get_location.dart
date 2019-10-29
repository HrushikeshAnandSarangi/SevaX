import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:sevaexchange/models/location_model.dart';

final searchScaffoldKey = GlobalKey<ScaffoldState>();
const kGoogleApiKey = "AIzaSyCfJs1RFK22W-KvpPWkTmJ3lhrGEKoJ-Gc";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class CustomSearchScaffold1 extends PlacesAutocompleteWidget {
  CustomSearchScaffold1()
      : super(
    apiKey: kGoogleApiKey,
    sessionToken: Uuid1().generateV4(),
    language: "en",
    components: [],
  );

  @override
  _CustomSearchScaffoldState1 createState() => _CustomSearchScaffoldState1();
}

class Uuid1 {
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

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

class _CustomSearchScaffoldState1 extends PlacesAutocompleteState {
  String locationText;
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, searchScaffoldKey.currentState);
      },
//      logo: Row(
//        children: [FlutterLogo()],
//        mainAxisAlignment: MainAxisAlignment.center,
//      ),
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      print(p.description);
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      LocationDataModel data = LocationDataModel(
          p.description,
          lat,
          lng,
      );
      Navigator.pop(context, data);
      scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    print(response);
    if (response != null && response.predictions.isNotEmpty) {
      // searchScaffoldKey.currentState.showSnackBar(
      //   SnackBar(content: Text("Got answer")),
      // );
    }
  }
}
