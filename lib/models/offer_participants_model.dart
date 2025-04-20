import 'dart:convert';

import 'package:flutter/material.dart';

OfferParticipantsModel offerParticipantsModelFromJson(String str) =>
    OfferParticipantsModel.fromJson(json.decode(str));

class OfferParticipantsModel {
  String? id;
  ClassDetails? classDetails;
  String? timebankId;
  String? offerId;
  ParticipantDetails? participantDetails;
  String? communityId;
  String? status;
  int? timestamp;

  OfferParticipantsModel({
    this.classDetails,
    this.timebankId,
    this.offerId,
    this.participantDetails,
    this.communityId,
    this.status,
    this.timestamp,
  });

  factory OfferParticipantsModel.fromJson(Map<String, dynamic> json) =>
      OfferParticipantsModel(
        classDetails: ClassDetails.fromJson(
            Map<String, dynamic>.from(json["classDetails"])),
        timebankId: json["timebankId"],
        offerId: json["offerId"],
        participantDetails: ParticipantDetails.fromJson(
            Map<String, dynamic>.from(json["participantDetails"])),
        communityId: json["communityId"],
        status: json["status"],
        timestamp: json["timestamp"],
      );
}

class ClassDetails {
  String? classTitle;
  int? numberOfClassHours;
  String? classHost;
  int? numberOfPreperationHours;
  String? sevauserid;
  String? email;
  String? classDescription;

  ClassDetails({
    this.classTitle,
    this.numberOfClassHours,
    this.classHost,
    this.numberOfPreperationHours,
    this.sevauserid,
    this.email,
    this.classDescription,
  });

  factory ClassDetails.fromJson(Map<String, dynamic> json) => ClassDetails(
        classTitle: json["classTitle"],
        numberOfClassHours: json["numberOfClassHours"],
        classHost: json["classHost"],
        numberOfPreperationHours: json["numberOfPreperationHours"],
        sevauserid: json["sevauserid"],
        email: json["email"],
        classDescription: json["classDescription"],
      );
}

class ParticipantDetails {
  String? photourl;
  String? bio;
  String? fullname;
  String? sevauserid;
  String? email;

  ParticipantDetails({
    this.photourl,
    this.bio,
    this.fullname,
    this.sevauserid,
    this.email,
  });

  factory ParticipantDetails.fromJson(Map<String, dynamic> json) =>
      ParticipantDetails(
        photourl: json["photourl"],
        bio: json["bio"],
        fullname: json["fullname"],
        sevauserid: json["sevauserid"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        'photourl': photourl,
        'bio': bio,
        'fullname': fullname,
        'sevauserid': sevauserid,
        'email': email,
      };
}

enum ParticipantStatus {
  NO_ACTION_FROM_CREATOR, //
  CREATOR_REQUESTED_CREDITS, //requested
  MEMBER_APPROVED_CREDIT_REQUEST, //approved credits
  MEMBER_REJECTED_CREDIT_REQUEST, //rejected
  MEMBER_TRANSACTION_SUCCESSFUL, //credited
  MEMBER_TRANSACTION_FAILED, //failed
  MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER, //Signuped
  MEMBER_DID_NOT_ATTEND, //
}

String getParticipantStatus(ParticipantStatus status) {
  switch (status) {
    case ParticipantStatus.MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER:
      return "SIGNED UP";
      break;
    case ParticipantStatus.CREATOR_REQUESTED_CREDITS:
      return 'REQUESTED';
      break;
    case ParticipantStatus.MEMBER_APPROVED_CREDIT_REQUEST:
      return 'APPROVED';
      break;
    case ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST:
      return 'REJECTED';
      break;
    case ParticipantStatus.MEMBER_TRANSACTION_SUCCESSFUL:
      return 'CREDITED';
      break;
    case ParticipantStatus.MEMBER_TRANSACTION_FAILED:
      return 'FAILED';
      break;
    case ParticipantStatus.MEMBER_DID_NOT_ATTEND:
      return 'NOT ATTENDED';
      break;
    case ParticipantStatus.NO_ACTION_FROM_CREATOR:
      return 'REQUEST';
      break;
    default:
      return "ERROR";
      break;
  }
}

Color getStatusColor(ParticipantStatus status) {
  if ([
    ParticipantStatus.MEMBER_APPROVED_CREDIT_REQUEST,
    ParticipantStatus.MEMBER_TRANSACTION_SUCCESSFUL,
    ParticipantStatus.NO_ACTION_FROM_CREATOR
  ].contains(status)) {
    return Colors.green;
  }
  if ([
    ParticipantStatus.MEMBER_DID_NOT_ATTEND,
    ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST,
    ParticipantStatus.MEMBER_TRANSACTION_FAILED,
  ].contains(status)) {
    return Colors.red;
  } else {
    return Colors.grey;
    //Use a default color
  }
}
