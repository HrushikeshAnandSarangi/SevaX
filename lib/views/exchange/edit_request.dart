import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as RequestManager;
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

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
      return S.of(context).edit;
    }
    return S.of(context).edit_project;
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
  final _formKey = GlobalKey<FormState>();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;

  String _selectedTimebankId;
  int oldHours = 0;
  int oldTotalRecurrences = 0;
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
//    this.oldTotalRecurrences = widget.requestModel.end.endType=="after"? widget.requestModel.end.after : 0;
    //this.selectedUsers = widget.requestModel.approvedUsers;
  }

  @override
  void didChangeDependencies() {
    this.requestModel.email = widget.requestModel.email;
    this.requestModel.fullName = widget.requestModel.fullName;
    this.requestModel.photoUrl = widget.requestModel.photoUrl;
    this.requestModel.sevaUserId = widget.requestModel.sevaUserId;

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
                S.of(context).request_title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: S.of(context).request_title_hint,
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
                    return S.of(context).request_subject;
                  }
                  widget.requestModel.title = value;
                },
              ),
              Text(' '),
              OfferDurationWidget(
                  title: S.of(context).request_duration,
                  startTime: startDate,
                  endTime: endDate),
              SizedBox(height: 8),
              Visibility(
                visible: widget.requestModel.isRecurring == true ||
                    widget.requestModel.autoGenerated == true,
                child: Container(
                  child: EditRepeatWidget(
                    requestModel: widget.requestModel,
                    offerModel: null,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                S.of(context).request_description,
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
                  hintText: S.of(context).request_description_hint,
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
                    return S.of(context).validation_error_general_text;
                  }
                  widget.requestModel.description = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(
                S.of(context).number_of_volunteers,
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
                  hintText: S.of(context).number_of_volunteers_required,
                  hintStyle: hintTextStyle,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.requestModel.numberOfApprovals = int.parse(value);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return S.of(context).validation_error_volunteer_count;
                  } else if (int.parse(value) < 0) {
                    return S
                        .of(context)
                        .validation_error_volunteer_count_negative;
                  } else if (int.parse(value) == 0) {
                    return S.of(context).validation_error_volunteer_count_zero;
                  } else {
                    requestModel.numberOfApprovals = int.parse(value);
                    setState(() {});
                    return null;
                  }
                },
              ),
              TotalCredits(
                  context,
                  requestModel,
                  OfferDurationWidgetState.starttimestamp,
                  OfferDurationWidgetState.endtimestamp),
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
                        if (widget.requestModel.isRecurring == true ||
                            widget.requestModel.autoGenerated == true) {
                          widget.requestModel.recurringDays =
                              EditRepeatWidgetState.getRecurringdays();
                          end.endType = EditRepeatWidgetState.endType == 0
                              ? "on"
                              : "after";
                          end.on = end.endType == "on"
                              ? EditRepeatWidgetState
                                  .selectedDate.millisecondsSinceEpoch
                              : null;
                          end.after = (end.endType == "after"
                              ? int.parse(EditRepeatWidgetState.after)
                              : 1);
                          widget.requestModel.end = end;
                        }

                        if (widget.requestModel.requestMode ==
                            RequestMode.PERSONAL_REQUEST) {
                          var onBalanceCheckResult;
                          if (widget.requestModel.isRecurring == true ||
                              widget.requestModel.autoGenerated == true) {
                            int recurrences =
                                widget.requestModel.end.endType == "after"
                                    ? (widget.requestModel.end.after -
                                            widget.requestModel.occurenceCount)
                                        .abs()
                                    : calculateRecurrencesOnMode(
                                        widget.requestModel);
                            onBalanceCheckResult = await RequestManager
                                .hasSufficientCreditsIncludingRecurring(
                                    credits: widget.requestModel.numberOfHours
                                        .toDouble(),
                                    userId: SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID,
                                    isRecurring:
                                        widget.requestModel.isRecurring,
                                    recurrences: recurrences);
                          } else {
                            onBalanceCheckResult = await RequestManager
                                .hasSufficientCreditsIncludingRecurring(
                                    credits: widget.requestModel.numberOfHours
                                        .toDouble(),
                                    userId: SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID,
                                    isRecurring:
                                        widget.requestModel.isRecurring,
                                    recurrences: 0);
                          }

                          if (!onBalanceCheckResult) {
                            showInsufficientBalance();
                            return;
                          }
                        }

                        /// TODO take language from Prakash
                        if (OfferDurationWidgetState.starttimestamp ==
                            OfferDurationWidgetState.endtimestamp) {
                          showDialogForTitle(
                              dialogTitle: S
                                  .of(context)
                                  .validation_error_same_start_date_end_date);
                          return;
                        }

                        // if (location != null) {
                        widget.requestModel.requestStart =
                            OfferDurationWidgetState.starttimestamp;
                        widget.requestModel.requestEnd =
                            OfferDurationWidgetState.endtimestamp;
                        widget.requestModel.location = location;
                        widget.requestModel.address = selectedAddress;
                        print(
                            "request model data === ${widget.requestModel.toMap()}");

                        if (widget.requestModel.isRecurring == true ||
                            widget.requestModel.autoGenerated == true) {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext viewContext) {
                                return WillPopScope(
                                    onWillPop: () {},
                                    child: AlertDialog(
                                        title:Text(S.of(context).this_is_repeating_event),
                                        actions: [
                                          FlatButton(
                                            child: Text(
                                              S.of(context).edit_this_event,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontFamily: 'Europa'),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(viewContext);
                                              linearProgressForCreatingRequest();
                                              await updateRequest(
                                                  requestModel:
                                                      widget.requestModel);
                                              Navigator.pop(dialogContext);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          FlatButton(
                                            child: Text(
                                              S.of(context).edit_subsequent_event,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontFamily: 'Europa'),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(viewContext);
                                              linearProgressForCreatingRequest();
                                              await updateRequest(
                                                  requestModel:
                                                      widget.requestModel);
                                              await RequestManager
                                                  .updateRecurrenceRequestsFrontEnd(
                                                      updatedRequestModel:
                                                          widget.requestModel);

                                        Navigator.pop(dialogContext);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        S.of(context).cancel,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontFamily: 'Europa',
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(viewContext);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          linearProgressForCreatingRequest();

                          await updateRequest(
                              requestModel: widget.requestModel);

                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        S.of(context).update_request.padLeft(10).padRight(10),
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

  void showDialogForTitle({String dialogTitle}) async {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
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

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).updating_request),
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
    memberAssignment = S.of(context).assign_to_volunteers;
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(memberAssignment),
        onPressed: () async {
          print("addVolunteersForAdmin():");

          print(" Selected users before ${selectedUsers.length}");

          onActivityResult = await Navigator.of(context).push(MaterialPageRoute(
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
                memberAssignment = S.of(context).assign_to_volunteers;
              else
                memberAssignment =
                    "${selectedUsers.length} ${S.of(context).volunteers_selected(selectedUsers.length)}";
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
            title: Text(S.of(context).insufficient_credits_for_request),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
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

  int calculateRecurrencesOnMode(RequestModel requestModel) {
    DateTime eventStartDate =
        DateTime.fromMillisecondsSinceEpoch(requestModel.requestStart);
    int recurrenceCount = 0;
    bool lastRound = false;
    while (lastRound == false) {
      eventStartDate = DateTime(
          eventStartDate.year,
          eventStartDate.month,
          eventStartDate.day + 1,
          eventStartDate.hour,
          eventStartDate.minute,
          eventStartDate.second);
      if (eventStartDate.millisecondsSinceEpoch <= requestModel.end.on &&
          recurrenceCount < 11) {
        if (requestModel.recurringDays.contains(eventStartDate.weekday % 7)) {
          recurrenceCount++;
        }
      } else {
        lastRound = true;
      }
    }
    log("on mode recurrence count isss $recurrenceCount");
    return recurrenceCount;
  }
}
