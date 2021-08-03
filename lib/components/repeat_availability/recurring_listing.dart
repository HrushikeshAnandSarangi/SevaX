import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_list_data_manager.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';

enum ComingToRecurringFrom {
  RecurringRequest,
  RecurringOffer,
  RecurringElastic,
  RecurringProjectRequest
}

class RecurringListing extends StatefulWidget {
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final OfferModel offerModel;
  final ComingFrom comingFrom;

  RecurringListing({
    Key key,
    @required this.requestModel,
    this.timebankModel,
    this.offerModel,
    @required this.comingFrom,
  }) : super(key: key);

  @override
  _RecurringListingState createState() => _RecurringListingState();
}

class _RecurringListingState extends State<RecurringListing> {
  TimebankModel timebankModel = null;
  CommunityModel communityModel;

  void initState() {
    super.initState();
    if (widget.timebankModel == null) {
      getTimebankForId(widget.offerModel == null
          ? widget.requestModel.timebankId
          : widget.offerModel.timebankId);
    } else {
      timebankModel = widget.timebankModel;
    }
  }

  Future<void> getTimebankForId(timebankId) async {
    DocumentSnapshot timebankDoc =
        await CollectionRef.timebank.doc(timebankId).get();
    timebankModel = TimebankModel.fromMap(timebankDoc.data());
  }

  Future<CommunityModel> getCommunityForId(communityId) async {
    DocumentSnapshot communityDoc =
        await CollectionRef.communities.doc(communityId).get();
    return CommunityModel(communityDoc.data());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offerModel == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "${S.of(context).recurring_list_heading}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: FutureBuilder<CommunityModel>(
              future: getCommunityForId(
                  SevaCore.of(context).loggedInUser.currentCommunity),
              builder: (context, commSnapshot) {
                if (!commSnapshot.hasData) {
                  return LoadingIndicator();
                }
                communityModel = commSnapshot.data;
                return Container(
                  child: StreamBuilder(
                      stream: RecurringListDataManager
                          .getRecurringRequestListStream(
                        parentRequestId: widget.requestModel.parent_request_id,
                      ),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null) {
                          List<RequestModel> requestModelList = snapshot.data;

                          return RecurringList(
                            requestModelList,
                            null,
                            timebankModel,
                            communityModel,
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                );
              }));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "${S.of(context).recurring_list_heading}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: FutureBuilder<CommunityModel>(
              future: getCommunityForId(
                  SevaCore.of(context).loggedInUser.currentCommunity),
              builder: (context, commSnapshot) {
                if (!commSnapshot.hasData) {
                  return LoadingIndicator();
                }
                communityModel = commSnapshot.data;
                return Container(
                  child: StreamBuilder(
                      stream:
                          RecurringListDataManager.getRecurringofferListStream(
                        parentOfferId: widget.offerModel.parent_offer_id,
                      ),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null) {
                          List<OfferModel> offerModelList = snapshot.data;

                          return RecurringList(null, offerModelList,
                              timebankModel, communityModel);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                );
              }));
    }
  }
}

class RecurringList extends StatefulWidget {
  List<RequestModel> requestmodel;
  List<OfferModel> offerModel;
  TimebankModel timebankModel;
  CommunityModel communityModel;

  RecurringList(this.requestmodel, this.offerModel, this.timebankModel,
      this.communityModel);

  @override
  _RecurringListState createState() => _RecurringListState();
}

class _RecurringListState extends State<RecurringList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.i(widget.offerModel == null
        ? widget.requestmodel.length.toString()
        : widget.offerModel.length.toString() + "Length of ===");

    if ((widget.offerModel == null
            ? widget.requestmodel.length
            : widget.offerModel.length) ==
        0) {
      return Center(
        child: Container(
          child: Text('All requests completed.'),
        ),
      );
    }
    return ListView.builder(
        itemCount: widget.offerModel == null
            ? widget.requestmodel.length
            : widget.offerModel.length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.offerModel == null) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  onTap: () => editRequest(
                      model: widget.requestmodel[index],
                      timebankModel: widget.timebankModel,
                      communityModel: widget.communityModel),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.cover,
                              placeholder: 'lib/assets/images/profile.png',
                              image: widget.requestmodel[index].photoUrl == null
                                  ? defaultUserImageURL
                                  : widget.requestmodel[index].photoUrl,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.requestmodel[index].title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  widget.requestmodel[index].description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTimeFormattedString(widget
                                        .requestmodel[index].requestStart),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    getTimeFormattedString(
                                        widget.requestmodel[index].requestEnd),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Offstage(
              offstage: isOfferVisible(
                widget.offerModel[index],
                SevaCore.of(context).loggedInUser.sevaUserID,
              ),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () async {
                    _navigateToOfferDetails(
                        widget.offerModel[index], widget.communityModel);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                getOfferTitle(
                                    offerDataModel: widget.offerModel[index]),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                getOfferDescription(
                                    offerDataModel: widget.offerModel[index]),
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              getOfferMetaData(
                                  context: context,
                                  startDate: widget.offerModel[index]
                                      ?.groupOfferDataModel?.startDate,
                                  offerType: widget.offerModel[index].offerType,
                                  selectedAddress:
                                      widget.offerModel[index].selectedAdrress),
                              Offstage(
                                offstage: widget.offerModel[index].email ==
                                    SevaCore.of(context).loggedInUser.email,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    CustomTextButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      color: isParticipant(
                                              context, widget.offerModel[index])
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                      child: Text(
                                        getButtonLabel(
                                                context,
                                                widget.offerModel[index],
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID) ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        // if (SevaCore.of(context)
                                        //         .loggedInUser
                                        //         .calendarId ==
                                        //     null) {
                                        //   _settingModalBottomSheet(context,
                                        //       widget.offerModel[index]);
                                        // } else {
                                        offerActions(
                                            context,
                                            widget.offerModel[index],
                                            ComingFrom.Offers);
                                        //}
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  void _navigateToOfferDetails(
      OfferModel model, CommunityModel communityModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_context) => BlocProvider(
          bloc: BlocProvider.of<HomeDashBoardBloc>(context),
          child: OfferDetailsRouter(
              offerModel: model, comingFrom: ComingFrom.Offers),
        ),
      ),
    );
  }

  Widget getOfferMetaData(
      {BuildContext context,
      int startDate,
      OfferType offerType,
      String selectedAddress}) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: offerType == OfferType.GROUP_OFFER
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: <Widget>[
          offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                    timeStamp: startDate,
                    timeZone: SevaCore.of(context).loggedInUser.timezone,
                  ),
                  icon: Icons.calendar_today)
              : Offstage(),
          offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                    timeStamp: startDate,
                    timeZone: SevaCore.of(context).loggedInUser.timezone,
                    format: "h:mm a",
                  ),
                  icon: Icons.access_time)
              : Offstage(),
          getOfferLocation(selectedAddress: selectedAddress) != null
              ? getStatsIcon(
                  label: getOfferLocation(selectedAddress: selectedAddress),
                  icon: Icons.location_on)
              : Container(),
        ],
      ),
    );
  }

  Widget getStatsIcon({String label, IconData icon}) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 15,
          color: Colors.grey,
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          label.trim(),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void editRequest(
      {RequestModel model, TimebankModel timebankModel, communityModel}) {
    timeBankBloc.setSelectedRequest(model);
    if (model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID ||
        isAccessAvailable(
            timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child:
                RequestTabHolder(isAdmin: true, communityModel: communityModel),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child: RequestDetailsAboutPage(
              requestItem: model,
              timebankModel: timebankModel,
              isAdmin: false,
              communityModel: communityModel,
              // communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
            ),
          ),
        ),
      );
    }
  }

  void _settingModalBottomSheet(context, OfferModel model) {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": [],
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
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          },
                        ),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          },
                        ),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Offers,
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
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    CustomTextButton(
                        child: Text(
                          S.of(context).skip_for_now,
                          style: TextStyle(
                              color: FlavorConfig.values.theme.primaryColor),
                        ),
                        onPressed: () {
                          Navigator.of(bc).pop();
                          offerActions(context, model, ComingFrom.Offers);
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    String timezoneAbb = SevaCore.of(context).loggedInUser.timezone;
    DateFormat dateFormat =
        DateFormat('d MMM hh:mm a ', Locale(getLangTag()).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }
}
