import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';

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
      return "Edit Request";
    }
    return "Edit Project Request";
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

  final _formKey = GlobalKey<FormState>();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

  String _dateMessageStart = ' START date and time ';
  String _dateMessageEnd = '  END date and time ';
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;

  String _selectedTimebankId;

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
                'Request title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                // decoration: InputDecoration(hintText: 'Campign request title'),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                initialValue: widget.requestModel.title,
                onChanged: (value) {
                  widget.requestModel.title = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the subject of your Request';
                  }
                  widget.requestModel.title = value;
                },
              ),
              Text(' '),
              OfferDurationWidget(
                  title: ' Request duration*',
                  startTime: startDate,
                  endTime: endDate),
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
              Text(
                'Request description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.grey,
                ),
              ),
              TextFormField(
                initialValue: widget.requestModel.description,
                decoration: InputDecoration(
                  hintText: 'Your Request \nand any #hashtags',
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
                    return 'Please enter some text';
                  }
                  widget.requestModel.description = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),

              // SizedBox(height: 40),
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
                  initialValue: "${widget.requestModel.numberOfHours ?? 0}",
                  decoration: InputDecoration(
                    hintText: 'No. of hours required',
                    hintStyle: textStyle,
                    // labelText: 'No. of volunteers',
                  ),
                  onChanged: (value) {
                    widget.requestModel.numberOfHours = int.parse(value);
                  },
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
                'No. of volunteers',
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
                  hintText: 'No. of approvals',
                  hintStyle: hintTextStyle,

                  // border: OutlineInputBorder(
                  //   borderRadius: const BorderRadius.all(
                  //     const Radius.circular(20.0),
                  //   ),
                  //   borderSide: new BorderSide(
                  //     color: Colors.black,
                  //     width: 1.0,
                  //   ),
                  // ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  widget.requestModel.numberOfApprovals = int.parse(value);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the number of volunteers needed';
                  }
                  widget.requestModel.numberOfApprovals = int.parse(value);
                },
              ),
//              if (FlavorConfig.appFlavor != Flavor.APP)
              //addVolunteersForAdmin(),
              SizedBox(height: 20),
              Center(
                child: FlatButton.icon(
                  icon: Icon(Icons.add_location),
                  label: SizedBox(
                    width: MediaQuery.of(context).size.width - 160,
                    child: Text(
                      selectedAddress == null || selectedAddress.isEmpty
                          ? '${this._getLocation()}'
                          : selectedAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    width: 250,
                    child: RaisedButton(
                      onPressed: () async {
                        if (location != null) {
                          widget.requestModel.requestStart =
                              OfferDurationWidgetState.starttimestamp;
                          widget.requestModel.requestEnd =
                              OfferDurationWidgetState.endtimestamp;
                          widget.requestModel.location = location;

                          //adding some members for humanity first
//                        List<String> arrayOfSelectedMembers = List();
//                        selectedUsers
//                            .forEach((k, v) => arrayOfSelectedMembers.add(k));
//                        requestModel.approvedUsers = arrayOfSelectedMembers;
                          print(widget.requestModel.toMap());
                          //adding some members for humanity first

                          if (_formKey.currentState.validate()) {
                            linearProgressForCreatingRequest();
                            await this.updateRequest(
                                requestModel: widget.requestModel);

//                          if (widget.isOfferRequest == true) {
//                            OfferModel offer = widget.offer;
//
//                            Set<String> offerRequestList = () {
//                              if (offer.requestList == null) return [];
//                              return offer.requestList;
//                            }()
//                                .toSet();
//                            offerRequestList.add(requestModel.id);
//                            offer.requestList = offerRequestList.toList();
//                            FirestoreManager.updateOfferWithRequest(
//                                offer: offer);
//                            sendOfferRequest(
//                                offerModel: widget.offer,
//                                requestSevaID: requestModel.sevaUserId);
//                            Navigator.pop(context);
//                            Navigator.pop(context);
//                          }
                            if (dialogContext != null) {
                              Navigator.pop(dialogContext);
                            }
                            Navigator.pop(context);
                          }
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Location not added'),
                          ));
                        }
                      },
                      child: Text(
                        "Update Request".padLeft(10).padRight(10),
                        style: Theme.of(context).primaryTextTheme.button,
                      ),
                    ),
                  ),
                ),
              ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: Center(
//                   child: RaisedButton(
//                     shape: StadiumBorder(),
//                     color: Theme.of(context).accentColor,
//                     onPressed: () async {
//                       if (location != null) {
//                         widget.requestModel.requestStart =
//                             OfferDurationWidgetState.starttimestamp;
//                         widget.requestModel.requestEnd =
//                             OfferDurationWidgetState.endtimestamp;
//                         widget.requestModel.location = location;

//                         //adding some members for humanity first
// //                        List<String> arrayOfSelectedMembers = List();
// //                        selectedUsers
// //                            .forEach((k, v) => arrayOfSelectedMembers.add(k));
// //                        requestModel.approvedUsers = arrayOfSelectedMembers;
//                         print(widget.requestModel.toMap());
//                         //adding some members for humanity first

//                         if (_formKey.currentState.validate()) {
//                           await this
//                               .updateRequest(requestModel: widget.requestModel);

// //                          if (widget.isOfferRequest == true) {
// //                            OfferModel offer = widget.offer;
// //
// //                            Set<String> offerRequestList = () {
// //                              if (offer.requestList == null) return [];
// //                              return offer.requestList;
// //                            }()
// //                                .toSet();
// //                            offerRequestList.add(requestModel.id);
// //                            offer.requestList = offerRequestList.toList();
// //                            FirestoreManager.updateOfferWithRequest(
// //                                offer: offer);
// //                            sendOfferRequest(
// //                                offerModel: widget.offer,
// //                                requestSevaID: requestModel.sevaUserId);
// //                            Navigator.pop(context);
// //                            Navigator.pop(context);
// //                          }
//                           Navigator.pop(context);
//                         }
//                       } else {
//                         Scaffold.of(context).showSnackBar(SnackBar(
//                           content: Text('Location not added'),
//                         ));
//                       }
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Icon(
//                           Icons.attachment,
//                           size: 24.0,
//                           color: FlavorConfig.values.buttonTextColor,
//                         ),
//                         Text(' '),
//                         Text(
//                           'Update Campign Request',
//                           style: TextStyle(
//                             color: FlavorConfig.values.buttonTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
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
            title: Text('Updating Request..'),
            content: LinearProgressIndicator(),
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
//  Future _updaterequestModel() async {
//
//  }

  Future<void> updateRequest({
    @required RequestModel requestModel,
  }) async {
    print(requestModel.toMap());

    return await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData(requestModel.toMap());
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
