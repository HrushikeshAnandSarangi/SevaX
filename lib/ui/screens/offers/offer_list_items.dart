import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_request/createrequest.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../flavor_config.dart';

class OfferListItems extends StatelessWidget {
  final String? timebankId;
  final BuildContext? parentContext;
  final TimebankModel? timebankModel;

  OfferListItems(
      {Key? key, this.parentContext, this.timebankId, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    logger.i("in offerlist build $timebankId");
    return StreamBuilder<List<OfferModel>>(
      stream: getOffersStream(
        timebankId: timebankId!,
        loggedInMemberSevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!,
      ),
      builder:
          (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
        if (snapshot.hasError) {
          return Text(
            '${S.of(context).general_stream_error}',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        List<OfferModel> offersList = snapshot.data!;
        offersList = filterBlockedOffersContent(
          context: context,
          requestModelList: offersList,
        );

        if (offersList.length == 0) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: EmptyWidget(
                title: S.of(context).no_offers_title,
                sub_title: S.of(context).no_content_common_description,
                titleFontSize: 16.0,
              ),
            ),
          );
        }
        var consolidatedList = GroupOfferCommons.groupAndConsolidateOffers(
            offersList, SevaCore.of(context).loggedInUser.sevaUserID!);
        return formatListOffer(consolidatedList: consolidatedList);
      },
    );
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel>? requestModelList, BuildContext? context}) {
    List<OfferModel> filteredList = [];
    requestModelList!.forEach((request) {
      if (!(SevaCore.of(context!)
              .loggedInUser
              .blockedMembers!
              .contains(request.sevaUserId) ||
          SevaCore.of(context)
              .loggedInUser
              .blockedBy!
              .contains(request.sevaUserId))) {
        filteredList.add(request);
      }
    });
    return filteredList;
  }

  Widget formatListOffer({List<OfferModelList>? consolidatedList}) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: consolidatedList!.length + 1,
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
            (offerModelList as OfferTitle).groupTitle!.contains("My");
        return Container(
          height: isMyContent ? 0 : 25,
          margin: isMyContent
              ? EdgeInsets.all(0)
              : EdgeInsets.fromLTRB(5, 12, 12, 18),
          child: Text(
            GroupOfferCommons.getGroupTitleForOffer(
              groupKey: (offerModelList as OfferTitle).groupTitle,
              context: context,
              isGroup: !isPrimaryTimebank(
                parentTimebankId: timebankModel!.parentTimebankId,
              ),
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      case OfferModelList.OFFER:
        return getOfferViewHolder(
            context, (offerModelList as OfferItem).offerModel!);
      default:
        return Container(); // Return an empty container as fallback
    }
  }

  void _navigateToOfferDetails(OfferModel model) {
    Navigator.push(
      parentContext!,
      MaterialPageRoute(
        builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(parentContext!),
            child: OfferDetailsRouter(
              offerModel: model,
              comingFrom: ComingFrom.Offers,
            )),
      ),
    );
  }

  Widget getOfferViewHolder(context, OfferModel model) {
    return OfferCard(
      isCardVisible: isOfferVisible(
        model,
        SevaCore.of(parentContext!).loggedInUser.sevaUserID!,
      ),
      requestType: model.type!,
      public: model.public!,
      virtual: model.virtual!,
      userCoordinates: model.location?.geopoint,
      offerCoordinates: model.location!.geopoint,
      isAutoGenerated: model.autoGenerated,
      isRecurring: model.isRecurring,
      type: model.type,
      isCreator: model.email == SevaCore.of(parentContext!).loggedInUser.email,
      title: getOfferTitle(offerDataModel: model),
      subtitle: getOfferDescription(offerDataModel: model),
      offerType: model.offerType!,
      startDate: model?.groupOfferDataModel?.startDate,
      selectedAddress: model.selectedAdrress,
      actionButtonLabel: getButtonLabel(
          context, model, SevaCore.of(parentContext!).loggedInUser.sevaUserID!),
      buttonColor:
          (model.type == RequestType.CASH || model.type == RequestType.GOODS)
              ? Theme.of(parentContext!).primaryColor
              : isParticipant(parentContext!, model)
                  ? Colors.grey
                  : Theme.of(parentContext!).primaryColor,
      onCardPressed: () async {
        // if goods/cash and not the creator and not a admin trying accept donation show dialog
        if (model.type != RequestType.TIME &&
            model.email != SevaCore.of(context).loggedInUser.email &&
            !isAccessAvailable(
              timebankModel!,
              SevaCore.of(context).loggedInUser.sevaUserID!,
            )) {
          adminCheckToAcceptOfferDialog(context);
          return;
        }

        if (model.isRecurring!) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_context) => BlocProvider(
                  bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                  child: RecurringListing(
                    offerModel: model,
                    timebankModel: timebankModel,
                    requestModel:
                        RequestModel(communityId: timebankModel!.communityId),
                    comingFrom: ComingFrom.Offers,
                  ),
                ),
              ));
          // Navigator.push(
          //   parentContext,
          //   MaterialPageRoute(
          //     builder: (context) => RecurringListing(
          //       offerModel: model,
          //       timebankModel: timebankModel,
          //       requestModel: null,
          //       comingFrom: ComingFrom.Offers,
          //     ),
          //   ),
          // );
        } else {
          _navigateToOfferDetails(model);
        }
      },
      onActionPressed: () async {
        bool isAccepted = getOfferParticipants(offerDataModel: model)
            .contains(model.sevaUserId);
        // if goods/cash and not the creator and not a admin trying accept donation show dialog
        if (model.type != RequestType.TIME &&
            model.email != SevaCore.of(context).loggedInUser.email &&
            !isAccessAvailable(timebankModel!,
                SevaCore.of(context).loggedInUser.sevaUserID!)) {
          adminCheckToAcceptOfferDialog(context);
          return;
        }

        if (model.type == RequestType.CASH ||
            model.type == RequestType.GOODS && !isAccepted) {
          navigateToDonations(context, model);
        } else {
          offerActions(parentContext!, model, ComingFrom.Offers);
        }
      },
    );
  }

  void navigateToCreateRequestFromOffer(context, OfferModel offerModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRequest(
          comingFrom: ComingFrom.Offers,
          isOfferRequest: true,
          offer: offerModel,
          projectId: '',
          requestModel: RequestModel(communityId: offerModel.communityId),
          projectModel: ProjectModel(),
          timebankId: offerModel.timebankId!,
          userModel: SevaCore.of(context).loggedInUser,
        ),
      ),
    );
  }

  Future<bool> adminCheckToAcceptOfferDialog(BuildContext context) async {
    return CustomDialogs.generalDialogWithCloseButton(
      context,
      // 'Only admin can accept Goods/Cash offers',
      // 'Only Community admins can accept offers of money / goods',
      S.of(context).only_community_admins_can_accept,
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
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel!.calendar_sync!,
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
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel!.calendar_sync!,
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
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel!.calendar_sync!,
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
                    CustomTextButton(
//                        child: Text(S.of(context).skip_for_now, style: TextStyle(color: Theme.of(context).primaryColor),),
                        shape: StadiumBorder(),
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          S.of(context).do_it_later,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
                        ),
                        onPressed: () {
                          Navigator.of(bc).pop();
                          offerActions(
                              parentContext!, model, ComingFrom.Offers);
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
