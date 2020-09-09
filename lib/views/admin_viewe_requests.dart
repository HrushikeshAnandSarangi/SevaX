//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:sevaexchange/constants/sevatitles.dart';
//import 'package:sevaexchange/l10n/l10n.dart';
//import 'package:sevaexchange/models/request_model.dart';
//import 'package:sevaexchange/models/user_model.dart';
//import 'package:sevaexchange/utils/app_config.dart';
//import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
//import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
//import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
//import 'package:sevaexchange/views/timebanks/admin_view_request_status.dart';
//import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
//
//import 'core.dart';
//import 'group_models/GroupingStrategy.dart';
//
//class ViewRequestsForAdmin extends StatelessWidget {
//  final String timebankId;
//  BuildContext parentContext;
//
//  ViewRequestsForAdmin(this.timebankId);
//
//  @override
//  Widget build(BuildContext context) {
//    parentContext = context;
//    if (timebankId != 'All') {
//      return Scaffold(
//          appBar: AppBar(
//            title: Text(
//              S.of(context).select_request,
//              style: TextStyle(
//                fontSize: 18,
//              ),
//            ),
//          ),
//          body: Column(
//            children: <Widget>[
//              FutureBuilder<Object>(
//                future: getUserForId(
//                    sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//                builder: (context, snapshot) {
//                  if (snapshot.hasError) {
//                    return Text('Error: ${snapshot.error}');
//                  }
//                  if (snapshot.connectionState == ConnectionState.waiting) {
//                    return LoadingIndicator();
//                  }
//                  UserModel user = snapshot.data;
//                  String loggedintimezone = user.timezone;
//
//                  return StreamBuilder<List<RequestModel>>(
//                    stream: getRequestListStream(
//                      timebankId: timebankId,
//                    ),
//                    builder: (BuildContext context,
//                        AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                      if (requestListSnapshot.hasError) {
//                        return Text('Error: ${requestListSnapshot.error}');
//                      }
//
//                      switch (requestListSnapshot.connectionState) {
//                        case ConnectionState.waiting:
//                          return LoadingIndicator();
//                        default:
//                          List<RequestModel> requestModelList =
//                              requestListSnapshot.data;
//                          requestModelList = filterBlockedRequestsContent(
//                            context: context,
//                            requestModelList: requestModelList,
//                          );
//
//                          if (requestModelList.length == 0) {
//                            return Padding(
//                              padding: const EdgeInsets.all(16.0),
//                              child: Center(
//                                child: Text(
//                                  S.of(context).no_requests,
//                                ),
//                              ),
//                            );
//                          }
//
//                          var consolidatedList =
//                              GroupRequestCommons.groupAndConsolidateRequests(
//                                  requestModelList,
//                                  SevaCore.of(context).loggedInUser.sevaUserID);
//
//                          return formatListFrom(
//                            consolidatedList: consolidatedList,
//                            loggedintimezone: loggedintimezone,
//                          );
//                      }
//                    },
//                  );
//                },
//              ),
//            ],
//          ));
//    } else {
//      return FutureBuilder<Object>(
//          future: getUserForId(
//              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//          builder: (context, snapshot) {
//            if (snapshot.hasError) {
//              return Text('Error: ${snapshot.error}');
//            }
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return LoadingIndicator();
//            }
//            UserModel user = snapshot.data;
//            String loggedintimezone = user.timezone;
//
//            return StreamBuilder<List<RequestModel>>(
//              stream: getAllRequestListStream(),
//              builder: (BuildContext context,
//                  AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                if (requestListSnapshot.hasError) {
//                  return Text('Error: ${requestListSnapshot.error}');
//                }
//                switch (requestListSnapshot.connectionState) {
//                  case ConnectionState.waiting:
//                    return LoadingIndicator();
//                  default:
//                    List<RequestModel> requestModelList =
//                        requestListSnapshot.data;
//
//                    requestModelList = filterBlockedRequestsContent(
//                        context: context, requestModelList: requestModelList);
//
//                    if (requestModelList.length == 0) {
//                      return Padding(
//                        padding: const EdgeInsets.all(16.0),
//                        child: Center(
//                          child: Text(
//                            S.of(context).no_requests,
//                          ),
//                        ),
//                      );
//                    }
//                    var consolidatedList =
//                        GroupRequestCommons.groupAndConsolidateRequests(
//                            requestModelList,
//                            SevaCore.of(context).loggedInUser.sevaUserID);
//                    return formatListFrom(consolidatedList: consolidatedList);
//                }
//              },
//            );
//          });
//    }
//  }
//
//  List<RequestModel> filterBlockedRequestsContent({
//    List<RequestModel> requestModelList,
//    BuildContext context,
//  }) {
//    List<RequestModel> filteredList = [];
//
//    requestModelList.forEach((request) => SevaCore.of(context)
//                .loggedInUser
//                .blockedMembers
//                .contains(request.sevaUserId) ||
//            SevaCore.of(context)
//                .loggedInUser
//                .blockedBy
//                .contains(request.sevaUserId)
//        ? "Filtering blocked content"
//        : filteredList.add(request));
//
//    return filteredList;
//  }
//
//  Widget formatListFrom(
//      {List<RequestModelList> consolidatedList, String loggedintimezone}) {
//    return Expanded(
//      child: Container(
//        child: ListView.builder(
//          itemCount: consolidatedList.length,
//          itemBuilder: (context, index) {
//            return getRequestView(consolidatedList[index], loggedintimezone);
//          },
//        ),
//      ),
//    );
//  }
//
//  Widget getRequestView(RequestModelList model, String loggedintimezone) {
//    switch (model.getType()) {
//      case RequestModelList.TITLE:
//        return Container();
//
//      // return Container(
//      //   margin: EdgeInsets.all(12),
//      //   child: Text(
//      //     GroupRequestCommons.getGroupTitle(
//      //         groupKey: (model as GroupTitle).groupTitle),
//      //   ),
//      // );
//
//      case RequestModelList.REQUEST:
//        return getRequestListViewHoldder(
//          model: (model as RequestItem).requestModel,
//          loggedintimezone: loggedintimezone,
//        );
//
//      default:
//        return Text("DEFAULT");
//    }
//  }
//
//  Widget getRequestListViewHoldder(
//      {RequestModel model, String loggedintimezone}) {
//    return Container(
//      decoration: containerDecorationR,
//      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//      child: Card(
//        color: Colors.white,
//        elevation: 2,
//        child: InkWell(
//          onTap: () {
//            Navigator.push(
//              parentContext,
//              MaterialPageRoute(
//                builder: (context) => ViewRequestStatus(
//                  requestModel: model,
//                ),
//              ),
//            );
//          },
//          child: Padding(
//            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//            child: Row(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                ClipOval(
//                  child: SizedBox(
//                    height: 45,
//                    width: 45,
//                    child: FadeInImage.assetNetwork(
//                      placeholder: 'lib/assets/images/profile.png',
//                      image: model.photoUrl == null
//                          ? defaultUserImageURL
//                          : model.photoUrl,
//                    ),
//                  ),
//                ),
//                SizedBox(width: 16),
//                Expanded(
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Text(
//                        model.title,
//                        style: Theme.of(parentContext).textTheme.subhead,
//                      ),
//                      Text(
//                        model.description,
//                        style: Theme.of(parentContext).textTheme.subtitle,
//                      ),
//                      SizedBox(height: 8),
//                      Wrap(
//                        crossAxisAlignment: WrapCrossAlignment.center,
//                        children: <Widget>[
//                          Text(getTimeFormattedString(
//                            model.requestStart,
//                            loggedintimezone,
//                          )),
//                          SizedBox(width: 2),
//                          Icon(Icons.arrow_forward, size: 14),
//                          SizedBox(width: 4),
//                          Text(getTimeFormattedString(
//                            model.requestEnd,
//                            loggedintimezone,
//                          )),
//                        ],
//                      ),
//                    ],
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
//    DateFormat dateFormat = DateFormat('d MMM hh:mm a ',
//        Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
//    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
//    DateTime localtime = getDateTimeAccToUserTimezone(
//        dateTime: datetime, timezoneAbb: timezoneAbb);
//    String from = dateFormat.format(
//      localtime,
//    );
//    return from;
//  }
//
//  BoxDecoration get containerDecoration {
//    return BoxDecoration(
//      borderRadius: BorderRadius.all(Radius.circular(2.0)),
//      boxShadow: [
//        BoxShadow(
//          color: Colors.black.withAlpha(2),
//          spreadRadius: 6,
//          offset: Offset(0, 3),
//          blurRadius: 6,
//        )
//      ],
//      color: Colors.white,
//    );
//  }
//
//  BoxDecoration get containerDecorationR {
//    return BoxDecoration(
//      borderRadius: BorderRadius.all(Radius.circular(2.0)),
//      boxShadow: [
//        BoxShadow(
//            color: Colors.black.withAlpha(2),
//            spreadRadius: 6,
//            offset: Offset(0, 3),
//            blurRadius: 6)
//      ],
//      color: Colors.white,
//    );
//  }
//}
