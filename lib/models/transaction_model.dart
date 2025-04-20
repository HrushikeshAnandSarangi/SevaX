import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/utils/app_config.dart';

import 'models.dart';

class TransactionModel extends DataModel {
  String? from;
  String? fromEmail_Id;
  String? to;
  String? toEmail_Id;
  bool? liveMode;
  int? timestamp;
  num? credits;
  bool? isApproved;
  String? type;
  String? typeid;
  String? timebankid;
  List<String>? transactionbetween;
  String? communityId;
  String? offerId;

  TransactionModel(
      {this.from,
      @required this.fromEmail_Id,
      this.timestamp,
      this.credits,
      this.to,
      @required this.toEmail_Id,
      this.isApproved = false,
      this.liveMode = false,
      this.type,
      this.typeid,
      this.timebankid,
      this.transactionbetween,
      @required this.communityId,
      this.offerId});

  //local variables
  String get createdDate => DateFormat('MMMM dd')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0));

  TransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('from')) {
      this.from = map['from'];
    }
    if (map.containsKey('fromEmail_Id')) {
      this.fromEmail_Id = map['fromEmail_Id'];
    }
    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
    if (map.containsKey('credits')) {
      this.credits = num.parse(map['credits'].toStringAsFixed(2));
    }
    if (map.containsKey('to')) {
      this.to = map['to'];
    }
    if (map.containsKey('toEmail_Id')) {
      this.toEmail_Id = map['toEmail_Id'];
    }
    if (map.containsKey('type')) {
      this.type = map['type'];
    }
    if (map.containsKey('isApproved')) {
      this.isApproved = map['isApproved'];
    }
    if (map.containsKey('typeid')) {
      this.typeid = map['typeid'];
    } else {
      this.typeid = '${map['fromEmail_Id']}*${map['timestamp']}';
    }
    if (map.containsKey('timebankid')) {
      this.timebankid = map['timebankid'];
    }
    if (map.containsKey('transactionbetween')) {
      List<String> transactionbetween =
          List.castFrom(map['transactionbetween']);
      this.transactionbetween = transactionbetween;
    }
    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }
    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }
    if (map.containsKey('offerId')) {
      this.offerId = map['offerId'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (this.from != null) {
      map['from'] = this.from;
    }
    if (this.fromEmail_Id != null) {
      map['fromEmail_Id'] = this.fromEmail_Id;
    }
    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }
    if (this.credits != null) {
      map['credits'] = num.parse(this.credits?.toStringAsFixed(2) ?? '0');
    }
    if (this.to != null) {
      map['to'] = this.to;
    }
    if (this.toEmail_Id != null) {
      map['toEmail_Id'] = this.toEmail_Id;
    }
    if (this.isApproved != null) {
      map['isApproved'] = this.isApproved;
    }
    if (this.type != null) {
      map['type'] = this.type;
    }
    if (this.typeid != null) {
      map['typeid'] = this.typeid;
    } else {
      map['typeid'] = this.fromEmail_Id! +
          '*' +
          DateTime.now().millisecondsSinceEpoch.toString();
    }
    if (this.timebankid != null) {
      map['timebankid'] = this.timebankid;
    }
    if (this.transactionbetween != null &&
        this.transactionbetween?.isNotEmpty == true) {
      map['transactionbetween'] = this.transactionbetween;
    }

    if (this.communityId != null) {
      map['communityId'] = this.communityId;
    }
    map['liveMode'] = !AppConfig.isTestCommunity;

    if (this.offerId != null) {
      map['offerId'] = this.offerId;
    }

    return map;
  }

  String debitCreditSymbol(id, timebankid, viewtype) {
    if (this.type == 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS') {
      return "+";
    } else if (this.type == 'TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE' ||
        this.type == 'TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE') {
      if (viewtype == 'user') {
        return "+";
      } else {
        return "-";
      }
    } else if (viewtype == 'user') {
      return this.from == id ? "-" : "+";
    } else if (viewtype == 'timebank') {
      return this.from == timebankid ? "-" : "+";
    } else {
      return this.from == id ? "-" : "+";
    }
  }
}

//refundfromoffer
