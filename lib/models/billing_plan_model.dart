import 'dart:convert';

//BillingAddress billingDetails;

BillingPlanModel billingPlanModelFromJson(String str) =>
    BillingPlanModel.fromJson(json.decode(str));

String billingPlanModelToJson(BillingPlanModel data) =>
    json.encode(data.toJson());

class BillingPlanModel {
  Plan? starterPlan;
  Plan? freePlan;

  BillingPlanModel({
    this.starterPlan,
    this.freePlan,
  });

  factory BillingPlanModel.fromJson(Map<String, dynamic> json) =>
      BillingPlanModel(
        starterPlan: Plan.fromJson(json["starter_plan"]),
        freePlan: Plan.fromJson(json["free_plan"]),
      );

  Map<String, dynamic> toJson() => {
        "starter_plan": starterPlan?.toJson(),
        "free_plan": freePlan?.toJson(),
      };
}

class Plan {
  String? createdOn;
  Action? action;

  Plan({
    this.createdOn,
    this.action,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        createdOn: json["created_on"],
        action: Action.fromJson(json["action"]),
      );

  Map<String, dynamic> toJson() => {
        "created_on": createdOn,
        "action": action?.toJson(),
      };
}

class Action {
  Data? userJoinsTimebank;
  Data? requestMade;
  Data? requestAccepted;
  Data? offerMade;
  Data? postFeed;
  Data? messageSent;
  Data? recievesNotification;
  Data? requestMarkedComplete;
  Data? adminReviewsCompleted;
  Data? userCreditedWithCoins;

  Action({
    this.userJoinsTimebank,
    this.requestMade,
    this.requestAccepted,
    this.offerMade,
    this.postFeed,
    this.messageSent,
    this.recievesNotification,
    this.requestMarkedComplete,
    this.adminReviewsCompleted,
    this.userCreditedWithCoins,
  });

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        userJoinsTimebank: Data.fromJson(json["user_joins_timebank"]),
        requestMade: Data.fromJson(json["request_made"]),
        requestAccepted: Data.fromJson(json["request_accepted"]),
        offerMade: Data.fromJson(json["offer_made"]),
        postFeed: Data.fromJson(json["post_feed"]),
        messageSent: Data.fromJson(json["message_sent"]),
        recievesNotification: Data.fromJson(json["recieves_notification"]),
        requestMarkedComplete: Data.fromJson(json["request_marked_complete"]),
        adminReviewsCompleted: Data.fromJson(json["admin_reviews_completed"]),
        userCreditedWithCoins: Data.fromJson(json["user_credited_with_coins"]),
      );

  Map<String, dynamic> toJson() => {
        "user_joins_timebank": userJoinsTimebank?.toJson(),
        "request_made": requestMade?.toJson(),
        "request_accepted": requestAccepted?.toJson(),
        "offer_made": offerMade?.toJson(),
        "post_feed": postFeed?.toJson(),
        "message_sent": messageSent?.toJson(),
        "recieves_notification": recievesNotification?.toJson(),
        "request_marked_complete": requestMarkedComplete?.toJson(),
        "admin_reviews_completed": adminReviewsCompleted?.toJson(),
        "user_credited_with_coins": userCreditedWithCoins?.toJson(),
      };
}

class Data {
  bool? billable;
  int? freeLimit;
  double? charge;

  Data({
    this.billable,
    this.freeLimit,
    this.charge,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        billable: json["billable"],
        freeLimit: int.parse(json["free_limit"]),
        charge: json["charge"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "billable": billable,
        "free_limit": freeLimit,
        "charge": charge,
      };
}
