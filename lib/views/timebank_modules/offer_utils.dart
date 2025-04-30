import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/module/index.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../flavor_config.dart';
import '../core.dart';

String getCashDonationAmount({required OfferModel offerDataModel}) {
  String TAGET_NOT_DEFINED = '';
  return offerDataModel.type == RequestType.CASH
      ? offerDataModel.cashModel?.targetAmount.toString() ?? TAGET_NOT_DEFINED
      : TAGET_NOT_DEFINED;
}

String getOfferTitle({required OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel?.title ?? ''
      : offerDataModel.groupOfferDataModel?.classTitle ?? '';
}

String getOfferDescription({required OfferModel offerDataModel}) {
  return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
      ? offerDataModel.individualOfferDataModel?.description ?? ''
      : offerDataModel.groupOfferDataModel?.classDescription ?? '';
}

List<String> getOfferParticipants({required OfferModel offerDataModel}) {
  if (offerDataModel.type == RequestType.GOODS) {
    return offerDataModel.goodsDonationDetails?.donors ?? [];
  } else if (offerDataModel.type == RequestType.CASH) {
    return offerDataModel.cashModel?.donors ?? [];
  } else if (offerDataModel.type == RequestType.LENDING_OFFER) {
    return offerDataModel.lendingOfferDetailsModel?.offerAcceptors ?? [];
  } else {
    return offerDataModel.offerType == OfferType.INDIVIDUAL_OFFER
        ? offerDataModel.individualOfferDataModel?.offerAcceptors ?? []
        : offerDataModel.groupOfferDataModel?.signedUpMembers ?? [];
  }
}

String getOfferLocation({required String selectedAddress}) {
  if (selectedAddress.contains(',')) {
    var slices = selectedAddress.split(',');
    return selectedAddress.split(',')[slices.length - 1];
  } else {
    return selectedAddress;
  }
}

String getFormatedTimeFromTimeStamp(
    {required int timeStamp,
    required String timeZone,
    String format = "EEEEEEE, MMMM dd"}) {
  return DateFormat(format, Locale(getLangTag()).toLanguageTag()).format(
    getDateTimeAccToUserTimezone(
        dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
        timezoneAbb: timeZone),
  );
}

bool isOfferVisible(OfferModel offerModel, String userId) {
  var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
  if (offerModel.offerType == OfferType.GROUP_OFFER) {
    if (offerModel.groupOfferDataModel?.signedUpMembers?.length ==
            offerModel.groupOfferDataModel?.sizeOfClass ||
        (offerModel.groupOfferDataModel?.endDate ?? 0) < currentTimeStamp) {
      if (offerModel.groupOfferDataModel?.signedUpMembers?.contains(userId) ??
          false) {
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
  BuildContext? context,
  String? offerId,
}) async {
  bool status = false;
  await showDialog(
    context: context!,
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
              color: Theme.of(context).colorScheme.secondary,
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
      email: SevaCore.of(context).loggedInUser.email!,
      credits: model.groupOfferDataModel?.numberOfClassHours?.toDouble() ?? 0.0,
      userId: _userId!,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity!,
    );

    late CommunityModel communityMoel;
    await CollectionRef.communities
        .doc(SevaCore.of(context).loggedInUser.currentCommunity)
        .get()
        .then((value) {
      communityMoel = CommunityModel(value.data() as Map<String, dynamic>);
    });

    if (hasSufficientCreditsResult.hasSuffiientCredits) {
      var myUserID = SevaCore.of(context).loggedInUser.sevaUserID ?? '';
      var email = SevaCore.of(context).loggedInUser.email ?? '';

      await confirmationDialog(
        context: context,
        title:
            "${S.of(context).you_are_signing_up_for_this_test} ${model.groupOfferDataModel?.classTitle!.trim()}. ${S.of(context).doing_so_will_debit_a_total_of} ${model.groupOfferDataModel?.numberOfClassHours} ${S.of(context).credits_from_you_after_you_say_ok}.",
        onConfirmed: () async {
          await updateOffer(
            offerId: model.id ?? '',
            userId: myUserID,
            userEmail: email,
            allowCalenderEvent: true,
            communityId: communityMoel.id,
            communityName: communityMoel.name,
            memberName: SevaCore.of(context).loggedInUser.fullname ?? '',
            memberPhotoUrl: SevaCore.of(context).loggedInUser.photoURL ?? '',
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank ?? '',
          ).then((value) => {
                if (true)
                  {
                    KloudlessWidgetManager<ApplyMode, OfferModel>()
                        .syncCalendar(
                      context: context,
                      builder: KloudlessWidgetBuilder()
                          .fromContext<ApplyMode, OfferModel>(
                        context: context,
                        id: model.id ?? '',
                        model: model,
                      ),
                    )
                  }
              });
        },
      );
    } else {
      await errorDialog(
        context: context,
        error:
            "${S.of(context).you_don_t_have_enough_credit_to_signup_for_this_class}",
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
    if (!_isParticipant && model.id != null) addBookMark(model.id!, _userId!);
  }
  return true;
}

Future<bool> updateOffer({
  String? userId,
  bool? allowCalenderEvent,
  String? userEmail,
  String? offerId,
  required String communityId,
  required String communityName,
  required String memberName,
  required String memberPhotoUrl,
  required String timebankId,
}) async {
  return await CollectionRef.offers
      .doc(offerId)
      .update(
        {
          'groupOfferDataModel.signedUpMembers': FieldValue.arrayUnion(
            [userId],
          ),
          if (allowCalenderEvent!)
            'allowedCalenderUsers': FieldValue.arrayUnion(
              [userEmail],
            ),
          'participantDetails.' + userId!: AcceptorModel(
            communityId: communityId,
            communityName: communityName,
            memberEmail: userEmail,
            memberName: memberName,
            memberPhotoUrl: memberPhotoUrl,
            timebankId: timebankId,
          ).toMap()
        },
      )
      .then((value) => true)
      .catchError((onError) => false);
}

Future<void> handleFeedBackNotificationLendingOffer({
  required BuildContext context,
  required OfferModel offerModel,
  required String notificationId,
  required String email,
  required FeedbackType feedbackType,
  required LendingOfferAcceptorModel lendingOfferAcceptorModel,
}) async {
  Map results = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ReviewFeedback(
        feedbackType:
            feedbackType, //if new questions then have to change this and update
      ),
    ),
  );

  if (results.containsKey('selection')) {
    CollectionRef.reviews.add(
      {
        "reviewer": email,
        "reviewed":
            feedbackType == FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER
                ? lendingOfferAcceptorModel.acceptorEmail
                : offerModel.email,
        "ratings": results['selection'],
        "requestId": offerModel.id,
        "comments": results['didComment'] ? results['comment'] : "No comments",
        'liveMode': !AppConfig.isTestCommunity,
      },
    );

    await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
      feedbackType,
      results,
      RequestModel(
          communityId:
              SevaCore.of(context).loggedInUser.currentCommunity ?? ''),
      SevaCore.of(context).loggedInUser,
      offerModel: offerModel,
      borrowerEmail: lendingOfferAcceptorModel.acceptorEmail,
    );
    if (feedbackType == FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER) {
      lendingOfferAcceptorModel.isLenderGaveReview = true;
      await LendingOffersRepo.updateLendingParticipantModel(
          offerId: offerModel.id!, model: lendingOfferAcceptorModel);
    } else {
      lendingOfferAcceptorModel.isBorrowerGaveReview = true;
      await LendingOffersRepo.updateLendingParticipantModel(
          offerId: offerModel.id!, model: lendingOfferAcceptorModel);
    }

    var loggedInUser = SevaCore.of(context).loggedInUser;
    if (feedbackType == FeedbackType.FEEDBACK_FOR_LENDER_FROM_BORROWER) {
      ParticipantInfo receiver = ParticipantInfo(
        id: offerModel.sevaUserId,
        photoUrl: offerModel.photoUrlImage,
        name: offerModel.fullName,
        type: ChatType.TYPE_PERSONAL,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: ChatType.TYPE_PERSONAL,
      );
      await sendBackgroundMessage(
          messageContent: getReviewMessage(
            reviewMessage:
                results['didComment'] ? results['comment'] : "No comments",
            userName: loggedInUser.fullname,
            context: context,
            requestTitle: offerModel.individualOfferDataModel?.title ?? '',
            isForCreator: true,
            isOfferReview: true,
          ),
          reciever: receiver,
          isTimebankMessage: false,
          timebankId: '',
          communityId: loggedInUser.currentCommunity ?? '',
          sender: sender);
    } else {
      ParticipantInfo receiver = ParticipantInfo(
        id: lendingOfferAcceptorModel.acceptorId,
        photoUrl: lendingOfferAcceptorModel.acceptorphotoURL,
        name: lendingOfferAcceptorModel.acceptorName,
        type: ChatType.TYPE_PERSONAL,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: ChatType.TYPE_PERSONAL,
      );
      await sendBackgroundMessage(
          messageContent: getReviewMessage(
            reviewMessage:
                results['didComment'] ? results['comment'] : "No comments",
            userName: loggedInUser.fullname,
            context: context,
            requestTitle: offerModel.individualOfferDataModel?.title,
            isForCreator: false,
            isOfferReview: true,
          ),
          reciever: receiver,
          isTimebankMessage: false,
          timebankId: '',
          communityId: loggedInUser.currentCommunity ?? '',
          sender: sender);
    }
    {
      NotificationsRepository.readUserNotification(notificationId, email);
    }
  }
}
