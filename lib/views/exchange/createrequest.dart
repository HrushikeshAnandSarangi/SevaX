import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
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
            _title,
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
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();

  RequestModel requestModel = RequestModel();
  var focusNodes = List.generate(5, (_) => FocusNode());

  GeoFirePoint location;

  double sevaCoinsValue = 0;
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;
  int sharedValue = 0;

  String _selectedTimebankId;

  Future<TimebankModel> getTimebankAdminStatus;
  TimebankModel timebankModel;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = widget.projectId;

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );

    fetchRemoteConfig();

    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      _fetchCurrentlocation;
    }

    print(location);
  }

  void get _fetchCurrentlocation async {
    try {
      Location templocation = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
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
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
    }
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  @override
  void didChangeDependencies() {
    if (widget.loggedInUser?.sevaUserID != null)
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
      color: Colors.black,
      fontFamily: 'Europa',
    );

    TextStyle hintTextStyle = TextStyle(
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
                      return requestSwitch();
                    } else {
                      this.requestModel.requestMode =
                          RequestMode.PERSONAL_REQUEST;
                      return Container();
                    }
                  },
                ),
                Text(
                  "Request title*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[0]);
                  },
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
                  ],
                  decoration: InputDecoration(
                    hintText: "Ex: Small carpentry work...",
                    hintStyle: hintTextStyle,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  initialValue: widget.offer != null && widget.isOfferRequest
                      ? getOfferTitle(
                          offerDataModel: widget.offer,
                        )
                      : "",
                  textCapitalization: TextCapitalization.sentences,
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
                ),
                SizedBox(height: 12),
                SizedBox(height: 20),
                Text(
                  "Request description*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  focusNode: focusNodes[0],
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[1]);
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Your Request and any #hashtags',
                    hintStyle: hintTextStyle,
                  ),
                  initialValue: widget.offer != null && widget.isOfferRequest
                      ? getOfferDescription(
                          offerDataModel: widget.offer,
                        )
                      : "",
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    requestModel.description = value;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Total no. of hours *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                    focusNode: focusNodes[1],
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focusNodes[2]);
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Total no. of hours required',
                      hintStyle: hintTextStyle,
                      // labelText: 'No. of volunteers',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the number of hours required';
                      } else if (int.parse(value) < 0) {
                        return 'No. of hours cannot be lesser than 0';
                      } else if (int.parse(value) == 0) {
                        return 'No. of hours cannot be 0';
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
                    color: Colors.black,
                  ),
                ),
                TextFormField(
                  focusNode: focusNodes[2],
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'No. of approvals',
                    hintStyle: hintTextStyle,
                    // labelText: 'No. of volunteers',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the number of volunteers needed';
                    } else if (int.parse(value) < 0) {
                      return 'No. of volunteers cannot be lesser than 0';
                    } else if (int.parse(value) == 0) {
                      return 'No. of volunteers cannot be 0';
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

  Widget requestSwitch() {
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
                if (val == 0) {
                  print("TIMEBANK___REQUEST");
                  requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
                } else {
                  print("PERSONAL___REQUEST");
                  requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
                }
                sharedValue = val;
              });
            }
          },
          //groupValue: sharedValue,
        ),
      );
    } else {
      if (widget.projectModel != null) {
        if (widget.projectModel.mode == 'Timebank') {
          requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        }
      }
      return Container();
    }
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Timebank Request',
      style: TextStyle(fontSize: 15.0),
    ),
    1: Text(
      'Personal Request',
      style: TextStyle(fontSize: 15.0),
    ),
  };

  BuildContext dialogContext;

  void createRequest() async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Please check your internet connection."),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    print('request mode ${requestModel.requestMode.toString()}');
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
          var onBalanceCheckResult = await hasSufficientCredits(
            credits: requestModel.numberOfHours.toDouble(),
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
          );

          if (!onBalanceCheckResult) {
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

  void showDialogForTitle({String dialogTitle}) async {
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
    var requestCoins = requestModel.numberOfHours;
    print("Number of Seva Credits:${requestCoins}");
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

    // credit the timebank the required credits before the request creation
    await TransactionBloc().createNewTransaction(
        requestModel.timebankId,
        requestModel.timebankId,
        DateTime.now().millisecondsSinceEpoch,
        requestModel.numberOfHours,
        true,
        "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
        requestModel.id,
        requestModel.timebankId);
    await FirestoreManager.createRequest(requestModel: requestModel);
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty) {
      ProjectModel projectModel = widget.projectModel;
//      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
//      if (!projectModel.members.contains(userSevaUserId)) {
//        projectModel.members.add(userSevaUserId);
//      }
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
