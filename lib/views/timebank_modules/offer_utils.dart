import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
  return DateFormat(format, Locale(getLangTag()).toLanguageTag()).format(
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
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
            ),
            child: CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Colors.grey,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.white,
                  fontFamily: 'Europa',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
              right: 15,
            ),
            child: CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              onPressed: () async {
                await CollectionRef.offers
                    .doc(offerId)
                    .update({'softDelete': true});
                Navigator.of(dialogContext).pop();
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).delete,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.white,
                  fontFamily: 'Europa',
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void removeBookmark(String offerId, String userId) {
  CollectionRef.offers.doc(offerId).update({
    'individualOfferDataModel.offerAcceptors': FieldValue.arrayRemove([userId])
  });
}

void addBookMark(String offerId, String userId) {
  CollectionRef.offers.doc(offerId).update({
    'individualOfferDataModel.offerAcceptors': FieldValue.arrayUnion([userId])
  });
}

bool isParticipant(BuildContext context, OfferModel model) {
  return getOfferParticipants(offerDataModel: model)
      .contains(SevaCore.of(context).loggedInUser.sevaUserID);
}

Future<bool> offerActions(
    BuildContext context, OfferModel model, ComingFrom comingFromVar) async {
  var _userId = SevaCore.of(context).loggedInUser.sevaUserID;
  bool _isParticipant = getOfferParticipants(offerDataModel: model)
      .contains(SevaCore.of(context).loggedInUser.sevaUserID);

  if (model.offerType == OfferType.GROUP_OFFER && !_isParticipant) {
    //Check balance here
    var hasSufficientCreditsResult =
        await SevaCreditLimitManager.hasSufficientCredits(
      email: SevaCore.of(context).loggedInUser.email,
      credits: model.groupOfferDataModel.numberOfClassHours.toDouble(),
      userId: _userId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );

    CommunityModel communityMoel;
    await CollectionRef.communities
        .doc(SevaCore.of(context).loggedInUser.currentCommunity)
        .get()
        .then((value) {
      communityMoel = CommunityModel(value.data());
    });

    if (hasSufficientCreditsResult.hasSuffiientCredits) {
      var myUserID = SevaCore.of(context).loggedInUser.sevaUserID;
      var email = SevaCore.of(context).loggedInUser.email;

      await confirmationDialog(
        context: context,
        title:
            "You are signing up for this ${model.groupOfferDataModel.classTitle.trim()}. Doing so will debit a total of ${model.groupOfferDataModel.numberOfClassHours} credits from you after you say OK.",
        onConfirmed: () async {
          if (SevaCore.of(context).loggedInUser.calendarId != null) {
            await updateOffer(
              offerId: model.id,
              userId: myUserID,
              userEmail: email,
              allowCalenderEvent: true,
              communityId: communityMoel.id,
              communityName: communityMoel.name,
              memberName: SevaCore.of(context).loggedInUser.fullname,
              memberPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
              timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
            );
          } else {
            await updateOffer(
              offerId: model.id,
              userId: myUserID,
              userEmail: email,
              allowCalenderEvent: false,
              communityId: communityMoel.id,
              communityName: communityMoel.name,
              memberName: SevaCore.of(context).loggedInUser.fullname,
              memberPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
              timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
            );
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
    switch (comingFromVar) {
      case ComingFrom.Offers:
        // TODO: navigate to offerdetails router from offers router.

        break;
      case ComingFrom.Elasticsearch:
//        ExtendedNavigator.ofRouter<ElasticsearchRouter>()
//            .pushOfferDetailsRouterElastic(
//          offerModel: model,
//          comingFrom: ComingFrom.Elasticsearch,
//        );
        break;
      //no need to handle below cases as it is only for offers so user comes from either offers router or elasticsearch router
      case ComingFrom.Requests:
      case ComingFrom.Projects:
      case ComingFrom.Chats:
      case ComingFrom.Groups:
      case ComingFrom.Settings:
      case ComingFrom.Members:
      case ComingFrom.Profile:
      case ComingFrom.Home:
      case ComingFrom.Billing:
        break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_context) => BlocProvider(
          bloc: BlocProvider.of<HomeDashBoardBloc>(context),
          child: OfferDetailsRouter(
            offerModel: model,
            comingFrom: comingFromVar,
          ),
        ),
      ),
    );
  } else {
    if (!_isParticipant) addBookMark(model.id, _userId);
  }
  return true;
}

void updateOffer({
  String userId,
  bool allowCalenderEvent,
  String userEmail,
  String offerId,
  @required String communityId,
  @required String communityName,
  @required String memberName,
  @required String memberPhotoUrl,
  @required String timebankId,
}) {
  CollectionRef.offers.doc(offerId).update(
    {
      'groupOfferDataModel.signedUpMembers': FieldValue.arrayUnion(
        [userId],
      ),
      if (allowCalenderEvent)
        'allowedCalenderUsers': FieldValue.arrayUnion(
          [userEmail],
        ),
      'participantDetails.' + userId: AcceptorModel(
        communityId: communityId,
        communityName: communityName,
        memberEmail: userEmail,
        memberName: memberName,
        memberPhotoUrl: memberPhotoUrl,
        timebankId: timebankId,
      ).toMap()
    },
  );
}
