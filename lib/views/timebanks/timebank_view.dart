import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix2;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as prefix1;
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_admin_view.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebankedit.dart';
import 'package:sevaexchange/views/campaigns/campaigncreate.dart';
import 'package:sevaexchange/views/campaigns/campaignjoin.dart';
import 'package:sevaexchange/views/timebanks/timebank_join_request.dart';
import 'package:sevaexchange/views/timebanks/timebank_join_requests_view.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';
import 'package:sevaexchange/globals.dart' as globals;

import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';
import 'edit_super_admins_view.dart';
import 'edit_timebank_view.dart';

class TimebankView extends StatefulWidget {
  final String timebankId;
  TimebankModel superAdminTimebankModel;

  TimebankView({
    @required this.timebankId,
    @required this.superAdminTimebankModel,
  });

  @override
  _TimebankViewState createState() => _TimebankViewState();
}

class _TimebankViewState extends State<TimebankView> {
  TimebankModel timebankModel;
  //TimebankModel superAdminModel;
  JoinRequestModel joinRequestModel = new JoinRequestModel();
  JoinRequestModel getRequestData = new JoinRequestModel();
  UserModel ownerModel;
  String title = 'Loading';
  String loggedInUser;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    //SevaCore.of(context).loggedInUser = UserData.shared.user;
    super.initState();
    //this.getRequestData = new JoinRequestModel();
  }

  Future getJoinRequestData() async {
    this.getRequestData = new JoinRequestModel();
    this.getRequestData = await getRequestStatusForId(
        timebankId: SevaCore.of(context).loggedInUser.currentTimebank);
  }

  Future<JoinRequestModel> getRequestStatusForId(
      {@required String timebankId}) async {
    assert(timebankId != null && timebankId.isNotEmpty,
        "Seva UserId cannot be null or empty");

    JoinRequestModel joinRequest;
    await Firestore.instance
        .collection('join_requests')
        .where('entity_type', isEqualTo: 'Timebank')
        .where('entity_id', isEqualTo: timebankId)
        .where('user_id',
            isEqualTo: SevaCore.of(context).loggedInUser.sevaUserID)
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
        joinRequest = JoinRequestModel.fromMap(documentSnapshot.data);
        print("joining data $joinRequest");
      });
    });

//    await Firestore.instance
//        .collection('users')
//        .where('sevauserid', isEqualTo: sevaUserId)
//        .getDocuments()
//        .then((QuerySnapshot querySnapshot) {
//      querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
//        userModel = UserModel.fromMap(documentSnapshot.data);
//      });
//    });

    return joinRequest;
  }

  @override
  Widget build(BuildContext buildcontext) {
    loggedInUser = SevaCore.of(context).loggedInUser.sevaUserID;
//    this.getJoinRequestData().catchError((error) {
//      print(error);
//    });
    return timebankStreamBuilder(buildcontext);
  }

//  void showDeleteConfirmation(TimebankModel model) {
//    print("${timebankModel.id} -----------------------");
//    showDialog(
//      context: context,
//      builder: (buildContext) {
//        return AlertDialog(
//          title: Text('Delete ${timebankModel.name}'),
//          content:
//              Text('Are you sure you want to delete ${timebankModel.name}'),
//          actions: <Widget>[
//            RaisedButton(
//              color: Colors.red,
//              child: Text(
//                '  Delete  ',
//                style: TextStyle(color: Colors.white),
//              ),
//              onPressed: () async {
//                // call firebase to delete the doc || when data is deleted the screen refreshes and shoes null pointer fix that one;
//                Navigator.pop(context);
//                await Firestore.instance
//                    .collection("timebanknew")
//                    .document(timebankModel.id)
//                    .delete()
//                    .then((onValue) {
//                  Navigator.pop(buildContext);
//                });
//              },
//            ),
//            FlatButton(
//              child: Text('Cancel'),
//              onPressed: () {
//                Navigator.pop(buildContext);
//              },
//            ),
//          ].reversed.toList(),
//        );
//      },
//      barrierDismissible: false,
//    );
//  }

  StreamBuilder<TimebankModel> timebankStreamBuilder(
      BuildContext buildcontext) {
    var timebankName = FlavorConfig.appFlavor == Flavor.APP ? "Timebank" : "Yang Gang";
    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
          timebankId: widget.timebankId),
      builder: (streamContext, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              appBar: AppBar(
                title: Text('Loading'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                    },
                  )
                ],
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
            break;
          default:
            this.timebankModel = snapshot.data;
            globals.timebankAvatarURL = timebankModel.photoUrl;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '${timebankModel.name}',
                  style: TextStyle(color: Colors.white),
                ),
                actions: <Widget>[
//                  IconButton(
//                    icon: Icon(Icons.home),
//                    onPressed: () {
//                      Navigator.popUntil(context,
//                          ModalRoute.withName(Navigator.defaultRouteName));
//                    },
//                  ),
//                  timebankModel.creatorId != SevaCore.of(context).loggedInUser.sevaUserID
//                      ? Offstage()
//                      : IconButton(
//                    icon: Icon(
//                      Icons.edit,
//                      color: Colors.white,
//                    ),
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => EditTimebankView(
//                            timebankModel: timebankModel,
//                          ),
//                        ),
//                      );
//                    },
//                  ),
                ],
              ),
              floatingActionButton: Visibility(
                // visible: FlavorConfig.appFlavor != Flavor.APP ? false : true,
                visible: false,
                child: FloatingActionButton.extended(
                  icon: Icon(
                    Icons.add,
                  ),
                  foregroundColor: FlavorConfig.values.buttonTextColor,
                  label: Text(
                    FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                        ? 'Create Yang Gang'
                        : 'Create Branch',
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TimebankCreate(
                                timebankId: timebankModel.id,
                              )),
                    );
                  },
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      right: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 15.0, left: 20.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: timebankModel.photoUrl ==
                                            null ||
                                        timebankModel.photoUrl.isEmpty
                                    ? AssetImage(
                                        'lib/assets/images/noimagefound.png')
                                    : NetworkImage(timebankModel.photoUrl),
                                minRadius: 40.0,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${timebankModel.name}' ?? '',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Divider(color: Colors.deepPurple),
                        ),

//                        timebankModel.admins.contains(loggedInUser)
//                            ? FlatButton(
//                                child: Text(
//                                  FlavorConfig.values.timebankName == "Yang 2020" ? 'Delete yang gang' : 'Delete timebank',
//                                  style: TextStyle(fontWeight: FontWeight.bold),
//                                ),
//                                textColor: Theme.of(context).accentColor,
//                                disabledTextColor:
//                                    Theme.of(context).accentColor,
//                                onPressed: () {
//
//                                },
//                              )
//                            : Offstage(),
                        timebankModel.admins.contains(loggedInUser)
                            ? Offstage()
                            : timebankModel.members.contains(loggedInUser)
                                ? Offstage()
                                : FlatButton(
                                    child: Text(
                                        'Request to join this ${FlavorConfig.values.timebankTitle}'),
                                    textColor: Theme.of(context).accentColor,
                                    disabledTextColor:
                                        Theme.of(context).accentColor,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          // return object of type Dialog
                                          return AlertDialog(
                                            title: new Text(
                                                "Why do you want to join the ${FlavorConfig.values.timebankTitle}? "),
                                            content: Form(
                                              key: formkey,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  hintText: 'Reason',
                                                  labelText: 'Reason',
                                                  // labelStyle: textStyle,
                                                  // labelStyle: textStyle,
                                                  // labelText: 'Description',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      const Radius.circular(
                                                          20.0),
                                                    ),
                                                    borderSide: new BorderSide(
                                                      color: Colors.black,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.multiline,
                                                maxLines: 1,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  joinRequestModel.reason =
                                                      value;
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontSize: dialogButtonSize,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                },
                                              ),
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text(
                                                  "Send Join Request",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontSize: dialogButtonSize,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  joinRequestModel.userId =
                                                      loggedInUser;
                                                  joinRequestModel
                                                      .timestamp = DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch;

                                                  joinRequestModel.entityId =
                                                      timebankModel.id;
                                                  joinRequestModel.entityType =
                                                      EntityType.Timebank;
                                                  joinRequestModel.accepted =
                                                      null;

                                                  if (formkey.currentState
                                                      .validate()) {
                                                    await createJoinRequest(
                                                        model:
                                                            joinRequestModel);

                                                    JoinRequestNotificationModel
                                                        joinReqModel =
                                                        JoinRequestNotificationModel(
                                                            timebankId:
                                                                timebankModel
                                                                    .id,
                                                            timebankTitle:
                                                                timebankModel
                                                                    .name);

                                                    NotificationsModel
                                                        notification =
                                                        NotificationsModel(
                                                      id: utils.Utils.getUuid(),
                                                      targetUserId:
                                                          timebankModel
                                                              .creatorId,
                                                      senderUserId:
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID,
                                                      type: prefix0
                                                          .NotificationType
                                                          .JoinRequest,
                                                      data:
                                                          joinReqModel.toMap(),
                                                    );
                                                    notification.timebankId =
                                                        FlavorConfig
                                                            .values.timebankId;

                                                    UserModel timebankCreator =
                                                        await FirestoreManager
                                                            .getUserForId(
                                                                sevaUserId:
                                                                    timebankModel
                                                                        .creatorId);

                                                    await Firestore.instance
                                                        .collection('users')
                                                        .document(
                                                            timebankCreator
                                                                .email)
                                                        .collection(
                                                            "notifications")
                                                        .document(
                                                            notification.id)
                                                        .setData(notification
                                                            .toMap());
                                                    // return;
                                                    Navigator.of(dialogContext)
                                                        .pop();
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                        // FlatButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => _whichRoute('timebanks'),
                        //       ),
                        //     );
                        //   },
                        //   child: _whichButton('timebanks'),
                        // ),
                        timebankModel.admins.contains(loggedInUser) ||
                                widget.superAdminTimebankModel.admins
                                    .contains(loggedInUser)
                            ? FlatButton(
                                child: Text(
                                  'Edit $timebankName',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                textColor: Theme.of(context).accentColor,
                                disabledTextColor:
                                    Theme.of(context).accentColor,
                                onPressed: () {
                                  prefix2.Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            _whichRoute('edityanggang')),
                                  );
                                },
                              )
                            : Offstage(),
                        //_showCreateCampaignButton(context),
                        //_showJoinRequests(context),
                        !timebankModel.members.contains(loggedInUser)
                            ? Offstage()
                            : FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            _whichRoute('viewcampaigns')),
                                  );
                                },
                                child: _whichButton('viewcampaigns'),
                              ),
//                        FlatButton(
//                          child: Text(
//                            FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
//                                ? 'View Yang Gangs'
//                                : 'View Branches',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w700,
//                                color: Theme.of(context).accentColor),
//                          ),
//                          onPressed: () {
//                            FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
//                                ? Navigator.pop(context)
//                                : Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) => BranchList(
//                                              timebankid: timebankModel.id,
//                                            )),
//                                  );
//                          },
//                        ),
//                        FlatButton(
//                          child: Text(
//                            'Create feed',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w700,
//                                color: Theme.of(context).accentColor),
//                          ),
//                          onPressed: () {
//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                  builder: (context) => NewsCreate(
//                                    timebankId: timebankModel.id,
//                                  ),
//                                ));
//                          },
//                        ),
//                        FlatButton(
//                          child: Text(
//                            'Create ${FlavorConfig.values.requestTitle}',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w700,
//                                color: Theme.of(context).accentColor),
//                          ),
//                          onPressed: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                builder: (context) => CreateRequest(
//                                  timebankId: timebankModel.id,
//                                ),
//                              ),
//                            );
//                          },
//                        ),
//                        FlatButton(
//                          child: Text(
//                            'Create ${FlavorConfig.values.offertitle}',
//                            style: TextStyle(
//                                fontWeight: FontWeight.w700,
//                                color: Theme.of(context).accentColor),
//                          ),
//                          onPressed: () {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => CreateOffer(
//                                        timebankId: timebankModel.id,
//                                      )),
//                            );
//                          },
//                        ),
                        !timebankModel.members.contains(loggedInUser)
                            ? Offstage()
                            : FlatButton(
                                child: Text(
                                  'View Members',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).accentColor),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TimebankAdminPage(
                                              timebankId: timebankModel.id,
                                              userEmail: SevaCore.of(context)
                                                  .loggedInUser
                                                  .email,
                                            )),
                                  );
                                },
                              ),
//                        !timebankModel.members.contains(loggedInUser)
//                            ? Offstage()
//                            : FlatButton(
//                                child: Text(
//                                  'View Accepted Offers',
//                                  style: TextStyle(
//                                      fontWeight: FontWeight.w700,
//                                      color: Theme.of(context).accentColor),
//                                ),
//                                onPressed: () {
//                                  Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) => AcceptedOffers(
//                                              timebankId: timebankModel.id,
//                                            )),
//                                  );
//                                },
//                              ),

                        timebankModel.parentTimebankId != null
                            ? FutureBuilder<Object>(
                                future: FirestoreManager.getTimeBankForId(
                                    timebankId: timebankModel.parentTimebankId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('Error: ${snapshot.error}');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return Offstage();
                                  TimebankModel model = snapshot.data;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.0, left: 20.0),
                                        child: Text(
                                          'Parent ${FlavorConfig.values.timebankTitle}',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.0, left: 20.0),
                                        child: Text(
                                          '${model.name}',
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  );
                                })
                            : Offstage(),

                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            'Mission Statement',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            '${timebankModel.missionStatement}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 20.0),
                          child: Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            '${timebankModel.address}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 20.0),
                          child: Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3.0),
                          child: FlatButton(
                            child: Text(
                              '${timebankModel.phoneNumber}',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w400),
                            ),
                            onPressed: () {
                              String _number = timebankModel.phoneNumber;
                              launch('tel:$_number');
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3.0),
                          child: FlatButton(
                            child: Text(
                              '${timebankModel.emailId}',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              String _email = '${timebankModel.emailId}';
                              launch('mailto:$_email');
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.only(top: 10.0, left: 20.0),
                        //   child: Text(
                        //     'Closed :',
                        //     style: TextStyle(
                        //       fontSize: 18.0,
                        //       fontWeight: FontWeight.w700,
                        //       decoration: TextDecoration.underline,
                        //     ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(top: 10.0, left: 20.0),
                        //   child: Text(
                        //     '${timebankModel.protected}',
                        //     style: TextStyle(fontSize: 18.0),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 20, bottom: 80),
                        //   child: Row(
                        //     children: <Widget>[
                        //       Text(
                        //         'Manage Members',
                        //         style: TextStyle(
                        //             fontSize: 18.0,
                        //             fontWeight: FontWeight.w700),
                        //       ),
                        //       //Hiding as of now as now the admin can see the same from view members page
                        //       //_showManageMembersButton(context)
                        //     ],
                        //   ),
                        // ),
                        // StreamBuilder<UserModel>(
                        //
                        //   stream: FirestoreManager.getUserForIdStream(
                        //       sevaUserId: timebankModel.creatorId),
                        //   builder: (context, snapshot) {
                        //     if (snapshot.hasError)
                        //       return Text('Error: ${snapshot.error}');
                        //     switch (snapshot.connectionState) {
                        //       case ConnectionState.waiting:
                        //         return Center(
                        //             child: CircularProgressIndicator());
                        //         break;
                        //       default:
                        //         UserModel ownerModel = snapshot.data;
                        //         this.ownerModel = ownerModel;
                        //         return FlatButton(
                        //           onPressed: ownerModel != null
                        //               ? () {
                        //                   Navigator.push(
                        //                       context,
                        //                       MaterialPageRoute(
                        //                           builder: (context) =>
                        //                               ProfileViewer(
                        //                                 userEmail:
                        //                                     ownerModel.email,
                        //                               )));
                        //                 }
                        //               : null,
                        //           child: Row(
                        //             children: <Widget>[
                        //               Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     left: 28.0,
                        //                     right: 8.0,
                        //                     top: 8.0,
                        //                     bottom: 8.0),
                        //                 child: CircleAvatar(
                        //                   // minRadius: 20.0,
                        //                   backgroundImage: ownerModel == null ||
                        //                           ownerModel.photoURL == null ||
                        //                           ownerModel.photoURL.isEmpty
                        //                       ? AssetImage(
                        //                           'lib/assets/images/noimagefound.png')
                        //                       : NetworkImage(
                        //                           ownerModel.photoURL),
                        //                 ),
                        //               ),
                        //               Flexible(
                        //                 child: Container(
                        //                   padding: EdgeInsets.only(right: 13.0),
                        //                   child: ownerModel != null &&
                        //                           ownerModel.fullname != null
                        //                       ? Text(
                        //                           ownerModel.fullname,
                        //                           overflow:
                        //                               TextOverflow.ellipsis,
                        //                           style: TextStyle(
                        //                             fontSize: 18.0,
                        //                           ),
                        //                         )
                        //                       : Container(),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //     }
                        //   },
                        // ),
                        //getTextWidgets(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  Widget _showCreateCampaignButton(BuildContext context) {
    if (timebankModel.admins
        .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _whichRoute('campaigns'),
            ),
          );
        },
        child: _whichButton('campaigns'),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _showJoinRequests(BuildContext context) {
    if (timebankModel.creatorId == UserData.shared.user.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _whichRoute('joinrequests'),
            ),
          );
        },
        child: _whichButton('joinrequests'),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _whichRoute(String section) {
    switch (section) {
      case 'timebanks':
        if (timebankModel.creatorId == UserData.shared.user.sevaUserID) {
          return TimebankEdit(
            ownerModel: ownerModel,
            timebankModel: timebankModel,
          );
        } else {
          return TimebankJoinRequest(
            timebankModel: timebankModel,
            owner: ownerModel,
          );
//        return PinView(
//            timebankModel:timebankModel,
//             owner:ownerModel,
//        );
        }
        break;
      //edityanggang
      case 'edityanggang':
        return EditSuperTimebankView(
          timebankId: timebankModel.id,
          superAdminTimebankModel: widget.superAdminTimebankModel,
        );
        break;
      case 'campaigns':
        if (timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          return CampaignCreate(
            timebankModel: timebankModel,
          );
        } else {
          return CampaignJoin();
        }
        break;
      case 'viewcampaigns':
        return CampaignsView(
          timebankModel: timebankModel,
        );
        break;
      case 'joinrequests':
        return TimebankJoinRequestView(
          timebankModel: timebankModel,
        );
        break;
      default:
        return null;
    }
  }

  Widget _whichButton(String section) {
    switch (section) {
      case 'timebanks':
        if (timebankModel.creatorId == UserData.shared.user.sevaUserID) {
          return Text(
            'Edit ${FlavorConfig.values.timebankTitle}',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          );
        } else {
          return Text(
            'Request to join this ${FlavorConfig.values.timebankTitle}',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          );
        }
        break;
      case 'campaigns':
        if (timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          return Text(
            'Create a project',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          );
        } else {
          return Text(
            'Join a project',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          );
        }
        break;
      case 'viewcampaigns':
        return Text(
          'View projects',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        );
        break;
      default:
        return null;
    }
  }

  Widget _showManageMembersButton(BuildContext context) {
    assert(timebankModel.id != null);
    if (timebankModel.admins.contains(UserData.shared.user.sevaUserID)) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TimebankAdminPage(
                  timebankId: timebankModel.id,
                  userEmail: SevaCore.of(context).loggedInUser.email,
                );
              },
            ),
          );
        },
        child: Icon(Icons.edit),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget getTextWidgets(BuildContext context) {
    List<Widget> list = List<Widget>();

    timebankModel.members.forEach(
      (member) {
        list.add(
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (routeContext) => ProfileViewer(userEmail: member),
                ),
              );
            },
            child: StreamBuilder<UserModel>(
                stream: FirestoreManager.getUserForEmailStream(member),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  UserModel user = snapshot.data;
                  return Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          // minRadius: 20.0,
                          backgroundImage: user.photoURL == null ||
                                  user.photoURL.isEmpty
                              ? AssetImage('lib/assets/images/noimagefound.png')
                              : NetworkImage(user.photoURL),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Text(
                            user.fullname ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
    );
  }

  ImageProvider _avatarImage(avatarURL) {
    if (avatarURL == null || avatarURL == '') {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(avatarURL);
    }
  }
}
