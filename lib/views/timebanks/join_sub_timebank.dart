// import 'package:cached_network_image/cached_network_image.dart';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
  ProgressDialog progressDialog;

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
  }

  Widget build(BuildContext context) {
    init(context);
    title = S.of(context).loading;
    JOIN = S.of(context).join;
    JOINED = S.of(context).joined;
    REQUESTED = S.of(context).requested;
    REJECTED = S.of(context).rejected;
    final _bloc = BlocProvider.of<UserDataBloc>(context);

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
//                ? CustomTextButton(
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
          : LoadingIndicator(),
    );
  }

  List<String> dropdownList = [];

  Widget getTimebanks({BuildContext context, UserDataBloc bloc}) {
    Size size = MediaQuery.of(context).size;
    List<TimebankModel> timebankList = [];

    return FutureBuilder<List<TimebankModel>>(
        future: getTimebanksForCommunity(
          userId: widget.loggedInUserModel.sevaUserID,
          communityId: widget.loggedInUserModel.currentCommunity,
          primaryTimebankId: widget.communityPrimaryTimebankId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Text('${S.of(context).general_stream_error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          if (snapshot.data.length == 0) {
            return Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(S.of(context).no_groups_found),
              ),
            );
          }

          timebankList = snapshot.data;
          timebankList.forEach((t) {
            dropdownList.add(t.id);
          });

          // Navigator.pop(context);

          if (snapshot.data != null) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                  child: Text(
                    S.of(context).group_description,
                  ),
                ),
                ListView.separated(
                  itemCount: timebankList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CompareToTimeBank status;
                    String userStatus = S.of(context).join;
                    TimebankModel timebank = timebankList.elementAt(index);
                    String userId = widget.loggedInUserModel.sevaUserID;
                    if (timebank.members.contains(userId) &&
                            isAccessAvailable(timebank, userId) ||
                        timebank.coordinators.contains(userId) ||
                        timebank.members.contains(userId)) {
                      status = CompareToTimeBank.JOINED;
                      userStatus = S.of(context).joined;
                      //    setState(() {});
                      return makeItem(timebank, status, bloc,
                          userStatus: userStatus);
                    }

                    if (_joinRequestModels != null) {
                      CompareToTimeBank campareStatus;

                      _joinRequestModels.forEach((joinRequestModel) {
                        if (joinRequestModel.entityId == timebank.id) {
                          if (joinRequestModel.operationTaken == true &&
                              joinRequestModel.accepted == false) {
                            campareStatus = CompareToTimeBank.REJECTED;
                            userStatus = S.of(context).rejected;
                          }
                          if (joinRequestModel.operationTaken == false) {
                            campareStatus = CompareToTimeBank.REQUESTED;
                            userStatus = S.of(context).requested;
                          }
                          if (joinRequestModel.accepted == true) {
                            campareStatus = CompareToTimeBank.JOINED;
                            userStatus = S.of(context).joined;
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

                    userStatus = S.of(context).join;
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

  void init(BuildContext context) {
    if (progressDialog == null)
      progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
      );
  }

  Widget makeItem(TimebankModel timebank, CompareToTimeBank status, bloc,
      {String userStatus}) {
    return InkWell(
      onTap: () {
        try {
          Provider.of<HomePageBaseBloc>(context, listen: false)
              .changeTimebank(timebank);
        } on Exception catch (e) {
          logger.e(e);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<UserDataBloc>(
              bloc: bloc,
              child: TabarView(
                userModel: SevaCore.of(context).loggedInUser,
                timebankModel: timebank,
              ),
            ),
          ),
        ).then((_) {
          try {
            Provider.of<HomePageBaseBloc>(context, listen: false)
                .switchToPreviousTimebank();
          } on Exception catch (e) {
            logger.e(e);
          }
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 3.3 / 2.3,
                    child: CachedNetworkImage(
                      imageUrl: timebank.photoUrl ?? defaultGroupImageURL,
                      fit: BoxFit.fitWidth,
                      errorWidget: (context, url, error) => Center(
                        child: Text(S.of(context).no_image_available),
                      ),
                      placeholder: (conext, url) {
                        return LoadingIndicator();
                      },
                    ),
                  ),
                  timebank.sponsored
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, right: 5),
                            child: Image.asset(
                              'images/icons/verified.png',
                              color: Colors.orange,
                              height: 28,
                              width: 28,
                            ),
                          ))
                      : Offstage(),
                ],
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
                    child: CustomElevatedButton(
                      color: userStatus == S.of(context).join
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                      // child: Text(getTimeBankStatusTitle(status) ?? "",
                      child: Text(userStatus ?? "",
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                      onPressed: () async {
                        if (userStatus == S.of(context).join) {
                          //TOFO
                          progressDialog.show();

                          await _assembleAndSendRequest(
                            subTimebankId: timebank.id,
                            subTimebankLabel: timebank.name,
                            userIdForNewMember:
                                widget.loggedInUserModel.sevaUserID,
                          ).catchError((onError) {
                            logger.e("Could not send request for group Join");
                          });
                          progressDialog.hide();

                          setState(() {
                            getData();
                          });
                          // return;
                        } else {}
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
    WriteBatch batchWrite = CollectionRef.batch;
    batchWrite.set(
        CollectionRef.timebank
            .doc(
              subtimebankId,
            )
            .collection("notifications")
            .doc(notification.id),
        (notification..isTimebankNotification = true).toMap());

    batchWrite.set(CollectionRef.joinRequests.doc(joinRequestModel.id),
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
      reason: S.of(context).i_want_to_volunteer,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: userIdForNewMember,
      isFromGroup: true,
      notificationId: utils.Utils.getUuid(),
    );
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
      isRead: false,
      isTimebankNotification: true,
      data: joinRequestModel.toMap(),
      communityId: widget.loggedInUserModel.currentCommunity,
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

    for (int i = 0; i < joinRequestModels.length; i++) {
      JoinRequestModel requestModel = joinRequestModels[i];

      if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].accepted == true) {
        return CompareToTimeBank.JOINED;
      } else if (isAccessAvailable(
              timeBank, widget.loggedInUserModel.sevaUserID) ||
          timeBank.coordinators.contains(widget.loggedInUserModel.sevaUserID) ||
          timeBank.members.contains(widget.loggedInUserModel.sevaUserID)) {
        return CompareToTimeBank.JOINED;
      } else if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].operationTaken == false) {
        return CompareToTimeBank.REQUESTED;
      } else if (joinRequestModels[i].entityId == timeBank.id &&
          joinRequestModels[i].operationTaken == true &&
          joinRequestModels[i].accepted == false) {
        return CompareToTimeBank.REJECTED;
      } else {
        return CompareToTimeBank.JOIN;
      }
    }
    return CompareToTimeBank.JOIN;
  }
}

Future<List<TimebankModel>> getTimebanksForCommunity(
    {String userId, String communityId, String primaryTimebankId}) async {
//  DocumentSnapshot documentSnapshot = await CollectionRef.communities.doc(communityId).get();
//  Map<String, dynamic> dataMap = documentSnapshot.data;
//  CommunityModel communityModel = CommunityModel(dataMap);
  List<TimebankModel> timebankList = [];
  return CollectionRef.timebank
      .where('community_id', isEqualTo: communityId)
      .get()
      .then((QuerySnapshot timebankModel) {
    timebankModel.docs.forEach((timebank) {
      var model = TimebankModel.fromMap(timebank.data());
      if (model.id != primaryTimebankId &&
          !model.softDelete &&
          (model.private == false ||
              model.managedCreatorIds.contains(userId))) {
        timebankList.add(model);
      }
    });
    return timebankList;
  }).catchError((onError) {
    return onError;
  });
}

class SevaProgressBar {
  // void cancelDialog() {
  //   progressDialog.hide();
  // }

  // void showDialog() {
  //   progressDialog.show();
  // }
}
