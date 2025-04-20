import 'dart:convert';

List<TimeBankBalanceTransactionModel> timeBankBalanceTransactionModelFromJson(
        String str) =>
    List<TimeBankBalanceTransactionModel>.from(json
        .decode(str)
        .map((x) => TimeBankBalanceTransactionModel.fromJson(x)));

String timeBankBalanceTransactionModelToJson(
        List<TimeBankBalanceTransactionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TimeBankBalanceTransactionModel {
  String? communityId;
  String? userId;
  String? requestId;
  double? amount;
  var timestamp;

  TimeBankBalanceTransactionModel(
      {this.communityId,
      this.userId,
      this.requestId,
      this.amount,
      this.timestamp});

  factory TimeBankBalanceTransactionModel.fromJson(Map<String, dynamic> json) =>
      TimeBankBalanceTransactionModel(
          communityId: json["communityId"],
          userId: json["userId"],
          requestId: json["requestId"],
          amount: json["amount"].toDouble(),
          timestamp: json["timestamp"]);

  Map<String, dynamic> toJson() => {
        "communityId": communityId,
        "userId": userId,
        "requestId": requestId,
        "amount": amount,
        "timestamp": timestamp
      };
}
