import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

import '../../flavor_config.dart';
import '../../new_baseline/models/project_model.dart';
import '../core.dart';
import '../project_view/about_project_view.dart';

class ProjectRequests extends StatefulWidget {
  String timebankId;
  final TimebankModel timebankModel;
  final ProjectModel projectModel;
  ProjectRequests(
      {@required this.timebankId,
      @required this.projectModel,
      @required this.timebankModel});
  State<StatefulWidget> createState() {
    return RequestsState();
  }
}

// Create a Form Widget

class RequestsState extends State<ProjectRequests>
    with SingleTickerProviderStateMixin {
  UserModel user = null;
  TabController tabController;
  ProjectModel projectModel;
  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this);
    projectModel = widget.projectModel;
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
    return DefaultTabController(
      length: 2,
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
                    Tab(text: "Requests"),
                    Tab(text: "About"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  requestBody,
                  AboutProjectView(
                    project_id: projectModel.id,
                    timebankId: widget.timebankId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get requestBody {
    return Column(
      children: <Widget>[
        requestStatusBar,
        addRequest,
        Container(
          height: 10,
        ),
        allRequests,
      ],
    );
  }

  Widget get allRequests {
    return Expanded(
      child: SizedBox(
        height: 200,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: requestResult,
        ),
      ),
    );
  }

  Widget get requestResult {
    return projectModel.pendingRequests.length == 0
        ? Column(
            children: <Widget>[
              Text(''),
              Text('No project request found'),
            ],
          )
        : ListView.builder(
            itemCount: projectModel.pendingRequests.length,
            itemBuilder: (_context, index) {
              return StreamBuilder<RequestModel>(
                stream: FirestoreManager.getRequestStreamById(
                    requestId: projectModel.pendingRequests[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return new Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return loadingWidget;
                    default:
                      RequestModel model = snapshot.data;
                      return FutureBuilder<String>(
                          future: _getLocation(model.location),
                          builder: (context, snapshot) {
                            var address = snapshot.data;
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return getProjectRequestWidget(
                                  model: model,
                                  loggedintimezone: user.timezone,
                                  context: context,
                                  address: "Fetching location",
                                );
                              default:
                                return getProjectRequestWidget(
                                  model: model,
                                  loggedintimezone: user.timezone,
                                  context: context,
                                  address: address,
                                );
                            }
                          });
                  }
                },
              );
            });
  }

  Future<Widget> getProjectRequestWidgetWithLocation({
    RequestModel model,
    String loggedintimezone,
    BuildContext context,
  }) async {
    var address = await _getLocation(model.location);
    return getProjectRequestWidget(
        model: model,
        loggedintimezone: loggedintimezone,
        context: context,
        address: address);
  }

  Widget get loadingWidget {
    return Container(
        height: 150,
        decoration: containerDecorationR,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }

  Widget getProjectRequestWidget({
    RequestModel model,
    String loggedintimezone,
    BuildContext context,
    String address,
  }) {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditRequest(
                  timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
                  requestModel: model,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(
                              Icons.add_location,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Container(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                "$address",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                ),
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
                            '${model.photoUrl}',
//                              'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                          ),
                          minRadius: 40.0,
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              getSpacerItem(
                                Text(
                                  '${model.title}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Text(
                                  '${getTimeFormattedString(model.requestStart, loggedintimezone) + '-' + getTimeFormattedString(model.requestEnd, loggedintimezone)}',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    '${model.description}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
    var pendingRequest = projectModel.pendingRequests.length;
    var completedRequest = projectModel.completedRequests.length;
    var totalRequests = pendingRequest + completedRequest;
    return Container(
      height: 75,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      color: Color.fromRGBO(250, 231, 53, 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              setTitle(num: '$totalRequests ?? "', title: 'Requests'),
              setTitle(num: '$pendingRequest ?? "', title: 'Pending'),
              setTitle(num: '$completedRequest ?? "', title: 'Completed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget getList({
    List<RequestModel> finalRequestModelList,
  }) {
    return Expanded(
      child: SizedBox(
        height: 200.0,
        child: ListView.builder(
            itemCount: finalRequestModelList.length + 1,
            itemBuilder: (_context, index) {
              return index < finalRequestModelList.length
                  ? FutureBuilder<Widget>(
                      future: getListTile(
                        model: finalRequestModelList[index],
                        loggedintimezone: user.timezone,
                        context: context,
                      ),
                      builder: (BuildContext context,
                          AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasData) return snapshot.data;

                        return getListWidgetItem(
                            model: finalRequestModelList[index],
                            loggedintimezone: user.timezone,
                            context: context,
                            address: "Fetching address");
                      })
                  : SizedBox(
                      height: 50,
                    );
            }),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
    DateFormat dateFormat = DateFormat('d MMM hh:mm a ');
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

    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? "Filtering blocked content"
        : filteredList.add(request));

    return filteredList;
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

  Future<Widget> getListTile({
    RequestModel model,
    String loggedintimezone,
    BuildContext context,
  }) async {
    var address = await _getLocation(model.location);
    return getListWidgetItem(
        model: model,
        loggedintimezone: loggedintimezone,
        context: context,
        address: address);
  }

  Widget getListWidgetItem(
      {RequestModel model,
      String loggedintimezone,
      BuildContext context,
      String address}) {
    bool isAdmin = false;
    if (model.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID ||
        widget.timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestDetailsAboutPage(
                  project_id: projectModel.id,
                  requestItem: model,
                  applied: isAdmin ? false : true,
                  timebankModel: widget.timebankModel,
                  isAdmin: isAdmin,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(
                              Icons.add_location,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Container(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                "$address",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.all(5),
                          height: 40,
                          width: 40,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              '${model.photoUrl}',
//                              'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                            ),
                            minRadius: 40.0,
                          ),
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              getSpacerItem(
                                Text(
                                  '${model.title}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Text(
                                  '${getTimeFormattedString(model.requestStart, loggedintimezone) + '-' + getTimeFormattedString(model.requestEnd, loggedintimezone)}',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    '${model.description}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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

  Future<String> _getLocation(GeoFirePoint location) async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    return address;
  }

  void createProjectRequest() async {
    var sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    if (widget.timebankModel.protected) {
      if (widget.timebankModel.admins.contains(sevaUserId)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateRequest(
              timebankId: widget.timebankModel.id,
              projectId: projectModel.id,
              projectModel: projectModel,
            ),
          ),
        );
      } else {
        _showProtectedTimebankMessage();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRequest(
            timebankId: widget.timebankModel.id,
            projectId: projectModel.id,
            projectModel: projectModel,
          ),
        ),
      );
    }
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Protected Timebank"),
          content: new Text("You cannot post requests in a protected timebank"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getSpacerItem(Widget item) {
    return Row(
      children: <Widget>[
        item,
        Spacer(),
      ],
    );
  }

  Widget get addRequest {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width - 20,
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "Add request",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            children: <Widget>[
              Container(
                height: 10,
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
                onTap: () => createProjectRequest(),
              ),
            ],
          ),
        ],
      ),
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
}
