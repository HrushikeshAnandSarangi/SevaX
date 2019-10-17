import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:intl/intl.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_model.dart' as prefix1;
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/select_request_view.dart';
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/workshop/workshop.dart';

import '../core.dart';
import '../core.dart';

class HelpView extends StatefulWidget {
  final TabController controller;

  HelpView(this.controller);

  HelpViewState createState() => HelpViewState();
}

class HelpViewState extends State<HelpView> {
  static bool isAdminOrCoordinator = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    FirestoreManager.getTimeBankForId(
            timebankId: FlavorConfig.values.timebankId)
        .then((timebank) {
      if (timebank.admins.contains(SevaCore.of(context).loggedInUser.email) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.email)) {
        setState(() {
          isAdminOrCoordinator = true;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: [
        Requests(context),
        Offers(context),
      ],
    );
  }
}

class Requests extends StatefulWidget {
  final BuildContext parentContext;

  Requests(this.parentContext);
  @override
  RequestsState createState() => RequestsState();
}

class RequestsState extends State<Requests> {
  _setORValue() {
    globals.orCreateSelector = 0;
  }

  String timebankId = FlavorConfig.values.timebankId;
  bool isNearme = false;
  List<TimebankModel> timebankList = [];
  @override
  Widget build(BuildContext context) {
    _setORValue();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: false,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Text(
                FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                    ? 'Yang Gang :'
                    : 'Timebank : ',
                style: (TextStyle(fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              StreamBuilder<Object>(
                  stream: FirestoreManager.getTimebanksForUserStream(
                    userId: SevaCore.of(context).loggedInUser.sevaUserID,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    timebankList = snapshot.data;
                    List<String> dropdownList = [];
                    timebankList.forEach((t) {
                      dropdownList.add(t.id);
                    });
                    return Expanded(
                      child: DropdownButton<String>(
                        value: timebankId,
                        onChanged: (String newValue) {
                          setState(() {
                            timebankId = newValue;
                          });
                        },
                        items: dropdownList
                            .map<DropdownMenuItem<String>>((String value) {
                          if (value == 'All') {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          } else
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
                                    TimebankModel timebankModel = snapshot.data;
                                    return Text(timebankModel.name);
                                  }),
                            );
                        }).toList(),
                      ),
                    );
                  }),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    if (isNearme == true)
                      isNearme = false;
                    else
                      isNearme = true;
                  });
                },
                child: isNearme == false ? Text('Near Me') : Text('All'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 0,
        ),
        isNearme == true
            ? NearRequestListItems(
                parentContext: context,
                timebankId: timebankId,
              )
            : RequestListItems(
                parentContext: context,
                timebankId: timebankId,
              )
      ],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.requestItem.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class Offers extends StatefulWidget {
  final BuildContext parentContext;

  Offers(this.parentContext);
  @override
  OffersState createState() => OffersState();
}

class OffersState extends State<Offers> {
  _setORValue() {
    globals.orCreateSelector = 1;
  }

  String timebankId = FlavorConfig.values.timebankId;
  List<TimebankModel> timebankList = [];
  bool isNearme = false;

  @override
  Widget build(BuildContext context) {
    _setORValue();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: false,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Text(
                FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                    ? 'Yang Gang :'
                    : 'Timebank : ',
                style: (TextStyle(fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              StreamBuilder<List<TimebankModel>>(
                  stream: FirestoreManager.getTimebanksForUserStream(
                    userId: SevaCore.of(context).loggedInUser.sevaUserID,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    timebankList = snapshot.data;
                    List<String> dropdownList = [];
                    timebankList.forEach((t) {
                      dropdownList.add(t.id);
                    });

                    return Expanded(
                      child: DropdownButton<String>(
                        value: timebankId,
                        onChanged: (String newValue) {
                          setState(() {
                            timebankId = newValue;
                          });
                        },
                        items: dropdownList
                            .map<DropdownMenuItem<String>>((String value) {
                          if (value == 'All') {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          } else
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
                                    TimebankModel timebankModel = snapshot.data;
                                    return Text(timebankModel.name);
                                  }),
                            );
                        }).toList(),
                      ),
                    );
                  }),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    if (isNearme == true)
                      isNearme = false;
                    else
                      isNearme = true;
                  });
                },
                child: isNearme == false ? Text('Near Me') : Text('All'),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 0,
        ),
        isNearme == true
            ? NearOfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
            : OfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
      ],
    );
  }
}

class OfferCardView extends StatelessWidget {
  final OfferModel offerModel;
  String sevaUserIdOffer;

  OfferCardView({Key key, @required this.offerModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          offerModel.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
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
                    color: offerModel.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text(
                            offerModel.title,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RichTextView(text: offerModel.description),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment(-1.0, 0.0),
                          child: Text('Posted By: ' + offerModel.fullName),
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
                                              offerModel.timestamp),
                                      timezoneAbb: usertimezone),
                                ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(' '),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                            color: Theme.of(context).accentColor,
                            onPressed: offerModel.sevaUserId ==
                                    SevaCore.of(context).loggedInUser.sevaUserID
                                ? null
                                : () {
                                    sevaUserIdOffer = offerModel.sevaUserId;
//                        Navigator.pop(context);
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) {
                                    //       return SelectRequestView(
                                    //         offerModel: offerModel,
                                    //       );
                                    //     },
                                    //   ),
                                    // );

                                    if (FlavorConfig.appFlavor == Flavor.APP) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SelectRequestView(
                                            offerModel: offerModel,
                                            sevaUserIdOffer: sevaUserIdOffer,
                                          ),
                                        ),
                                      );
                                    } else if (HelpViewState
                                            .isAdminOrCoordinator ==
                                        true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SelectRequestView(
                                            offerModel: offerModel,
                                            sevaUserIdOffer: sevaUserIdOffer,
                                          ),
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                new Text("Permission Denied"),
                                            content: new Text(
                                                "You need to be an Admin or Coordinator to have permission to send request to offers"),
                                            actions: <Widget>[
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
                                  },
                            child: Text(
                              'Send Request',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class NearRequestListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const NearRequestListItems({Key key, this.timebankId, this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
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
              stream: FirestoreManager.getNearRequestListStream(
                timebankId: timebankId,
              ),
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
                    if (requestModelList.length == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text('No Requests')),
                      );
                    }
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: ListView(
                          children: requestModelList.map(
                            (RequestModel requestModel) {
                              return getRequestView(
                                  requestModel, loggedintimezone);
                            },
                          ).toList(),
                        ),
                      ),
                    );
                }
              },
            );
          });
    } else {
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
              stream: FirestoreManager.getNearRequestListStream(),
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
                    if (requestModelList.length == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text('No Requests')),
                      );
                    }
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: ListView(
                          children: requestModelList.map(
                            (RequestModel requestModel) {
                              return getRequestView(
                                  requestModel, loggedintimezone);
                            },
                          ).toList(),
                        ),
                      ),
                    );
                }
              },
            );
          });
    }
  }

  Widget getRequestView(RequestModel model, String loggedintimezone) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => RequestCardView(requestItem: model),
              ),
            );
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
                        image: model.photoUrl),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
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

class RequestListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const RequestListItems({Key key, this.timebankId, this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
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
              stream: FirestoreManager.getRequestListStream(
                timebankId: timebankId,
              ),
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
                        loggedintimezone: loggedintimezone);
                }
              },
            );
          });
    } else {
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

  Widget formatListFrom(
      {List<RequestModelList> consolidatedList, String loggedintimezone}) {
    return Expanded(
      child: Container(
        child: ListView(
          children: consolidatedList.map((RequestModelList requestModel) {
            return getRequestView(requestModel, loggedintimezone);
          }).toList(),
        ),
      ),
    );
  }

  Widget getRequestView(RequestModelList model, String loggedintimezone) {
    switch (model.getType()) {
      case RequestModelList.TITLE:
        return Container(
          margin: EdgeInsets.all(12),
          child: Text(
            GroupRequestCommons.getGroupTitle(
                groupKey: (model as GroupTitle).groupTitle),
          ),
        );

      case RequestModelList.REQUEST:
        return getRequestListViewHoldder(
          model: (model as RequestItem).requestModel,
          loggedintimezone: loggedintimezone,
        );

      default:
        return Text("DEFAULT");
    }
  }

  Widget getRequestListViewHoldder(
      {RequestModel model, String loggedintimezone}) {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => RequestCardView(requestItem: model),
              ),
            );
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
                        image: model.photoUrl),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
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
            blurRadius: 6)
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

class OfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const OfferListItems({Key key, this.parentContext, this.timebankId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: FirestoreManager.getOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }

              //Here we apply grouping startegy
              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);
              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    } else {
      return StreamBuilder<List<OfferModel>>(
        stream: FirestoreManager.getAllOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }

              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);
              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    }
  }

  Widget formatListOffer({List<OfferModelList> consolidatedList}) {
    return Expanded(
      child: Container(
        child: ListView(
          children: consolidatedList.map((OfferModelList offerModel) {
            return getOfferWidget(offerModel);
          }).toList(),
        ),
      ),
    );
  }

  Widget getOfferWidget(OfferModelList model) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: getOfferView(model),
    );
  }

  Widget getOfferView(OfferModelList offerModelList) {
    switch (offerModelList.getType()) {
      case OfferModelList.TITLE:
        return Container(
          margin: EdgeInsets.all(12),
          child: Text(
            GroupOfferCommons.getGroupTitleForOffer(
                groupKey: (offerModelList as OfferTitle).groupTitle),
          ),
        );

      case OfferModelList.OFFER:
        return getOfferViewHolder((offerModelList as OfferItem).offerModel);
    }
  }

  Widget getOfferViewHolder(OfferModel model) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => OfferCardView(offerModel: model),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<UserModel>(
                stream: FirestoreManager.getUserForIdStream(
                  sevaUserId: model.sevaUserId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return CircleAvatar(foregroundColor: Colors.red);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar();
                  }
                  UserModel user = snapshot.data;
                  return ClipOval(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: FadeInImage.assetNetwork(
                          placeholder: 'lib/assets/images/profile.png',
                          image: user.photoURL),
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              Expanded(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(0),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}

class NearOfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const NearOfferListItems({Key key, this.parentContext, this.timebankId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: FirestoreManager.getNearOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;

              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    } else {
      return StreamBuilder<List<OfferModel>>(
        stream: FirestoreManager.getNearOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    }
  }

  Widget getOfferWidget(OfferModel model) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => OfferCardView(offerModel: model),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<UserModel>(
                  stream: FirestoreManager.getUserForIdStream(
                    sevaUserId: model.sevaUserId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return CircleAvatar(foregroundColor: Colors.red);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar();
                    }
                    UserModel user = snapshot.data;
                    return ClipOval(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: FadeInImage.assetNetwork(
                            placeholder: 'lib/assets/images/profile.png',
                            image: user.photoURL),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16),
                Expanded(
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

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
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
