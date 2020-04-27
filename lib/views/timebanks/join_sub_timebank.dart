// import 'package:cached_network_image/cached_network_image.dart';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;

import '../timebank_content_holder.dart';

class JoinSubTimeBankView extends StatefulWidget {
  final UserModel loggedInUserModel;
  final bool isFromDash;
  final String communityId;
  final String communityPrimaryTimebankId;

  JoinSubTimeBankView({
    this.loggedInUserModel,
    @required this.isFromDash,
    @required this.communityId,
    @required this.communityPrimaryTimebankId,
  });

  _JoinSubTimeBankViewState createState() => _JoinSubTimeBankViewState();
}

enum CompareToTimeBank { JOINED, REQUESTED, REJECTED, JOIN }

class _JoinSubTimeBankViewState extends State<JoinSubTimeBankView> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();
  TimebankModel timebankModel;
  //TimebankModel superAdminModel;
  JoinRequestModel joinRequestModel = new JoinRequestModel();
  //JoinRequestModel getRequestData = new JoinRequestModel();
  UserModel ownerModel;
  String title = 'Loading';
  String loggedInUser;
  final formkey = GlobalKey<FormState>();
  String userStatus = '';
  static const String JOIN = "Join";
  static const String JOINED = "Joined";
  static const String REQUESTED = "Requested";
  static const String REJECTED = "Rejected";

  bool hasError = false;
  String errorMessage1 = '';
  List<JoinRequestModel> _joinRequestModels;
  bool isDataLoaded = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void getData() async {
    createEditCommunityBloc.getChildTimeBanks(context);

    _joinRequestModels =
        await getFutureUserRequest(userID: widget.loggedInUserModel.sevaUserID);
    setState(() {
      isDataLoaded = true;
    });

    //print('User request ${}');

    // print('User request ${newList}');
  }

  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<UserDataBloc>(context);
    print("in explore ==> ${_bloc.user.email}");
    return Scaffold(
//      appBar: AppBar(
//        title: Text("Group",
//            style: TextStyle(
//              fontSize: 20,
//              fontFamily: "Europa",
//            )),
//        centerTitle: true,
//        actions: <Widget>[
//          Offstage(
//            offstage: true,
//            child: widget.isFromDash
//                ? FlatButton(
//                    child: Text(
//                      "Continue",
//                      style: TextStyle(
//                        fontSize: 16,
//                        fontFamily: "Europa",
//                      ),
//                    ),
//                    textColor: Colors.lightBlue,
//                    onPressed: () {
//                      Navigator.of(context).push(MaterialPageRoute(
//                          builder: (context) => HomeDashBoard()));
//                    },
//                  )
//                : Text(""),
//          )
//        ],
//      ),
      body: isDataLoaded
          ? SingleChildScrollView(
              child: getTimebanks(context: context, bloc: _bloc),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  List<String> dropdownList = [];

  Widget getTimebanks({BuildContext context, UserDataBloc bloc}) {
    Size size = MediaQuery.of(context).size;
    List<TimebankModel> timebankList = [];
    return FutureBuilder<List<TimebankModel>>(
        future: getTimebanksForCommunity(
          communityId: widget.loggedInUserModel.currentCommunity,
          primaryTimebankId: widget.communityPrimaryTimebankId,
        ),
        builder: (context, snapshot) {
          //    print('timee ${snapshot.data}');
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text("No groups found"),
              ),
            );
          }

          timebankList = snapshot.data;
          timebankList.forEach((t) {
            dropdownList.add(t.id);
            //  print('timee  banks  ${t}');
          });

          // Navigator.pop(context);
          print("data ${dropdownList.length}");

          if (snapshot.data != null) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                  child: Text(
                    "Groups within a Timebank allow for granular activities. You can join one of the groups below or create your own group",
                  ),
                ),
                ListView.separated(
                  itemCount: timebankList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CompareToTimeBank status;
                    TimebankModel timebank = timebankList.elementAt(index);
                    //  print('timebank is ${timebankList.length}');
                    if (timebank.admins
                            .contains(widget.loggedInUserModel.sevaUserID) ||
                        timebank.coordinators
                            .contains(widget.loggedInUserModel.sevaUserID) ||
                        timebank.members
                            .contains(widget.loggedInUserModel.sevaUserID)) {
                      status = CompareToTimeBank.JOINED;
                      userStatus = 'Joined';
                      return makeItem(timebank, status, bloc, userStatus);
                    } else if (_joinRequestModels != null) {
                      CompareToTimeBank campareStatus;

                      _joinRequestModels.forEach((joinRequestModel) {
                        if (joinRequestModel.entityId == timebank.id) {
                          print('timebank is true ${timebank.id}');

                          if (joinRequestModel.operationTaken == true &&
                              joinRequestModel.accepted == false) {
                            campareStatus = CompareToTimeBank.REJECTED;
                            print('request us rejected ${timebank.id}');
                            userStatus = 'Rejected';
                          } else if (joinRequestModel.operationTaken == false) {
                            campareStatus = CompareToTimeBank.REQUESTED;
                            userStatus = 'Requested';
                          } else if (joinRequestModel.accepted == true) {
                            campareStatus = CompareToTimeBank.JOINED;
                            userStatus = 'Joined';
                          }
                        }
                      });
                      if (campareStatus != CompareToTimeBank.JOIN) {
                        status = campareStatus;
                        return makeItem(timebank, status, bloc, userStatus);
                      }
                      status = CompareToTimeBank.JOIN;
                      userStatus = 'Join';
                      return makeItem(timebank, status, bloc, userStatus);
                    } else {
                      userStatus = 'Join';
                      status = CompareToTimeBank.JOIN;
                      return makeItem(timebank, status, bloc, userStatus);
                    }
                  },
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,
                    );
                  },
                ),
              ],
            );
          }
          return CircularProgressIndicator();
        });
  }

  Widget makeItem(TimebankModel timebank, CompareToTimeBank status, bloc,
      String userStatus) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<UserDataBloc>(
              bloc: bloc,
              child: TimebankTabsViewHolder.of(
                timebankId: timebank.id,
                timebankModel: timebank,
              ),
            ),
          ),
        );
      },
      child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 3.3 / 2.3,
                child: CachedNetworkImage(
                  imageUrl: timebank.photoUrl ?? defaultGroupImageURL,
                  fit: BoxFit.fitWidth,
                  errorWidget: (context, url, error) =>
                      Center(child: Text('No Image Avaialable')),
                  placeholder: (conext, url) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          timebank.name ?? "",
                          style: TextStyle(
                            fontFamily: "Europa",
                            fontSize: 18,
                            color: Colors.black,
                          ),
//                                maxLines: 1,
                        ),
                        Text(
                          timebank.address ??
                              "" + ' .' + timebank.members.length.toString() ??
                              " ",
                          style: TextStyle(
                              fontFamily: "Europa",
                              fontSize: 14,
                              color: Colors.grey),
                          maxLines: 1,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: RaisedButton(
                      elevation: 0,
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: Text(getTimeBankStatusTitle(status) ?? "",
                          style: TextStyle(fontSize: 14)),
                      onPressed: userStatus == 'Join'
                          ? () async {
                              //    print('print time data ${timebank.creatorId}');
                              joinRequestModel.reason =
                                  "i want to join this group";
                              joinRequestModel.userId =
                                  widget.loggedInUserModel.sevaUserID;
                              joinRequestModel.timestamp =
                                  DateTime.now().millisecondsSinceEpoch;

                              joinRequestModel.entityId = timebank.id;
                              joinRequestModel.entityType = EntityType.Timebank;
                              joinRequestModel.accepted = false;

                              await updateJoinRequest(model: joinRequestModel);

                              JoinRequestNotificationModel joinReqModel =
                                  JoinRequestNotificationModel(
                                      timebankId: timebank.id,
                                      timebankTitle: timebank.name,
                                      reasonToJoin: joinRequestModel.reason);

                              NotificationsModel notification =
                                  NotificationsModel(
                                id: utils.Utils.getUuid(),
                                targetUserId: timebank.creatorId,
                                senderUserId:
                                    widget.loggedInUserModel.sevaUserID,
                                type: prefix0.NotificationType.JoinRequest,
                                data: joinReqModel.toMap(),
                              );

                              notification.timebankId =
                                  FlavorConfig.values.timebankId;
                              //  print('creator id ${notification.timebankId}');

                              UserModel timebankCreator =
                                  await FirestoreManager.getUserForId(
                                      sevaUserId: timebank.creatorId);
                              //print('time creator email ${timebankCreator.email}');

                              await Firestore.instance
                                  .collection('users')
                                  .document(timebankCreator.email)
                                  .collection("notifications")
                                  .document(notification.id)
                                  .setData(notification.toMap());

                              setState(() {
                                getData();
                              });
                              return;
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  String getTimeBankStatusTitle(CompareToTimeBank status) {
    switch (status) {
      case CompareToTimeBank.JOIN:
        return JOIN;

      case CompareToTimeBank.JOINED:
        return JOINED;

      case CompareToTimeBank.REJECTED:
        return REJECTED;

      case CompareToTimeBank.REQUESTED:
        return REQUESTED;

      default:
        return JOIN;
    }
  }

  CompareToTimeBank compareTimeBanks(
      List<JoinRequestModel> joinRequestModels, TimebankModel timeBank) {
    // CompareToTimeBank status;
    print("inside compareTimeBanks length " +
        joinRequestModels.length.toString());
    for (int i = 0; i < joinRequestModels.length; i++) {
      JoinRequestModel requestModel = joinRequestModels[i];
      print("inside compareTimeBanks " + joinRequestModels[i].userId);
      print("inside compareTimeBanks accepted " +
          joinRequestModels[i].accepted.toString());
      print(
          "inside compareTimeBanks enity id " + joinRequestModels[i].entityId);
      print("inside compareTimeBanks timebank id two " + timeBank.id);

      if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].accepted == true) {
        return CompareToTimeBank.JOINED;
      } else if (timeBank.admins
              .contains(widget.loggedInUserModel.sevaUserID) ||
          timeBank.coordinators.contains(widget.loggedInUserModel.sevaUserID) ||
          timeBank.members.contains(widget.loggedInUserModel.sevaUserID)) {
        print("user status joined");

        return CompareToTimeBank.JOINED;
      } else if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].operationTaken == false) {
        print("user status requested");

        return CompareToTimeBank.REQUESTED;
      } else if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].operationTaken == true &&
          joinRequestModels[i].accepted == false) {
        print("user status rejected");

        return CompareToTimeBank.REJECTED;
      } else {
        print("user status join");

        return CompareToTimeBank.JOIN;
      }
    }
    return CompareToTimeBank.JOIN;
  }
}

Future<List<TimebankModel>> getTimebanksForCommunity(
    {String communityId, String primaryTimebankId}) async {
  List<TimebankModel> timebankList = [];

  return Firestore.instance
      .collection('timebanknew')
      .where('community_id', isEqualTo: communityId)
      .getDocuments()
      .then((QuerySnapshot timebankModel) {
    timebankModel.documents.forEach((timebank) {
      var model = TimebankModel.fromMap(timebank.data);
      if (model.id != primaryTimebankId) timebankList.add(model);
    });
    return timebankList;
  }).catchError((onError) {
    return onError;
  });
}
