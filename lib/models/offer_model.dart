import 'models.dart';
import 'package:flutter/material.dart';

class OfferModel extends DataModel {
  String id;
  String title;
  String description;
  String schedule;
  String email;
  String fullName;
  String sevaUserId;
  String associatedRequest;
  List<String> requestList;
  int timestamp;
  String timebankId;

  Color color;

  OfferModel({
    this.id,
    this.title,
    this.description,
    this.email,
    this.fullName,
    this.sevaUserId,
    this.schedule,
    this.associatedRequest,
    this.color,
    this.requestList,
    this.timestamp,
    this.timebankId,
  });

  OfferModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('description')) {
      this.description = map['description'];
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
    if (map.containsKey('schedule')) {
      this.schedule = map['schedule'];
    }
    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
    if (map.containsKey('requestList')) {
      List<String> requests = List.castFrom(map['requestList']);
      this.requestList = requests;
    } else {
      this.requestList = [];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }
    if (this.title != null && this.title.isNotEmpty) {
      map['title'] = this.title;
    }
    if (this.description != null && this.description.isNotEmpty) {
      map['description'] = this.description;
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
    if (this.schedule != null && this.schedule.isNotEmpty) {
      map['schedule'] = this.schedule;
    }
    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }
    if (this.requestList != null) {
      map['requestList'] = this.requestList;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }

    return map;
  }
}
