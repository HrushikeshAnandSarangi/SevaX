import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../flavor_config.dart';

class OfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  final TimebankModel timebankModel;
  String sevaUserId;
  OfferListItems(
      {Key key, this.parentContext, this.timebankId, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    return StreamBuilder<List<OfferModel>>(
      stream: getOffersStream(timebankId: timebankId),
      builder:
          (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
        if (snapshot.hasError)
          return Text('${S.of(context).general_stream_error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return LoadingIndicator();
          default:
            List<OfferModel> offersList = snapshot.data;
            offersList = filterBlockedOffersContent(
                context: context, requestModelList: offersList);
            if (offersList.length == 0) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(S.of(context).no_offers),
                ),
              );
            }
            var consolidatedList = GroupOfferCommons.groupAndConsolidateOffers(
                offersList, SevaCore.of(context).loggedInUser.sevaUserID);
            return formatListOffer(consolidatedList: consolidatedList);
        }
      },
    );
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel> requestModelList, BuildContext context}) {
    List<OfferModel> filteredList = [];
    requestModelList.forEach((request) {
      if (!(SevaCore.of(context)
              .loggedInUser
              .blockedMembers
              .contains(request.sevaUserId) ||
          SevaCore.of(context)
              .loggedInUser
              .blockedBy
              .contains(request.sevaUserId))) {
        filteredList.add(request);
      }
    });
    return filteredList;
  }

  Widget formatListOffer({List<OfferModelList> consolidatedList}) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: consolidatedList.length + 1,
            itemBuilder: (context, index) {
              if (index >= consolidatedList.length) {
                return Container(
                  width: double.infinity,
                  height: 65,
                );
              }
              return getOfferWidget(consolidatedList[index], context);
            }),
      ),
    );
  }

  Widget getOfferWidget(OfferModelList model, BuildContext context) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: getOfferView(model, context),
    );
  }

  Widget getOfferView(OfferModelList offerModelList, BuildContext context) {
    switch (offerModelList.getType()) {
      case OfferModelList.TITLE:
        var isMyContent =
            (offerModelList as OfferTitle).groupTitle.contains("My");
        return Container(
          height: isMyContent ? 0 : 25,
          margin: isMyContent
              ? EdgeInsets.all(0)
              : EdgeInsets.fromLTRB(5, 12, 12, 18),
          child: Text(
            GroupOfferCommons.getGroupTitleForOffer(
                groupKey: (offerModelList as OfferTitle).groupTitle,
                context: context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      case OfferModelList.OFFER:
        return getOfferViewHolder(
            context, (offerModelList as OfferItem).offerModel);
    }
  }

  void _navigateToOfferDetails(OfferModel model) {
    Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  }

  Widget getOfferViewHolder(context, OfferModel model) {
    return OfferCard(
      isCardVisible: isOfferVisible(
        model,
        SevaCore.of(parentContext).loggedInUser.sevaUserID,
      ),
      userCoordinates: model.currentUserLocation,
      offerCoordinates: model.location?.coords,
      isAutoGenerated: model.autoGenerated,
      isRecurring: model.isRecurring,
      type: model.type,
      isCreator: model.email == SevaCore.of(parentContext).loggedInUser.email,
      title: getOfferTitle(offerDataModel: model),
      subtitle: getOfferDescription(offerDataModel: model),
      offerType: model.offerType,
      startDate: model?.groupOfferDataModel?.startDate,
      selectedAddress: model.selectedAdrress,
      actionButtonLabel: getButtonLabel(
          context, model, SevaCore.of(parentContext).loggedInUser.sevaUserID),
      buttonColor:
          (model.type == RequestType.CASH || model.type == RequestType.GOODS)
              ? Theme.of(parentContext).primaryColor
              : isParticipant(parentContext, model)
                  ? Colors.grey
                  : Theme.of(parentContext).primaryColor,
      onCardPressed: () async {
        if (model.isRecurring) {
          Navigator.push(
              parentContext,
              MaterialPageRoute(
                  builder: (context) => RecurringListing(
                        offerModel: model,
                        timebankModel: timebankModel,
                        requestModel: null,
                      )));
        } else {
          _navigateToOfferDetails(model);
        }
      },
      onActionPressed: () async {
        if (SevaCore.of(parentContext).loggedInUser.calendarId == null &&
            model.offerType == OfferType.GROUP_OFFER) {
          _settingModalBottomSheet(parentContext, model);
        } else {
          offerActions(parentContext, model);
        }
      },
    );
  }

  void navigateToDonations(context, OfferModel offerModel) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DonationView(
                  offerModel: offerModel,
                  timabankName: '',
                  requestModel: null,
                  notificationId: null,
              ),
          ),
      );
  }

  void _settingModalBottomSheet(context, OfferModel model) {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": []
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    S.of(context).calendars_popup_desc,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/googlecal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                            }),
                      ),
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/outlookcal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                            }),
                      ),
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset("lib/assets/images/ical.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                            }),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
//                        child: Text(S.of(context).skip_for_now, style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                        child: Text(
                          S.of(context).do_it_later,
                          style: TextStyle(
                              color: FlavorConfig.values.theme.primaryColor),
                        ),
                        onPressed: () {
                          Navigator.of(bc).pop();
                          offerActions(parentContext, model);
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(0),
          spreadRadius: 4,
          offset: Offset(0, 3),
          blurRadius: 6,
        )
      ],
      color: Colors.white,
    );
  }
}
