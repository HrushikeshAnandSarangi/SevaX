import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/models.dart';

class RequestModel extends DataModel {
  String id;
  String title;
  String description;
  String email;
  String fullName;
  String sevaUserId;
  String photoUrl;
  List<String> acceptors;
  int durationOfRequest;
  int postTimestamp;
  int requestEnd;
  int requestStart;
  bool accepted;
  String rejectedReason;
  List<TransactionModel> transactions;
  String timebankId;
  int numberOfApprovals;
  List<String> approvedUsers;
  List<String> invitedUsers;
  GeoFirePoint location;
  String root_timebank_id;
  Color color;
  bool isNotified = false;

  RequestMode requestMode;

  RequestModel({
    this.id,
    this.title,
    this.description,
    this.durationOfRequest,
    this.email,
    this.fullName,
    this.sevaUserId,
    this.photoUrl,
    this.accepted,
    this.postTimestamp,
    this.requestEnd,
    this.requestStart,
    this.acceptors,
    this.color,
    this.transactions,
    this.rejectedReason,
    this.timebankId,
    this.approvedUsers = const [],
    this.invitedUsers,
    this.numberOfApprovals = 1,
    this.location,
    this.root_timebank_id,
  });

  RequestModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('requestMode')) {
      if (map['requestMode'] == "PERSONAL_REQUEST") {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      } else if (map['requestMode'] == "TIMEBANK_REQUEST") {
        this.requestMode = RequestMode.TIMEBANK_REQUEST;
      } else {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      }
    } else {
      this.requestMode = RequestMode.PERSONAL_REQUEST;
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
    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }
    if (map.containsKey('requestorphotourl')) {
      this.photoUrl = map['requestorphotourl'];
    }
    if (map.containsKey('acceptors')) {
      List<String> acceptorList = List.castFrom(map['acceptors']);
      this.acceptors = acceptorList;
    } else {
      this.acceptors = [];
    }
    if (map.containsKey('invitedUsers')) {
      List<String> invitedUsersList = List.castFrom(map['invitedUsers']);
      this.invitedUsers = invitedUsersList;
    } else {
      this.invitedUsers = [];
    }
    if (map.containsKey('durationofrequest')) {
      this.durationOfRequest = map['durationofrequest'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('request_end')) {
      this.requestEnd = map['request_end'];
    }
    if (map.containsKey('request_start')) {
      this.requestStart = map['request_start'];
    }
    if (map.containsKey('accepted')) {
      this.accepted = map['accepted'];
    }

    if (map.containsKey('isNotified')) {
      this.isNotified = map['isNotified'];
    }

    if (map.containsKey('transactions')) {
      List<TransactionModel> transactionList = [];
      List transactionDataList = List.castFrom(map['transactions']);

      transactionList = transactionDataList.map<TransactionModel>((data) {
        Map<String, dynamic> transactionmap = Map.castFrom(data);
        return TransactionModel.fromMap(transactionmap);
      }).toList();

      this.transactions = transactionList;
    }
    if (map.containsKey('rejectedReason')) {
      this.rejectedReason = map['rejectedReason'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('approvedUsers')) {
      List<String> approvedUserList = List.castFrom(map['approvedUsers']);
      this.approvedUsers = approvedUserList;
    }
    if (map.containsKey('numberOfApprovals')) {
      this.numberOfApprovals = map['numberOfApprovals'];
    }
    if (map.containsKey('location')) {
      GeoPoint geoPoint = map['location']['geopoint'];

      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    }
  }

  RequestModel.fromMapElasticSearch(Map<String, dynamic> map) {
    if (map.containsKey('requestMode')) {
      if (map['requestMode'] == "PERSONAL_REQUEST") {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      } else if (map['requestMode'] == "TIMEBANK_REQUEST") {
        this.requestMode = RequestMode.TIMEBANK_REQUEST;
      } else {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      }
    } else {
      this.requestMode = RequestMode.PERSONAL_REQUEST;
    }

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
    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }
    if (map.containsKey('requestorphotourl')) {
      this.photoUrl = map['requestorphotourl'];
    }
    if (map.containsKey('acceptors')) {
      List<String> acceptorList = List.castFrom(map['acceptors']);
      this.acceptors = acceptorList;
    }
    if (map.containsKey('invitedUsers')) {
      List<String> invitedUsersList = List.castFrom(map['invitedUsers']);
      this.invitedUsers = invitedUsersList;
    }
    if (map.containsKey('durationofrequest')) {
      this.durationOfRequest = map['durationofrequest'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('request_end')) {
      this.requestEnd = map['request_end'];
    }
    if (map.containsKey('request_start')) {
      this.requestStart = map['request_start'];
    }
    if (map.containsKey('accepted')) {
      this.accepted = map['accepted'];
    }

    if (map.containsKey('isNotified')) {
      this.isNotified = map['isNotified'];
    }

    if (map.containsKey('transactions')) {
      List<TransactionModel> transactionList = [];
      List transactionDataList = List.castFrom(map['transactions']);

      transactionList = transactionDataList.map<TransactionModel>((data) {
        Map<String, dynamic> transactionmap = Map.castFrom(data);
        return TransactionModel.fromMap(transactionmap);
      }).toList();

      this.transactions = transactionList;
    }
    if (map.containsKey('rejectedReason')) {
      this.rejectedReason = map['rejectedReason'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('approvedUsers')) {
      List<String> approvedUserList = List.castFrom(map['approvedUsers']);
      this.approvedUsers = approvedUserList;
    }
    if (map.containsKey('numberOfApprovals')) {
      this.numberOfApprovals = map['numberOfApprovals'];
    }
    if (map.containsKey('location')) {
      GeoPoint geoPoint = GeoPoint(map['location']['geopoint']['_latitude'],
          map['location']['geopoint']['_longitude']);

      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (requestMode != null) {
      switch (requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          object['requestMode'] = "PERSONAL_REQUEST";
          break;

        case RequestMode.TIMEBANK_REQUEST:
          object['requestMode'] = "TIMEBANK_REQUEST";
          break;
      }
    } else {
      object['requestMode'] = "PERSONAL_REQUEST";
    }

    if (this.title != null && this.title.isNotEmpty) {
      object['title'] = this.title;
    }
    if (this.root_timebank_id != null && this.root_timebank_id.isNotEmpty) {
      object['root_timebank_id'] = this.root_timebank_id;
    }
    if (this.description != null && this.description.isNotEmpty) {
      object['description'] = this.description;
    }
    if (this.email != null && this.email.isNotEmpty) {
      object['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      object['fullname'] = this.fullName;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      object['sevauserid'] = this.sevaUserId;
    }
    if (this.photoUrl != null && this.photoUrl.isNotEmpty) {
      object['requestorphotourl'] = this.photoUrl;
    }
    if (this.acceptors != null) {
      object['acceptors'] = this.acceptors;
    }
    if (this.invitedUsers != null) {
      object['invitedUsers'] = this.invitedUsers;
    }
    if (this.durationOfRequest != null) {
      object['durationofrequest'] = this.durationOfRequest;
    }
    if (this.postTimestamp != null) {
      object['posttimestamp'] = this.postTimestamp;
    }
    if (this.requestEnd != null) {
      object['request_end'] = this.requestEnd;
    }
    if (this.requestStart != null) {
      object['request_start'] = this.requestStart;
    }
    if (this.accepted != null) {
      object['accepted'] = this.accepted;
    }

    if (this.isNotified != null) {
      object['isNotified'] = this.isNotified;
    }

    if (this.transactions != null) {
      List<Map<String, dynamic>> transactionList =
          this.transactions.map<Map<String, dynamic>>((map) {
        return map.toMap();
      }).toList();
      object['transactions'] = transactionList;
    }
    if (this.rejectedReason != null && this.rejectedReason.isNotEmpty) {
      object['rejectedReason'] = this.rejectedReason;
    }
    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.approvedUsers != null) {
      object['approvedUsers'] = this.approvedUsers;
    }
    if (this.numberOfApprovals != null) {
      object['numberOfApprovals'] = this.numberOfApprovals;
    }
    if (this.location != null) {
      object['location'] = this.location.data;
    }
    if (this.id != null) {
      object['id'] = this.id;
    }
    return object;
  }

  @override
  String toString() {
    return 'RequestModel{id: $id, title: $title, description: $description, email: $email, fullName: $fullName, sevaUserId: $sevaUserId, photoUrl: $photoUrl, acceptors: $acceptors, durationOfRequest: $durationOfRequest, postTimestamp: $postTimestamp, requestEnd: $requestEnd, requestStart: $requestStart, accepted: $accepted, rejectedReason: $rejectedReason, transactions: $transactions, timebankId: $timebankId, numberOfApprovals: $numberOfApprovals, approvedUsers: $approvedUsers, invitedUsers: $invitedUsers, location: $location, root_timebank_id: $root_timebank_id, color: $color, isNotified: $isNotified}';
  }
}

enum RequestMode {
  PERSONAL_REQUEST,
  TIMEBANK_REQUEST,
}
