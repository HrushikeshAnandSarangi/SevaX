// To parse this JSON data, do
//
//     final lendingPlaceModel = lendingPlaceModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class LendingPlaceModel {
  LendingPlaceModel({
    @required this.placeName,
    @required this.noOfGuests,
    @required this.noOfRooms,
    @required this.noOfBathRooms,
    @required this.commonSpace,
    @required this.houseRules,
    @required this.houseImages,
    @required this.creatorId,
    @required this.email,
    @required this.timestamp,
    @required this.amenities,
  });

  String placeName;
  int noOfGuests;
  int noOfRooms;
  int noOfBathRooms;
  String commonSpace;
  String houseRules;
  List<dynamic> houseImages;
  String creatorId;
  String email;
  int timestamp;
  Map<String, String> amenities;

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
                  : List<dynamic>.from(json["house_images"].map((x) => x)),
          creatorId: json["creatorId"] == null ? null : json["creatorId"],
          email: json["email"] == null ? null : json["email"],
          timestamp: json["timestamp"] == null ? null : json["timestamp"],
          amenities: json["amenities"] == null
              ? {}
              : Map<String, String>.from(json["amenities"] ?? {}) ?? {});

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
        "creatorId": creatorId == null ? null : creatorId,
        "email": email == null ? null : email,
        "timestamp": timestamp == null ? null : timestamp,
        "amenities": amenities == null ? null : amenities,
      };
}
