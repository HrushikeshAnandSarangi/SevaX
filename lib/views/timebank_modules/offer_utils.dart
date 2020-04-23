import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

import '../core.dart';

String getOfferTitle({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.title
      : offerDataModel.groupOfferDataModel.classTitle;
}

String getOfferDescription({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.description
      : offerDataModel.groupOfferDataModel.classDescription;
}

List<String> getOfferParticipants({OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel.offerAcceptors ?? []
      : offerDataModel.groupOfferDataModel.signedUpMembers ?? [];
}

String getOfferLocation({String selectedAddress}) {
  if (selectedAddress != null) {
    if (selectedAddress.contains(',')) {
      var slices = selectedAddress.split(',');
      return selectedAddress.split(',')[slices.length - 1];
    } else {
      return selectedAddress;
    }
  } else {
    return "Anonymous";
  }
}

String getFormatedTimeFromTimeStamp(
    {int timeStamp, String timeZone, String format = "EEEEEEE, MMMM dd"}) {
  return DateFormat(format).format(
    getDateTimeAccToUserTimezone(
        dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
        timezoneAbb: timeZone),
  );
}

bool isOfferVisible(OfferModel offerModel, String userId) {
  if (offerModel.offerType == OfferType.GROUP_OFFER) {
    if (offerModel.groupOfferDataModel.signedUpMembers.length ==
        offerModel.groupOfferDataModel.sizeOfClass) {
      if (offerModel.groupOfferDataModel.signedUpMembers.contains(userId)) {
        return false;
      } else if (offerModel.sevaUserId == userId) {
        return false;
      }
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

String getButtonLabel(OfferModel offerModel, String userId) {
  if (offerModel.offerType == OfferType.GROUP_OFFER) {
    if (offerModel.groupOfferDataModel.signedUpMembers.contains(userId))
      return "SignedUp";
    else
      return "SignUp";
  } else {
    if (offerModel.individualOfferDataModel.offerAcceptors.contains(userId))
      return "Bookmarked";
    else
      return "Bookmark";
  }
}

Future<bool> offerActions(BuildContext context, OfferModel model) async {
  var _userId = SevaCore.of(context).loggedInUser.sevaUserID;
  bool _isParticipant = getOfferParticipants(offerDataModel: model)
      .contains(SevaCore.of(context).loggedInUser.sevaUserID);

  if (model.offerType == OfferType.GROUP_OFFER && !_isParticipant) {
    //Check balance here
    if (true) {
      await confirmationDialog(
        context: context,
        title:
            "You are signing up for this ${model.groupOfferDataModel.classTitle.trim()}. Doing so will debit a total of ${model.groupOfferDataModel.numberOfClassHours} credits from you after you say OK.",
        onConfirmed: () {
          var myUserID = SevaCore.of(context).loggedInUser.sevaUserID;
          Firestore.instance
              .collection("offers")
              .document(model.id)
              .updateData({
            'groupOfferDataModel.signedUpMembers': FieldValue.arrayUnion(
              [myUserID],
            )
          });
        },
      );
    } else {
      await errorDialog(
        context: context,
        error: "You don't have enough credit to signup for this class",
      );
    }
  } else {
    Firestore.instance.collection("offers").document(model.id).updateData(
      {
        'individualOfferDataModel.offerAcceptors': _isParticipant
            ? FieldValue.arrayRemove([_userId])
            : FieldValue.arrayUnion([_userId])
      },
    );
  }
  return true;
}
