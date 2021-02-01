// To parse this JSON data, do
//
//     final latLngFromZipCode = latLngFromZipCodeFromJson(jsonString);

import 'dart:convert';

LatLngFromZipCode latLngFromZipCodeFromJson(String str) => LatLngFromZipCode.fromJson(json.decode(str));

String latLngFromZipCodeToJson(LatLngFromZipCode data) => json.encode(data.toJson());

class LatLngFromZipCode {
  LatLngFromZipCode({
    this.results,
    this.status,
  });

  List<Result> results;
  String status;

  LatLngFromZipCode copyWith({
    List<Result> results,
    String status,
  }) =>
      LatLngFromZipCode(
        results: results ?? this.results,
        status: status ?? this.status,
      );

  factory LatLngFromZipCode.fromJson(Map<String, dynamic> json) => LatLngFromZipCode(
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "status": status,
  };
}

class Result {
  Result({
    this.addressComponents,
    this.formattedAddress,
    this.geometry,
    this.placeId,
    this.types,
  });

  List<AddressComponent> addressComponents;
  String formattedAddress;
  Geometry geometry;
  String placeId;
  List<String> types;

  Result copyWith({
    List<AddressComponent> addressComponents,
    String formattedAddress,
    Geometry geometry,
    String placeId,
    List<String> types,
  }) =>
      Result(
        addressComponents: addressComponents ?? this.addressComponents,
        formattedAddress: formattedAddress ?? this.formattedAddress,
        geometry: geometry ?? this.geometry,
        placeId: placeId ?? this.placeId,
        types: types ?? this.types,
      );

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    addressComponents: List<AddressComponent>.from(json["address_components"].map((x) => AddressComponent.fromJson(x))),
    formattedAddress: json["formatted_address"],
    geometry: Geometry.fromJson(json["geometry"]),
    placeId: json["place_id"],
    types: List<String>.from(json["types"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "address_components": List<dynamic>.from(addressComponents.map((x) => x.toJson())),
    "formatted_address": formattedAddress,
    "geometry": geometry.toJson(),
    "place_id": placeId,
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class AddressComponent {
  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  String longName;
  String shortName;
  List<String> types;

  AddressComponent copyWith({
    String longName,
    String shortName,
    List<String> types,
  }) =>
      AddressComponent(
        longName: longName ?? this.longName,
        shortName: shortName ?? this.shortName,
        types: types ?? this.types,
      );

  factory AddressComponent.fromJson(Map<String, dynamic> json) => AddressComponent(
    longName: json["long_name"],
    shortName: json["short_name"],
    types: List<String>.from(json["types"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "long_name": longName,
    "short_name": shortName,
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class Geometry {
  Geometry({
    this.bounds,
    this.location,
    this.locationType,
    this.viewport,
  });

  Bounds bounds;
  Location location;
  String locationType;
  Bounds viewport;

  Geometry copyWith({
    Bounds bounds,
    Location location,
    String locationType,
    Bounds viewport,
  }) =>
      Geometry(
        bounds: bounds ?? this.bounds,
        location: location ?? this.location,
        locationType: locationType ?? this.locationType,
        viewport: viewport ?? this.viewport,
      );

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    bounds: Bounds.fromJson(json["bounds"]),
    location: Location.fromJson(json["location"]),
    locationType: json["location_type"],
    viewport: Bounds.fromJson(json["viewport"]),
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
    this.northeast,
    this.southwest,
  });

  Location northeast;
  Location southwest;

  Bounds copyWith({
    Location northeast,
    Location southwest,
  }) =>
      Bounds(
        northeast: northeast ?? this.northeast,
        southwest: southwest ?? this.southwest,
      );

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds(
    northeast: Location.fromJson(json["northeast"]),
    southwest: Location.fromJson(json["southwest"]),
  );

  Map<String, dynamic> toJson() => {
    "northeast": northeast.toJson(),
    "southwest": southwest.toJson(),
  };
}

class Location {
  Location({
    this.lat,
    this.lng,
  });

  double lat;
  double lng;

  Location copyWith({
    double lat,
    double lng,
  }) =>
      Location(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}
