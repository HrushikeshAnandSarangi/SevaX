import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TimebankCodeModel {
  int createdOn;
  String timebankCode;
  String timebankId;
  int validUpto;
  List<String> usersOnBoarded;



  TimebankCodeModel(
      {this.createdOn, this.timebankCode, this.timebankId, this.validUpto});

  TimebankCodeModel.fromMap(Map<String, dynamic> data) {
    this.createdOn = data['createdOn'];
    this.timebankCode = data['timebankCode'];
    this.timebankId = data['timebankId'];
    this.validUpto = data['validUpto'];

    this.usersOnBoarded = data['usersOnboarded'] == null ?
      null : new List<String>.from( data['usersOnboarded'].map( (u) => u));
  }
}
