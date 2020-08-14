import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/workshop/approvedUsers.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

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
    print("is commig from settings ${widget.isFromSettings}");
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
                              AppLocalizations.of(context)
                                  .translate('requests', 'my_requests'),
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
                                  if (SevaCore.of(context)
                                          .loggedInUser
                                          .calendarId ==
                                      null) {
                                    _settingModalBottomSheet(context);
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
              // Container(
              //   width: 120,
              //   child: CupertinoSegmentedControl<int>(
              //     selectedColor: Theme.of(context).primaryColor,
              //     children: {
              //       0: Text(
              //         AppLocalizations.of(context).translate('shared', 'all'),
              //         style: TextStyle(fontSize: 10.0),
              //       ),
              //       1: Text(
              //         AppLocalizations.of(context)
              //             .translate('shared', 'near_me'),
              //         style: TextStyle(fontSize: 10.0),
              //       ),
              //     },
              //     borderColor: Colors.grey,
              //     padding: EdgeInsets.only(left: 0, right: 5.0),
              //     groupValue: sharedValue,
              //     onValueChanged: (int val) {
              //       if (val != sharedValue) {
              //         setState(() {
              //           if (isNearme == true)
              //             isNearme = false;
              //           else
              //             isNearme = true;
              //         });
              //         setState(() {
              //           sharedValue = val;
              //         });
              //       }
              //     },
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
          isNearme == true
              ? NearRequestListItems(
                  parentContext: context,
                  timebankId: timebankId,
                  timebankModel: widget.timebankModel,
                  isFromSettings: widget.isFromSettings,
                )
              : RequestListItems(
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
            AppLocalizations.of(context)
                .translate('requests', 'select_request'),
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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    "Would you like to link your calendar with Sevax before proceeding ?",
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
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                      child: Text("Do it later", style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                      onPressed: (){
                        Navigator.of(bc).pop();
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
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('requests', 'protected_timebank')),
          content: Text(AppLocalizations.of(context)
              .translate('requests', 'cannot_post')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                  AppLocalizations.of(context).translate('homepage', 'close')),
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
        AppLocalizations.of(context).translate('links', 'linkToWeb'),
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: AppLocalizations.of(context)
              .translate('requests', 'requests_help'),
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
                            title: Text(AppLocalizations.of(context).translate(
                                'requests', 'delete_request_confirm')),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('requests', 'dont_delete'),
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
                                  AppLocalizations.of(context)
                                      .translate('requests', 'delete_request'),
                                  style: TextStyle(
                                    fontSize: dialogButtonSize,
                                  ),
                                ),
                                onPressed: () {
                                  deleteRequest(
                                      requestModel: widget.requestItem);
                                  Navigator.pop(viewcontext);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
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
                  '${AppLocalizations.of(context).translate('requests', 'error')} ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
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
                            '${AppLocalizations.of(context).translate('requests', 'from')}  ' +
                                DateFormat(
                                        'MMMM dd, yyyy @ h:mm a',
                                        Locale(AppConfig.prefs
                                                .getString('language_code'))
                                            .toLanguageTag())
                                    .format(
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
                            '${AppLocalizations.of(context).translate('requests', 'untill')}  ' +
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
                          child: Text(
                              '${AppLocalizations.of(context).translate('requests', 'posted_by')} ' +
                                  widget.requestItem.fullName),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            '${AppLocalizations.of(context).translate('requests', 'post_date')}  ' +
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
                              '${AppLocalizations.of(context).translate('requests', 'required')} ' +
                                  '${widget.requestItem.numberOfApprovals}'),
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
                                  ? AppLocalizations.of(context)
                                      .translate('requests', 'withdraw')
                                  : AppLocalizations.of(context)
                                      .translate('requests', 'accept'),
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
                                        ? AppLocalizations.of(context)
                                            .translate(
                                                'requests', 'not_approved_yet')
                                        : AppLocalizations.of(context)
                                            .translate('requests',
                                                'view_approved_members'),
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

class NearRequestListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  final TimebankModel timebankModel;
  final bool isFromSettings;

  const NearRequestListItems({
    Key key,
    this.timebankId,
    this.parentContext,
    this.timebankModel,
    this.isFromSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(" $isFromSettings  $timebankId");
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
          sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(AppLocalizations.of(context)
                .translate('requests', 'something_wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel user = snapshot.data;
          String loggedintimezone = user.timezone;
          print("time zone is === $loggedintimezone");
          return StreamBuilder<List<RequestModel>>(
            stream: timebankId != 'All'
                ? FirestoreManager.getNearRequestListStream(
                    timebankId: timebankId,
                    loggedInUser: SevaCore.of(context).loggedInUser,
                    isFromSettings: isFromSettings)
                : FirestoreManager.getNearRequestListStream(
                    isFromSettings: isFromSettings),
            builder: (BuildContext context,
                AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
              if (requestListSnapshot.hasError) {
                return Text(
                    '${AppLocalizations.of(context).translate('requests', 'error')} ${requestListSnapshot.error}');
              }
              switch (requestListSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());

                default:
                  List<RequestModel> requestModelList =
                      requestListSnapshot.data;
                  requestModelList = filterBlockedRequestsContent(
                      context: context, requestModelList: requestModelList);

                  if (requestModelList.length == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(AppLocalizations.of(context)
                              .translate('requests', 'no_requests'))),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: requestModelList.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= requestModelList.length) {
                          return Container(
                            width: double.infinity,
                            height: 65,
                          );
                        }
                        return getRequestView(
                          requestModelList[index],
                          loggedintimezone,
                          context,
                        );
                      },
                    ),
                  );
              }
            },
          );
        });
  }

  List<RequestModel> filterBlockedRequestsContent(
      {List<RequestModel> requestModelList, BuildContext context}) {
    List<RequestModel> filteredList = [];

    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? AppLocalizations.of(context).translate('requests', 'filtering')
        : filteredList.add(request));

    return filteredList;
  }

  Widget getRequestView(
    RequestModel model,
    String loggedintimezone,
    BuildContext context,
  ) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            timeBankBloc.setSelectedRequest(model);
            if (model.sevaUserId ==
                    SevaCore.of(context).loggedInUser.sevaUserID ||
                timebankModel.admins
                    .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestTabHolder(isAdmin: true),
                ),
              );
            } else {
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestDetailsAboutPage(
                      requestItem: model,
                      timebankModel: timebankModel,
                      isAdmin: false),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: FadeInImage.assetNetwork(
                      placeholder: 'lib/assets/images/profile.png',
                      image: model.photoUrl,
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
                        model.title,
                        style: Theme.of(parentContext).textTheme.subhead,
                      ),
                      Text(
                        model.description,
                        style: Theme.of(parentContext).textTheme.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(getTimeFormattedString(
                              model.requestStart, loggedintimezone)),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward, size: 14),
                          SizedBox(width: 4),
                          Text(getTimeFormattedString(
                              model.requestEnd, loggedintimezone)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          model.acceptors.contains(SevaCore.of(context)
                                      .loggedInUser
                                      .email) ||
                                  model.approvedUsers.contains(
                                      SevaCore.of(context).loggedInUser.email)
                              ? Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  width: 100,
                                  height: 32,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.all(0),
                                    color: Colors.green,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('requests', 'applied'),
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
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          spreadRadius: 4,
          offset: Offset(0, 3),
          blurRadius: 6,
        )
      ],
      color: Colors.white,
    );
  }
}

class RequestListItems extends StatefulWidget {
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
      this.isFromSettings});

  @override
  State<StatefulWidget> createState() {
    return RequestListItemsState();
  }
}

class RequestListItemsState extends State<RequestListItems> {
  @override
  void initState() {
    super.initState();

    print("is commig from settings ${widget.isFromSettings}");
    if (!widget.isFromSettings) {
      timeBankBloc.getRequestsStreamFromTimebankId(widget.timebankId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timebankId != 'All') {
      return FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                  '${AppLocalizations.of(context).translate('requests', 'error')} ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            UserModel user = snapshot.data;
            String loggedintimezone = user.timezone;
            if (!widget.isFromSettings) {
              return StreamBuilder(
                  stream: timeBankBloc.timebankController,
                  builder:
                      (context, AsyncSnapshot<TimebankController> snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                          '${AppLocalizations.of(context).translate('requests', 'error')} ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
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
                              child: Text(AppLocalizations.of(context)
                                  .translate('requests', 'no_requests'))),
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
                      );
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return Text("");
                  });
            } else {
              return StreamBuilder<List<RequestModel>>(
                stream: FirestoreManager.getRequestListStream(
                  timebankId: widget.timebankModel.id,
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
                  if (requestListSnapshot.hasError) {
                    return Text(
                        '${AppLocalizations.of(context).translate('requests', 'error')} ${requestListSnapshot.error}');
                  }
                  switch (requestListSnapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      List<RequestModel> requestModelList =
                          requestListSnapshot.data;
                      requestModelList = filterBlockedRequestsContent(
                          context: context, requestModelList: requestModelList);

                      if (requestModelList.length == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                              child: Text(AppLocalizations.of(context)
                                  .translate('requests', 'no_requests'))),
                        );
                      }
                      var consolidatedList =
                          GroupRequestCommons.groupAndConsolidateRequests(
                              requestModelList,
                              SevaCore.of(context).loggedInUser.sevaUserID);
                      return formatListFrom(consolidatedList: consolidatedList);
                  }
                },
              );
            }
          });
    } else {
      return FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                  '${AppLocalizations.of(context).translate('requests', 'error')} ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<List<RequestModel>>(
              stream: FirestoreManager.getAllRequestListStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
                if (requestListSnapshot.hasError) {
                  return Text(
                      '${AppLocalizations.of(context).translate('requests', 'error')} ${requestListSnapshot.error}');
                }
                switch (requestListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<RequestModel> requestModelList =
                        requestListSnapshot.data;
                    requestModelList = filterBlockedRequestsContent(
                        context: context, requestModelList: requestModelList);

                    if (requestModelList.length == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text(AppLocalizations.of(context)
                                .translate('requests', 'no_requests'))),
                      );
                    }
                    var consolidatedList =
                        GroupRequestCommons.groupAndConsolidateRequests(
                            requestModelList,
                            SevaCore.of(context).loggedInUser.sevaUserID);
                    return formatListFrom(
                      consolidatedList: consolidatedList,
                      projectId: widget.projectId,
                    );
                }
              },
            );
          });
    }
  }

  List<RequestModel> filterBlockedRequestsContent({
    List<RequestModel> requestModelList,
    BuildContext context,
  }) {
    List<RequestModel> filteredList = [];

    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? AppLocalizations.of(context).translate('requests', 'filtering')
        : filteredList.add(request));

    return filteredList;
  }

  Widget formatListFrom(
      {List<RequestModelList> consolidatedList,
      String loggedintimezone,
      String userEmail,
      String projectId}) {
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
          return getRequestView(
            consolidatedList[index],
            loggedintimezone,
            userEmail,
          );
        },
      )),
    );
  }

  Widget getRequestView(
      RequestModelList model, String loggedintimezone, String userEmail) {
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
        );

      default:
        return Text(
            AppLocalizations.of(context).translate('requests', 'default'));
    }
  }

  Widget getFromNormalRequest(
      {RequestModel model, String loggedintimezone, String userEmail}) {
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
                              margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                              child: Center(
                                child: Visibility(
                                  visible: model.isRecurring,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecurringRequestList(
                                                  model: model),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.navigate_next),
                                  ),
                                ),
                              ))
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          model.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(widget.parentContext).textTheme.subtitle,
                        ),
                      ),
                      SizedBox(height: 8),
                      Visibility(
                        visible: !model.isRecurring,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              getTimeFormattedString(
                                  model.requestStart, loggedintimezone),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward, size: 14),
                            SizedBox(width: 4),
                            Text(
                              getTimeFormattedString(
                                model.requestEnd,
                                loggedintimezone,
                              ),
                            ),
                          ],
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
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  width: 100,
                                  height: 32,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.all(0),
                                    color: Colors.green,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('requests', 'applied'),
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
          ),
        ),
      ),
    );
  }

  Widget getRequestListViewHolder(
      {RequestModel model, String loggedintimezone, String userEmail}) {
    if (!widget.isProjectRequest) {
      return getFromNormalRequest(
        model: model,
        loggedintimezone: loggedintimezone,
        userEmail: userEmail,
      );
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
      print("is recurring ===== ${model.isRecurring}");
      Navigator.push(
          widget.parentContext,
          MaterialPageRoute(
              builder: (context) => RecurringRequestList(
                    model: model,
                    timebankModel: widget.timebankModel,
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
