import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/views/workshop/approvedUsers.dart';

import '../core.dart';

class RequestsModule extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  RequestsModule.of({this.timebankId, this.timebankModel});

  @override
  RequestsState createState() => RequestsState();
}

class RequestsState extends State<RequestsModule> {
  String timebankId;

  _setORValue() {
    globals.orCreateSelector = 0;
  }

  bool isNearme = false;
  List<TimebankModel> timebankList = [];
  bool isNearMe = false;
  int sharedValue = 0;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'Near Me',
      style: TextStyle(fontSize: 10.0),
    ),
  };

  @override
  Widget build(BuildContext context) {
    _setORValue();
    timebankId = widget.timebankModel.id;
    print("----------->>>$timebankId");

    return Container(
      margin: EdgeInsets.only(left: 0, right: 0, top: 10),
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: false,
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                  // width: double.,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      Text(
                        'My Requests',
                        style: (TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Image.asset("lib/assets/images/add.png"),
                          ),
                        ),
                        onTap: () {
                          if (widget.timebankModel.protected) {
                            if (widget.timebankModel.admins.contains(
                                SevaCore.of(context).loggedInUser.sevaUserID)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateRequest(
                                    timebankId: timebankId,
                                  ),
                                ),
                              );
                              return;
                            }
                            _showProtectedTimebankMessage();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateRequest(
                                  timebankId: timebankId,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Offstage(
                  offstage: true,
                  child: StreamBuilder<Object>(
                      stream: FirestoreManager.getTimebanksForUserStream(
                        userId: SevaCore.of(context).loggedInUser.sevaUserID,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        timebankList = snapshot.data;
                        List<String> dropdownList = [];
                        int adminOfCount = 0;
                        if (FlavorConfig.values.timebankName == "Yang 2020") {
                          dropdownList.add("Create Yang Gang");
                        }
                        timebankList.forEach((t) {
                          dropdownList.add(t.id);

                          if (t.admins.contains(
                              SevaCore.of(context).loggedInUser.sevaUserID)) {
                            adminOfCount++;

                            SevaCore.of(context)
                                .loggedInUser
                                .timebankIdForYangGangAdmin = t.id;
                          }
                        });
                        SevaCore.of(context)
                            .loggedInUser
                            .associatedWithTimebanks = dropdownList.length;
                        SevaCore.of(context).loggedInUser.adminOfYanagGangs =
                            adminOfCount;
                        return DropdownButton<String>(
                          value: timebankId,
                          onChanged: (String newValue) {
                            if (newValue == "Create Yang Gang") {
                              {
                                this.createSubTimebank(context);
                              }
                            } else {
                              setState(() {
                                SevaCore.of(context)
                                    .loggedInUser
                                    .currentTimebank = newValue;
                                timebankId = newValue;
                              });
                            }
                          },
                          items: dropdownList
                              .map<DropdownMenuItem<String>>((String value) {
                            if (value == "Create Yang Gang") {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            } else {
                              if (value == 'All') {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              } else {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: FutureBuilder<Object>(
                                      future: FirestoreManager.getTimeBankForId(
                                          timebankId: value),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError)
                                          return new Text(
                                              'Error: ${snapshot.error}');
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Offstage();
                                        }
                                        TimebankModel timebankModel =
                                            snapshot.data;
                                        return Text(
                                          timebankModel.name,
                                          style: TextStyle(fontSize: 15.0),
                                        );
                                      }),
                                );
                              }
                            }
                          }).toList(),
                        );
                      }),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 120,
                  child: CupertinoSegmentedControl<int>(
                    selectedColor: Theme.of(context).primaryColor,
                    children: logoWidgets,

                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    groupValue: sharedValue,
                    onValueChanged: (int val) {
                      print(val);
                      if (val != sharedValue) {
                        setState(() {
                          if (isNearme == true)
                            isNearme = false;
                          else
                            isNearme = true;
                        });
                        setState(() {
                          sharedValue = val;
                        });
                      }
                    },
                    //groupValue: sharedValue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                ),
              ],
            ),
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
                )
              : RequestListItems(
                  parentContext: context,
                  timebankId: timebankId,
                  timebankModel: widget.timebankModel)
        ],
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

  void createSubTimebank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimebankCreate(
          timebankId: FlavorConfig.values.timebankId,
        ),
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
                            title: Text(
                                'Are you sure you want to delete this request?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'No',
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
                                  'Yes',
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
              return new Text('Error: ${snapshot.error}');
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
                            'From:  ' +
                                DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                            'Until:  ' +
                                DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                          child:
                              Text('Posted By: ' + widget.requestItem.fullName),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            'PostDate:  ' +
                                DateFormat('MMMM dd, yyyy @ h:mm a').format(
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
                          child: Text('Number of volunteers required: ' +
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
                                  ? 'Withdraw Request'
                                  : 'Accept Request',
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
                                        ? 'No Approved members yet'
                                        : 'View Approved Members',
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
    print(requestModel.toMap());

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

  const NearRequestListItems({
    Key key,
    this.timebankId,
    this.parentContext,
    this.timebankModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel user = snapshot.data;
          String loggedintimezone = user.timezone;
          return StreamBuilder<List<RequestModel>>(
            stream: timebankId != 'All'
                ? FirestoreManager.getNearRequestListStream(
                    timebankId: timebankId)
                : FirestoreManager.getNearRequestListStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
              if (requestListSnapshot.hasError) {
                return new Text('Error: ${requestListSnapshot.error}');
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
                      child: Center(child: Text('No Requests')),
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
                      return getRequestView(
                        requestModelList[index],
                        loggedintimezone,
                        context,
                      );
                    },
                  );
              }
            },
          );
        });

//    if (timebankId != 'All') {
//      print("ifff " + timebankId);
//      return FutureBuilder<Object>(
//          future: FirestoreManager.getUserForId(
//              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//          builder: (context, snapshot) {
//            if (snapshot.hasError) {
//              return new Text('Error: ${snapshot.error}');
//            }
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Center(child: CircularProgressIndicator());
//            }
//            UserModel user = snapshot.data;
//            String loggedintimezone = user.timezone;
//
//            return StreamBuilder<List<RequestModel>>(
//              stream: FirestoreManager.getNearRequestListStream(
//                timebankId: timebankId,
//              ),
//              builder: (BuildContext context,
//                  AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                if (requestListSnapshot.hasError) {
//                  return new Text('Error: ${requestListSnapshot.error}');
//                }
//                switch (requestListSnapshot.connectionState) {
//                  case ConnectionState.waiting:
//                    return Center(child: CircularProgressIndicator());
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
//                        child: Center(child: Text('No Requests')),
//                      );
//                    }
//
//                    return ListView.builder(
//                      shrinkWrap: true,
//                      itemCount: requestModelList.length + 1,
//                      itemBuilder: (context, index) {
//                        if (index >= requestModelList.length) {
//                          return Container(
//                            width: double.infinity,
//                            height: 65,
//                          );
//                        }
//                        return getRequestView(
//                          requestModelList[index],
//                          loggedintimezone,
//                          context,
//                        );
//                      },
//                    );
//                }
//              },
//            );
//          });
//    } else {
//      return FutureBuilder<Object>(
//          future: FirestoreManager.getUserForId(
//              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//          builder: (context, snapshot) {
//            if (snapshot.hasError) {
//              return new Text('Error: ${snapshot.error}');
//            }
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Center(child: CircularProgressIndicator());
//            }
//            UserModel user = snapshot.data;
//            String loggedintimezone = user.timezone;
//
//            return StreamBuilder<List<RequestModel>>(
//              stream: FirestoreManager.getNearRequestListStream(),
//              builder: (BuildContext context,
//                  AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                if (requestListSnapshot.hasError) {
//                  return new Text('Error: ${requestListSnapshot.error}');
//                }
//                switch (requestListSnapshot.connectionState) {
//                  case ConnectionState.waiting:
//                    return Center(child: CircularProgressIndicator());
//                  //filter
//
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
//                        child: Center(child: Text('No Requests')),
//                      );
//                    }
//
//                    return Container(
//                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                      child: ListView(
//                        shrinkWrap: true,
//                        children: requestModelList.map(
//                          (RequestModel requestModel) {
//                            return getRequestView(
//                                requestModel, loggedintimezone, context);
//                          },
//                        ).toList(),
//                      ),
//                    );
//                }
//              },
//            );
//          });
//    }
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

  Widget getRequestView(
    RequestModel model,
    String loggedintimezone,
    BuildContext context,
  ) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: () {
            if (model.sevaUserId ==
                    SevaCore.of(context).loggedInUser.sevaUserID ||
                timebankModel.admins
                    .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestTabHolder(),
                ),
              );
            } else {
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestDetailsAboutPage(
                      requestItem: model, timebankModel: timebankModel),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.title,
                      style: Theme.of(parentContext).textTheme.subhead,
                    ),
                    Text(
                      model.description,
                      style: Theme.of(parentContext).textTheme.subtitle,
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
                  ],
                ),
              ],
            ),
          ),
        ),
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

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}

class RequestListItems extends StatefulWidget {
  final String timebankId;
  final BuildContext parentContext;
  final TimebankModel timebankModel;

  RequestListItems(
      {Key key, this.timebankId, this.parentContext, this.timebankModel});

  @override
  State<StatefulWidget> createState() {
    return RequestListItemsState();
  }
}

class RequestListItemsState extends State<RequestListItems> {
  @override
  void initState() {
    super.initState();
    timeBankBloc.getRequestsStreamFromTimebankId(widget.timebankId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timebankId != 'All') {
      print("if");
      return FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            UserModel user = snapshot.data;
            String loggedintimezone = user.timezone;
            return StreamBuilder(
                stream: timeBankBloc.timebankController,
                builder: (context, AsyncSnapshot<TimebankController> snapshot) {
                  if (snapshot.hasError) {
                    return new Text('Error: ${snapshot.error}');
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
                        child: Center(child: Text('No Requests')),
                      );
                    }
                    var consolidatedList =
                        GroupRequestCommons.groupAndConsolidateRequests(
                            requestModelList,
                            SevaCore.of(context).loggedInUser.sevaUserID);
                    return formatListFrom(
                        consolidatedList: consolidatedList,
                        loggedintimezone: loggedintimezone,
                        userEmail: SevaCore.of(context).loggedInUser.email);
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Text("");
                });
          });
    } else {
      print("else");
      return FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<List<RequestModel>>(
              stream: FirestoreManager.getAllRequestListStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
                if (requestListSnapshot.hasError) {
                  return new Text('Error: ${requestListSnapshot.error}');
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
                        child: Center(child: Text('No Requests')),
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
        ? "Filtering blocked content"
        : filteredList.add(request));

    return filteredList;
  }

  Widget formatListFrom(
      {List<RequestModelList> consolidatedList,
      String loggedintimezone,
      String userEmail}) {
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

        return Container(
          height: !isMyContent ? 18 : 0,
          margin: !isMyContent ? EdgeInsets.all(12) : EdgeInsets.all(0),
          child: Text(
            GroupRequestCommons.getGroupTitle(
                groupKey: (model as GroupTitle).groupTitle),
          ),
        );

      case RequestModelList.REQUEST:
        return getRequestListViewHoldder(
          model: (model as RequestItem).requestModel,
          loggedintimezone: loggedintimezone,
          userEmail: userEmail,
        );

      default:
        return Text("DEFAULT");
    }
  }

  Widget getRequestListViewHoldder(
      {RequestModel model, String loggedintimezone, String userEmail}) {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            timeBankBloc.setSelectedRequest(model);
            timeBankBloc.setSelectedTimeBankDetails(widget.timebankModel);

            if (model.sevaUserId ==
                    SevaCore.of(context).loggedInUser.sevaUserID ||
                widget.timebankModel.admins
                    .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
              Navigator.push(
                widget.parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestTabHolder(),
                ),
              );
            } else {
              Navigator.push(
                widget.parentContext,
                MaterialPageRoute(
                  builder: (context) => RequestDetailsAboutPage(
                      requestItem: model, timebankModel: widget.timebankModel),
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
                      placeholder: defaultUserImageURL,
                      //  placeholder: 'lib/assets/images/profile.png',
                      image: model.photoUrl == null
                          ? defaultUserImageURL
                          : model.photoUrl,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.title,
                      style: Theme.of(widget.parentContext).textTheme.subhead,
                    ),
                    Text(
                      model.description,
                      style: Theme.of(widget.parentContext).textTheme.subtitle,
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
                        Text(
                          getTimeFormattedString(
                            model.requestEnd,
                            loggedintimezone,
                          ),
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: !model.acceptors.contains(userEmail),
                      child: Container(
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.all(12),
                          // width: double.infinity,
                          child: Container(
                            width: 100,
                            height: 32,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(0),
                              color: Color.fromRGBO(44, 64, 140, 0.7),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(width: 1),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(44, 64, 140, 1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Applied',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                ],
                              ),
                              onPressed: () {},
                            ),
                          )),
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
