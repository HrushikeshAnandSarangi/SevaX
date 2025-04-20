import 'dart:convert';

import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class NotificationsModel extends DataModel {
  String? id;
  NotificationType? type;
  Map<String, dynamic>? data;
  String? targetUserId;
  String? senderUserId;
  String? senderPhotoUrl;
  bool? isRead;
  String? timebankId;
  String? communityId;
  int? timestamp;
  bool? isTimebankNotification;

  NotificationsModel({
    this.id,
    this.type,
    this.data,
    this.targetUserId,
    this.isRead = false,
    this.senderUserId,
    this.senderPhotoUrl,
    this.timebankId,
    this.communityId,
    this.timestamp,
    this.isTimebankNotification,
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
    if (map.containsKey('senderPhotoUrl')) {
      this.senderPhotoUrl = map['senderPhotoUrl'];
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
    return "$communityId $targetUserId ";
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['isTimebankNotification'] = isTimebankNotification ?? false;

    if (this.id != null) {
      map['id'] = this.id;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }

    if (this.senderUserId != null) {
      map['senderUserId'] = this.senderUserId;
    }
    if (this.senderPhotoUrl != null) {
      map['senderPhotoUrl'] = this.senderPhotoUrl;
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
  AddManualTimeRequest,
  RequestScheduleReminder,
  RecurringRequestUpdated,
  RecurringOfferUpdated,
  RequestAccept,
  OneToManyRequestAccept,
  OneToManyRequestInviteAccepted,
  OneToManyRequestInviteRejected,
  OneToManyRequestCompleted,
  OneToManyCreatorRejectedCompletion,
  ONETOMANY_REQUEST_ATTENDEES_FEEDBACK,
  // OneToManyRequestDoneForSpeaker,
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
  TypeChangeOwnership,
  TypeChangeGroupOwnership,
  TYPE_CHANGE_GROUP_OWNERSHIP_UPDATE_TO_COMMUNITY_OWNER,
  TypeMemberAdded,
  TypeMemberJoinViaCode,
  GroupJoinInvite,
  TYPE_MEMBER_HAS_INSUFFICENT_CREDITS,
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
  APPROVED_MEMBER_WITHDRAWING_REQUEST,
  //sponser group request
  APPROVE_SPONSORED_GROUP_REQUEST,
  //ONE TO MAY OFFER CANCELLATION
  OFFER_CANCELLED_BY_CREATOR,
  DEBITED_SEVA_COINS_TIMEBANK,
  SEVA_COINS_DEBITED,
  SEVA_COINS_CREDITED,
  MEMBER_RECEIVED_CREDITS_DONATION,
  COMMUNITY_RECEIVED_CREDITS_DONATION,

  //PROMOTION AND DEMOTION
  MEMBER_PROMOTED_AS_ADMIN,
  ADMIN_PROMOTED_AS_ORGANIZER,
  MEMBER_DEMOTED_FROM_ADMIN,
  ADMIN_DEMOTED_FROM_ORGANIZER,

  //Donation notifications
  GOODS_DONATION_REQUEST,
  ACKNOWLEDGE_DONOR_DONATION, //creator and timebank
  CASH_DONATION_COMPLETED_SUCCESSFULLY, //donor
  GOODS_DONATION_COMPLETED_SUCCESSFULLY, //donor
  CASH_DONATION_MODIFIED_BY_CREATOR, //donor
  GOODS_DONATION_MODIFIED_BY_CREATOR, //donor
  CASH_DONATION_ACKNOWLEDGED_BY_DONOR, //creator and timebank
  GOODS_DONATION_ACKNOWLEDGED_BY_DONOR, //creator and timebank
  CASH_DONATION_MODIFIED_BY_DONOR, //creator and timebank
  GOODS_DONATION_MODIFIED_BY_DONOR, //creator and timebank

  //Manual time claim
  MANUAL_TIME_CLAIM,
  MANUAL_TIME_CLAIM_APPROVED,
  MANUAL_TIME_CLAIM_REJECTED,

  //Borrow Requests 2nd half of request flow Notifications
  NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK,
  NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT,
  NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK,

  //messaging room
  MEMBER_ADDED_TO_MESSAGE_ROOM,
  MEMBER_REMOVED_FROM_MESSAGE_ROOM,

  //messaging room
  COMMUNITY_ADDED_TO_MESSAGE_ROOM,
  COMMUNITY_REMOVED_FROM_MESSAGE_ROOM,

  //offer request invite
  OfferRequestInvite,
  TimeOfferInvitationFromCreator,

  //lending offers notification
  MEMBER_ACCEPT_LENDING_OFFER, //done
  NOTIFICATION_TO_BORROWER_REJECTED_LENDING_OFFER, //done
  NOTIFICATION_TO_BORROWER_APPROVED_LENDING_OFFER, //done
  NOTIFICATION_TO_LENDER_PLACE_CHECKED_IN, //done
  NOTIFICATION_TO_LENDER_PLACE_CHECKED_OUT, //done
  NOTIFICATION_TO_LENDER_ITEMS_COLLECTED, //done
  NOTIFICATION_TO_LENDER_ITEMS_RETURNED, //done
  NOTIFICATION_TO_BORROWER_FOR_LENDING_FEEDBACK, //done

  // Idle / No activity Notifications reminders for Borrow Requests and Lending Offers
  BorrowRequestIdleFirstWarning,
  BorrowRequestIdleSecondWarning,
  BorrowRequestIdleSoftDeleted,
  LendingOfferIdleFirstWarning,
  LendingOfferIdleSecondWarning,
  LendingOfferIdleSoftDeleted,
}

//Check the method
NotificationType stringToNotificationType(String str) {
  return NotificationType.values.firstWhere(
    (v) => v.toString() == 'NotificationType.' + str.trim(),
  );
}

Map<String, NotificationType> typeMapper = {
  "NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK":
      NotificationType.NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK,
  "NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT":
      NotificationType.NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT,
  "NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK":
      NotificationType.NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK,
  "AddManualTimeRequest": NotificationType.AddManualTimeRequest,
  "RequestScheduleReminder": NotificationType.RequestScheduleReminder,
  "RecurringRequestUpdated": NotificationType.RecurringRequestUpdated,
  "RecurringOfferUpdated": NotificationType.RecurringOfferUpdated,
  "RequestAccept": NotificationType.RequestAccept,
  "RequestApprove": NotificationType.RequestApprove,
  "RequestInvite": NotificationType.RequestInvite,
  "OneToManyRequestAccept": NotificationType.OneToManyRequestAccept,
  "OneToManyRequestInviteAccepted":
      NotificationType.OneToManyRequestInviteAccepted,
  "OneToManyRequestInviteRejected":
      NotificationType.OneToManyRequestInviteRejected,
  "OneToManyRequestCompleted": NotificationType.OneToManyRequestCompleted,
  "OneToManyCreatorRejectedCompletion":
      NotificationType.OneToManyCreatorRejectedCompletion,
  "ONETOMANY_REQUEST_ATTENDEES_FEEDBACK":
      NotificationType.ONETOMANY_REQUEST_ATTENDEES_FEEDBACK,
  // "OneToManyRequestDoneForSpeaker":
  // NotificationType.OneToManyRequestDoneForSpeaker,
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
  "TypeMemberJoinViaCode": NotificationType.TypeMemberJoinViaCode,
  "TypeChangeOwnership": NotificationType.TypeChangeOwnership,
  "TypeChangeGroupOwnership": NotificationType.TypeChangeGroupOwnership,
  "TYPE_CHANGE_GROUP_OWNERSHIP_UPDATE_TO_COMMUNITY_OWNER":
      NotificationType.TYPE_CHANGE_GROUP_OWNERSHIP_UPDATE_TO_COMMUNITY_OWNER,
  "GroupJoinInvite": NotificationType.GroupJoinInvite,
  "ACKNOWLEDGE_DONOR_DONATION": NotificationType.ACKNOWLEDGE_DONOR_DONATION,
  "GOODS_DONATION_REQUEST": NotificationType.GOODS_DONATION_REQUEST,
  "TYPE_MEMBER_HAS_INSUFFICENT_CREDITS":
      NotificationType.TYPE_MEMBER_HAS_INSUFFICENT_CREDITS,
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
  "APPROVED_MEMBER_WITHDRAWING_REQUEST":
      NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST,
  //ONE TO MANY OFFER
  "OFFER_CANCELED_BY_CREATOR": NotificationType.OFFER_CANCELLED_BY_CREATOR,
  "DEBITED_SEVA_COINS_TIMEBANK": NotificationType.DEBITED_SEVA_COINS_TIMEBANK,
  "SEVA_COINS_CREDITED": NotificationType.SEVA_COINS_CREDITED,

  "MEMBER_RECEIVED_CREDITS_DONATION":
      NotificationType.MEMBER_RECEIVED_CREDITS_DONATION,
  "COMMUNITY_RECEIVED_CREDITS_DONATION":
      NotificationType.COMMUNITY_RECEIVED_CREDITS_DONATION,

  "SEVA_COINS_DEBITED": NotificationType.SEVA_COINS_DEBITED,
  "ADMIN_PROMOTED_AS_ORGANIZER": NotificationType.ADMIN_PROMOTED_AS_ORGANIZER,
  "ADMIN_DEMOTED_FROM_ORGANIZER": NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER,
  "MEMBER_PROMOTED_AS_ADMIN": NotificationType.MEMBER_PROMOTED_AS_ADMIN,
  "MEMBER_DEMOTED_FROM_ADMIN": NotificationType.MEMBER_DEMOTED_FROM_ADMIN,

  //Messaging room
  "MEMBER_ADDED_TO_MESSAGE_ROOM": NotificationType.MEMBER_ADDED_TO_MESSAGE_ROOM,
  "MEMBER_REMOVED_FROM_MESSAGE_ROOM":
      NotificationType.MEMBER_REMOVED_FROM_MESSAGE_ROOM,
  //DONATIONS
  "CASH_DONATION_COMPLETED_SUCCESSFULLY":
      NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY,
  "GOODS_DONATION_COMPLETED_SUCCESSFULLY":
      NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY,
  "CASH_DONATION_MODIFIED_BY_CREATOR":
      NotificationType.CASH_DONATION_MODIFIED_BY_CREATOR,
  "GOODS_DONATION_MODIFIED_BY_CREATOR":
      NotificationType.GOODS_DONATION_MODIFIED_BY_CREATOR,
  "CASH_DONATION_ACKNOWLEDGED_BY_DONOR":
      NotificationType.CASH_DONATION_ACKNOWLEDGED_BY_DONOR,
  "GOODS_DONATION_ACKNOWLEDGED_BY_DONOR":
      NotificationType.GOODS_DONATION_ACKNOWLEDGED_BY_DONOR,
  "CASH_DONATION_MODIFIED_BY_DONOR":
      NotificationType.CASH_DONATION_MODIFIED_BY_DONOR,
  "GOODS_DONATION_MODIFIED_BY_DONOR":
      NotificationType.GOODS_DONATION_MODIFIED_BY_DONOR,

  //Manual time claim
  "MANUAL_TIME_CLAIM": NotificationType.MANUAL_TIME_CLAIM,
  "MANUAL_TIME_CLAIM_REJECTED": NotificationType.MANUAL_TIME_CLAIM_REJECTED,
  "MANUAL_TIME_CLAIM_APPROVED": NotificationType.MANUAL_TIME_CLAIM_APPROVED,
  "APPROVE_SPONSORED_GROUP_REQUEST":
      NotificationType.APPROVE_SPONSORED_GROUP_REQUEST,
  "OfferRequestInvite": NotificationType.OfferRequestInvite,
  "TimeOfferInvitationFromCreator":
      NotificationType.TimeOfferInvitationFromCreator,
  //Messaging room
  "COMMUNITY_ADDED_TO_MESSAGE_ROOM":
      NotificationType.COMMUNITY_ADDED_TO_MESSAGE_ROOM,
  "COMMUNITY_REMOVED_FROM_MESSAGE_ROOM":
      NotificationType.COMMUNITY_REMOVED_FROM_MESSAGE_ROOM,

  //Lending offers
  "MEMBER_ACCEPT_LENDING_OFFER": NotificationType.MEMBER_ACCEPT_LENDING_OFFER,
  "NOTIFICATION_TO_BORROWER_APPROVED_LENDING_OFFER":
      NotificationType.NOTIFICATION_TO_BORROWER_APPROVED_LENDING_OFFER,
  "NOTIFICATION_TO_BORROWER_REJECTED_LENDING_OFFER":
      NotificationType.NOTIFICATION_TO_BORROWER_REJECTED_LENDING_OFFER,
  "NOTIFICATION_TO_LENDER_PLACE_CHECKED_IN":
      NotificationType.NOTIFICATION_TO_LENDER_PLACE_CHECKED_IN,
  "NOTIFICATION_TO_LENDER_PLACE_CHECKED_OUT":
      NotificationType.NOTIFICATION_TO_LENDER_PLACE_CHECKED_OUT,
  "NOTIFICATION_TO_LENDER_ITEMS_COLLECTED":
      NotificationType.NOTIFICATION_TO_LENDER_ITEMS_COLLECTED,
  "NOTIFICATION_TO_LENDER_ITEMS_RETURNED":
      NotificationType.NOTIFICATION_TO_LENDER_ITEMS_RETURNED,

  "BorrowRequestIdleFirstWarning":
      NotificationType.BorrowRequestIdleFirstWarning,
  "BorrowRequestIdleSecondWarning":
      NotificationType.BorrowRequestIdleSecondWarning,
  "BorrowRequestIdleSoftDeleted": NotificationType.BorrowRequestIdleSoftDeleted,
  "LendingOfferIdleFirstWarning": NotificationType.LendingOfferIdleFirstWarning,
  "LendingOfferIdleSecondWarning":
      NotificationType.LendingOfferIdleSecondWarning,
  "LendingOfferIdleSoftDeleted": NotificationType.LendingOfferIdleSoftDeleted,
  "NOTIFICATION_TO_BORROWER_FOR_LENDING_FEEDBACK":
      NotificationType.NOTIFICATION_TO_BORROWER_FOR_LENDING_FEEDBACK,
};

ClearNotificationModel clearNotificationModelFromJson(String str) =>
    ClearNotificationModel.fromJson(json.decode(str));

class ClearNotificationModel {
  bool isClearNotificationEnabled;
  List<NotificationType> notificationType;

  ClearNotificationModel({
    required this.isClearNotificationEnabled,
    required this.notificationType,
  });

  factory ClearNotificationModel.fromJson(Map<String, dynamic> json) =>
      ClearNotificationModel(
        isClearNotificationEnabled: json["isClearNotificationEnabled"],
        notificationType: List<NotificationType>.from(
            json["notificationType"].map((x) => typeMapper[x])),
      );
}

class ReccuringRequestUpdated {
  String? eventName;
  int? eventDate;
  String? photoUrl;
  String? requestId;

  ReccuringRequestUpdated.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('eventName')) {
      this.eventName = map['eventName'];
    }

    if (map.containsKey('eventDate')) {
      this.eventDate = map['eventDate'];
    }

    if (map.containsKey('photoUrl')) {
      this.photoUrl = map['photoUrl'];
    }

    if (map.containsKey('requestId')) {
      this.requestId = map['requestId'];
    }
  }
}

class ReccuringOfferUpdated {
  String? eventName;
  int? eventDate;
  String? photoUrl;
  String? offerId;

  ReccuringOfferUpdated.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('eventName')) {
      this.eventName = map['eventName'];
    }

    if (map.containsKey('eventDate')) {
      this.eventDate = map['eventDate'];
    }

    if (map.containsKey('photoUrl')) {
      this.photoUrl = map['photoUrl'];
    }

    if (map.containsKey('requestId')) {
      this.offerId = map['offerId'];
    }
  }
}
