import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/approvedUsers.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:sevaexchange/widgets/distance_from_current_location.dart';

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

  bool isNearme = false;
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
                      minWidth: 110.0,
                      height: 50.0,
                      buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                      child: Stack(
                        children: [
                          FlatButton(
                            onPressed: () {},
                            child: Text(
                              S.of(context).my_requests,
                              style: (TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                          ),
                          Positioned(
                            // will be positioned in the top right of the container
                            top: -10,
                            right: -10,
                            child: infoButton(
                              context: context,
                              key: GlobalKey(),
                              type: InfoType.REQUESTS,
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.isFromSettings
                        ? Container()
                        : TransactionLimitCheck(
                            isSoftDeleteRequested:
                                widget.timebankModel.requestedSoftDelete,
                            child: GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 0),
                                child: Icon(
                                  Icons.add_circle,
                                  color: FlavorConfig.values.theme.primaryColor,
                                ),
                              ),
                              onTap: () {
                                if (widget.timebankModel.protected) {
                                  if (widget.timebankModel.admins.contains(
                                    SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID,
                                  )) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRequest(
                                          timebankId: timebankId,
                                          projectId: '',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _showProtectedTimebankMessage();
                                } else {
                                  if (widget.timebankModel.id ==
                                          FlavorConfig.values.timebankId &&
                                      !widget.timebankModel.admins.contains(
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
              Container(
                height: 40,
                width: 40,
                child: IconButton(
                  icon: Image.asset(
                    'lib/assets/images/help.png',
                  ),
                  color: FlavorConfig.values.theme.primaryColor,
                  //iconSize: 16,
                  onPressed: showRequestsWebPage,
                ),
              ),
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
          )
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
            FlatButton(
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

  void navigateToWebView({
    BuildContext context,
    AboutMode aboutMode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevaWebView(aboutMode),
      ),
    );
  }
}

class RequestCardView extends StatefulWidget {
  final RequestModel requestItem;

  RequestCardView({
    Key key,
    @required this.requestItem,
  }) : super(key: key);

  @override
  _RequestCardViewState createState() => _RequestCardViewState();
}

class _RequestCardViewState extends State<RequestCardView> {
  void _acceptRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    FirestoreManager.acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void _withdrawRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(SevaCore.of(context).loggedInUser.email);
    widget.requestItem.acceptors = acceptorList.toList();
    FirestoreManager.acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRequest(
                          timebankId:
                              SevaCore.of(context).loggedInUser.currentTimebank,
                          requestModel: widget.requestItem,
                        ),
                      ),
                    );
                  },
                )
              : Offstage(),
          widget.requestItem.sevaUserId ==
                      SevaCore.of(context).loggedInUser.sevaUserID &&
                  widget.requestItem.acceptors.length == 0
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext viewcontext) {
                        return AlertDialog(
                          title: Text(S
                              .of(context)
                              .request_delete_confirmation_message),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                S.of(context).no,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(viewcontext);
                              },
                            ),
                            FlatButton(
                              child: Text(
                                S.of(context).yes,
                                style: TextStyle(
                                  fontSize: dialogButtonSize,
                                ),
                              ),
                              onPressed: () {
                                deleteRequest(requestModel: widget.requestItem);
                                Navigator.pop(viewcontext);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : Offstage()
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.requestItem.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                S.of(context).general_stream_error,
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            UserModel userModel = snapshot.data;
            String usertimezone = userModel.timezone;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: widget.requestItem.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            widget.requestItem.title,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RichTextView(
                              text: widget.requestItem.description),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).from}:  ' +
                                DateFormat(
                                  'MMMM dd, yyyy @ h:mm a',
                                  Locale(AppConfig.prefs
                                          .getString('language_code'))
                                      .toLanguageTag(),
                                ).format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.requestStart),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).until}:  ' +
                                DateFormat(
                                        'MMMM dd, yyyy @ h:mm a',
                                        Locale(AppConfig.prefs
                                                .getString('language_code'))
                                            .toLanguageTag())
                                    .format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.requestEnd),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text('${S.of(context).posted_by}:' +
                              widget.requestItem.fullName),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).posted_date}:  ' +
                                DateFormat(
                                        'MMMM dd, yyyy @ h:mm a',
                                        Locale(AppConfig.prefs
                                                .getString('language_code'))
                                            .toLanguageTag())
                                    .format(
                                  getDateTimeAccToUserTimezone(
                                      dateTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.requestItem.postTimestamp),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${S.of(context).number_of_volunteers_required} ' +
                                '${widget.requestItem.numberOfApprovals}',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' '),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: widget.requestItem.sevaUserId ==
                                    SevaCore.of(context).loggedInUser.sevaUserID
                                ? null
                                : () {
                                    widget.requestItem.acceptors.contains(
                                            SevaCore.of(context)
                                                .loggedInUser
                                                .email)
                                        ? _withdrawRequest()
                                        : _acceptRequest();
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              widget.requestItem.acceptors.contains(
                                      SevaCore.of(context).loggedInUser.email)
                                  ? S.of(context).withdraw +
                                      ' ' +
                                      S.of(context).request
                                  : S.of(context).accept +
                                      ' ' +
                                      S.of(context).request,
                              style: TextStyle(
                                color: FlavorConfig.values.buttonTextColor,
                              ),
                            ),
                          ),
                        ),
                        widget.requestItem.sevaUserId !=
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ? Offstage()
                            : Container(
                                padding: EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  onPressed: widget.requestItem.approvedUsers
                                              .length <
                                          1
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        RequestStatusView(
                                                          requestId: widget
                                                              .requestItem.id,
                                                        ),
                                                fullscreenDialog: true),
                                          );
                                        },
                                  child: Text(
                                    widget.requestItem.approvedUsers.length < 1
                                        ? S.of(context).no_approved_members
                                        : S.of(context).view_approved_members,
                                    style: TextStyle(
                                      color:
                                          FlavorConfig.values.buttonTextColor,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Future<void> deleteRequest({
    @required RequestModel requestModel,
  }) async {
    return await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .delete();
  }
}

class RequestListItems extends StatefulWidget {
  final Coordinates currentCoords;
  final String timebankId;
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
      this.currentCoords});

  @override
  State<StatefulWidget> createState() {
    return RequestListItemsState();
  }
}

class RequestListItemsState extends State<RequestListItems> {
  Coordinates currentLocation;
  @override
  void initState() {
    super.initState();
    if (!widget.isFromSettings) {
      timeBankBloc.getRequestsStreamFromTimebankId(widget.timebankId);
    }
  }

// todo::findcurrentLocation )(abhishek)
  Future<Coordinates> findcurrentLocation() async {
    final Location _location = Location();
    var location = await _location.getLocation();
    if (location == null) {
      return null;
    }
    Coordinates distance = Coordinates(location.latitude, location.longitude);
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('${S.of(context).general_stream_error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          UserModel user = snapshot.data;
          String loggedintimezone = user.timezone;
          if (!widget.isFromSettings) {
            return FutureBuilder(
              future: findcurrentLocation(),
              builder: (_, coords) => StreamBuilder(
                stream: timeBankBloc.timebankController,
                builder: (context, AsyncSnapshot<TimebankController> snapshot) {
                  if (snapshot.hasError) {
                    return Text('${S.of(context).general_stream_error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator();
                  }
                  if (snapshot.hasData) {
                    List<RequestModel> requestModelList =
                        snapshot.data.requests;
                    requestModelList = filterBlockedRequestsContent(
                        context: context, requestModelList: requestModelList);

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
                      loggedintimezone: loggedintimezone,
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      projectId: widget.projectId,
                      currentCoords: coords.data,
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Text("");
                },
              ),
            );
          } else {
            return FutureBuilder(
              future: findcurrentLocation(),
              builder: (_, coords) => StreamBuilder<List<RequestModel>>(
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
                            child: Text(S.of(context).no +
                                ' ' +
                                S.of(context).requests),
                          ),
                        );
                      }
                      var consolidatedList =
                          GroupRequestCommons.groupAndConsolidateRequests(
                              requestModelList,
                              SevaCore.of(context).loggedInUser.sevaUserID);
                      return formatListFrom(
                        consolidatedList: consolidatedList,
                        currentCoords: coords.data,
                      );
                  }
                },
              ),
            );
          }
        });
    // } else {
    //   return FutureBuilder<Object>(
    //       future: FirestoreManager.getUserForId(
    //           sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
    //       builder: (context, snapshot) {
    //         if (snapshot.hasError) {
    //           return Text('${S.of(context).general_stream_error}');
    //         }
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return LoadingIndicator();
    //         }
    //         return StreamBuilder<List<RequestModel>>(
    //           stream: FirestoreManager.getAllRequestListStream(),
    //           builder: (BuildContext context,
    //               AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
    //             if (requestListSnapshot.hasError) {
    //               return Text('${S.of(context).general_stream_error}');
    //             }
    //             switch (requestListSnapshot.connectionState) {
    //               case ConnectionState.waiting:
    //                 return LoadingIndicator();
    //               default:
    //                 List<RequestModel> requestModelList =
    //                     requestListSnapshot.data;
    //                 requestModelList = filterBlockedRequestsContent(
    //                     context: context, requestModelList: requestModelList);

    //                 if (requestModelList.length == 0) {
    //                   return Padding(
    //                     padding: const EdgeInsets.all(16.0),
    //                     child: Center(
    //                       child: Text(
    //                           S.of(context).no + ' ' + S.of(context).requests),
    //                     ),
    //                   );
    //                 }
    //                 var consolidatedList =
    //                     GroupRequestCommons.groupAndConsolidateRequests(
    //                         requestModelList,
    //                         SevaCore.of(context).loggedInUser.sevaUserID);
    //                 return formatListFrom(
    //                     consolidatedList: consolidatedList,
    //                     projectId: widget.projectId,
    //                     currentCoords: coords);
    //             }
    //           },
    //         );
    //       });
  }

  List<RequestModel> filterBlockedRequestsContent({
    List<RequestModel> requestModelList,
    BuildContext context,
  }) {
    List<RequestModel> filteredList = [];

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
                groupKey: (model as GroupTitle).groupTitle),
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
        return getTagMainFrame('Cash Request');

      case RequestType.GOODS:
        return getTagMainFrame('Goods Request');

      case RequestType.TIME:
        return getTagMainFrame('Time Request');

      default:
        return Container();
    }
  }

  Widget getTagMainFrame(String tagTitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 3, right: 5, top: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
            child: Text(
              tagTitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
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
              children: [
                Row(
                  children: <Widget>[
                    requestLocation != null
                        ? Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          )
                        : Container(),
                    requestLocation != null
                        ? Text(requestLocation)
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
                          .replaceAll('hours ago', 'h'),
                      style: TextStyle(
                        fontFamily: 'Europa',
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //todo::::::::::::::::::::DistanceFromCurrentLocation::::::::::::::::::::::::::
                      Row(
                        children: [
                          getAppropriateTag(model.requestType),
                          SizedBox(width: 10),
                          model.location != null
                              ? DistanceFromCurrentLocation(
                                  currentLocation: currentCoords,
                                  coordinates: Coordinates(
                                      model.location.latitude,
                                      model.location.longitude),
                                  isKm: true,
                                )
                              : Container(),
                        ],
                      ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                model.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(widget.parentContext)
                                    .textTheme
                                    .subhead,
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
                                              builder: (context) =>
                                                  RecurringListing(
                                                requestModel: model,
                                                offerModel: null,
                                                timebankModel: null,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(Icons.navigate_next),
                                      ),
                                    ),
                                  ))
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(widget.parentContext)
                                  .textTheme
                                  .subtitle,
                            ),
                          ),
                          Visibility(
                            visible: model.isRecurring,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Recurring",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              model.acceptors.contains(userEmail) ||
                                      model.approvedUsers.contains(userEmail)
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      width: 100,
                                      height: 32,
                                      child: FlatButton(
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
    widget.isAdmin =
        model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID
            ? true
            : false;
    timeBankBloc.setIsAdmin(widget.isAdmin);

    if (model.isRecurring) {
      Navigator.push(
          widget.parentContext,
          MaterialPageRoute(
              builder: (context) => RecurringListing(
                    requestModel: model,
                    timebankModel: widget.timebankModel,
                    offerModel: null,
                  )));
    } else if (model.sevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID ||
        widget.timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        widget.parentContext,
        MaterialPageRoute(
          builder: (context) => RequestTabHolder(
            isAdmin: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        widget.parentContext,
        MaterialPageRoute(
          builder: (context) => RequestDetailsAboutPage(
            requestItem: model,
            timebankModel: widget.timebankModel,
            isAdmin: false,
          ),
        ),
      );
    }
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
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

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(2),
          spreadRadius: 6,
          offset: Offset(0, 3),
          blurRadius: 6,
        )
      ],
      color: Colors.white,
    );
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
}
