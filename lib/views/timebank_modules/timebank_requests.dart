import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/distance_from_current_location.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../core.dart';

class RequestsModule extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  final bool isFromSettings;

  RequestsModule.of({this.timebankId, this.timebankModel, this.isFromSettings});

  @override
  RequestsState createState() => RequestsState();
}

class RequestsState extends State<RequestsModule> {
  String timebankId;

  void _setORValue() {
    globals.orCreateSelector = 0;
  }

  List<TimebankModel> timebankList = [];
  bool isNearMe = false;
  int sharedValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setORValue();
    timebankId = widget.timebankModel.id;
    var body = Container(
      margin: EdgeInsets.only(left: 0, right: 0, top: 7),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 120.0,
                      height: 50.0,
                      buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: CustomTextButton(
                              onPressed: () {},
                              child: Text(
                                S.of(context).my_requests,
                                style: (TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: -20,
                            child: Container(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: infoButton(
                                context: context,
                                key: GlobalKey(),
                                type: InfoType.REQUESTS,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.isFromSettings
                        ? Container()
                        : TransactionLimitCheck(
                            comingFrom: ComingFrom.Requests,
                            timebankId: timebankId,
                            isSoftDeleteRequested:
                                widget.timebankModel.requestedSoftDelete,
                            child: GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.add_circle,
                                  color: FlavorConfig.values.theme.primaryColor,
                                ),
                              ),
                              onTap: () {
                                if (widget.timebankModel.protected) {
                                  if (isAccessAvailable(
                                      widget.timebankModel,
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .sevaUserID)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRequest(
                                          comingFrom: ComingFrom.Requests,
                                          timebankId: timebankId,
                                          projectId: '',
                                          userModel:
                                              SevaCore.of(context).loggedInUser,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _showProtectedTimebankMessage();
                                } else {
                                  if (widget.timebankModel.id ==
                                          FlavorConfig.values.timebankId &&
                                      !isAccessAvailable(
                                          widget.timebankModel,
                                          SevaCore.of(context)
                                              .loggedInUser
                                              .sevaUserID)) {
                                    showAdminAccessMessage(context: context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRequest(
                                          timebankId: timebankId,
                                          projectId: '',
                                          userModel:
                                              SevaCore.of(context).loggedInUser,
                                          comingFrom: ComingFrom.Requests,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                  ],
                ),
              ),
              Spacer(),
              // Container(
              //   height: 40,
              //   width: 40,
              //   child: IconButton(
              //     icon: Image.asset(
              //       'lib/assets/images/help.png',
              //     ),
              //     color: FlavorConfig.values.theme.primaryColor,
              //     //iconSize: 16,
              //     onPressed: showRequestsWebPage,
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
          Divider(
            color: Colors.white,
            height: 0,
          ),
          RequestListItems(
              parentContext: context,
              timebankId: timebankId,
              timebankModel: widget.timebankModel,
              isProjectRequest: false,
              isFromSettings: widget.isFromSettings,
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID)
        ],
      ),
    );
    if (widget.isFromSettings) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).select_request,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        body: body,
      );
    }
    return body;
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).protected_timebank),
          content:
              Text(S.of(context).protected_timebank_request_creation_error),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showRequestsWebPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        "links_${S.of(context).localeName}",
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).requests + ' ' + S.of(context).help,
          urlToHit: dynamicLinks['requestsInfoLink']),
      context: context,
    );
  }
}

class RequestListItems extends StatefulWidget {
  final Coordinates currentCoords;
  final String timebankId;
  final String sevaUserId;
  String projectId;
  final BuildContext parentContext;
  final TimebankModel timebankModel;
  bool isProjectRequest = false;
  final bool isFromSettings;
  bool isAdmin;

  RequestListItems(
      {Key key,
      this.timebankId,
      this.parentContext,
      this.timebankModel,
      this.isAdmin,
      this.isProjectRequest,
      this.projectId,
      this.isFromSettings,
      this.currentCoords,
      this.sevaUserId});

  @override
  State<StatefulWidget> createState() {
    return RequestListItemsState();
  }
}

class RequestListItemsState extends State<RequestListItems> {
  Future<Coordinates> currentCoords;
  @override
  void initState() {
    // currentCoords = findcurrentLocation();
    super.initState();

    if (!widget.isFromSettings) {
      timeBankBloc.getRequestsStreamFromTimebankId(
          widget.timebankId, widget.sevaUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Coordinates>(
      future: LocationHelper.getCoordinates(),
      builder: (context, currentLocation) {
        if (currentLocation.connectionState == ConnectionState.waiting) {
          log(' set true');

          return LoadingIndicator();
        }
        String loggedintimezone = SevaCore.of(context).loggedInUser.timezone;
        log('sett ${widget.isFromSettings}');

        if (!widget.isFromSettings) {
          return StreamBuilder(
            stream: timeBankBloc.timebankController,
            builder: (context, AsyncSnapshot<TimebankController> snapshot) {
              if (snapshot.hasError) {
                return Text('${S.of(context).general_stream_error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.hasData) {
                log('lenth ${snapshot.data.requests.length}');

                List<RequestModel> requestModelList = snapshot.data.requests;
                requestModelList = filterBlockedRequestsContent(
                    context: context, requestModelList: requestModelList);

                if (requestModelList.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: EmptyWidget(
                        title: S.of(context).no_requests_title,
                        sub_title: S.of(context).no_content_common_description,
                      ),
                    ),
                  );
                }
                var consolidatedList =
                    GroupRequestCommons.groupAndConsolidateRequests(
                        requestModelList,
                        SevaCore.of(context).loggedInUser.sevaUserID);
                return formatListFrom(
                  consolidatedList: consolidatedList,
                  loggedintimezone: loggedintimezone,
                  userEmail: SevaCore.of(context).loggedInUser.email,
                  projectId: widget.projectId,
                  currentCoords: currentLocation.data,
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Text("");
            },
          );
        } else {
          return StreamBuilder<List<RequestModel>>(
            stream: FirestoreManager.getRequestListStream(
              timebankId: widget.timebankModel.id,
            ),
            builder: (BuildContext context,
                AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
              if (requestListSnapshot.hasError) {
                return Text('${S.of(context).general_stream_error}');
              }
              switch (requestListSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return LoadingIndicator();
                default:
                  List<RequestModel> requestModelList =
                      requestListSnapshot.data;
                  requestModelList = filterBlockedRequestsContent(
                    context: context,
                    requestModelList: requestModelList,
                  );

                  if (requestModelList.length == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                            S.of(context).no + ' ' + S.of(context).requests),
                      ),
                    );
                  }
                  var consolidatedList =
                      GroupRequestCommons.groupAndConsolidateRequests(
                          requestModelList,
                          SevaCore.of(context).loggedInUser.sevaUserID);
                  return formatListFrom(
                    consolidatedList: consolidatedList,
                    currentCoords: currentLocation.data,
                  );
              }
            },
          );
        }
      },
    );
  }

  List<RequestModel> filterBlockedRequestsContent({
    List<RequestModel> requestModelList,
    BuildContext context,
  }) {
    List<RequestModel> filteredList = [];

    requestModelList.forEach(
      (request) {
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
      },
    );

    return filteredList;
  }

  Widget formatListFrom({
    List<RequestModelList> consolidatedList,
    String loggedintimezone,
    String userEmail,
    String projectId,
    Coordinates currentCoords,
  }) {
    return Expanded(
      child: Container(
          child: ListView.builder(
        shrinkWrap: true,
        itemCount: consolidatedList.length + 1,
        itemBuilder: (context, index) {
          if (index >= consolidatedList.length) {
            return Container(
              width: double.infinity,
              height: 65,
            );
          }
          return getRequestView(consolidatedList[index], loggedintimezone,
              userEmail, currentCoords);
        },
      )),
    );
  }

  Widget getRequestView(RequestModelList model, String loggedintimezone,
      String userEmail, Coordinates currentCoords) {
    switch (model.getType()) {
      case RequestModelList.TITLE:
        var isMyContent = (model as GroupTitle).groupTitle.contains("My");
        if (widget.isProjectRequest) {
          return Container();
        }

        return Container(
          height: !isMyContent ? 18 : 0,
          margin: !isMyContent ? EdgeInsets.all(12) : EdgeInsets.all(0),
          child: Text(
            GroupRequestCommons.getGroupTitle(
                groupKey: (model as GroupTitle).groupTitle,
                context: context,
                isGroup: !isPrimaryTimebank(
                    parentTimebankId: widget.timebankModel.parentTimebankId)),
          ),
        );

      case RequestModelList.REQUEST:
        return getRequestListViewHolder(
            model: (model as RequestItem).requestModel,
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
      case RequestType.ONE_TO_MANY_REQUEST:
        return getTagMainFrame(S.of(context).one_to_many.sentenceCase() +
            '' +
            S.of(context).request);
      // case RequestType.BORROW:
      //   return getTagMainFrame(S.of(context).borrow_request_title);
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
        return null;
      }
    } else {
      return null;
    }
  }

  Widget getFromNormalRequest(
      {RequestModel model,
      String loggedintimezone,
      String userEmail,
      Coordinates currentCoords}) {
    var requestLocation = getLocation(model.address);

    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () => editRequest(model: model),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SevaCore.of(context)
                        .loggedInUser
                        .curatedRequestIds
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
                        ? DistanceFromCurrentLocation(
                            currentLocation: currentCoords,
                            coordinates: Coordinates(model.location.latitude,
                                model.location.longitude),
                            isKm: true,
                          )
                        : Container(),
                    Spacer(),
                    Text(
                      timeAgo
                          .format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  model.postTimestamp),
                              locale: Locale(AppConfig.prefs
                                      .getString('language_code'))
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
                              : model.photoUrl,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            children: [
                              getAppropriateTag(model.requestType),
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
                                    tagTitle: S.of(context).public,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: model.isRecurring ?? false,
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TagView(
                                    tagTitle: S.of(context).recurring,
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
                                  model.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(widget.parentContext)
                                      .textTheme
                                      .subtitle1,
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                                child: Center(
                                  child: Visibility(
                                    visible: model.isRecurring,
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
                            visible: !model.isRecurring,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  getTimeFormattedString(
                                      model.requestEnd, loggedintimezone),
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
                                      model.requestEnd, loggedintimezone),
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
                              model.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(widget.parentContext)
                                  .textTheme
                                  .subtitle2,
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
                                      (model.acceptors.contains(userEmail) ||
                                          model.approvedUsers
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

  Widget getRequestListViewHolder(
      {RequestModel model,
      String loggedintimezone,
      String userEmail,
      Coordinates currentCoords}) {
    if (!widget.isProjectRequest) {
      return getFromNormalRequest(
          model: model,
          loggedintimezone: loggedintimezone,
          userEmail: userEmail,
          currentCoords: currentCoords);
    }
    return Container();
  }

  void editRequest({RequestModel model}) {
    timeBankBloc.setSelectedRequest(model);
    timeBankBloc.setSelectedTimeBankDetails(widget.timebankModel);
    if (model.requestMode == RequestMode.PERSONAL_REQUEST) {
      widget.isAdmin =
          model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID
              ? true
              : false;
    } else {
      widget.isAdmin = isAccessAvailable(
          widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID);
    }
    timeBankBloc.setIsAdmin(widget.isAdmin);

    if (model.isRecurring) {
      Navigator.push(
          widget.parentContext,
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
        isAccessAvailable(widget.timebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        widget.parentContext,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<HomeDashBoardBloc>(context),
            child: RequestTabHolder(
              //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
              isAdmin: true,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        widget.parentContext,
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

  // BoxDecoration get containerDecoration {
  //   return BoxDecoration(
  //     borderRadius: BorderRadius.all(Radius.circular(2.0)),
  //     boxShadow: [
  //       BoxShadow(
  //         color: Colors.black.withAlpha(2),
  //         spreadRadius: 6,
  //         offset: Offset(0, 3),
  //         blurRadius: 6,
  //       )
  //     ],
  //     color: Colors.white,
  //   );
  // }

}

BoxDecoration get containerDecorationR {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withAlpha(2),
          spreadRadius: 6,
          offset: Offset(0, 3),
          blurRadius: 6)
    ],
    color: Colors.white,
  );
}
