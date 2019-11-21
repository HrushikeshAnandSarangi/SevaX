import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;

  CreateRequest({Key key, this.isOfferRequest, this.offer, this.timebankId})
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Create Campaign Request",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: RequestCreateForm(
        isOfferRequest: widget.isOfferRequest,
        offer: widget.offer,
        timebankId: widget.timebankId,
      ),
    );
  }
}

class RequestCreateForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  RequestCreateForm({this.isOfferRequest, this.offer, this.timebankId});

  @override
  RequestCreateFormState createState() {
    return RequestCreateFormState();
  }
}

class RequestCreateFormState extends State<RequestCreateForm> {
  final GlobalKey<_CreateRequestState> _offerState = GlobalKey();
  final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();

  final _formKey = GlobalKey<FormState>();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

  String _dateMessageStart = ' START date and time ';
  String _dateMessageEnd = '  END date and time ';
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;

  String _selectedTimebankId;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
  }

  @override
  void didChangeDependencies() {
    FirestoreManager.getUserForIdStream(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID)
        .listen((userModel) {
      this.requestModel.email = userModel.email;
      this.requestModel.fullName = userModel.fullname;
      this.requestModel.photoUrl = userModel.photoURL;
      this.requestModel.sevaUserId = userModel.sevaUserID;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Campaign request title'),
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
              Text(' '),
              OfferDurationWidget(
                title: ' Request Duration*',
                //startTime: CalendarWidgetState.startDate,
                //endTime: CalendarWidgetState.endDate
              ),
              SizedBox(height: 8),

              // FlatButton(
              //   //Request Date and Time
              //   color: Color.fromRGBO(112, 196, 147, 1.0),
              //   onPressed: () {
              //     DateTime selectedDate;
              //     if (requestModel.requestStart == null) {
              //       selectedDate = DateTime.now();
              //     } else {
              //       selectedDate = DateTime.fromMillisecondsSinceEpoch(
              //         requestModel.requestStart,
              //       );
              //     }

              //     DatePicker.showDateTimePicker(
              //       context,
              //       showTitleActions: true,
              //       onChanged: (date) {
              //         requestModel.requestStart = date.millisecondsSinceEpoch;
              //         setState(() {
              //           _dateMessageStart = ' ' +
              //               DateTime.fromMillisecondsSinceEpoch(
              //                 requestModel.requestStart,
              //               ).toString();
              //         });
              //       },
              //       onConfirm: (date) {
              //         requestModel.requestStart = date.millisecondsSinceEpoch;
              //         setState(() {
              //           _dateMessageStart = ' ' +
              //               DateTime.fromMillisecondsSinceEpoch(
              //                 requestModel.requestStart,
              //               ).toString();
              //         });
              //       },
              //       currentTime: DateTime(
              //         selectedDate.year,
              //         selectedDate.month,
              //         selectedDate.day,
              //         selectedDate.hour,
              //         selectedDate.minute,
              //         00,
              //       ),
              //     );
              //   },
              //   child: Row(
              //     children: [
              //       Icon(Icons.calendar_today, size: 24.0),
              //       Text(_dateMessageStart),
              //     ],
              //   ),
              // ),
              // Text(' '),
              // FlatButton(
              //   color: Color.fromRGBO(112, 196, 0, 1.0),
              //   onPressed: () {
              //     DateTime selectedDate;

              //     if (requestModel.requestEnd == null) {
              //       selectedDate = DateTime.now();
              //     } else {
              //       selectedDate = DateTime.fromMillisecondsSinceEpoch(
              //         requestModel.requestEnd,
              //       );
              //     }

              //     DatePicker.showDateTimePicker(
              //       context,
              //       showTitleActions: true,
              //       onChanged: (date) {
              //         requestModel.requestEnd = date.millisecondsSinceEpoch;
              //         setState(() {
              //           _dateMessageEnd = ' ' +
              //               DateTime.fromMillisecondsSinceEpoch(
              //                       requestModel.requestEnd)
              //                   .toString();
              //         });
              //       },
              //       onConfirm: (date) {
              //         requestModel.requestEnd = date.millisecondsSinceEpoch;
              //         setState(() {
              //           _dateMessageEnd = ' ' +
              //               DateTime.fromMillisecondsSinceEpoch(
              //                       requestModel.requestEnd)
              //                   .toString();
              //         });
              //       },
              //       currentTime: DateTime(
              //         selectedDate.year,
              //         selectedDate.month,
              //         selectedDate.day,
              //         selectedDate.hour,
              //         selectedDate.minute,
              //         00,
              //       ),
              //     );
              //   },
              //   child: Row(
              //     children: [
              //       Icon(Icons.calendar_today, size: 24.0),
              //       Text(_dateMessageEnd),
              //     ],
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Your Campaign Request and any #hashtags',
                  labelText: 'Campaign request description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  requestModel.description = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'No. of approvals',
                  labelText: 'No. of volunteers',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the number of volunteers needed';
                  }
                  requestModel.numberOfApprovals = int.parse(value);
                },
              ),
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      if (location != null) {
                        requestModel.requestStart =
                            OfferDurationWidgetState.starttimestamp;
                        requestModel.requestEnd =
                            OfferDurationWidgetState.endtimestamp;

                        //adding some members for humanity first
                        List<String> arrayOfSelectedMembers = List();
                        selectedUsers
                            .forEach((k, v) => arrayOfSelectedMembers.add(k));
                        requestModel.approvedUsers = arrayOfSelectedMembers;
                        //adding some members for humanity first

                        if (_formKey.currentState.validate()) {
                          await _writeToDB();

                          if (widget.isOfferRequest == true) {
                            OfferModel offer = widget.offer;

                            Set<String> offerRequestList = () {
                              if (offer.requestList == null) return [];
                              return offer.requestList;
                            }()
                                .toSet();
                            offerRequestList.add(requestModel.id);
                            offer.requestList = offerRequestList.toList();
                            FirestoreManager.updateOfferWithRequest(
                                offer: offer);
                            sendOfferRequest(
                                offerModel: widget.offer,
                                requestSevaID: requestModel.sevaUserId);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                          Navigator.pop(context);
                        }
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Location not added'),
                        ));
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.attachment,
                          size: 24.0,
                          color: FlavorConfig.values.buttonTextColor,
                        ),
                        Text(' '),
                        Text(
                          'Pin Campaign Request',
                          style: TextStyle(
                            color: FlavorConfig.values.buttonTextColor,
                          ),
                        ),
                      ],
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

  Map<String, UserModel> selectedUsers;
  Map onActivityResult;

  String memberAssignment = "Assign to volunteers";

  Widget addVolunteersForAdmin() {
    if (selectedUsers == null) {
      selectedUsers = HashMap();
    }

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
                  SevaCore.of(context).loggedInUser.currentTimebank,
                  selectedUsers)));

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

  Future _writeToDB() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    requestModel.id = '${requestModel.email}*$timestampString';
    requestModel.postTimestamp = timestamp;
    requestModel.accepted = false;
    requestModel.acceptors = [];
    requestModel.location = location;
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
