import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/models/data_model.dart';

class NotificationsModel extends DataModel {
  String id;
  NotificationType type;
  Map<String, dynamic> data;
  String targetUserId;
  String senderUserId;
  bool isRead;
  String timebankId;
  String communityId;
  bool directToMember;

  NotificationsModel({
    this.id,
    this.type,
    this.data,
    this.targetUserId,
    this.isRead = false,
    this.senderUserId,
    @required this.timebankId,
    @required this.communityId,
    this.directToMember = true,
  });

  NotificationsModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
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

    if (map.containsKey('type')) {
      String typeString = map['type'];
      if (typeString == 'RequestAccept') {
        this.type = NotificationType.RequestAccept;
      }

      if (typeString == 'JoinRequest') {
        this.type = NotificationType.JoinRequest;
      }

      if (typeString == 'RequestApprove') {
        this.type = NotificationType.RequestApprove;
      }
      if (typeString == 'RequestReject') {
        this.type = NotificationType.RequestReject;
      }
      if (typeString == 'RequestCompleted') {
        this.type = NotificationType.RequestCompleted;
      }
      if (typeString == 'RequestCompletedApproved') {
        this.type = NotificationType.RequestCompletedApproved;
      }
      if (typeString == 'RequestCompletedRejected') {
        this.type = NotificationType.RequestCompletedRejected;
      }
      if (typeString == 'TransactionCredit') {
        this.type = NotificationType.TransactionCredit;
      }
      if (typeString == 'TransactionDebit') {
        this.type = NotificationType.TransactionDebit;
      }
      if (typeString == 'OfferAccept') {
        this.type = NotificationType.OfferAccept;
      }
      if (typeString == 'OfferReject') {
        this.type = NotificationType.OfferReject;
      }

      if (typeString == 'AcceptedOffer') {
        this.type = NotificationType.AcceptedOffer;
      }

      if (typeString == 'RequestInvite') {
        this.type = NotificationType.RequestInvite;
      }
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
  }

  @override
  String toString() {
    // TODO: implement toString
    return "${this.type} -- ${this.isRead} -- ";
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
  AcceptedOffer
}
