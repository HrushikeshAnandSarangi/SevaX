import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_list_data_manager.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';


class RecurringListing extends StatefulWidget {
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final OfferModel offerModel;

  RecurringListing({Key key, @required this.requestModel, this.timebankModel, this.offerModel,})
      : super(key: key);

  @override
  _RecurringListingState createState() => _RecurringListingState();
}

class _RecurringListingState extends State<RecurringListing> {
  TimebankModel timebankModel = null;

  void initState() {
    super.initState();
    if(widget.timebankModel == null){
      getTimebankForId(widget.offerModel == null ? widget.requestModel.timebankId : widget.offerModel.timebankId);
    }else{
      timebankModel = widget.timebankModel;
    }

  }

  Future<void> getTimebankForId(timebankId) async {
    DocumentSnapshot timebankDoc = await Firestore.instance.collection("timebankDoc").document(timebankId).get();
    timebankModel =  TimebankModel.fromMap(timebankDoc.data);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offerModel==null){
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "${S.of(context).recurring_list_heading}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: Container(
            child: StreamBuilder(
                stream: RecurringListDataManager.getRecurringRequestListStream(
                  parentRequestId: widget.requestModel.parent_request_id,
                ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    List<RequestModel> requestModelList = snapshot.data;
                    print("snapshot data is ==== ${snapshot.data.length}");
                    requestModelList
                        .forEach((k) => print('snapshot id is ==> ${k.id}'));
                    return RecurringList(requestModelList, null, timebankModel);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ));
    }
    else{
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "${S.of(context).recurring_list_heading}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: Container(
            child: StreamBuilder(
                stream: RecurringListDataManager.getRecurringofferListStream(
                  parentOfferId: widget.offerModel.parent_offer_id,
                ),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    List<OfferModel> offerModelList = snapshot.data;
                    print("snapshot data is ==== ${snapshot.data.length}");
                    offerModelList
                        .forEach((k) => print('snapshot id is ==> ${k.id}'));
                    return RecurringList(null, offerModelList, timebankModel);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ));
    }
  }
}

class RecurringList extends StatefulWidget {
  List<RequestModel> requestmodel;
  List<OfferModel> offerModel;
  TimebankModel timebankModel;

  RecurringList(this.requestmodel, this.offerModel, this.timebankModel);

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
    return ListView.builder(
        itemCount: widget.offerModel == null ? widget.requestmodel.length : widget.offerModel.length,
        itemBuilder: (BuildContext context, int index) {
          if(widget.offerModel == null){
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  onTap: () => editRequest(
                      model: widget.requestmodel[index],
                      timebankModel: widget.timebankModel),
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
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  widget.requestmodel[index].description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Text(
                                    getTimeFormattedString(
                                        widget.requestmodel[index].requestStart),
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
          }
          else {
            return Offstage(
              offstage: isOfferVisible(
                widget.offerModel[index],
                SevaCore.of(context).loggedInUser.sevaUserID,
              ),
              child: Card(
                elevation: 2,
                child: InkWell(
                  onTap: () async {
                    _navigateToOfferDetails(widget.offerModel[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                getOfferTitle(offerDataModel: widget.offerModel[index]),
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
                                  getOfferDescription(offerDataModel: widget.offerModel[index]),
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              getOfferMetaData(
                                context: context,
                                startDate: widget.offerModel[index]?.groupOfferDataModel?.startDate,
                                offerType: widget.offerModel[index].offerType,
                                selectedAddress: widget.offerModel[index].selectedAdrress
                              ),
                              Offstage(
                                offstage: widget.offerModel[index].email == SevaCore.of(context).loggedInUser.email,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.only(left: 10, right: 10),
                                      color:
                                      isParticipant(context, widget.offerModel[index])
                                          ? Colors.grey
                                          : Theme.of(context).primaryColor,
                                      child: Text(
                                        getButtonLabel(widget.offerModel[index], SevaCore.of(context).loggedInUser.sevaUserID) ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if(SevaCore.of(context).loggedInUser.calendarId==null) {
                                          _settingModalBottomSheet(context, widget.offerModel[index]);
                                        }else{
                                          offerActions(context, widget.offerModel[index]);
                                        }
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

  void _navigateToOfferDetails(OfferModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  }

  Widget getOfferMetaData({BuildContext context, int startDate, OfferType offerType, String selectedAddress}) {
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

  void editRequest({RequestModel model, TimebankModel timebankModel}) {
    timeBankBloc.setSelectedRequest(model);
    if (model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID ||
        timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestTabHolder(
            isAdmin: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailsAboutPage(
            requestItem: model,
            timebankModel: timebankModel,
            isAdmin: false,
          ),
        ),
      );
    }
  }

  void _settingModalBottomSheet(context, OfferModel model) {
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
                  padding: const EdgeInsets.fromLTRB(6,6,6,6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/ical.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                          }
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
//                        child: Text(S.of(context).skip_for_now, style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                        child: Text(S.of(context).do_it_later, style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                        onPressed: (){
                          Navigator.of(bc).pop();
                          offerActions(context, model);
                        }
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    String timezoneAbb = SevaCore.of(context).loggedInUser.timezone;
    DateFormat dateFormat = DateFormat('d MMM hh:mm a ',
        Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }
}
