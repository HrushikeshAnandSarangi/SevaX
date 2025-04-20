import 'dart:convert';

import 'offer_participants_model.dart';

OneToManyNotificationDataModel oneToManyNotificationDataModelFromJson(
        String str) =>
    OneToManyNotificationDataModel.fromJson(json.decode(str));

class OneToManyNotificationDataModel {
  ClassDetails? classDetails;
  ParticipantDetails? participantDetails;

  OneToManyNotificationDataModel({
    this.classDetails,
    this.participantDetails,
  });

  factory OneToManyNotificationDataModel.fromJson(Map<String, dynamic> json) =>
      OneToManyNotificationDataModel(
        classDetails: ClassDetails.fromJson(
            Map<String, dynamic>.from(json["classDetails"])),
        participantDetails: ParticipantDetails.fromJson(
            Map<String, dynamic>.from(json["participantDetails"] ?? {})),
      );
}

enum OFFER_NOTIFICATION_TYPE {
  DEBIT_FROM_OFFER,
  CREDIT_FROM_OFFER_ON_HOLD,
  CREDIT_FROM_OFFER_APPROVED,
  CREDIT_FROM_OFFER,
  DEBIT_FULFILMENT_FROM_TIMEBANK,
  NEW_MEMBER_SIGNUP_OFFER,
  OFFER_FULFILMENT_ACHIEVED,
  OFFER_SUBSCRIPTION_COMPLETED,
  FEEDBACK_FROM_SIGNUP_MEMBER,
}

OFFER_NOTIFICATION_TYPE stringToNotificationType(String str) {
  return OFFER_NOTIFICATION_TYPE.values.firstWhere(
    (v) => v.toString() == 'OFFER_NOTIFICATION_TYPE.' + str,
  );
}
