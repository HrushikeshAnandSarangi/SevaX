import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class NotificationsModel extends DataModel {
  String id;
  NotificationType type;
  Map<String, dynamic> data;
  String targetUserId;
  String senderUserId;
  bool isRead;
  String timebankId;
  String communityId;
  int timestamp;

  NotificationsModel({
    this.id,
    this.type,
    this.data,
    this.targetUserId,
    this.isRead = false,
    this.senderUserId,
     this.timebankId,
     this.communityId,
  });

  NotificationsModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('type')) {
      this.type = typeMapper[map['type']];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey("communityId")) {
      this.communityId = map['senderUserId'];
    }

    if (map.containsKey('senderUserId')) {
      this.senderUserId = map['senderUserId'];
    }

    if (map.containsKey('data')) {
      this.data = Map.castFrom(map['data']);
    }
    if (map.containsKey('userId')) {
      this.targetUserId = map['userId'];
    }

    if (map.containsKey('isRead')) {
      this.isRead = map['isRead'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
  }

  @override
  String toString() {
    return " type : ${this.type} -- ${this.data} -- ";
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.id != null) {
      map['id'] = this.id;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }

    if (this.senderUserId != null) {
      map['senderUserId'] = this.senderUserId;
    }

    if (this.type != null) {
      map['type'] = this.type.toString().split('.').last;
    }

    if (this.data != null) {
      map['data'] = this.data;
    }

    if (this.targetUserId != null) {
      map['userId'] = this.targetUserId;
    }

    if (this.isRead != null) {
      map['isRead'] = this.isRead;
    }

    if (this.communityId != null) {
      map['communityId'] = this.communityId;
    }

    map['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    return map;
  }
}

enum NotificationType {
  RecurringRequestUpdated,
  RequestAccept,
  RequestApprove,
  RequestInvite,
  RequestReject,
  RequestCompleted,
  RequestCompletedApproved,
  RequestCompletedRejected,
  TransactionCredit,
  TransactionDebit,
  OfferAccept,
  OfferReject,
  JoinRequest,
  AcceptedOffer,
  TypeMemberExitTimebank,
  TypeMemberAdded,
  GroupJoinInvite,
  TYPE_DEBIT_FROM_OFFER,
  TYPE_CREDIT_FROM_OFFER_ON_HOLD,
  TYPE_CREDIT_FROM_OFFER_APPROVED,
  TYPE_CREDIT_FROM_OFFER,
  TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK,
  TYPE_NEW_MEMBER_SIGNUP_OFFER,
  TYPE_OFFER_FULFILMENT_ACHIEVED,
  TYPE_OFFER_SUBSCRIPTION_COMPLETED,
  TYPE_FEEDBACK_FROM_SIGNUP_MEMBER,
  TYPE_DELETION_REQUEST_OUTPUT,
  TYPE_REPORT_MEMBER,
}

//Check the method
NotificationType stringToNotificationType(String str) {
  return NotificationType.values.firstWhere(
    (v) => v.toString() == 'NotificationType.' + str.trim(),
  );
}

Map<String, NotificationType> typeMapper = {
  "RequestAccept": NotificationType.RequestAccept,
  "RequestApprove": NotificationType.RequestApprove,
  "RequestInvite": NotificationType.RequestInvite,
  "RequestReject": NotificationType.RequestReject,
  "RequestCompleted": NotificationType.RequestCompleted,
  "RequestCompletedApproved": NotificationType.RequestCompletedApproved,
  "RequestCompletedRejected": NotificationType.RequestCompletedRejected,
  "TransactionCredit": NotificationType.TransactionCredit,
  "TransactionDebit": NotificationType.TransactionDebit,
  "OfferAccept": NotificationType.OfferAccept,
  "OfferReject": NotificationType.OfferReject,
  "JoinRequest": NotificationType.JoinRequest,
  "AcceptedOffer": NotificationType.AcceptedOffer,
  "TypeMemberExitTimebank": NotificationType.TypeMemberExitTimebank,
  "TypeMemberAdded": NotificationType.TypeMemberAdded,
  "GroupJoinInvite": NotificationType.GroupJoinInvite,
  "TYPE_DEBIT_FROM_OFFER": NotificationType.TYPE_DEBIT_FROM_OFFER,
  "TYPE_CREDIT_FROM_OFFER_ON_HOLD":
      NotificationType.TYPE_CREDIT_FROM_OFFER_ON_HOLD,
  "TYPE_CREDIT_FROM_OFFER_APPROVED":
      NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED,
  "TYPE_CREDIT_FROM_OFFER": NotificationType.TYPE_CREDIT_FROM_OFFER,
  "TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK":
      NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK,
  "TYPE_NEW_MEMBER_SIGNUP_OFFER": NotificationType.TYPE_NEW_MEMBER_SIGNUP_OFFER,
  "TYPE_OFFER_FULFILMENT_ACHIEVED":
      NotificationType.TYPE_OFFER_FULFILMENT_ACHIEVED,
  "TYPE_OFFER_SUBSCRIPTION_COMPLETED":
      NotificationType.TYPE_OFFER_SUBSCRIPTION_COMPLETED,
  "TYPE_FEEDBACK_FROM_SIGNUP_MEMBER":
      NotificationType.TYPE_FEEDBACK_FROM_SIGNUP_MEMBER,
  "TYPE_REPORT_MEMBER": NotificationType.TYPE_REPORT_MEMBER,
  "TYPE_DELETION_REQUEST_OUTPUT": NotificationType.TYPE_DELETION_REQUEST_OUTPUT,
  "TYPE_REPORT_MEMBER": NotificationType.TYPE_REPORT_MEMBER,
};

ClearNotificationModel clearNotificationModelFromJson(String str) =>
    ClearNotificationModel.fromJson(json.decode(str));

class ClearNotificationModel {
  bool isClearNotificationEnabled;
  List<NotificationType> notificationType;

  ClearNotificationModel({
    this.isClearNotificationEnabled,
    this.notificationType,
  });

  factory ClearNotificationModel.fromJson(Map<String, dynamic> json) =>
      ClearNotificationModel(
        isClearNotificationEnabled: json["isClearNotificationEnabled"],
        notificationType: List<NotificationType>.from(
            json["notificationType"].map((x) => typeMapper[x])),
      );
}
