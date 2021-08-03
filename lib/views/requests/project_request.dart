import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/projects/bloc/project_description_bloc.dart';
import 'package:sevaexchange/ui/screens/projects/pages/project_chat.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/resources/community_list_provider.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
import '../../new_baseline/models/project_model.dart';
import '../core.dart';
import '../project_view/about_project_view.dart';

class ProjectRequests extends StatefulWidget {
  final ComingFrom comingFrom;
  String timebankId;
  final TimebankModel timebankModel;
  final ProjectModel projectModel;
  ProjectRequests(@required this.comingFrom,
      {@required this.timebankId,
      @required this.projectModel,
      @required this.timebankModel});
//  State<StatefulWidget> createState() {
  RequestsState createState() => RequestsState();
}

// Create a Form Widget

class RequestsState extends State<ProjectRequests>
    with SingleTickerProviderStateMixin {
  UserModel user = null;

  ProjectModel projectModel;
  bool isProjectMember = false;
  bool isChatVisible = false;
  final ProjectDescriptionBloc bloc = ProjectDescriptionBloc();

  @override
  void initState() {
    super.initState();
    projectModel = widget.projectModel;
    bloc.init(projectModel.associatedMessaginfRoomId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      FirestoreManager.getUserForIdStream(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID)
          .listen((onData) {
        user = onData;
        setState(() {});
      });
      FirestoreManager.getProjectStream(projectId: projectModel.id)
          .listen((onData) {
        projectModel = onData;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = SevaCore.of(context).loggedInUser;
    isProjectMember = (ProjectMessagingRoomHelper.getAssociatedMembers(
              associatedmembers: projectModel.associatedmembers,
            ).contains(user.sevaUserID) ||
            projectModel.creatorId == user.sevaUserID) &&
        projectModel.associatedmembers.isNotEmpty;

    return BlocProvider(
      bloc: bloc,
      child: DefaultTabController(
        length: isProjectMember ? 3 : 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.5,
            title: Text(
              '${projectModel.name}',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: 150.0),
                child: Material(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    indicatorColor: Theme.of(context).accentColor,
                    labelColor: Colors.white,
                    isScrollable: false,
                    tabs: <Widget>[
                      Tab(
                        text: S.of(context).requests,
                      ),
                      Tab(
                        text: S.of(context).about,
                      ),
                      ...isProjectMember ? [Tab(text: 'Chat')] : [],
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ProjectRequestList(
                      timebankModel: widget.timebankModel,
                      projectModel: projectModel,
                      userModel: user,
                    ),
                    AboutProjectView(
                      project_id: projectModel.id,
                      timebankModel: widget.timebankModel,
                    ),
                    ...isProjectMember ? [ProjectChatView()] : [],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectRequestList extends StatefulWidget {
  final ProjectModel projectModel;
  final TimebankModel timebankModel;
  final UserModel userModel;

  ProjectRequestList({this.projectModel, this.timebankModel, this.userModel});

  @override
  ProjectRequestListState createState() => ProjectRequestListState();
}

class ProjectRequestListState extends State<ProjectRequestList> {
  ProjectModel projectModel;
  int completedCount = 0;
  int pendingCount = 0;
  int totalCount = 0;
  List<RequestModel> requestList = [];
  final requestApiProvider = RequestApiProvider();
  @override
  void initState() {
    super.initState();

    projectModel = widget.projectModel;

    getData();
  }

  void getData() async {
    await requestApiProvider
        .getProjectCompletedList(projectId: widget.projectModel.id)
        .then((onValue) {
      completedCount = onValue.length;
    });

    await requestApiProvider
        .getProjectPendingList(projectId: widget.projectModel.id)
        .then((onValue) {
      pendingCount = onValue.length;
    });

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: requestBody(),
    );
  }

  Widget setTitle({String num, String title}) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            num,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getLocation(GeoFirePoint location) async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    return address;
  }

  void createProjectRequest() async {
    var sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;

    if ((widget.projectModel.mode == ProjectMode.TIMEBANK_PROJECT &&
            isAccessAvailable(widget.timebankModel,
                SevaCore.of(context).loggedInUser.sevaUserID)) ||
        (widget.projectModel.mode == ProjectMode.MEMBER_PROJECT &&
            widget.projectModel.creatorId == sevaUserId)) {
      proceedCreatingRequest();
    } else {
      _showProtectedTimebankMessage();
    }
  }

  void _settingModalBottomSheet(context) {
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
                        comingFrom: ComingFrom.Projects,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
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
                              proceedCreatingRequest();
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Projects,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
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
                              proceedCreatingRequest();
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Projects,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
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
                              proceedCreatingRequest();
                            }),
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
                          proceedCreatingRequest();
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  void proceedCreatingRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRequest(
          comingFrom: ComingFrom.Projects,
          timebankId: widget.timebankModel.id,
          projectId: widget.projectModel.id,
          projectModel: widget.projectModel,
          userModel: SevaCore.of(context).loggedInUser,
        ),
      ),
    );
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).access_denied),
          content: Text(S.of(context).not_authorized_create_request),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getSpacerItem(Widget item, item2) {
    return Row(
      children: <Widget>[
        item,
        Spacer(),
        item2,
      ],
    );
  }

  Widget get addRequest {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width - 20,
      child: Row(
        children: <Widget>[
//          Column(
//            children: <Widget>[
//              Text(
//                "Add request",
//                style: TextStyle(
//                  fontWeight: FontWeight.w500,
//                  fontSize: 20,
//                ),
//              ),
//            ],
//          ),
          ButtonTheme(
            minWidth: 110.0,
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
                      S.of(context).add_requests,
                      style: (TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                    ),
                  ),
                ),
                Positioned(
                  // will be positioned in the top right of the container
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
          Container(
            margin: EdgeInsets.only(left: 10),
          ),
          GestureDetector(
              child: Container(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Icon(
                    Icons.add_circle_outline,
                    color: FlavorConfig.values.theme.primaryColor,
                  ),
                ),
              ),
              onTap: () {
                if (widget.projectModel.requestedSoftDelete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 6),
                      content: Text(
                          S.of(context).deleted_events_create_request_message),
                      action: SnackBarAction(
                        label: S.of(context).dismiss,
                        onPressed: () =>
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                      ),
                    ),
                  );
                } else {
                  createProjectRequest();
                }
              }),
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
        ],
      ),
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
        title: S.of(context).request + ' ' + S.of(context).help,
        urlToHit: dynamicLinks['requestsInfoLink'],
      ),
      context: context,
    );
  }

  Widget requestBody() {
    return Column(
      children: <Widget>[
        requestStatusBar,
        addRequest,
        Container(
          height: 10,
        ),
        allRequests(),
      ],
    );
  }

  Widget allRequests() {
    return Expanded(
      child: SizedBox(
        height: 200,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: requestResult(buildContext: context),
        ),
      ),
    );
  }

  Widget requestResult({BuildContext buildContext}) {
    return StreamBuilder<List<RequestModel>>(
      stream: FirestoreManager.getProjectRequestsStream(
          project_id: widget.projectModel.id),
      builder: (BuildContext context,
          AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
        if (requestListSnapshot.hasError) {
          return Text(
            S.of(context).general_stream_error,
          );
        }
        switch (requestListSnapshot.connectionState) {
          case ConnectionState.waiting:
            return LoadingIndicator();
          default:
            List<RequestModel> requestModelList = requestListSnapshot.data;
            requestModelList = filterCompletedRequests(
                requestModelList: requestModelList, mContext: context);
            requestModelList = filterBlockedRequestsContent(
                context: context, requestModelList: requestModelList);

            if (requestModelList.length == 0) {
              return Center(
                child: EmptyWidget(
                  title: S.of(context).no_requests_title,
                  sub_title: S.of(context).no_content_common_description,
                ),
                // child: Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: RichText(
                //     textAlign: TextAlign.center,
                //     text: TextSpan(
                //       children: <TextSpan>[
                //         TextSpan(
                //           style: TextStyle(color: Colors.grey, fontSize: 14),
                //           text: S.of(context).no_requests_available + ' ',
                //         ),
                //         TextSpan(
                //             text: S.of(context).creating_one,
                //             style: TextStyle(
                //               color: Theme.of(context).primaryColor,
                //             ),
                //             recognizer: TapGestureRecognizer()
                //               ..onTap = createProjectRequest),
                //       ],
                //     ),
                //   ),
                // ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: requestModelList.length + 1,
              itemBuilder: (context, index) {
                if (index >= requestModelList.length) {
                  return Container(
                    width: double.infinity,
                    height: 65,
                  );
                }
                // return requestModelList.elementAt(index).address != null

                return FutureBuilder<String>(
                    future: _getLocation(
                        requestModelList.elementAt(index).location),
                    builder: (context, snapshot) {
                      var address = snapshot.data;
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return getProjectRequestWidget(
                            model: requestModelList.elementAt(index),
                            loggedintimezone:
                                SevaCore.of(context).loggedInUser.timezone,
                            mContext: context,
                            address: S.of(context).fetching_location,
                          );
                        default:
                          return getProjectRequestWidget(
                            model: requestModelList.elementAt(index),
                            loggedintimezone:
                                SevaCore.of(context).loggedInUser.timezone,
                            mContext: context,
                            address: address,
                          );
                      }
                    });
              },
            );
        }
      },
    );
  }

//  Future<Widget> getProjectRequestWidgetWithLocation({
//    RequestModel model,
//    String loggedintimezone,
//    BuildContext context,
//  }) async {
//    var address = await _getLocation(model.location);
//    return getProjectRequestWidget(
//        model: model,
//        loggedintimezone: loggedintimezone,
//        context: context,
//        address: address);
//  }

  Widget get loadingWidget {
    return Container(
        height: 150,
        decoration: containerDecorationR,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          child: LoadingIndicator(),
        ));
  }

  Widget getAppropriateTag(RequestType requestType) {
    switch (requestType) {
      case RequestType.CASH:
        return getTagMainFrame(S.of(context).cash_request);
      case RequestType.GOODS:
        return getTagMainFrame(S.of(context).goods_request);
      case RequestType.TIME:
        return getTagMainFrame(S.of(context).time_request);
      case RequestType.ONE_TO_MANY_REQUEST:
        return getTagMainFrame(S.of(context).one_to_many.sentenceCase() +
            '' +
            S.of(context).request);
      // case RequestType.BORROW:
      //   return getTagMainFrame((context).borrow_request_title);

      default:
        return Container();
    }
  }

  Widget getTagMainFrame(String tagTitle) {
    return Container(
        margin: EdgeInsets.only(right: 10), child: TagView(tagTitle: tagTitle));
  }

  Widget getProjectRequestWidget({
    RequestModel model,
    String loggedintimezone,
    BuildContext mContext,
    String address,
  }) {
    bool isAdmin = false;
    if (model.sevaUserId == SevaCore.of(mContext).loggedInUser.sevaUserID ||
        isAccessAvailable(widget.timebankModel,
            SevaCore.of(mContext).loggedInUser.sevaUserID)) {
      isAdmin = true;
    }
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (model.sevaUserId ==
                    SevaCore.of(mContext).loggedInUser.sevaUserID ||
                isAccessAvailable(widget.timebankModel,
                    SevaCore.of(mContext).loggedInUser.sevaUserID)) {
              timeBankBloc.setSelectedRequest(model);
              timeBankBloc.setSelectedTimeBankDetails(widget.timebankModel);
              timeBankBloc.setIsAdmin(isAdmin);
              if (model.isRecurring) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecurringListing(
                      comingFrom: ComingFrom.Projects,
                      requestModel: model,
                      offerModel: null,
                      timebankModel: null,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (mContext) => BlocProvider(
                      bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                      child: RequestTabHolder(
                        isAdmin: true,
                        //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                      ),
                    ),
                  ),
                );
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (mContext) => BlocProvider(
                    bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                    child: RequestDetailsAboutPage(
                      requestItem: model,
                      //   applied: isAdmin ? false : true,
                      timebankModel: widget.timebankModel,
                      isAdmin: isAdmin,
                      //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                    ),
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                model.address != null
                    ? Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.add_location,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 170,
                                    child: Text(
                                      model.address ?? address,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  onPressed: null,
                                ),
                              ],
                            ),
                            Spacer(),
//                      Text(
//                        '${model.postTimestamp}',
//                        style: TextStyle(
//                          color: Colors.black38,
//                        ),
//                      )
                          ],
                        ),
                      )
                    : Container(),
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        height: 40,
                        width: 40,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            model.photoUrl ?? defaultUserImageURL,
                          ),
                          minRadius: 40.0,
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
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
                                ],
                              ),
                              getSpacerItem(
                                Flexible(
                                  child: Text(
                                    '${model.title}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                model.isRecurring
                                    ? Icon(Icons.navigate_next, size: 20)
                                    : Container(),
                              ),
                              getSpacerItem(
                                Text(
                                  !model.isRecurring
                                      ? '${getTimeFormattedString(model.requestStart, loggedintimezone) + '- ' + getTimeFormattedString(model.requestEnd, loggedintimezone)}'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(),
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 8,
                                  child: Text(
                                    '${model.description}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(),
                              ),
                              getSpacerItem(
                                Visibility(
                                  visible: model.isRecurring,
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          S.of(context).recurring,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(),
                              ),
                            ],
                          ),
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

  Widget get requestStatusBar {
    var pendingRequest = pendingCount;
    var completedRequest = completedCount;
    var totalRequests = pendingCount + completedCount;
    return Container(
      height: 75,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      color: Colors.black12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              setTitle(
                num: '${totalRequests ?? ""}',
                title: S.of(context).requests,
              ),
              setTitle(
                num: '${pendingRequest ?? ""}',
                title: S.of(context).pending,
              ),
              setTitle(
                num: '${completedRequest ?? ""}',
                title: S.of(context).completed,
              ),
            ],
          ),
        ],
      ),
    );
  }
//

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

  List<RequestModel> filterBlockedRequestsContent(
      {List<RequestModel> requestModelList, BuildContext context}) {
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

  List<RequestModel> filterCompletedRequests(
      {List<RequestModel> requestModelList, BuildContext mContext}) {
    // List<RequestModel> filteredList = [];
    String sevauserid = SevaCore.of(mContext).loggedInUser.sevaUserID;

    requestModelList.forEach((request) {
      if (sevauserid != request.sevaUserId ||
          !isAccessAvailable(widget.timebankModel,
              SevaCore.of(context).loggedInUser.sevaUserID)) {
        requestModelList.removeWhere((request) =>
            widget.projectModel.completedRequests.contains(request.id));
      }
    });

    return requestModelList;
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
