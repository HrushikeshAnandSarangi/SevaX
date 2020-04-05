import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  String projectId;

  CreateRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.projectId,
      this.projectModel})
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
                  projectModel: widget.projectModel,
                );
              }
              return Text('');
            }));
  }

  String get _title {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
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
  final ProjectModel projectModel;
  String projectId;
  RequestCreateForm(
      {this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.loggedInUser,
      this.projectId,
      this.projectModel});

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

  Future<TimebankModel> getTimebankAdminStatus;
  TimebankModel timebankModel;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
    this.requestModel.projectId = widget.projectId;

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );

    fetchRemoteConfig();

    if (FlavorConfig.appFlavor == Flavor.APP) {
      _fetchCurrentlocation;
    }

    print(location);
  }

  void get _fetchCurrentlocation {
    Location().getLocation().then((onValue) {
      print("Location1:$onValue");
      location = GeoFirePoint(onValue.latitude, onValue.longitude);
      LocationUtility()
          .getFormattedAddress(
        location.latitude,
        location.longitude,
      )
          .then((address) {
        setState(() {
          this.selectedAddress = address;
        });
      });
    });
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
                FutureBuilder<TimebankModel>(
                  future: getTimebankAdminStatus,
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return Text(snapshot.error.toString());
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    timebankModel = snapshot.data;
                    if (snapshot.data.admins.contains(
                        SevaCore.of(context).loggedInUser.sevaUserID)) {
                      return requestSwitch;
                    } else {
                      return Container();
                    }
                  },
                ),
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
                          ? ""
                          : "",
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
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
                  'No. of hours *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.grey,
                  ),
                ),
                TextFormField(
                    decoration: InputDecoration(
                      hintText: 'No. of hours required',
                      hintStyle: textStyle,
                      // labelText: 'No. of volunteers',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the number of hours required';
                      } else {
                        requestModel.numberOfHours = int.parse(value);
                        return null;
                      }
                    }),
                SizedBox(height: 20),
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
                  },
                ),
                SizedBox(height: 40),
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

  Widget get requestSwitch {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
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
              setState(() {
                print("$sharedValue -- $val");
                if (sharedValue == 0) {
                  requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
                } else {
                  requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
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

    if (_formKey.currentState.validate()) {
      // validate request start and end date
      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        showDialogForTitle(
            dialogTitle:
                "Please mention the start and end date of the request");
        return;
      }

      if (!hasRegisteredLocation()) {
        showDialogForTitle(dialogTitle: "Please add location to your request");
        return;
      }

      //in case the request is created for an accepted offer
      if (widget.isOfferRequest == true && widget.userModel != null) {
        if (requestModel.approvedUsers == null) requestModel.approvedUsers = [];

        List<String> approvedUsers = [];
        approvedUsers.add(widget.userModel.email);
        requestModel.approvedUsers = approvedUsers;
      }

      //Form and date is valid
      switch (requestModel.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          sevaCoinsValue = await getMemberBalance(
            SevaCore.of(context).loggedInUser.email,
            SevaCore.of(context).loggedInUser.sevaUserID,
          );

          print(
              "Seva Coins $sevaCoinsValue -------------------------------------------");

          if (!hasSufficientBalance()) {
            showInsufficientBalance();
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel.fullName = timebankModel.name;
          requestModel.photoUrl = timebankModel.photoUrl;
          break;
      }
      linearProgressForCreatingRequest();
      await _writeToDB();
      await _updateProjectModel();

      if (widget.isOfferRequest == true && widget.userModel != null) {
        Navigator.pop(dialogContext);
        Navigator.pop(context, {'response': 'ACCEPTED'});
      } else {
        Navigator.pop(dialogContext);
        Navigator.pop(context);
      }
    }
  }

  bool hasRegisteredLocation() {
    print("Location ---========================= ${requestModel.location}");
    return location != null;
  }

  void linearProgressForCreatingRequest() {
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
  }

  void showInsufficientBalance() {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
                'Your seva credits are not sufficient to create the request.'),
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

  Future<void> showDialogForTitle({String dialogTitle}) async {
    if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
      var timebankDetails = await FirestoreManager.getTimeBankForId(
          timebankId: requestModel.timebankId);
      requestModel.fullName = timebankDetails.name;
      requestModel.photoUrl = timebankDetails.photoUrl;
    }

    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
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

  bool hasSufficientBalance() {
    if (requestModel.requestStart == null) {
      requestModel.requestStart = DateTime.now().millisecondsSinceEpoch;
    }

    if (requestModel.requestEnd == null) {
      requestModel.requestEnd = DateTime.now().millisecondsSinceEpoch;
    }
    print("Project id : ${widget.projectId}");
    if (widget.projectId != null && widget.projectId.isNotEmpty) {
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
    var requestCoins = requestModel.numberOfHours;
    print("Hours:${diffDate.inHours} --> " +
        requestModel.numberOfApprovals.toString());
    print("Number of seva coins:${requestCoins}");
    print("Seva coin available:${sevaCoinsValue}");

    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);

    print("Final amount in hand:${finalbalance}");

    return requestCoins <= finalbalance;
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

    if (requestModel.id == null) return;
    await FirestoreManager.createRequest(requestModel: requestModel);
  }

  Future _updateProjectModel() async {
    if (widget.projectId != null) {
      ProjectModel projectModel = widget.projectModel;
      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
      if (!projectModel.members.contains(userSevaUserId)) {
        projectModel.members.add(userSevaUserId);
      }
      projectModel.pendingRequests.add(requestModel.id);
      await FirestoreManager.updateProject(projectModel: projectModel);
    }
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
