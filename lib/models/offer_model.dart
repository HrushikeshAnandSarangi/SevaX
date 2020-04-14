import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/flavor_config.dart';

import 'models.dart';

enum OfferType { INDIVIDUAL_OFFER, GROUP_OFFER }

class GroupOfferDataModel {
  String classTitle;
  int startDate;
  int endDate;
  int numberOfPreperationHours;
  int numberOfClassHours;
  String classDescription;
  List<String> signedUpMembers;

  GroupOfferDataModel();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.classTitle != null) map['classTitle'] = this.classTitle;

    if (this.startDate != null) map['startDate'] = this.startDate;

    if (this.endDate != null) map['endDate'] = this.endDate;

    if (this.numberOfPreperationHours != null)
      map['numberOfPreperationHours'] = this.numberOfPreperationHours;

    if (this.numberOfClassHours != null)
      map['numberOfClassHours'] = this.numberOfClassHours;

    if (this.classDescription != null)
      map['classDescription'] = this.classDescription;

    if (this.signedUpMembers != null)
      map['signedUpMembers'] = this.signedUpMembers;

    return map;
  }

  @override
  GroupOfferDataModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('classTitle')) {
      this.classTitle = map['classTitle'];
    }

    if (map.containsKey('startDate')) {
      this.startDate = map['startDate'];
    }

    if (map.containsKey('endDate')) {
      this.endDate = map['endDate'];
    }

    if (map.containsKey('numberOfPreperationHours')) {
      this.numberOfPreperationHours = map['numberOfPreperationHours'];
    }

    if (map.containsKey('numberOfClassHours')) {
      this.numberOfClassHours = map['numberOfClassHours'];
    }

    if (map.containsKey('classDescription')) {
      this.classDescription = map['classDescription'];
    }

    if (map.containsKey('signedUpMembers')) {
      List<String> signedUpMembers = List.castFrom(map['signedUpMembers']);
      this.signedUpMembers = signedUpMembers;
    } else {
      this.signedUpMembers = [];
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return "classTitle:$classTitle + classDescription:$classDescription + startDate:$startDate + endDate:$endDate + numberOfClassHours:$numberOfClassHours + numberOfPreperationHours:$numberOfPreperationHours";
  }
}

class IndividualOfferDataModel extends DataModel {
  String title;
  String description;
  String schedule;
  List<String> offerAcceptors;

  IndividualOfferDataModel();

  

  @override
  IndividualOfferDataModel.fromMap(Map<dynamic, dynamic> map) {

    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('schedule')) {
      this.schedule = map['schedule'];
    }

    if (map.containsKey("offerAcceptors")) {
      List<String> offerAcceptors = List.castFrom(map['offerAcceptors']);
      this.offerAcceptors = offerAcceptors;
    } else {
      this.offerAcceptors = [];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (title != null) {
      map['title'] = title;
    }

    if (description != null) {
      map['description'] = description;
    }

    if (schedule != null) {
      map['schedule'] = schedule;
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Title : $title,  Description : $description, Schedule  : $schedule";
  }
}

class OfferModel extends DataModel {
  String id;
  String email;
  String fullName;
  String sevaUserId;
  String associatedRequest;
  int timestamp;
  String timebankId;
  GeoFirePoint location;
  bool acceptedOffer = false;
  String root_timebank_id;
  OfferType offerType;
  String photoUrlImage;
  Color color;
  String selectedAdrress;

  GroupOfferDataModel groupOfferDataModel;
  IndividualOfferDataModel individualOfferDataModel;

  OfferModel({
    this.id,
    this.email,
    this.fullName,
    this.sevaUserId,
    this.associatedRequest,
    this.color,
    this.timestamp,
    this.timebankId,
    this.location,
    this.offerType,
    this.groupOfferDataModel,
    this.individualOfferDataModel,
    this.selectedAdrress,
  }) {
    this.root_timebank_id = FlavorConfig.values.timebankId;
  }

  @override
  String toString() {
    return "id = $id, email = $email, fullName : $fullName , selectedAddress : $selectedAdrress indiOffer : $individualOfferDataModel, groupOffer : $groupOfferDataModel";
  }

  OfferModel.fromMapElasticSearch(Map<String, dynamic> map) {
    if (map.containsKey('offerType')) {
      this.offerType = map['offerType'];

      if (map['offerType'] == OfferType.GROUP_OFFER.toString()) {
        this.offerType = OfferType.GROUP_OFFER;
      } else {
        this.offerType = OfferType.INDIVIDUAL_OFFER;
      }
    }

    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey("selectedAdrress")) {
      this.selectedAdrress = map['selectedAdrress'];
    }

    if (map.containsKey('offerType')) {
      this.offerType = map['offerType'];
    }

    if (map.containsKey("offerAccepted")) {
      this.acceptedOffer = map['offerAccepted'];
    }

    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }
    if (map.containsKey('associatedRequest')) {
      this.associatedRequest = map['associatedRequest'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('location')) {
      GeoPoint geoPoint = GeoPoint(map['location']['geopoint']['_latitude'],
          map['location']['geopoint']['_longitude']);
      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    }

    if (map.containsKey("individualOfferDataModel"))
      this.individualOfferDataModel =
          IndividualOfferDataModel.fromMap(map['individualOfferDataModel']);
    else
      this.individualOfferDataModel = null;

    if (map.containsKey("groupOfferDataModel"))
      this.groupOfferDataModel =
          GroupOfferDataModel.fromMap(map['groupOfferDataModel']);
    else
      this.groupOfferDataModel = null;
  }

  OfferModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('offerType')) {
      if (map['offerType'] == describeOfferType(OfferType.GROUP_OFFER)) {
        this.offerType = OfferType.GROUP_OFFER;
      } else {
        this.offerType = OfferType.INDIVIDUAL_OFFER;
      }
    }

    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey("selectedAdrress")) {
      this.selectedAdrress = map['selectedAdrress'];
    }

    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }

    if (map.containsKey('associatedRequest')) {
      this.associatedRequest = map['associatedRequest'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('location')) {
      GeoPoint geoPoint = map['location']['geopoint'];
      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    }

    if (map.containsKey("individualOfferDataModel"))
      this.individualOfferDataModel =
          IndividualOfferDataModel.fromMap(map['individualOfferDataModel']);
    else
      this.individualOfferDataModel = null;

    if (map.containsKey("groupOfferDataModel"))
      this.groupOfferDataModel =
          GroupOfferDataModel.fromMap(map['groupOfferDataModel']);
    else
      this.groupOfferDataModel = null;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    // print("+++++++++++++++++++++++ ${this.groupOfferDataModel}");
    map['groupOfferDataModel'] = this.groupOfferDataModel.toMap() ?? null;

    map['individualOfferDataModel'] =
        this.individualOfferDataModel.toMap() ?? null;

    if (this.offerType != null) {
      map['offerType'] = describeOfferType(this.offerType);
    }

    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }

    if (this.selectedAdrress != null && this.selectedAdrress.isNotEmpty) {
      map['selectedAdrress'] = this.selectedAdrress;
    }

    if (this.root_timebank_id != null && this.root_timebank_id.isNotEmpty) {
      map['root_timebank_id'] = this.root_timebank_id;
    }

    if (this.email != null && this.email.isNotEmpty) {
      map['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      map['fullName'] = this.fullName;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      map['sevaUserId'] = this.sevaUserId;
    }
    if (this.associatedRequest != null && this.associatedRequest.isNotEmpty) {
      map['assossiatedRequest'] = this.associatedRequest;
    } else {
      map['assossiatedRequest'] = null;
    }

    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }

    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }
    if (this.location != null) {
      map['location'] = this.location.data;
    }

    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }
    // if (this.title != null && this.title.isNotEmpty) {
    //   map['title'] = this.title;
    // }
    // if (this.description != null && this.description.isNotEmpty) {
    //   map['description'] = this.description;
    // }
    if (this.email != null && this.email.isNotEmpty) {
      map['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      map['fullName'] = this.fullName;
    }

    if (this.offerType != null) {
      map['offerType'] = this.offerType.toString();
    }

    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      map['sevaUserId'] = this.sevaUserId;
    }
    if (this.associatedRequest != null && this.associatedRequest.isNotEmpty) {
      map['assossiatedRequest'] = this.associatedRequest;
    } else {
      map['assossiatedRequest'] = null;
    }
    // if (this.schedule != null && this.schedule.isNotEmpty) {
    //   map['schedule'] = this.schedule;
    // }
    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }
    if (this.location != null) {
      map['location'] = this.location.data;
    }

    return map;
  }

  String describeOfferType(OfferType offerType) {
    switch (offerType) {
      case OfferType.GROUP_OFFER:
        return "GROUP_OFFER";
      case OfferType.INDIVIDUAL_OFFER:
        return "INDIVIDUAL_OFFER";
    }
  }
}
