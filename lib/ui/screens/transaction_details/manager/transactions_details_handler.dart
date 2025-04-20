import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

String getTimelineLabel(
    String tag, BuildContext context, RequestType requestType) {
  logger.i(tag);
  String finalLabel = '';

  //convert string tag to timeline tag type
  TimelineTransactionTags convertedtTag =
      getConvertedTimelineTransactionTagsType(tag);

  logger.e('Initial LABEL 1: ' + tag);

  //return label according to tag for requests
  finalLabel = getTimelineLabelForRequests(convertedtTag, context, requestType);

  logger.e('FINAL LABEL 1: ' + finalLabel);

  return finalLabel == '' ? S.of(context).no_data : finalLabel;
}

//
// Fetch Label Functions for Each type of request
//
getTimelineLabelForRequests(TimelineTransactionTags tag, BuildContext context,
    RequestType requestType) {
  switch (tag) {
    case TimelineTransactionTags.APPLIED_REQUEST:
      return S.of(context).time_applied_request_tag;
      break;
    case TimelineTransactionTags.WITHDRAWN_REQUEST:
      return S.of(context).time_withdrawn_request_tag;
      break;
    case TimelineTransactionTags.REQUEST_APPROVED:
      return S.of(context).time_request_approved_tag;
      break;
    case TimelineTransactionTags.REQUEST_REJECTED:
      return S.of(context).time_request_rejected_tag;
      break;
    case TimelineTransactionTags.CLAIM_CREDITS:
      return S.of(context).time_claim_credits_tag;
      break;
    case TimelineTransactionTags.CLAIM_ACCEPTED:
      return S.of(context).time_claim_accepted_tag;
      break;
    case TimelineTransactionTags.CLAIM_DECLINED:
      return S.of(context).time_claim_declined_tag;
      break;
    case TimelineTransactionTags.PLEDGED_BY_DONOR:
      if (requestType != null && requestType == RequestType.GOODS)
        return S.of(context).goods_pledged_by_donor_tag;
      else
        return S.of(context).money_pledged_by_donor_tag.toLowerCase();
      break;
    case TimelineTransactionTags.ACKNOWLEDGED_GOODS_DONATION:
      return S.of(context).goods_acknowledged_donation_tag;
      break;
    case TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_CREATOR:
      return S.of(context).goods_donation_modified_by_creator_tag;
      break;
    case TimelineTransactionTags.GOODS_DONATION_CREATOR_REJECTED:
      return S.of(context).goods_donation_creator_rejected_tag;
      break;
    case TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_DONOR:
      return S.of(context).goods_donation_modified_by_donor_tag;
      break;
    case TimelineTransactionTags.ACKNOWLEDGED_MONEY_DONATION:
      return S.of(context).money_acknowledged_donation_tag;
      break;
    case TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_CREATOR:
      return S.of(context).money_donation_modified_by_creator_tag;
      break;
    case TimelineTransactionTags.MONEY_DONATION_CREATOR_REJECTED:
      return S.of(context).money_donation_creator_rejected_tag;
      break;
    case TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_DONOR:
      return S.of(context).money_donation_modified_by_donor_tag;
      break;
    case TimelineTransactionTags.MONEY_DONATION_REJECTED_BY_CREATOR:
      return S.of(context).money_donation_creator_rejected_tag;
      break;
    case TimelineTransactionTags.GOODS_DONATION_REJECTED_BY_CREATOR:
      return S.of(context).goods_donation_creator_rejected_tag;
    case TimelineTransactionTags.Transaction:
      return 'Transaction';
    case TimelineTransactionTags.SIGNED_UP_FOR_OFFER:
      return S.of(context).time_signed_up_for_offer_tag;
    case TimelineTransactionTags.DEBITED_FOR_ONE_TO_MANY_OFFER:
      return S.of(context).time_debited_for_one_to_many_offer_tag;
    case TimelineTransactionTags.OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER:
      return S
          .of(context)
          .time_offer_creator_credited_for_one_to_many_offer_tag;
    case TimelineTransactionTags.TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER:
      return S.of(context).timebank_debited_for_one_to_many_offer_tag;
    case TimelineTransactionTags.TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER:
      return S.of(context).timebank_credited_for_one_to_many_offer_tag;
      break;
    case TimelineTransactionTags.OfferAccepted:
      return S.of(context).time_offer_accepted_tag;
    case TimelineTransactionTags.REQUESTED_BY_ADMIN:
      return S.of(context).requested_by_admin_tag;
    case TimelineTransactionTags.CLAIMED_FOR_MANUAL_TIME:
      return S.of(context).claimed_for_manual_time_tag;
    case TimelineTransactionTags.ACCEPTED_MANUAL_TIME_REQUEST:
      return S.of(context).accepted_manual_time_request_tag;
    case TimelineTransactionTags.REJECTED_MANUAL_TIME_REQUEST:
      return S.of(context).rejected_manual_time_request_tag;

    default:
      return '';
  }
}

//
//TimelineTransactionTags For Requests Enums
//

enum TimelineTransactionTags {
  REQUESTED_BY_ADMIN,
  PLEDGED_BY_DONOR,
  ACKNOWLEDGED_GOODS_DONATION,
  GOODS_DONATION_REJECTED_BY_CREATOR,
  GOODS_DONATION_MODIFIED_BY_DONOR,
  ACKNOWLEDGED_MONEY_DONATION,
  MONEY_DONATION_REJECTED_BY_CREATOR,
  MONEY_DONATION_MODIFIED_BY_DONOR,
  APPLIED_REQUEST,
  WITHDRAWN_REQUEST,
  REQUEST_APPROVED,
  REQUEST_REJECTED,
  CLAIM_CREDITS,
  CLAIM_ACCEPTED,
  CLAIM_DECLINED,
  GOODS_DONATION_MODIFIED_BY_CREATOR,
  GOODS_DONATION_CREATOR_REJECTED,
  MONEY_DONATION_MODIFIED_BY_CREATOR,
  MONEY_DONATION_CREATOR_REJECTED,
  Transaction,
  OfferAccepted,
  SIGNED_UP_FOR_OFFER,
  DEBITED_FOR_ONE_TO_MANY_OFFER,
  OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER,
  TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER,
  TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER,
  CLAIMED_FOR_MANUAL_TIME,
  ACCEPTED_MANUAL_TIME_REQUEST,
  REJECTED_MANUAL_TIME_REQUEST,
}

extension TransactionTagsLabel on TimelineTransactionTags {
  String get readable {
    switch (this) {
      case TimelineTransactionTags.APPLIED_REQUEST:
        return 'APPLIED_REQUEST';
      case TimelineTransactionTags.WITHDRAWN_REQUEST:
        return 'WITHDRAWN_REQUEST';
      case TimelineTransactionTags.REQUEST_APPROVED:
        return 'REQUEST_APPROVED';
      case TimelineTransactionTags.REQUEST_REJECTED:
        return 'REQUEST_REJECTED';
      case TimelineTransactionTags.CLAIM_CREDITS:
        return 'CLAIM_CREDITS';
      case TimelineTransactionTags.CLAIM_ACCEPTED:
        return 'CLAIM_ACCEPTED';
      case TimelineTransactionTags.CLAIM_DECLINED:
        return 'CLAIM_DECLINED';
      case TimelineTransactionTags.PLEDGED_BY_DONOR:
        return 'PLEDGED_BY_DONOR';
      case TimelineTransactionTags.ACKNOWLEDGED_GOODS_DONATION:
        return 'ACKNOWLEDGED_GOODS_DONATION';
      case TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_CREATOR:
        return 'GOODS_DONATION_MODIFIED_BY_CREATOR';
      case TimelineTransactionTags.GOODS_DONATION_CREATOR_REJECTED:
        return 'GOODS_DONATION_CREATOR_REJECTED';
      case TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_DONOR:
        return 'GOODS_DONATION_MODIFIED_BY_DONOR';
      case TimelineTransactionTags.ACKNOWLEDGED_MONEY_DONATION:
        return 'ACKNOWLEDGED_MONEY_DONATION';
      case TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_CREATOR:
        return 'MONEY_DONATION_MODIFIED_BY_CREATOR';
      case TimelineTransactionTags.MONEY_DONATION_CREATOR_REJECTED:
        return 'MONEY_DONATION_CREATOR_REJECTED';
      case TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_DONOR:
        return 'MONEY_DONATION_MODIFIED_BY_DONOR';
      case TimelineTransactionTags.MONEY_DONATION_REJECTED_BY_CREATOR:
        return 'MONEY_DONATION_REJECTED_BY_CREATOR';
      case TimelineTransactionTags.GOODS_DONATION_REJECTED_BY_CREATOR:
        return 'GOODS_DONATION_REJECTED_BY_CREATOR';
      case TimelineTransactionTags.REQUESTED_BY_ADMIN:
        return 'REQUESTED_BY_ADMIN';
        break;
      case TimelineTransactionTags.SIGNED_UP_FOR_OFFER:
        return 'SIGNED_UP_FOR_OFFER';
      case TimelineTransactionTags.DEBITED_FOR_ONE_TO_MANY_OFFER:
        return 'DEBITED_FOR_ONE_TO_MANY_OFFER';
      case TimelineTransactionTags.OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER:
        return 'OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER';
      case TimelineTransactionTags.TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER:
        return 'TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER';
      case TimelineTransactionTags.TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER:
        return 'TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER';
      case TimelineTransactionTags.OfferAccepted:
        return 'OfferAccepted';
      case TimelineTransactionTags.Transaction:
        return 'Transaction';
      case TimelineTransactionTags.CLAIMED_FOR_MANUAL_TIME:
        return 'CLAIMED_FOR_MANUAL_TIME';
      case TimelineTransactionTags.ACCEPTED_MANUAL_TIME_REQUEST:
        return 'ACCEPTED_MANUAL_TIME_REQUEST';
      case TimelineTransactionTags.REJECTED_MANUAL_TIME_REQUEST:
        return 'REJECTED_MANUAL_TIME_REQUEST';
      default:
        return 'tagError $this';
    }
  }
}

TimelineTransactionTags getConvertedTimelineTransactionTagsType(
    String stringTag) {
  switch (stringTag) {
    case 'APPLIED_REQUEST':
      return TimelineTransactionTags.APPLIED_REQUEST;
      break;
    case 'WITHDRAWN_REQUEST':
      return TimelineTransactionTags.WITHDRAWN_REQUEST;
      break;
    case 'REQUEST_APPROVED':
      return TimelineTransactionTags.REQUEST_APPROVED;
      break;
    case 'REQUEST_REJECTED':
      return TimelineTransactionTags.REQUEST_REJECTED;
      break;
    case 'CLAIM_CREDITS':
      return TimelineTransactionTags.CLAIM_CREDITS;
      break;
    case 'CLAIM_ACCEPTED':
      return TimelineTransactionTags.CLAIM_ACCEPTED;
      break;
    case 'CLAIM_DECLINED':
      return TimelineTransactionTags.CLAIM_DECLINED;
      break;
    case 'PLEDGED_BY_DONOR':
      return TimelineTransactionTags.PLEDGED_BY_DONOR;
      break;
    case 'ACKNOWLEDGED_GOODS_DONATION':
      return TimelineTransactionTags.ACKNOWLEDGED_GOODS_DONATION;
      break;
    case 'GOODS_DONATION_MODIFIED_BY_CREATOR':
      return TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_CREATOR;
      break;
    case 'GOODS_DONATION_CREATOR_REJECTED':
      return TimelineTransactionTags.GOODS_DONATION_CREATOR_REJECTED;
      break;
    case 'GOODS_DONATION_MODIFIED_BY_DONOR':
      return TimelineTransactionTags.GOODS_DONATION_MODIFIED_BY_DONOR;
      break;
    case 'GOODS_DONATION_REJECTED_BY_CREATOR':
      return TimelineTransactionTags.GOODS_DONATION_REJECTED_BY_CREATOR;
    case 'MONEY_DONATION_MODIFIED_BY_DONOR':
      return TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_DONOR;
    case 'ACKNOWLEDGED_MONEY_DONATION':
      return TimelineTransactionTags.ACKNOWLEDGED_MONEY_DONATION;
    case 'MONEY_DONATION_MODIFIED_BY_CREATOR':
      return TimelineTransactionTags.MONEY_DONATION_MODIFIED_BY_CREATOR;
    case 'MONEY_DONATION_CREATOR_REJECTED':
      return TimelineTransactionTags.MONEY_DONATION_CREATOR_REJECTED;

    case 'MONEY_DONATION_REJECTED_BY_CREATOR':
      return TimelineTransactionTags.MONEY_DONATION_REJECTED_BY_CREATOR;
    case 'REQUESTED_BY_ADMIN':
      return TimelineTransactionTags.REQUESTED_BY_ADMIN;
    case 'Transaction':
      return TimelineTransactionTags.Transaction;

    case 'SIGNED_UP_FOR_OFFER':
      return TimelineTransactionTags.SIGNED_UP_FOR_OFFER;
    case 'DEBITED_FOR_ONE_TO_MANY_OFFER':
      return TimelineTransactionTags.DEBITED_FOR_ONE_TO_MANY_OFFER;
    case 'OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER':
      return TimelineTransactionTags
          .OFFER_CERATOR_CREDITED_FOR_ONE_TO_MANY_OFFER;
    case 'TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER':
      return TimelineTransactionTags.TIMEBANK_DEBITED_FOR_ONE_TO_MANY_OFFER;
    case 'TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER':
      return TimelineTransactionTags.TIMEBANK_CREDITED_FOR_ONE_TO_MANY_OFFER;
    case 'OfferAccepted':
      return TimelineTransactionTags.OfferAccepted;
    case 'CLAIMED_FOR_MANUAL_TIME':
      return TimelineTransactionTags.CLAIMED_FOR_MANUAL_TIME;
    case 'ACCEPTED_MANUAL_TIME_REQUEST':
      return TimelineTransactionTags.ACCEPTED_MANUAL_TIME_REQUEST;
    case 'REJECTED_MANUAL_TIME_REQUEST':
      return TimelineTransactionTags.REJECTED_MANUAL_TIME_REQUEST;

    default:
      logger.i('tag error 1 $stringTag');
      return null!;
  }
}

//--------------------------------------//
// -------------------------------------> To Get Transaction Types Label
//--------------------------------------//
String getTransactionTypeLabel(
    // RequestType requestType,
    String tag,
    BuildContext context) {
  logger.i(tag);
  String finalLabel = '';

  //convert string tag to timeline tag type
  TransactionTypeTags convertedtTag = getConvertedTransactionTypeTag(tag);

  logger.e('Initial LABEL 2: ' + tag);

  //return label according to tag for requests
  finalLabel = getTransactionTypeFinalLabel(convertedtTag, context);

  logger.e('FINAL LABEL 2: ' + finalLabel);

  return finalLabel == '' ? S.of(context).no_data : finalLabel;
}

//
// Fetch Label Functions for Each type of request
//
getTransactionTypeFinalLabel(TransactionTypeTags tag, BuildContext context) {
  switch (tag) {
    case TransactionTypeTags.ADMIN_DONATE_TOUSER:
      return S
          .of(context)
          .ADMIN_DONATE_TOUSER_tag; // ADD .replace and check if community or group
      break;

    case TransactionTypeTags.MANNUAL_TIME:
      return S.of(context).MANNUAL_TIME_tag;
      break;

    case TransactionTypeTags.OFFER_CREDIT_FROM_TIMEBANK:
      return S.of(context).OFFER_CREDIT_FROM_TIMEBANK_tag;
      break;

    case TransactionTypeTags.OFFER_CREDIT_TO_TIMEBANK:
      return S.of(context).OFFER_CREDIT_TO_TIMEBANK;
      break;

    case TransactionTypeTags.REQUEST_CREATION_TIMEBANK_FILL_CREDITS:
      return S.of(context).REQUEST_CREATION_TIMEBANK_FILL_CREDITS;
      break;

    case TransactionTypeTags.SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE:
      return S.of(context).SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE;
      break;

    case TransactionTypeTags.TAX:
      return S.of(context).TAX_tag;
      break;

    case TransactionTypeTags.TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE:
      return S.of(context).TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE_tag;
      break;

    case TransactionTypeTags.TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE:
      return S.of(context).TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE_tag;
      break;

    case TransactionTypeTags.TIME_REQUEST:
      return S.of(context).TIME_REQUEST_tag;
      break;

    case TransactionTypeTags.USER_DONATE_TOTIMEBANK:
      return S.of(context).USER_DONATE_TOTIMEBANK_tag;
      break;

    case TransactionTypeTags.USER_PAYLOAN_TOTIMEBANK:
      return S.of(context).USER_PAYLOAN_TOTIMEBANK_tag;
      break;

    default:
      return '';
  }
}

//
//TimelineTransactionTags For Requests Enums
//

enum TransactionTypeTags {
  ADMIN_DONATE_TOUSER,
  MANNUAL_TIME,
  OFFER_CREDIT_FROM_TIMEBANK,
  OFFER_CREDIT_TO_TIMEBANK,
  REQUEST_CREATION_TIMEBANK_FILL_CREDITS,
  SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE,
  TAX,
  TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE,
  TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE,
  TIME_REQUEST,
  USER_DONATE_TOTIMEBANK,
  USER_PAYLOAN_TOTIMEBANK,
  // RequestMode.TIMEBANK_REQUEST
//RequestMode.TIMEBANK_REQUEST
}

extension TransactionTypeLabel on TransactionTypeTags {
  String get readable {
    switch (this) {
      case TransactionTypeTags.ADMIN_DONATE_TOUSER:
        return 'ADMIN_DONATE_TOUSER';
      case TransactionTypeTags.MANNUAL_TIME:
        return 'MANNUAL_TIME';
      case TransactionTypeTags.OFFER_CREDIT_FROM_TIMEBANK:
        return 'OFFER_CREDIT_FROM_TIMEBANK';
      case TransactionTypeTags.OFFER_CREDIT_TO_TIMEBANK:
        return 'OFFER_CREDIT_TO_TIMEBANK';
      case TransactionTypeTags.REQUEST_CREATION_TIMEBANK_FILL_CREDITS:
        return 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS';
      case TransactionTypeTags.SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE:
        return 'SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE';
      case TransactionTypeTags.TAX:
        return 'TAX';
      case TransactionTypeTags.TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE:
        return 'TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE';
      case TransactionTypeTags.TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE:
        return 'TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE';
      case TransactionTypeTags.TIME_REQUEST:
        return 'TIME_REQUEST';
      case TransactionTypeTags.USER_DONATE_TOTIMEBANK:
        return 'USER_DONATE_TOTIMEBANK';
      case TransactionTypeTags.USER_PAYLOAN_TOTIMEBANK:
        return 'USER_PAYLOAN_TOTIMEBANK';

      default:
        return 'tagError $this';
    }
  }
}

TransactionTypeTags getConvertedTransactionTypeTag(String stringTag) {
  switch (stringTag) {
    case 'ADMIN_DONATE_TOUSER':
      return TransactionTypeTags.ADMIN_DONATE_TOUSER;
      break;

    case 'MANNUAL_TIME':
      return TransactionTypeTags.MANNUAL_TIME;
      break;

    case 'OFFER_CREDIT_FROM_TIMEBANK':
      return TransactionTypeTags.OFFER_CREDIT_FROM_TIMEBANK;
      break;

    case 'OFFER_CREDIT_TO_TIMEBANK':
      return TransactionTypeTags.OFFER_CREDIT_TO_TIMEBANK;
      break;

    case 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS':
      return TransactionTypeTags.REQUEST_CREATION_TIMEBANK_FILL_CREDITS;
      break;

    case 'SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE':
      return TransactionTypeTags.SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE;
      break;

    case 'TAX':
      return TransactionTypeTags.TAX;
      break;

    case 'TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE':
      return TransactionTypeTags.TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE;
      break;

    case 'TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE':
      return TransactionTypeTags.TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE;
      break;

    case 'TIME_REQUEST':
      return TransactionTypeTags.TIME_REQUEST;
      break;

    case 'USER_DONATE_TOTIMEBANK':
      return TransactionTypeTags.USER_DONATE_TOTIMEBANK;
      break;

    case 'USER_PAYLOAN_TOTIMEBANK':
      return TransactionTypeTags.USER_PAYLOAN_TOTIMEBANK;
      break;

    default:
      logger.i('tag error 2 $stringTag');
      return null!;
  }
}
