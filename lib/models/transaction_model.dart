import 'models.dart';

class TransactionModel extends DataModel {
  String from;
  String to;
  int timestamp;
  num credits;
  bool isApproved;

  TransactionModel({
    this.from,
    this.timestamp,
    this.credits,
    this.to,
    this.isApproved = false,
  });

  TransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('from')) {
      this.from = map['from'];
    }
    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }
    if (map.containsKey('credits')) {
      this.credits = map['credits'];
    }
    if (map.containsKey('to')) {
      this.to = map['to'];
    }
    if (map.containsKey('isApproved')) {
      this.isApproved = map['isApproved'];
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
      map['credits'] = this.credits;
    }
    if (this.to != null) {
      map['to'] = this.to;
    }
    if (this.isApproved != null) {
      map['isApproved'] = this.isApproved;
    }
    return map;
  }
}
