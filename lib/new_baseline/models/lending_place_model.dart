// To parse this JSON data, do
//
//     final lendingPlaceModel = lendingPlaceModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class LendingPlaceModel {
  LendingPlaceModel({
    this.placeName,
    this.noOfGuests,
    this.noOfRooms,
    this.noOfBathRooms,
    this.commonSpace,
    this.houseRules,
    this.houseImages,
    this.amenities,
  });
  String placeName;
  int noOfGuests;
  int noOfRooms;
  int noOfBathRooms;
  String commonSpace;
  String houseRules;
  List<String> houseImages;
  Map<String, dynamic> amenities;

  factory LendingPlaceModel.fromJson(String str) =>
      LendingPlaceModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LendingPlaceModel.fromMap(Map<String, dynamic> json) =>
      LendingPlaceModel(
          placeName: json["placeName"] == null ? null : json["placeName"],
          noOfGuests: json["no_of_guests"] == null
              ? null
              : json["no_of_guests"],
          noOfRooms: json["no_of_rooms"] == null ? null : json["no_of_rooms"],
          noOfBathRooms: json["no_of_bathRooms"] == null
              ? null
              : json["no_of_bathRooms"],
          commonSpace: json["common_space"] ==
                  null
              ? null
              : json["common_space"],
          houseRules: json["house_rules"] == null ? null : json["house_rules"],
          houseImages:
              json["house_images"] ==
                      null
                  ? null
                  : List<String>.from(json["house_images"].map((x) => x)),
          amenities: json["amenities"] == null
              ? {}
              : Map<String, dynamic>.from(json["amenities"] ?? {}) ?? {});

  Map<String, dynamic> toMap() => {
        "placeName": placeName == null ? null : placeName,
        "no_of_guests": noOfGuests == null ? null : noOfGuests,
        "no_of_rooms": noOfRooms == null ? null : noOfRooms,
        "no_of_bathRooms": noOfBathRooms == null ? null : noOfBathRooms,
        "common_space": commonSpace == null ? null : commonSpace,
        "house_rules": houseRules == null ? null : houseRules,
        "house_images": houseImages == null
            ? null
            : List<dynamic>.from(houseImages.map((x) => x)),
        "amenities": amenities == null ? null : amenities,
      };
}
