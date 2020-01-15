// import 'package:cached_network_image/cached_network_image.dart';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';

import '../core.dart';
import '../timebank_content_holder.dart';

class JoinSubTimeBankView extends StatefulWidget {
  final UserModel loggedInUserModel;
  final bool isFromDash;

  JoinSubTimeBankView({this.loggedInUserModel, @required this.isFromDash});



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
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getData();
  }

  void getData() async {
    createEditCommunityBloc.getChildTimeBanks();

    _joinRequestModels =
        await getFutureUserRequest(userID: widget.loggedInUserModel.sevaUserID);
    isDataLoaded = true;
    setState(() {});

    //print('User request ${}');

    // print('User request ${newList}');
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
//          leading: BackButton(color: Colors.black87),

          title: Text("Time Banks",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Europa",
              )),
          centerTitle: true,
          actions: <Widget>[
            Offstage(
              offstage: true,
              child: widget.isFromDash ? FlatButton(
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Europa",
                  ),
                ),
                textColor: Colors.lightBlue,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeDashBoard()));
                },
              ): Text(""),
            )
          ]),
    );
  }

  List<String> dropdownList = [];

  Widget getTimebanks({BuildContext context}) {
    Size size = MediaQuery.of(context).size;

    List<TimebankModel> timebankList = [];
    return StreamBuilder<CommunityCreateEditController>(
        stream: createEditCommunityBloc.createEditCommunity,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          timebankList = snapshot.data.timebanks;
          timebankList.forEach((t) {
            dropdownList.add(t.id);
          });

          // Navigator.pop(context);
          print("data ${dropdownList.length}");

          if (snapshot.data != null) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                  child: Text(
                    "Join the timebank to contribute to the community for the change",
                  ),
                ),
                ListView.separated(
                  itemCount: timebankList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    TimebankModel timebank = timebankList.elementAt(index);
                    CompareToTimeBank status;
                    if (_joinRequestModels != null) {
                      status = compareTimeBanks(_joinRequestModels, timebank);
                      // print(timebank.children.toString());
                      return makeItem(timebank, status);
                    } else {
                      status = CompareToTimeBank.JOIN;
                      return makeItem(timebank, status);
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

  Widget makeItem(TimebankModel timebank, CompareToTimeBank status) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimebankTabsViewHolder.of(
              timebankId: timebank.id,
              timebankModel: timebank,
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
                  imageUrl: timebank.photoUrl,
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
                          timebank.address +
                                  ' .' +
                                  timebank.members.length.toString() ??
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
                      shape: StadiumBorder(),
                      textColor: Colors.lightBlue,
                      child: Text(getTimeBankStatusTitle(status) ?? "",
                          style: TextStyle(fontSize: 14)),
                      onPressed: status == CompareToTimeBank.JOIN
                          ? () async {
                              //    print('print time data ${timebank.creatorId}');
                              joinRequestModel.reason = "i want to join";
                              joinRequestModel.userId =
                                  widget.loggedInUserModel.sevaUserID;
                              joinRequestModel.timestamp =
                                  DateTime.now().millisecondsSinceEpoch;

                              joinRequestModel.entityId = timebank.id;
                              joinRequestModel.entityType = EntityType.Timebank;
                              joinRequestModel.accepted = false;

                              await createJoinRequest(model: joinRequestModel);

                              JoinRequestNotificationModel joinReqModel =
                                  JoinRequestNotificationModel(
                                      timebankId: timebank.id,
                                      timebankTitle: timebank.name);

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
      List<JoinRequestModel> joinRequestModels, TimebankModel timeBank) {// CompareToTimeBank status;
    for (int i = 0; i < joinRequestModels.length; i++) {
      JoinRequestModel requestModel = joinRequestModels[i];

      if (requestModel.entityId == timeBank.id &&
          joinRequestModels[i].accepted==true) {
        return CompareToTimeBank.JOINED;
      } else if (requestModel.entityId == timeBank.id &&
          requestModel.operationTaken == false) {
        return CompareToTimeBank.REQUESTED;
      }
      else if (requestModel.entityId == timeBank.id &&
          requestModel.operationTaken == true &&
          requestModel.accepted == false) {
        return CompareToTimeBank.REJECTED;
      }else{
       return CompareToTimeBank.JOIN;
      }
    }
   return CompareToTimeBank.JOIN;
  }
}
