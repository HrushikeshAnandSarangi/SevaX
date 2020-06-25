import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart' as RequestManager;

class EditRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  RequestModel requestModel;

  EditRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.requestModel})
      : super(key: key);

  @override
  _EditRequestState createState() => _EditRequestState();
}

class _EditRequestState extends State<EditRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: RequestEditForm(
        requestModel: widget.requestModel,
        isOfferRequest: widget.isOfferRequest,
        offer: widget.offer,
        timebankId: widget.timebankId,
      ),
    );
  }

  String get title {
    if (widget.requestModel.projectId == null ||
        widget.requestModel.projectId == "" ||
        widget.requestModel.projectId.isEmpty) {
      return AppLocalizations.of(context).translate('create_request', 'edit');
    }
    return AppLocalizations.of(context)
        .translate('create_request', 'edit_project');
  }
}

class RequestEditForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  RequestModel requestModel;

  RequestEditForm(
      {this.isOfferRequest, this.offer, this.timebankId, this.requestModel});

  @override
  RequestEditFormState createState() {
    return RequestEditFormState();
  }
}

class RequestEditFormState extends State<RequestEditForm> {
  final GlobalKey<_EditRequestState> _offerState = GlobalKey();
  final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();
  End end = End();
  int editType = 0;
  final _formKey = GlobalKey<FormState>();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;

  String _selectedTimebankId;
  int oldHours =0;
  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );
  BuildContext dialogContext;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.location = widget.requestModel.location;
    this.selectedAddress = widget.requestModel.address;
    this.oldHours = widget.requestModel.numberOfHours;
    //this.selectedUsers = widget.requestModel.approvedUsers;
  }

  @override
  void didChangeDependencies() {
    this.requestModel.email = widget.requestModel.email;
    this.requestModel.fullName = widget.requestModel.fullName;
    this.requestModel.photoUrl = widget.requestModel.photoUrl;
    this.requestModel.sevaUserId = widget.requestModel.sevaUserId;

//    FirestoreManager.getUserForIdStream(
//        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID)
//        .listen((userModel) {
//      this.requestModel.email = userModel.email;
//      this.requestModel.fullName = userModel.fullname;
//      this.requestModel.photoUrl = userModel.photoURL;
//      this.requestModel.sevaUserId = userModel.sevaUserID;
//    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    var startDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestStart));
    var endDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestEnd));
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)
                    .translate('create_request', 'request_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate(
                      'create_request', 'small_carpenty'),
                  hintStyle: hintTextStyle,
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                initialValue: widget.requestModel.title,
                onChanged: (value) {
                  widget.requestModel.title = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context)
                        .translate('create_request', 'subject');
                  }
                  widget.requestModel.title = value;
                },
              ),
              Text(' '),
              OfferDurationWidget(
                  title: AppLocalizations.of(context)
                      .translate('create_request', 'duration'),
                  startTime: startDate,
                  endTime: endDate),
              SizedBox(height: 8),
              Visibility(
                visible: widget.requestModel.isRecurring,
                child: Container(
                  child: EditRepeatWidget(requestModel:widget.requestModel),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                AppLocalizations.of(context)
                    .translate('create_request', 'desc'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                initialValue: widget.requestModel.description,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate(
                      'create_request', 'request_hash'),
                  hintStyle: hintTextStyle,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                maxLength: 500,
                onChanged: (value) {
                  widget.requestModel.description = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context).translate(
                        'create_request', 'request_hash_empty');
                  }
                  widget.requestModel.description = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),

              // SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)
                    .translate('create_request', 'total_hours'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                  initialValue: "${widget.requestModel.numberOfHours ?? 0}",
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate(
                        'create_request', 'hours_required'),
                    hintStyle: hintTextStyle,
                    // labelText: 'No. of volunteers',
                  ),
                  onChanged: (value) {
                    widget.requestModel.numberOfHours = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .translate('create_request',
                          'hours_required_err');
                    } else if (int.parse(value) < 0) {
                      return AppLocalizations.of(context)
                          .translate('create_request',
                          'hours_required_zero');
                    } else if (int.parse(value) == 0) {
                      return AppLocalizations.of(context)
                          .translate('create_request',
                          'hours_required_not_zero');
                    } else {
                      requestModel.numberOfHours =
                          int.parse(value);
                      return null;
                    }
                  }),
              SizedBox(height: 20),

              Text(
                AppLocalizations.of(context).translate(
                    'create_request', 'no_of_volunteers'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                initialValue: "${widget.requestModel.numberOfApprovals}",
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate(
                      'create_request', 'no_of_volunteers'),
                  hintStyle: hintTextStyle,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.requestModel.numberOfApprovals = int.parse(value);
                },
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
                    return null;
                  }
                },
              ),
//              if (FlavorConfig.appFlavor != Flavor.APP)
              //addVolunteersForAdmin(),
              SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Center(
                  child: Container(
                    width: 250,
                    child: RaisedButton(
                      onPressed: () async {
                        if(widget.requestModel.requestMode.toString()=="PERSONAL_REQUEST" && oldHours!=widget.requestModel.numberOfHours){
                          var onBalanceCheckResult = await RequestManager.hasSufficientCredits(
                            credits: requestModel.numberOfHours.toDouble(),
                            userId: SevaCore.of(context).loggedInUser.sevaUserID,
                          );
                          if (!onBalanceCheckResult) {
                            showInsufficientBalance();
                            return;
                          }
                        }
                        if (location != null) {
                          widget.requestModel.requestStart =
                              OfferDurationWidgetState.starttimestamp;
                          widget.requestModel.requestEnd =
                              OfferDurationWidgetState.endtimestamp;
                          widget.requestModel.location = location;
                          widget.requestModel.address = selectedAddress;
                          print("request model data === ${widget.requestModel.toMap()}");

                          if(widget.requestModel.isRecurring) {
                            widget.requestModel.recurringDays = EditRepeatWidgetState.getRecurringdays();
                            end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
                            end.on = end.endType=="on" ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch:null;
                            end.after = (end.endType =="after" ? int.parse(EditRepeatWidgetState.after) : 1);
                            print("end model is = ${end.toMap()}");
                            widget.requestModel.end = end;
                            print("request model is = ${requestModel.toMap()}");

                            showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext viewContext) {
                              return WillPopScope(
                                onWillPop: () {},
                                child:AlertDialog(
                                  title:Text("This is a repeating event"),
                                  actions:[
                                    FlatButton(
                                      child: Text(
                                        "Edit this event only",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontFamily: 'Europa'),
                                      ),
                                      onPressed: () async {
                                        editType = 0;
                                        Navigator.pop(viewContext);
                                        linearProgressForCreatingRequest();
                                        await updateRequest(requestModel: widget.requestModel);
                                        Navigator.pop(dialogContext);
                                        Navigator.pop(context);

                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "Edit subsequent events",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontFamily: 'Europa'),
                                      ),
                                      onPressed: () async {
                                        editType=1;
                                        Navigator.pop(viewContext);
                                        linearProgressForCreatingRequest();
                                        await updateRequest(requestModel: widget.requestModel);
                                        await RequestManager.updateRecurrenceRequests(widget.requestModel.id);
                                        Navigator.pop(dialogContext);
                                        Navigator.pop(context);

                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        "cancel",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                            fontFamily: 'Europa'),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(viewContext);
                                      },
                                    ),
                                  ]

                                )
                              );
                            });

//                            linearProgressForCreatingRequest();

//                              await updateRequest(requestModel: widget.requestModel);
//
//                              if(editType==1){
//                                await RequestManager.updateRecurrenceRequests(widget.requestModel);
//                              }


                          } else {

                            linearProgressForCreatingRequest();

                            await updateRequest(requestModel: widget.requestModel);

                            Navigator.pop(dialogContext);
                            Navigator.pop(context);
                          }
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Location not added'),
                          ));
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('create_request',
                            'update_request_button').padLeft(10).padRight(10),
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
    );
  }

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate(
                'create_request', 'progress_update')),
            content: LinearProgressIndicator(),
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
    memberAssignment = AppLocalizations.of(context)
        .translate('create_request', 'assign_members');
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(memberAssignment),
        onPressed: () async {
          print("addVolunteersForAdmin():");

          print(" Selected users before ${selectedUsers.length}");

          onActivityResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectMembersInGroup(
                    timebankId:
                        SevaCore.of(context).loggedInUser.currentTimebank,
                    userSelected: selectedUsers,
                    userEmail: SevaCore.of(context).loggedInUser.email,
                    listOfalreadyExistingMembers: [],
                  )));

          if (onActivityResult != null &&
              onActivityResult.containsKey("membersSelected")) {
            selectedUsers = onActivityResult['membersSelected'];
            setState(() {
              if (selectedUsers.length == 0)
                memberAssignment = AppLocalizations.of(context)
                    .translate('create_request', 'assign_to_vol');
              else
                memberAssignment =
                "${selectedUsers.length} ${AppLocalizations.of(context).translate('create_request', 'vol_selected')}";
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

  Future<void> updateRequest({
    @required RequestModel requestModel,
  }) async {
    print(requestModel.toMap());

    return await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData(requestModel.toMap());
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
