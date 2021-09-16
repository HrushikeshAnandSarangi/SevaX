import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

String getTimelineLabel(
    // RequestType requestType,
    String tag,
    BuildContext context) {
  String finalLabel = '';

  //convert string tag to timeline tag type
  TimelineTransactionTags convertedtTag =
      getConvertedTimelineTransactionTagsType(tag);

  logger.e('Initial LABEL: ' + tag);

  //return label according to tag for requests
  finalLabel = getTimelineLabelForRequests(convertedtTag, context);

  logger.e('FINAL LABEL: ' + finalLabel);

  return finalLabel == '' ? S.of(context).error_loading_status : finalLabel;
}

//
// Fetch Label Functions for Each type of request
//
getTimelineLabelForRequests(TimelineTransactionTags tag, BuildContext context) {
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
      return S.of(context).goods_pledged_by_donor_tag;
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
      break;
    default:
      return '';
  }
}

//
//TimelineTransactionTags For Requests Enums
//
enum TimelineTransactionTags {
  APPLIED_REQUEST,
  WITHDRAWN_REQUEST,
  REQUEST_APPROVED,
  REQUEST_REJECTED,
  CLAIM_CREDITS,
  CLAIM_ACCEPTED,
  CLAIM_DECLINED,
  PLEDGED_BY_DONOR,
  ACKNOWLEDGED_GOODS_DONATION,
  GOODS_DONATION_MODIFIED_BY_CREATOR,
  GOODS_DONATION_CREATOR_REJECTED,
  GOODS_DONATION_MODIFIED_BY_DONOR,
  ACKNOWLEDGED_MONEY_DONATION,
  MONEY_DONATION_MODIFIED_BY_CREATOR,
  MONEY_DONATION_CREATOR_REJECTED,
  MONEY_DONATION_MODIFIED_BY_DONOR,
  MONEY_DONATION_REJECTED_BY_CREATOR,
  GOODS_DONATION_REJECTED_BY_CREATOR,
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

      default:
        return 'Error Loading Type';
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

    default:
      return null;
  }
}




// getTimelineLabelForCashRequest(
//     CashRequestTransactionTags tag, BuildContext context) {}

// getTimelineLabelForGoodsRequest(tag, BuildContext context) {
//   switch (tag) {
//     case GoodsRequestTransactionTags.PLEDGED_BY_DONOR:
//       return S.of(context).goods_pledged_by_donor_tag;
//       break;
//     case GoodsRequestTransactionTags.ACKNOWLEDGED_GOODS_DONATION:
//       return S.of(context).goods_acknowledged_donation_tag;
//       break;
//     case GoodsRequestTransactionTags.GOODS_DONATION_MODIFIED_BY_CREATOR:
//       return S.of(context).goods_donation_modified_by_creator_tag;
//       break;
//     case GoodsRequestTransactionTags.GOODS_DONATION_CREATOR_REJECTED:
//       return S.of(context).goods_donation_creator_rejected_tag;
//       break;
//     case GoodsRequestTransactionTags.GOODS_DONATION_MODIFIED_BY_DONOR:
//       return S.of(context).goods_donation_modified_by_donor_tag;
//       break;
//   }
// }


//
//Goods Request Enums
//
// enum GoodsRequestTransactionTags {
//   PLEDGED_BY_DONOR,
//   ACKNOWLEDGED_GOODS_DONATION,
//   GOODS_DONATION_MODIFIED_BY_CREATOR,
//   GOODS_DONATION_CREATOR_REJECTED,
//   GOODS_DONATION_MODIFIED_BY_DONOR,
// }

// extension GoodsTransactionTagsLabel on GoodsRequestTransactionTags {
//   String get readable {
//     switch (this) {
//       case GoodsRequestTransactionTags.PLEDGED_BY_DONOR:
//         return 'PLEDGED_BY_DONOR';
//       case GoodsRequestTransactionTags.ACKNOWLEDGED_GOODS_DONATION:
//         return 'ACKNOWLEDGED_GOODS_DONATION';
//       case GoodsRequestTransactionTags.GOODS_DONATION_MODIFIED_BY_CREATOR:
//         return 'GOODS_DONATION_MODIFIED_BY_CREATOR';
//       case GoodsRequestTransactionTags.GOODS_DONATION_CREATOR_REJECTED:
//         return 'GOODS_DONATION_CREATOR_REJECTED';
//       case GoodsRequestTransactionTags.GOODS_DONATION_MODIFIED_BY_DONOR:
//         return 'GOODS_DONATION_MODIFIED_BY_DONOR';

//       default:
//         return 'Error Loading Type';
//     }
//   }
// }
