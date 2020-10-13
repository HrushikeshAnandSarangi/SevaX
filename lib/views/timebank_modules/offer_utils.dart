import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/calender_event_confirm_dialog.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../../flavor_config.dart';
import '../core.dart';

String getCashDonationAmount({OfferModel offerDataModel}) {
  String TAGET_NOT_DEFINED = '';
  return offerDataModel.type == RequestType.CASH
      ? offerDataModel.cashModel.targetAmount.toString()
      : TAGET_NOT_DEFINED;
}

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
  if (offerDataModel.type == RequestType.GOODS) {
    return offerDataModel.goodsDonationDetails.donors ?? [];
  } else if (offerDataModel.type == RequestType.CASH) {
    return offerDataModel.cashModel.donors ?? [];
  } else {
    return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
        ? offerDataModel.individualOfferDataModel.offerAcceptors ?? []
        : offerDataModel.groupOfferDataModel.signedUpMembers ?? [];
  }
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
    return null;
  }
}

String getFormatedTimeFromTimeStamp(
    {int timeStamp, String timeZone, String format = "EEEEEEE, MMMM dd"}) {
  return DateFormat(format,
          Locale(AppConfig.prefs.getString('language_code')).toLanguageTag())
      .format(
    getDateTimeAccToUserTimezone(
        dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
        timezoneAbb: timeZone),
  );
}

bool isOfferVisible(OfferModel offerModel, String userId) {
  var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
  if (offerModel.offerType == OfferType.GROUP_OFFER) {
    if (offerModel.groupOfferDataModel.signedUpMembers.length ==
            offerModel.groupOfferDataModel.sizeOfClass ||
        offerModel.groupOfferDataModel.endDate < currentTimeStamp) {
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

String getButtonLabel(context, OfferModel offerModel, String userId) {
  List<String> participants = getOfferParticipants(offerDataModel: offerModel);
  if (offerModel.offerType == OfferType.GROUP_OFFER) {
    if (participants.contains(userId))
      return S.of(context).signed_up;
    else
      return S.of(context).sign_up;
  } else {
    if (offerModel.type == RequestType.CASH ||
        offerModel.type == RequestType.GOODS) {
      if (participants.contains(userId)) {
        return S.of(context).accepted_offer;
      } else {
        return S.of(context).accept_offer;
      }
    } else if (participants.contains(userId))
      return S.of(context).bookmarked.firstWordUpperCase();
    else
      return S.of(context).bookmark.firstWordUpperCase();
  }
}

Future<void> deleteOffer({
  BuildContext context,
  String offerId,
}) async {
  bool status = false;
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          S.of(context).delete_offer,
        ),
        content: Text(
          S.of(context).delete_offer_confirmation,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              S.of(context).cancel,
              style: TextStyle(fontSize: dialogButtonSize, color: Colors.red),
            ),
          ),
          FlatButton(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            color: Theme.of(context).accentColor,
            textColor: FlavorConfig.values.buttonTextColor,
            onPressed: () async {
              await Firestore.instance
                  .collection("offers")
                  .document(offerId)
                  .updateData({'softDelete': true});
              Navigator.of(dialogContext).pop();
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).delete,
            ),
          ),
        ],
      );
    },
  );
}

void removeBookmark(String offerId, String userId) {
  Firestore.instance.collection("offers").document(offerId).updateData({
    'individualOfferDataModel.offerAcceptors': FieldValue.arrayRemove([userId])
  });
}

void addBookMark(String offerId, String userId) {
  Firestore.instance.collection("offers").document(offerId).updateData({
    'individualOfferDataModel.offerAcceptors': FieldValue.arrayUnion([userId])
  });
}

bool isParticipant(BuildContext context, OfferModel model) {
  return getOfferParticipants(offerDataModel: model)
      .contains(SevaCore.of(context).loggedInUser.sevaUserID);
}

Future<bool> offerActions(BuildContext context, OfferModel model) async {
  var _userId = SevaCore.of(context).loggedInUser.sevaUserID;
  bool _isParticipant = getOfferParticipants(offerDataModel: model)
      .contains(SevaCore.of(context).loggedInUser.sevaUserID);

  if (model.offerType == OfferType.GROUP_OFFER && !_isParticipant) {
    //Check balance here
    var hasSufficientCredits = await FirestoreManager.hasSufficientCredits(
      credits: model.groupOfferDataModel.numberOfClassHours.toDouble(),
      userId: _userId,
    );

    if (hasSufficientCredits) {
      var myUserID = SevaCore.of(context).loggedInUser.sevaUserID;
      var email = SevaCore.of(context).loggedInUser.email;

      await confirmationDialog(
        context: context,
        title:
            "You are signing up for this ${model.groupOfferDataModel.classTitle.trim()}. Doing so will debit a total of ${model.groupOfferDataModel.numberOfClassHours} credits from you after you say OK.",
        onConfirmed: () {
          if (SevaCore.of(context).loggedInUser.calendarId != null) {
            showDialog(
              context: context,
              builder: (_context) {
                return CalenderEventConfirmationDialog(
                  title: model.groupOfferDataModel.classTitle,
                  isrequest: false,
                  cancelled: () async {
                    updateOffer(
                        offerId: model.id,
                        userId: myUserID,
                        userEmail: email,
                        allowCalenderEvent: false);

                    Navigator.of(_context).pop();
                  },
                  addToCalender: () async {
                    updateOffer(
                        offerId: model.id,
                        userId: myUserID,
                        userEmail: email,
                        allowCalenderEvent: true);

                    Navigator.of(_context).pop();
                  },
                );
              },
            );
          } else {
            updateOffer(
                offerId: model.id,
                userId: myUserID,
                userEmail: email,
                allowCalenderEvent: false);
          }
        },
      );
    } else {
      await errorDialog(
        context: context,
        error: "You don't have enough credit to signup for this class",
      );
    }
  } else if ((model.type == RequestType.CASH ||
      model.type == RequestType.GOODS)) {
//    if (!_isParticipant) addBookMark(model.id, _userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  } else {
    if (!_isParticipant) addBookMark(model.id, _userId);
  }
  return true;
}

void updateOffer(
    {String userId,
    bool allowCalenderEvent,
    String userEmail,
    String offerId}) {
  if (allowCalenderEvent) {
    Firestore.instance.collection("offers").document(offerId).updateData({
      'groupOfferDataModel.signedUpMembers': FieldValue.arrayUnion(
        [userId],
      ),
      'allowedCalenderUsers': FieldValue.arrayUnion(
        [userEmail],
      )
    });
  } else {
    Firestore.instance.collection("offers").document(offerId).updateData({
      'groupOfferDataModel.signedUpMembers': FieldValue.arrayUnion(
        [userId],
      )
    });
  }
}
