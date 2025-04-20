import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_listing_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/distance_from_current_location.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class VirtualRequests extends StatefulWidget {
  final String? timebankId;
  final TimebankModel? timebankModel;

  VirtualRequests({this.timebankId, this.timebankModel});

  @override
  _VirtualRequestsState createState() => _VirtualRequestsState();
}

class _VirtualRequestsState extends State<VirtualRequests> {
  late Future<GeoPoint> currentCoords;

  bool isAdmin = false;
  @override
  void initState() {
    // TODO: implement initState
    final user = SevaCore.of(context).loggedInUser;
    // Parse latitude and longitude from the lat_lng string
    double latitude = 0.0;
    double longitude = 0.0;
    if (user.lat_lng != null) {
      List<String> latLngList = user.lat_lng!.split(',');
      if (latLngList.length == 2) {
        latitude = double.tryParse(latLngList[0]) ?? 0.0;
        longitude = double.tryParse(latLngList[1]) ?? 0.0;
      }
    }
    currentCoords = Future.value(GeoPoint(latitude, longitude));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String loggedintimezone = SevaCore.of(context).loggedInUser.timezone!;

    return FutureBuilder<GeoPoint>(
        future: currentCoords,
        builder: (context, currentLocation) {
          return StreamBuilder<List<RequestModel>>(
            stream: FirestoreManager.getAllVirtualRequestListStream(
                timebankid: widget.timebankId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logger.e(snapshot.error);
                return Text(S.of(context).general_stream_error);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.hasData) {
                List<RequestModel> requestModelList = snapshot.data!;
                requestModelList = filterBlockedRequestsContent(
                    context: context, requestModelList: requestModelList);

                if (requestModelList.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: emptyData(
                        msg: S.of(context).no_requests_title,
                      ),
                    ),
                  );
                }
                var consolidatedList =
                    GroupRequestCommons.groupAndConsolidateRequests(
                        requestModelList,
                        SevaCore.of(context).loggedInUser.sevaUserID!);
                return formatListFrom(
                  consolidatedList: consolidatedList,
                  loggedintimezone: loggedintimezone,
                  userEmail: SevaCore.of(context).loggedInUser.email!,
                  currentCoords: currentLocation.data,
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Text("");
            },
          );
        });
  }

  Widget emptyData({String? msg}) {
    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Image.asset(
                'images/icons/empty_feed.png',
                height: 160,
                width: 214,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                msg!,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<RequestModel> filterBlockedRequestsContent({
    List<RequestModel>? requestModelList,
    BuildContext? context,
  }) {
    List<RequestModel> filteredList = [];

    requestModelList!.forEach(
      (request) {
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
      },
    );

    return filteredList;
  }

  Widget formatListFrom({
    List<RequestModelList>? consolidatedList,
    String? loggedintimezone,
    String? userEmail,
    GeoPoint? currentCoords,
  }) {
    return Expanded(
      child: Container(
          child: ListView.builder(
        shrinkWrap: true,
        itemCount: consolidatedList!.length + 1,
        itemBuilder: (context, index) {
          if (index >= consolidatedList.length) {
            return Container(
              width: double.infinity,
              height: 65,
            );
          }
          return getRequestView(consolidatedList[index], loggedintimezone!,
              userEmail!, currentCoords!);
        },
      )),
    );
  }

  Widget getRequestView(RequestModelList model, String loggedintimezone,
      String userEmail, GeoPoint currentCoords) {
    switch (model.getType()) {
      case RequestModelList.TITLE:
        var isMyContent = (model as GroupTitle).groupTitle!.contains("My");

        return Container(
          height: !isMyContent ? 18 : 0,
          margin: !isMyContent ? EdgeInsets.all(12) : EdgeInsets.all(0),
          child: Text(
            GroupRequestCommons.getGroupTitle(
                groupKey: (model as GroupTitle).groupTitle,
                context: context,
                isGroup: !isPrimaryTimebank(
                    parentTimebankId: widget.timebankModel!.parentTimebankId)),
          ),
        );

      case RequestModelList.REQUEST:
        return getRequestListViewHolder(
            model: (model as RequestItem).requestModel!,
            loggedintimezone: loggedintimezone,
            userEmail: userEmail,
            currentCoords: currentCoords);

      default:
        return Text(S.of(context).default_text.toUpperCase());
    }
  }

  Widget getAppropriateTag(RequestType requestType) {
    switch (requestType) {
      case RequestType.CASH:
        return getTagMainFrame(S.of(context).cash_request);
      case RequestType.GOODS:
        return getTagMainFrame(S.of(context).goods_request);
      case RequestType.TIME:
        return getTagMainFrame(S.of(context).time_request);

      default:
        return Container();
    }
  }

  Widget getTagMainFrame(String tagTitle) {
    return Container(
        margin: EdgeInsets.only(right: 10), child: TagView(tagTitle: tagTitle));
  }

  String getLocation(String location) {
    if (location != null && location.length > 1) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        return null!;
      }
    } else {
      return null!;
    }
  }

  Widget getFromNormalRequest(
      {RequestModel? model,
      String? loggedintimezone,
      String? userEmail,
      GeoPoint? currentCoords}) {
    var requestLocation = getLocation(model!.address!);

    return Container(
      decoration: RequestViewClassifer.containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () => editRequest(model: model!),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SevaCore.of(context)
                        .loggedInUser
                        .curatedRequestIds!
                        .contains(model.id)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getTagMainFrame('recommended'),
                        ],
                      )
                    : Offstage(),
                Row(
                  children: <Widget>[
                    requestLocation != null
                        ? Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          )
                        : Container(),
                    requestLocation != null
                        ? Expanded(
                            child: Text(
                              requestLocation,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Container(),
                    SizedBox(width: 10),
                    model.location != null &&
                            model.sevaUserId !=
                                SevaCore.of(context).loggedInUser.sevaUserID
                        ? (model.location != null
                            ? DistanceFromCurrentLocation(
                                currentLocation: currentCoords,
                                coordinates: GeoPoint(model.location!.latitude,
                                    model.location!.longitude),
                                isKm: true,
                              )
                            : Container())
                        : Container(),
                    Spacer(),
                    Text(
                      timeAgo
                          .format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  model.postTimestamp!),
                              locale: Locale(AppConfig.prefs!
                                      .getString('language_code')!)
                                  .toLanguageTag())
                          .replaceAll('hours ago', 'hr'),
                      style: TextStyle(
                        fontFamily: 'Europa',
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipOval(
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'lib/assets/images/profile.png',
                          image: model.photoUrl == null
                              ? defaultUserImageURL
                              : model.photoUrl!,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              getAppropriateTag(model.requestType!),
                              Visibility(
                                visible: model.virtualRequest ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: S.of(context).virtual,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: model.public ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: 'Public',
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: model.isRecurring ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: 'Recurring',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  model.title!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                                child: Center(
                                  child: Visibility(
                                    visible: model.isRecurring!,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_context) => BlocProvider(
                                              bloc: BlocProvider.of<
                                                  HomeDashBoardBloc>(context),
                                              child: RecurringListing(
                                                comingFrom: ComingFrom.Requests,
                                                requestModel: model,
                                                offerModel: null,
                                                timebankModel: null,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.navigate_next),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Visibility(
                            visible: !model.isRecurring!,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  getTimeFormattedString(
                                      model.requestEnd!, loggedintimezone!),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.remove,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  getTimeFormattedString(
                                      model.requestEnd!, loggedintimezone),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              model.description!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          // Visibility(
                          //   visible: model.isRecurring,
                          //   child: Wrap(
                          //     crossAxisAlignment: WrapCrossAlignment.center,
                          //     children: <Widget>[
                          //       Text(
                          //         S.of(context).recurring,
                          //         style: TextStyle(
                          //             fontSize: 16.0,
                          //             color: Theme.of(context).primaryColor,
                          //             fontWeight: FontWeight.bold),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              model.email != userEmail &&
                                      (model.acceptors!.contains(userEmail) ||
                                          model.approvedUsers!
                                              .contains(userEmail))
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      width: 100,
                                      height: 32,
                                      child: CustomTextButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        color: Colors.green,
                                        child: Text(
                                          S.of(context).applied,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () {},
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editRequest({RequestModel? model}) {
    timeBankBloc.setSelectedRequest(model);
    timeBankBloc.setSelectedTimeBankDetails(widget.timebankModel);
    if (model!.requestMode == RequestMode.PERSONAL_REQUEST) {
      isAdmin = model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID
          ? true
          : false;
    } else {
      isAdmin = isAccessAvailable(
          widget.timebankModel!, SevaCore.of(context).loggedInUser.sevaUserID!);
    }
    timeBankBloc.setIsAdmin(isAdmin);

    if (model.isRecurring!) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_context) => BlocProvider(
                    bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                    child: RecurringListing(
                      comingFrom: ComingFrom.Requests,
                      requestModel: model,
                      timebankModel: widget.timebankModel,
                      offerModel: null,
                    ),
                  )));
    } else if (model.sevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID ||
        isAccessAvailable(widget.timebankModel!,
            SevaCore.of(context).loggedInUser.sevaUserID!)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child: RequestTabHolder(
              communityModel: BlocProvider.of<HomeDashBoardBloc>(context)!
                  .selectedCommunityModel!,
              isAdmin: true,
            ),
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
              timebankModel: widget.timebankModel,
              isAdmin: false,
              //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
            ),
          ),
        ),
      );
    }
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
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

  Widget getRequestListViewHolder(
      {RequestModel? model,
      String? loggedintimezone,
      String? userEmail,
      GeoPoint? currentCoords}) {
    return getFromNormalRequest(
        model: model,
        loggedintimezone: loggedintimezone,
        userEmail: userEmail,
        currentCoords: currentCoords);
  }
}
