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
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';
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
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';

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
                return new Text(
                    '${AppLocalizations.of(context).translate('shared', 'error')}: ${snapshot.error}');
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
      return AppLocalizations.of(context).translate('create_request', 'create');
    }
    return AppLocalizations.of(context)
        .translate('create_request', 'create_project');
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
  End end = End();
  var focusNodes = List.generate(5, (_) => FocusNode());

  GeoFirePoint location;

  double sevaCoinsValue = 0;
  String hoursMessage;
  String selectedAddress;
  int sharedValue = 0;

  String _selectedTimebankId;

  Future<TimebankModel> getTimebankAdminStatus;
  Future getProjectsByFuture;
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
    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    fetchRemoteConfig();

    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      // _fetchCurrentlocation;
    }
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
    hoursMessage = AppLocalizations.of(context)
        .translate('create_request', 'set_duration');
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
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;
    headerContainer(snapshot) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (snapshot.data.admins
          .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
        return requestSwitch();
      } else {
        this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        return Container();
      }
    }

    addToProjectContainer(snapshot, projectModelList, requestModel) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (snapshot.data.admins
          .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
        return ProjectSelection(
            requestModel: requestModel,
            projectModelList: projectModelList,
            selectedProject: null,
            admin: snapshot.data.admins
                .contains(SevaCore.of(context).loggedInUser.sevaUserID));
      } else {
        this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        return ProjectSelection(
          requestModel: requestModel,
          projectModelList: projectModelList,
          selectedProject: null,
          admin: false,
        );
      }
    }

    return FutureBuilder<TimebankModel>(
        future: getTimebankAdminStatus,
        builder: (context, snapshot) {
          return FutureBuilder<List<ProjectModel>>(
              future: getProjectsByFuture,
              builder: (projectscontext, projectListSnapshot) {
                List<ProjectModel> projectModelList = projectListSnapshot.data;
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
                            headerContainer(snapshot),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('create_request', 'request_title'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: Colors.black,
                              ),
                            ),
                            TextFormField(
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[0]);
                              },
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter(
                                    RegExp("[a-zA-Z0-9_ ]*"))
                              ],
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .translate(
                                        'create_request', 'small_carpenty'),
                                hintStyle: hintTextStyle,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              initialValue:
                                  widget.offer != null && widget.isOfferRequest
                                      ? getOfferTitle(
                                          offerDataModel: widget.offer,
                                        )
                                      : "",
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .translate('create_request', 'subject');
                                }
                                requestModel.title = value;
                              },
                            ),
                            SizedBox(height: 30),
                            OfferDurationWidget(
                              title: AppLocalizations.of(context)
                                  .translate('create_request', 'duration'),
                            ),
                            SizedBox(height: 12),
                            RepeatWidget(),
                            SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('create_request', 'desc'),
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
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[1]);
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .translate(
                                        'create_request', 'request_hash'),
                                hintStyle: hintTextStyle,
                              ),
                              initialValue:
                                  widget.offer != null && widget.isOfferRequest
                                      ? getOfferDescription(
                                          offerDataModel: widget.offer,
                                        )
                                      : "",
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context).translate(
                                      'create_request', 'request_hash_empty');
                                }
                                requestModel.description = value;
                              },
                            ),
                            SizedBox(height: 20),
                            isFromRequest(
                              projectId: widget.projectId,
                            )
                                ? addToProjectContainer(
                                    snapshot,
                                    projectModelList,
                                    requestModel,
                                  )
                                : Container(),
                            SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context).translate(
                                  'create_request', 'no_of_volunteers'),
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
                              onChanged: (v) {
                                if (v.isNotEmpty && int.parse(v) >= 0) {
                                  requestModel.numberOfApprovals = int.parse(v);
                                  setState(() {});
                                }
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .translate(
                                        'create_request', 'no_of_volunteers'),
                                hintStyle: hintTextStyle,
                                // labelText: 'No. of volunteers',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context).translate(
                                      'create_request',
                                      'no_of_volunteers_zero');
                                } else if (int.parse(value) < 0) {
                                  return AppLocalizations.of(context).translate(
                                      'create_request',
                                      'no_of_volunteers_zero_err');
                                } else if (int.parse(value) == 0) {
                                  return AppLocalizations.of(context).translate(
                                      'create_request',
                                      'no_of_volunteers_zero_err1');
                                } else {
                                  requestModel.numberOfApprovals =
                                      int.parse(value);
                                  setState(() {});
                                  return null;
                                }
                              },
                            ),
                            TotalCredits(
                                requestModel,
                                OfferDurationWidgetState.starttimestamp,
                                OfferDurationWidgetState.endtimestamp),
                            SizedBox(height: 40),
                            Center(
                              child: LocationPickerWidget(
                                selectedAddress: selectedAddress,
                                location: location,
                                onChanged: (LocationDataModel dataModel) {
                                  log("received data model");
                                  setState(() {
                                    location = dataModel.geoPoint;
                                    this.selectedAddress = dataModel.location;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30.0),
                              child: Center(
                                child: Container(
                                  // width: 150,
                                  child: RaisedButton(
                                    onPressed: createRequest,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('create_request',
                                              'create_request_button')
                                          .padLeft(10)
                                          .padRight(10),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .button,
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
              });
        });
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
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
          children: {
            0: Text(
              AppLocalizations.of(context)
                  .translate('shared', 'timebank_request'),
              style: TextStyle(fontSize: 12.0),
            ),
            1: Text(
              AppLocalizations.of(context)
                  .translate('shared', 'personal_request'),
              style: TextStyle(fontSize: 12.0),
            ),
          },
          borderColor: Colors.grey,
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          groupValue: sharedValue,

          onValueChanged: (int val) {
            if (val != sharedValue) {
              setState(() {
                if (val == 0) {
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

  BuildContext dialogContext;

  void createRequest() async {
    // verify f the start and end date time is not same

    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('shared', 'check_internet')),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel.autoGenerated = false;

    requestModel.isRecurring = RepeatWidgetState.isRecurring;
    if (requestModel.isRecurring) {
      requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
      requestModel.occurenceCount = 1;
      end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
      end.on = end.endType == "on"
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after =
          (end.endType == "after" ? int.parse(RepeatWidgetState.after) : null);
      print("end model is = ${end.toMap()} ${end.endType}");
      requestModel.end = end;
      print("request model is = ${requestModel.toMap()}");
    }

    if (_formKey.currentState.validate()) {
      // validate request start and end date

      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        showDialogForTitle(
            dialogTitle: AppLocalizations.of(context)
                .translate('create_request', 'start_date_err'));
        return;
      }

      /// TODO take language from Prakash
      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle: AppLocalizations.of(context)
                .translate('create_request', 'sam_date_time'));
        return;
      }

      // if (!hasRegisteredLocation()) {
      //   showDialogForTitle(
      //       dialogTitle: AppLocalizations.of(context)
      //           .translate('create_request', 'add_location'));
      //   return;
      // }

      //in case the request is created for an accepted offer
      if (widget.isOfferRequest == true && widget.userModel != null) {
        if (requestModel.approvedUsers == null) requestModel.approvedUsers = [];

        List<String> approvedUsers = [];
        approvedUsers.add(widget.userModel.email);
        requestModel.approvedUsers = approvedUsers;
      }
      requestModel.softDelete = false;

      if (requestModel.isRecurring) {
        if (requestModel.recurringDays.length == 0) {
          showDialogForTitle(
              dialogTitle: AppLocalizations.of(context)
                  .translate('create_request', 'recurringDays_err'));
          return;
        }
      }

      //Form and date is valid
      switch (requestModel.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          var myDetails = SevaCore.of(context).loggedInUser;
          this.requestModel.fullName = myDetails.fullname;
          this.requestModel.photoUrl = myDetails.photoURL;

          var onBalanceCheckResult = await hasSufficientCredits(
            credits: requestModel.numberOfHours.toDouble(),
            userId: myDetails.sevaUserID,
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
            title: Text(AppLocalizations.of(context)
                .translate('create_request', 'progress')),
            content: LinearProgressIndicator(),
          );
        });
  }

  void showInsufficientBalance() {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)
                .translate('create_request', 'not_enough_seva')),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('create_request', 'ok'),
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
                  AppLocalizations.of(context)
                      .translate('create_request', 'ok'),
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

  String memberAssignment;

  Widget addVolunteersForAdmin() {
    if (selectedUsers == null) {
      selectedUsers = HashMap();
    }

    if (widget.userModel != null) {
      Map<String, UserModel> map = HashMap();
      map[widget.userModel.email] = widget.userModel;
      selectedUsers.addAll(map);
    }
    memberAssignment = AppLocalizations.of(context)
        .translate('create_request', 'assign_members');
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(selectedUsers != null && selectedUsers.length > 0
            ? "${selectedUsers.length} ${AppLocalizations.of(context).translate('create_request', 'selected')}"
            : memberAssignment),
        onPressed: () async {
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
              if (selectedUsers != null && selectedUsers.length == 0)
                memberAssignment = AppLocalizations.of(context)
                    .translate('create_request', 'assign_to_vol');
              else
                memberAssignment =
                    "${selectedUsers.length ?? ''} ${AppLocalizations.of(context).translate('create_request', 'vol_selected')}";
            });
          } else {
            //no users where selected
          }
          // SelectMembersInGroup
        },
      ),
    );
  }

  String getTimeInFormat(int timeStamp) {
    return DateFormat('EEEEEEE, MMMM dd yyyy',
            Locale(AppConfig.prefs.getString('language_code')).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
    );
  }

  bool hasSufficientBalance() {
    var requestCoins = requestModel.numberOfHours;
    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
    return requestCoins <= finalbalance;
  }

  Future _writeToDB() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    requestModel.id = '${requestModel.email}*$timestampString';
    if (requestModel.isRecurring) {
      requestModel.parent_request_id = requestModel.id;
    } else {
      requestModel.parent_request_id = null;
    }
    requestModel.postTimestamp = timestamp;
    requestModel.accepted = false;
    requestModel.acceptors = [];
    requestModel.invitedUsers = [];
    requestModel.address = selectedAddress;
    requestModel.location = location;
    requestModel.root_timebank_id = FlavorConfig.values.timebankId;
    requestModel.softDelete = false;
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

    if (requestModel.isRecurring) {
      await FirestoreManager.createRecurringEvents(requestModel: requestModel);
    }
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

  Future<Map> showTimebankAdvisory() {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
              "Select Project",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            content: Form(
              child: Container(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    "Projects here",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('shared', 'capital_cancel'),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate('shared', 'proceed'),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
//                  return Navigator.of(viewContext).pop({'PROCEED': true});
                },
              ),
            ],
          );
        });
  }
}

Widget TotalCredits(requestModel, int starttimestamp, int endtimestamp) {
  var label;
  var totalhours = DateTime.fromMillisecondsSinceEpoch(endtimestamp)
      .difference(DateTime.fromMillisecondsSinceEpoch(starttimestamp))
      .inHours;
  var totalminutes = DateTime.fromMillisecondsSinceEpoch(endtimestamp)
      .difference(DateTime.fromMillisecondsSinceEpoch(starttimestamp))
      .inMinutes;
  var totalallowedhours = (totalhours + ((totalminutes / 60) / 100).ceil());
  var totalCredits = requestModel.numberOfApprovals * totalallowedhours;
  requestModel.numberOfHours = totalCredits;
  if (totalallowedhours > 0 && totalCredits > 0) {
    if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
      label = totalCredits.toString() +
          " Credits will be added to timebank, per participant you can allocate maximum of " +
          totalallowedhours.toString() +
          " credits";
    } else {
      label = totalCredits.toString() +
          " Credits will be needed for the request, per participant you can allocate maximum of " +
          totalallowedhours.toString() +
          " credits";
    }
  } else {
    label = "";
  }

  return Text(
    label,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: 'Europa',
      color: Colors.black54,
    ),
  );
}

class ProjectSelection extends StatefulWidget {
  ProjectSelection(
      {Key key,
      this.requestModel,
      this.admin,
      this.projectModelList,
      this.selectedProject})
      : super(key: key);
  final admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    List<dynamic> list = [
      {
        "name": AppLocalizations.of(context)
            .translate('create_request', 'none_project'),
        "code": "None"
      }
    ];
    for (var i = 0; i < widget.projectModelList.length; i++) {
      list.add({
        "name": widget.projectModelList[i].name,
        "code": widget.projectModelList[i].id,
        "timebankproject": widget.projectModelList[i].mode == 'Timebank'
      });
    }
    return new MultiSelect(
      autovalidate: true,
      initialValue: ['None'],
      titleText: AppLocalizations.of(context)
          .translate('create_request', 'assign_to_project'),
      maxLength: 1, // optional
      hintText: AppLocalizations.of(context)
          .translate('create_request', 'tap_select'),
      validator: (dynamic value) {
        if (value == null) {
          return AppLocalizations.of(context)
              .translate('create_request', 'assign_to_one');
        }
        return null;
      },
      errorText: AppLocalizations.of(context)
          .translate('create_request', 'assign_to_one'),
      dataSource: list,
      admin: widget.admin,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        if (value != null && value[0] != 'None') {
          widget.requestModel.projectId = value[0];
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }

//  void _onFormSaved() {
//    final FormState form = _formKey.currentState;
//    form.save();
//  }
}
