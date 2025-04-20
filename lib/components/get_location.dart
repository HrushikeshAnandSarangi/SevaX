import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/location_model.dart';

class CustomSearchScaffold extends StatelessWidget {
  final String hint;
  final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  CustomSearchScaffold(this.hint, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: searchScaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(hint),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showPlacesSearch(context);
            if (result != null) {
              Navigator.pop(context, _createLocationData(result));
            }
          },
          child: const Text('Search Location'),
        ),
      ),
    );
  }

  Future<PlaceDetails?> showPlacesSearch(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesSearchScreen(
          apiKey: FlavorConfig.values.googleMapsKey!,
        ),
      ),
    );
  }

  LocationDataModel _createLocationData(PlaceDetails place) {
    return LocationDataModel(
      place.name ?? '',
      place.geometry?.location.lat ?? 0.0,
      place.geometry?.location.lng ?? 0.0,
    );
  }
}

class PlacesSearchScreen extends StatefulWidget {
  final String apiKey;

  const PlacesSearchScreen({Key? key, required this.apiKey}) : super(key: key);

  @override
  State<PlacesSearchScreen> createState() => _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<PlacesSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final GoogleMapsPlaces _placesClient;
  final _uuid = Uuid();
  late String _sessionToken;
  Timer? _debounceTimer;
  List<Prediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.generateV4();
    _placesClient = GoogleMapsPlaces(apiKey: widget.apiKey);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _predictions = []);
        return;
      }

      try {
        final response = await _placesClient.autocomplete(
          query,
          sessionToken: _sessionToken,
          language: 'en',
        );
        setState(() => _predictions = response.predictions);
      } catch (_) {
        setState(() => _predictions = []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(prediction.description ?? ''),
                  onTap: () async {
                    if (prediction.placeId == null) return;

                    final details = await _placesClient.getDetailsByPlaceId(
                      prediction.placeId!,
                      sessionToken: _sessionToken,
                      fields: ['geometry', 'name'],
                    );

                    if (mounted) Navigator.pop(context, details.result);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    return '${_bits(16)}${_bits(16)}-'
        '${_bits(16)}-'
        '4${_bits(12)}-'
        '${_printVariant()}${_bits(12)}-'
        '${_bits(16)}${_bits(16)}${_bits(16)}';
  }

  String _bits(int count) =>
      _random.nextInt(1 << count).toRadixString(16).padLeft(count ~/ 4, '0');

  String _printVariant() => ['8', '9', 'a', 'b'][_random.nextInt(4)];
}
