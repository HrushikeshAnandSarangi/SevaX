import 'models.dart';

class TransactionModel extends DataModel {
  String from;
  String to;
  int timestamp;
  num credits;
  bool isApproved;
  String type;
  String typeid;
  String timebankid;
  List<String> transactionbetween;

  TransactionModel(
      {this.from,
      this.timestamp,
      this.credits,
      this.to,
      this.isApproved = false,
      this.type,
      this.typeid,
      this.timebankid,
      this.transactionbetween});

  TransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('from')) {
      this.from = map['from'];
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
    if (map.containsKey('type')) {
      this.type = map['type'];
    }
    if (map.containsKey('isApproved')) {
      this.isApproved = map['isApproved'];
    }
    if (map.containsKey('typeid')) {
      this.typeid = map['typeid'];
    }
    if (map.containsKey('timebankid')) {
      this.timebankid = map['timebankid'];
    }
    if (map.containsKey('transactionbetween')) {
      List<String> transactionbetween =
          List.castFrom(map['transactionbetween']);
      this.transactionbetween = transactionbetween;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (this.from != null) {
      map['from'] = this.from;
    }
    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }
    if (this.credits != null) {
      map['credits'] = num.parse(this.credits.toStringAsFixed(2));
    }
    if (this.to != null) {
      map['to'] = this.to;
    }
    if (this.isApproved != null) {
      map['isApproved'] = this.isApproved;
    }
    if (this.type != null) {
      map['type'] = this.type;
    }
    if (this.typeid != null) {
      map['typeid'] = this.typeid;
    }
    if (this.timebankid != null) {
      map['timebankid'] = this.timebankid;
    }
    if (this.transactionbetween != null && this.transactionbetween.isNotEmpty) {
      map['transactionbetween'] = this.transactionbetween;
    }
    return map;
  }

  String debitCreditSymbol(id, timebankid, viewtype) {
    if (this.type == 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS') {
      return "+";
    } else if (viewtype == 'user') {
      return this.from == id ? "-" : "+";
    } else if (viewtype == 'timebank') {
      return this.from == timebankid ? "-" : "+";
    } else {
      return this.from == id ? "-" : "+";
    }
  }
}
