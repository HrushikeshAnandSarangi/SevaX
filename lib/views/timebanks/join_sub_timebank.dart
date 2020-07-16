// import 'package:cached_network_image/cached_network_image.dart';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import '../timebank_content_holder.dart';

class JoinSubTimeBankView extends StatefulWidget {
  final UserModel loggedInUserModel;
  final bool isFromDash;
  final String communityId;
  final String communityPrimaryTimebankId;

  JoinSubTimeBankView(
      {this.loggedInUserModel,
      @required this.isFromDash,
      this.communityId,
      this.communityPrimaryTimebankId});

  _JoinSubTimeBankViewState createState() => _JoinSubTimeBankViewState();
}

enum CompareToTimeBank { JOINED, REQUESTED, REJECTED, JOIN }

class _JoinSubTimeBankViewState extends State<JoinSubTimeBankView> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();
  TimebankModel timebankModel;
  JoinRequestModel joinRequestModel = JoinRequestModel();
  UserModel ownerModel;
  String title;
  String loggedInUser;
  final formkey = GlobalKey<FormState>();
  String JOIN;
  String JOINED;
  String REQUESTED;
  String REJECTED;
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
    title =
        AppLocalizations.of(context).translate('jointimebank_sub', 'loading');
    JOIN = AppLocalizations.of(context).translate('jointimebank_sub', 'join');
    JOINED =
        AppLocalizations.of(context).translate('jointimebank_sub', 'joined');
    REQUESTED =
        AppLocalizations.of(context).translate('jointimebank_sub', 'requested');
    REJECTED =
        AppLocalizations.of(context).translate('jointimebank_sub', 'rejected');
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
          if (snapshot.hasError)
            return Text(
                '${AppLocalizations.of(context).translate('jointimebank_sub', 'error_text')} ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(AppLocalizations.of(context)
                    .translate('jointimebank_sub', 'no_groups')),
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
                    AppLocalizations.of(context)
                        .translate('jointimebank_sub', 'desc'),
                  ),
                ),
                ListView.separated(
                  itemCount: timebankList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CompareToTimeBank status;
                    String userStatus = AppLocalizations.of(context)
                        .translate('jointimebank_sub', 'join');

                    TimebankModel timebank = timebankList.elementAt(index);
                    //  print('timebank is ${timebankList.length}');
                    if (timebank.admins
                            .contains(widget.loggedInUserModel.sevaUserID) ||
                        timebank.coordinators
                            .contains(widget.loggedInUserModel.sevaUserID) ||
                        timebank.members
                            .contains(widget.loggedInUserModel.sevaUserID)) {
                      status = CompareToTimeBank.JOINED;
                      userStatus = AppLocalizations.of(context)
                          .translate('jointimebank_sub', 'joined');
                      //    setState(() {});
                      return makeItem(timebank, status, bloc,
                          userStatus: userStatus);
                    }

                    if (_joinRequestModels != null) {
                      CompareToTimeBank campareStatus;

                      _joinRequestModels.forEach((joinRequestModel) {
                        if (joinRequestModel.entityId == timebank.id) {
                          print('timebank is true ${timebank.id}');

                          if (joinRequestModel.operationTaken == true &&
                              joinRequestModel.accepted == false) {
                            campareStatus = CompareToTimeBank.REJECTED;
                            print('request us rejected ${timebank.id}');
                            userStatus = AppLocalizations.of(context)
                                .translate('jointimebank_sub', 'rejected');
                          }
                          if (joinRequestModel.operationTaken == false) {
                            campareStatus = CompareToTimeBank.REQUESTED;
                            userStatus = AppLocalizations.of(context)
                                .translate('jointimebank_sub', 'requested');
                          }
                          if (joinRequestModel.accepted == true) {
                            campareStatus = CompareToTimeBank.JOINED;
                            userStatus = AppLocalizations.of(context)
                                .translate('jointimebank_sub', 'joined');
                          }
                          campareStatus = CompareToTimeBank.JOIN;

                          // userStatus = 'Join';
                        }
                      });

                      status = campareStatus;
                      //setState(() {});

                      return makeItem(timebank, status, bloc,
                          userStatus: userStatus);
                    }

                    userStatus = AppLocalizations.of(context)
                        .translate('jointimebank_sub', 'join');
                    status = CompareToTimeBank.JOIN;
                    return makeItem(timebank, status, bloc,
                        userStatus: userStatus);
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
      {String userStatus}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<UserDataBloc>(
              bloc: bloc,
              child: TabarView(
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
                  errorWidget: (context, url, error) => Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('jointimebank_sub', 'no_image'))),
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
                      color: userStatus ==
                              AppLocalizations.of(context)
                                  .translate('jointimebank_sub', 'join')
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      // child: Text(getTimeBankStatusTitle(status) ?? "",
                      child: Text(userStatus ?? "",
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                      onPressed: () async {
                        if (userStatus ==
                            AppLocalizations.of(context)
                                .translate('jointimebank_sub', 'join')) {
                          await _assembleAndSendRequest(
                            subTimebankId: timebank.id,
                            subTimebankLabel: timebank.name,
                            userIdForNewMember:
                                widget.loggedInUserModel.sevaUserID,
                          );

                          setState(() {
                            getData();
                          });
                          // return;
                        } else {
                          print('user status ${userStatus}');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Future _assembleAndSendRequest({
    String userIdForNewMember,
    String subTimebankLabel,
    String subTimebankId,
  }) async {
    var joinRequestModel = _assembleJoinRequestModel(
      userIdForNewMember: userIdForNewMember,
      subTimebankLabel: subTimebankLabel,
      subtimebankId: subTimebankId,
    );

    var notification = _assembleNotificationForJoinRequest(
      joinRequestModel: joinRequestModel,
      userIdForNewMember: userIdForNewMember,
      creatorId: userIdForNewMember,
      subTimebankId: subTimebankId,
    );

    await createAndSendJoinJoinRequest(
      joinRequestModel: joinRequestModel,
      notification: notification,
      subtimebankId: subTimebankId,
    ).commit();
  }

  WriteBatch createAndSendJoinJoinRequest({
    String subtimebankId,
    prefix0.NotificationsModel notification,
    JoinRequestModel joinRequestModel,
  }) {
    WriteBatch batchWrite = Firestore.instance.batch();
    batchWrite.setData(
        Firestore.instance
            .collection('timebanknew')
            .document(
              subtimebankId,
            )
            .collection("notifications")
            .document(notification.id),
        notification.toMap());

    batchWrite.setData(
        Firestore.instance
            .collection('join_requests')
            .document(joinRequestModel.id),
        joinRequestModel.toMap());
    return batchWrite;
  }

  JoinRequestModel _assembleJoinRequestModel({
    String userIdForNewMember,
    String subTimebankLabel,
    String subtimebankId,
  }) {
    return JoinRequestModel(
        timebankTitle: subTimebankLabel,
        accepted: false,
        entityId: subtimebankId,
        entityType: EntityType.Timebank,
        operationTaken: false,
        reason: AppLocalizations.of(context)
            .translate('jointimebank_sub', 'reason'),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        userId: userIdForNewMember,
        isFromGroup: true,
        notificationId: utils.Utils.getUuid());
  }

  NotificationsModel _assembleNotificationForJoinRequest({
    String userIdForNewMember,
    JoinRequestModel joinRequestModel,
    String subTimebankId,
    String creatorId,
  }) {
    return NotificationsModel(
      timebankId: subTimebankId,
      id: joinRequestModel.notificationId,
      targetUserId: creatorId,
      senderUserId: userIdForNewMember,
      type: prefix0.NotificationType.JoinRequest,
      data: joinRequestModel.toMap(),
      communityId: "NOT_REQUIRED",
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
//  DocumentSnapshot documentSnapshot = await Firestore.instance.collection('communities').document(communityId).get();
//  Map<String, dynamic> dataMap = documentSnapshot.data;
//  CommunityModel communityModel = CommunityModel(dataMap);
  List<TimebankModel> timebankList = [];
  return Firestore.instance
      .collection('timebanknew')
      .where('community_id', isEqualTo: communityId)
      .getDocuments()
      .then((QuerySnapshot timebankModel) {
    timebankModel.documents.forEach((timebank) {
      var model = TimebankModel.fromMap(timebank.data);
      if (model.id != primaryTimebankId &&
          !model.softDelete &&
          model.private == false) {
        timebankList.add(model);
      }
    });
    return timebankList;
  }).catchError((onError) {
    return onError;
  });
}
