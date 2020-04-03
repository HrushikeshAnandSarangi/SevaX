import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  String projectId;

  CreateRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.projectId})
      : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? "Create Yang Gang Request"
                : _title,
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: StreamBuilder<UserModelController>(
            stream: userBloc.getLoggedInUser,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data != null) {
                return RequestCreateForm(
                    isOfferRequest: widget.isOfferRequest,
                    offer: widget.offer,
                    timebankId: widget.timebankId,
                    userModel: widget.userModel,
                    loggedInUser: snapshot.data.loggedinuser,
                    projectId: widget.projectId,
                );
              }
              return Text('');
            }));
  }
  String get _title {
    if(widget.projectId == null || widget.projectId.isEmpty ||  widget.projectId == ""){
      return "Create Request";
    }
    return "Create Project Request";
  }
}

class RequestCreateForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  String projectId;
  RequestCreateForm(
      {this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.loggedInUser,
      this.projectId});

  @override
  RequestCreateFormState createState() {
    return RequestCreateFormState();
  }
}

class RequestCreateFormState extends State<RequestCreateForm> {
//  final GlobalKey<_CreateRequestState> _offerState = GlobalKey();
//  final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();

  final _formKey = GlobalKey<FormState>();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

//  String _dateMessageStart = ' START date and time ';
//  String _dateMessageEnd = '  END date and time ';
  double sevaCoinsValue = 0;
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;

  String _selectedTimebankId;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
    this.requestModel.projectId = widget.projectId;

    // print("Email goes like this " + SevaCore.of(context).loggedInUser.email);
    fetchRemoteConfig();

    print(location);
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  @override
  void didChangeDependencies() {
    FirestoreManager.getUserForIdStream(
            sevaUserId: widget.loggedInUser.sevaUserID)
        .listen((userModel) {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontSize: 14,
      // fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Europa',
    );

    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    this.requestModel.email = loggedInUser.email;
    this.requestModel.fullName = loggedInUser.fullname;
    this.requestModel.photoUrl = loggedInUser.photoURL;
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;

    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                requestSwitch,

                Text(
                  FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                      ? "Yang gang request title"
                      : "Request title*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                        ? "Yang gang request title"
                        : "Ex: Small carpentry work...",
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: textStyle,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the subject of your request';
                    }
                    requestModel.title = value;
                  },
                ),
                SizedBox(height: 30),
                OfferDurationWidget(
                  title: ' Request duration',
                  //startTime: CalendarWidgetState.startDate,
                  //endTime: CalendarWidgetState.endDate
                ),
                SizedBox(height: 12),
                SizedBox(height: 20),
                Text(
                  FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                      ? "Yang Gang Request description"
                      : "Request description*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Your Request \nand any #hashtags',
                    hintStyle: textStyle,
                  ),
                  initialValue:
                      widget.isOfferRequest != null && widget.isOfferRequest
                          ? widget.offer.description
                          : "",
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    requestModel.description = value;
                    // return null;
                  },
                ),
                SizedBox(height: 40),
                Text(
                  'No. of volunteers*',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'No. of approvals',
                      hintStyle: textStyle,
                      // labelText: 'No. of volunteers',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the number of volunteers needed';
                      } else {
                        requestModel.numberOfApprovals = int.parse(value);
                        return null;
                      }
                    }),
                SizedBox(height: 20),
                if (FlavorConfig.appFlavor != Flavor.APP)
                  addVolunteersForAdmin(),
                Center(
                  child: FlatButton.icon(
                    icon: Icon(Icons.add_location),
                    label: Text(
                      selectedAddress == null || selectedAddress.isEmpty
                          ? 'Add Location'
                          : selectedAddress,
                    ),
                    color: Colors.grey[200],
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<GeoFirePoint>(
                          builder: (context) => LocationPicker(
                            selectedLocation: location,
                          ),
                        ),
                      ).then((point) {
                        if (point != null) location = point;
                        _getLocation();
                        log('ReceivedLocation: $selectedAddress');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Container(
                      // width: 150,
                      child: RaisedButton(
                        onPressed: createRequest,
                        child: Text(
                          "Create Request".padLeft(10).padRight(10),
                          style: Theme.of(context).primaryTextTheme.button,
                        ),
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
  }

  Widget get requestSwitch{
    if(widget.projectId == null || widget.projectId.isEmpty ||  widget.projectId == ""){
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: double.infinity,
        child: CupertinoSegmentedControl<int>(
          selectedColor: Theme.of(context).primaryColor,
          children: logoWidgets,
          borderColor: Colors.grey,

          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          groupValue: sharedValue,
          onValueChanged: (int val) {
            print(val);
            if (val != sharedValue) {
              setState(() {});
              setState(() {
                print("$sharedValue -- $val");
                if (sharedValue == 0) {
                  requestModel.requestMode =
                      RequestMode.TIMEBANK_REQUEST;
                } else {
                  requestModel.requestMode =
                      RequestMode.PERSONAL_REQUEST;
                }
                sharedValue = val;
              });
            }
          },
          //groupValue: sharedValue,
        ),
      );
    }
    return Container();
  }


  int sharedValue = 0;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Personal Request',
      style: TextStyle(fontSize: 15.0),
    ),
    1: Text(
      'Timebank Request',
      style: TextStyle(fontSize: 15.0),
    ),
  };

  BuildContext dialogContext;

  void createRequest() async {

    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;

    //adding some members for humanity first
    List<String> arrayOfSelectedMembers = List();

    if (selectedUsers != null) {
      selectedUsers.forEach((k, v) => arrayOfSelectedMembers.add(k));
    }
    requestModel.approvedUsers = arrayOfSelectedMembers;

    sevaCoinsValue = await getMemberBalance(
      SevaCore.of(context).loggedInUser.email,
      SevaCore.of(context).loggedInUser.sevaUserID,
    );

    if (_formKey.currentState.validate() && !_checkValidityForSevaCoins) {
      return showDialog(
          context: context,
          builder: (BuildContext viewContext) {
            return AlertDialog(
              title:
                  Text('Insufficient seva coins for user to process requests'),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(viewContext).pop();
                  },
                ),
              ],
            );
          });
    }

    //adding some members for humanity first
    if (_formKey.currentState.validate()) {
      if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
        var timebankDetails = await FirestoreManager.getTimeBankForId(
            timebankId: requestModel.timebankId);
        requestModel.fullName = timebankDetails.name;
        requestModel.photoUrl = timebankDetails.photoUrl;
      }

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (createDialogContext) {
            dialogContext = createDialogContext;
            return AlertDialog(
              title: Text('Creating Request..'),
              content: LinearProgressIndicator(),
            );
          });

      print("Select Members");
      if (widget.isOfferRequest == true && widget.userModel != null) {
        if (requestModel.approvedUsers == null) requestModel.approvedUsers = [];
        requestModel.approvedUsers.add(widget.userModel.email);
      }

      await _writeToDB();

      if (widget.isOfferRequest == true && widget.userModel != null) {
        print(
            "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
        // OfferModel offer = widget.offer;
        // Set<String> offerRequestList = () {
        //   if (offer.requestList == null) return [];
        //   return offer.requestList;
        // }()
        //     .toSet();
        // offerRequestList.add(requestModel.id);
        // offer.requestList = offerRequestList.toList();
        // FirestoreManager.updateOfferWithRequest(offer: offer);
        // sendOfferRequest(
        //     offerModel: widget.offer,
        //     requestSevaID: requestModel.sevaUserId);

        // Navigator.pop(dialogContext);
        // Navigator.pop(context);
        Navigator.pop(dialogContext);
        Navigator.pop(context, {'response': 'ACCEPTED'});
      } else {
        Navigator.pop(dialogContext);
        Navigator.pop(context);
      }
    }
  }

  Map<String, UserModel> selectedUsers;
  Map onActivityResult;

  String memberAssignment = "Assign to volunteers";

  Widget addVolunteersForAdmin() {
    if (selectedUsers == null) {
      selectedUsers = HashMap();
    }

    if (widget.userModel != null) {
      Map<String, UserModel> map = HashMap();
      map[widget.userModel.email] = widget.userModel;
      selectedUsers.addAll(map);
    }

    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(selectedUsers != null && selectedUsers.length > 0
            ? "${selectedUsers.length} members selected"
            : memberAssignment),
        onPressed: () async {
          print("addVolunteersForAdmin():");

          print(" Selected users before ${selectedUsers.length}");

          onActivityResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectMembersInGroup(
                timebankId: widget.loggedInUser.currentTimebank,
                userEmail: widget.loggedInUser.email,
                userSelected: selectedUsers,
                listOfalreadyExistingMembers: [],
              ),
            ),
          );

          if (onActivityResult != null &&
              onActivityResult.containsKey("membersSelected")) {
            selectedUsers = onActivityResult['membersSelected'];
            setState(() {
              if (selectedUsers.length == 0)
                memberAssignment = "Assign to volunteers";
              else
                memberAssignment =
                    "${selectedUsers.length} volunteers selected";
            });
            print("Data is present Selected users ${selectedUsers.length}");
          } else {
            print("No users where selected");
            //no users where selected
          }
          // SelectMembersInGroup
        },
      ),
    );
  }

  String getTimeInFormat(int timeStamp) {
    return DateFormat('EEEEEEE, MMMM dd yyyy').format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
    );
  }

  bool get _checkValidityForSevaCoins {
    if (requestModel.requestStart == null) {
      requestModel.requestStart = DateTime.now().millisecondsSinceEpoch;
    }

    if (requestModel.requestEnd == null) {
      requestModel.requestEnd = DateTime.now().millisecondsSinceEpoch;
    }
    print("Project id : ${widget.projectId}");
    if(widget.projectId != null && widget.projectId.isNotEmpty){
      requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      print("Inside yes");
      return true;
    }

    print(getTimeInFormat(requestModel.requestStart) +
        " <- Start   -> End " +
        getTimeInFormat(requestModel.requestEnd));

    var diffDate = DateTime.fromMillisecondsSinceEpoch(requestModel.requestEnd)
        .difference(
            DateTime.fromMillisecondsSinceEpoch(requestModel.requestStart));
    var requestCoins = diffDate.inHours * requestModel.numberOfApprovals;
    print("Hours:${diffDate.inHours} --> " +
        requestModel.numberOfApprovals.toString());
    print("Number of seva coins:${requestCoins.abs()}");
    print("Seva coin available:${sevaCoinsValue.abs()}");

    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue.abs() + lowerLimit ?? 10).abs();

    print("Final amount in hand:${finalbalance}");

    return requestCoins.abs() <= finalbalance;
  }

  Future _writeToDB() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    requestModel.id = '${requestModel.email}*$timestampString';
    requestModel.postTimestamp = timestamp;
    requestModel.accepted = false;
    requestModel.acceptors = [];
    requestModel.location =
        location == null ? GeoFirePoint(40.754387, -73.984291) : location;
    requestModel.root_timebank_id = FlavorConfig.values.timebankId;
    //requestModel.r

    if (requestModel.requestStart == null) {
      requestModel.requestStart = DateTime.now().millisecondsSinceEpoch;
    }

    if (requestModel.requestEnd == null) {
      requestModel.requestEnd = DateTime.now().millisecondsSinceEpoch;
    }

    if (requestModel.id == null) return;
    await FirestoreManager.createRequest(requestModel: requestModel);
  }

  Future _getLocation() async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );

    setState(() {
      this.selectedAddress = address;
    });
  }

}
