// To parse this JSON data, do
//
//     final latLngFromZipCode = latLngFromZipCodeFromJson(jsonString);

import 'dart:convert';

LatLngFromZipCode latLngFromZipCodeFromJson(String str) =>
    LatLngFromZipCode.fromJson(json.decode(str));

String latLngFromZipCodeToJson(LatLngFromZipCode data) =>
    json.encode(data.toJson());

class LatLngFromZipCode {
  LatLngFromZipCode({
    required this.results,
    required this.status,
  });

  List<Result> results;
  String status;

  LatLngFromZipCode copyWith({
    List<Result>? results,
    String? status,
  }) =>
      LatLngFromZipCode(
        results: results ?? this.results,
        status: status ?? this.status,
      );

  factory LatLngFromZipCode.fromJson(Map<String, dynamic> json) =>
      LatLngFromZipCode(
        results: List<Result>.from((json["results"] as List<dynamic>)
            .map((x) => Result.fromJson(x as Map<String, dynamic>))),
        status: json["status"] as String,
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "status": status,
      };
}

class Result {
  Result({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    required this.types,
  });

  List<AddressComponent> addressComponents;
  String formattedAddress;
  Geometry geometry;
  String placeId;
  List<String> types;

  Result copyWith({
    List<AddressComponent>? addressComponents,
    String? formattedAddress,
    Geometry? geometry,
    String? placeId,
    List<String>? types,
  }) =>
      Result(
        addressComponents: addressComponents ?? this.addressComponents,
        formattedAddress: formattedAddress ?? this.formattedAddress,
        geometry: geometry ?? this.geometry,
        placeId: placeId ?? this.placeId,
        types: types ?? this.types,
      );

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        addressComponents: List<AddressComponent>.from(
            (json["address_components"] as List<dynamic>).map(
                (x) => AddressComponent.fromJson(x as Map<String, dynamic>))),
        formattedAddress: json["formatted_address"] as String,
        geometry: Geometry.fromJson(json["geometry"] as Map<String, dynamic>),
        placeId: json["place_id"] as String,
        types: List<String>.from(
            (json["types"] as List<dynamic>).map((x) => x as String)),
      );

  Map<String, dynamic> toJson() => {
        "address_components":
            List<dynamic>.from(addressComponents.map((x) => x.toJson())),
        "formatted_address": formattedAddress,
        "geometry": geometry.toJson(),
        "place_id": placeId,
        "types": List<dynamic>.from(types.map((x) => x)),
      };
}

class AddressComponent {
  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  String longName;
  String shortName;
  List<String> types;

  AddressComponent copyWith({
    String? longName,
    String? shortName,
    List<String>? types,
  }) =>
      AddressComponent(
        longName: longName ?? this.longName,
        shortName: shortName ?? this.shortName,
        types: types ?? this.types,
      );

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longName: json["long_name"] as String,
        shortName: json["short_name"] as String,
        types: List<String>.from(
            (json["types"] as List<dynamic>).map((x) => x as String)),
      );

  Map<String, dynamic> toJson() => {
        "long_name": longName,
        "short_name": shortName,
        "types": List<dynamic>.from(types.map((x) => x)),
      };
}

class Geometry {
  Geometry({
    required this.bounds,
    required this.location,
    required this.locationType,
    required this.viewport,
  });

  Bounds bounds;
  Location location;
  String locationType;
  Bounds viewport;

  Geometry copyWith({
    Bounds? bounds,
    Location? location,
    String? locationType,
    Bounds? viewport,
  }) =>
      Geometry(
        bounds: bounds ?? this.bounds,
        location: location ?? this.location,
        locationType: locationType ?? this.locationType,
        viewport: viewport ?? this.viewport,
      );

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        bounds: Bounds.fromJson(json["bounds"] as Map<String, dynamic>),
        location: Location.fromJson(json["location"] as Map<String, dynamic>),
        locationType: json["location_type"] as String,
        viewport: Bounds.fromJson(json["viewport"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "bounds": bounds.toJson(),
        "location": location.toJson(),
        "location_type": locationType,
        "viewport": viewport.toJson(),
      };
}

class Bounds {
  Bounds({
    required this.northeast,
    required this.southwest,
  });

  Location northeast;
  Location southwest;

  Bounds copyWith({
    Location? northeast,
    Location? southwest,
  }) =>
      Bounds(
        northeast: northeast ?? this.northeast,
        southwest: southwest ?? this.southwest,
      );

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
        northeast: Location.fromJson(json["northeast"] as Map<String, dynamic>),
        southwest: Location.fromJson(json["southwest"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "northeast": northeast.toJson(),
        "southwest": southwest.toJson(),
      };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  Location copyWith({
    double? lat,
    double? lng,
  }) =>
      Location(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: (json["lat"] as num).toDouble(),
        lng: (json["lng"] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}
