import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

import '../core.dart';

class EditGroupView extends StatelessWidget {
  final TimebankModel timebankModel;
  EditGroupView({@required this.timebankModel});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditGroupForm(
        timebankModel: timebankModel,
      ),
    );
  }
}

// Create a Form Widget
class EditGroupForm extends StatefulWidget {
  final TimebankModel timebankModel;
  EditGroupForm({@required this.timebankModel});
  @override
  EditGroupFormState createState() {
    return EditGroupFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class EditGroupFormState extends State<EditGroupForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress;
  TextEditingController searchTextController;
  var _searchText = "";
  String errTxt;
  final _textUpdates = StreamController<String>();
  void initState() {
    super.initState();

    if (widget.timebankModel.location != null) {
      location = widget.timebankModel.location;
      selectedAddress = widget.timebankModel.address;
    }
    searchTextController =
        new TextEditingController(text: widget.timebankModel.name);

    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));

    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 600))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        if (widget.timebankModel.name != s) {
          SearchManager.searchGroupForDuplicate(
                  queryString: s.trim(),
                  communityId:
                      SevaCore.of(context).loggedInUser.currentCommunity)
              .then((groupFound) {
            if (groupFound) {
              setState(() {
                errTxt = 'Group name already exists';
              });
            } else {
              setState(() {
                groupFound = false;
                errTxt = null;
              });
            }
          });
        }
      }
    });
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment = "+ Add Members";

  void updateGroupDetails() {
    widget.timebankModel.photoUrl =
        globals.timebankAvatarURL ?? widget.timebankModel.photoUrl;
    // widget.timebankModel.protected = protectedVal;
    widget.timebankModel.address = selectedAddress;
    widget.timebankModel.location =
        location == null ? GeoFirePoint(40.754387, -73.984291) : location;

    updateTimebank(timebankModel: widget.timebankModel).then((onValue) {
      showDialogForSuccess(dialogTitle: "Details updated successfully.");
    });
    globals.timebankAvatarURL = null;
  }

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: SingleChildScrollView(
          child: (FlavorConfig.appFlavor == Flavor.APP ||
                  FlavorConfig.appFlavor == Flavor.SEVA_DEV)
              ? createSevaX
              : createTimebankHumanityFirst,
        ),
      ),
    );
  }

//umesha@uipep.com
//upnsd143 uipep
  Widget get createSevaX {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  TimebankAvatar(
                    photoUrl: widget.timebankModel.photoUrl ?? null,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Group logo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          headingText('Name your group', true),
          TextFormField(
            textInputAction: TextInputAction.done,
            controller: searchTextController,
            decoration: InputDecoration(
              errorText: errTxt,
              hintText: "Ex: Pets-in-town, Citizen collab",
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              widget.timebankModel.name = value;
            },
          ),
          headingText('About', true),
          TextFormField(
            initialValue: widget.timebankModel.missionStatement ?? "",
            decoration: InputDecoration(
              hintText: 'Ex: A bit more about your group',
            ),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              widget.timebankModel.missionStatement = value;
            },
          ),
          // Row(
          //   children: <Widget>[
          //     headingText('Protected group', false),
          //     Column(
          //       children: <Widget>[
          //         Divider(),
          //         Checkbox(
          //           checkColor: Colors.white,
          //           activeColor: Colors.green,
          //           value: widget.timebankModel.protected,
          //           onChanged: (bool value) {
          //             setState(() {
          //               widget.timebankModel.protected = value;
          //             });
          //           },
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          // Text(
          //   'Protected groups are for political campaigns and certain nonprofits where user to user transactions are disabled.',
          //   style: TextStyle(
          //     fontSize: 12,
          //     color: Colors.grey,
          //   ),
          // ),
          headingText('Is this pin at a right place?', false),
          Container(
            margin: EdgeInsets.all(20),
            child: Center(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate() &&
                      (errTxt == null || errTxt == "")) {
                    updateGroupDetails();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Update',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                ),
                textColor: Colors.blue,
              ),
            ),
          ),
        ]);
  }

  Widget headingText(String name, bool isMandatory) {
    if (isMandatory) {
      name = name + "*";
    }
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget get createTimebankHumanityFirst {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
            child: Padding(
          padding: EdgeInsets.all(5.0),
          child: TimebankAvatar(),
        )),
        Padding(
          padding: EdgeInsets.all(15.0),
        ),
        TextFormField(
          controller: searchTextController,
          decoration: InputDecoration(
            errorText: errTxt,
            hintText: FlavorConfig.values.timebankName == "Yang 2020"
                ? "Yang Gang Chapter"
                : "Timebank Name",
            labelText: FlavorConfig.values.timebankName == "Yang 2020"
                ? "Yang Gang Chapter"
                : "Timebank Name",
            // labelStyle: textStyle,
            // labelStyle: textStyle,
            // labelText: 'Description',
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
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            widget.timebankModel.name = value;
            return "";
          },
        ),
        Text(' '),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'What you are about',
            labelText: 'Mission Statement',
            // labelStyle: textStyle,
            // labelStyle: textStyle,
            // labelText: 'Description',
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
          maxLines: null,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            widget.timebankModel.missionStatement = value;
            return "";
          },
        ),
        Text(''),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'The Timebank\'s primary email',
            labelText: 'Email',
            // labelStyle: textStyle,
            // labelStyle: textStyle,
            // labelText: 'Description',
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
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            widget.timebankModel.emailId = value;
            return "";
          },
        ),
        Text(''),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'The Timebanks primary phone number',
            labelText: 'Phone Number',
            // labelStyle: textStyle,
            // labelStyle: textStyle,
            // labelText: 'Description',
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
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            widget.timebankModel.phoneNumber = value;
            return "";
          },
        ),
        Text(''),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Your main address',
            labelText: 'Address',
            // labelStyle: textStyle,
            // labelStyle: textStyle,
            // labelText: 'Description',
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
          maxLines: null,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            widget.timebankModel.address = value;
            return "";
          },
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5),
            ),
            Text(
              'Closed :',
              style: TextStyle(fontSize: 18),
            ),
            Checkbox(
              value: protectedVal,
              onChanged: (bool value) {
                setState(() {
                  protectedVal = value;
                });
              },
            ),
          ],
        ),
        // Text(sevaUserID),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                  MaterialPageRoute<LocationDataModel>(
                    builder: (context) => LocationPicker(
                      selectedLocation: location,
                    ),
                  ),
                ).then((dataModel) {
                  if (dataModel != null) location = dataModel.geoPoint;
                  // _getLocation();
                  setState(() {
                    this.selectedAddress = dataModel.location;
                  });
                  log('ReceivedLocation: $selectedAddress');
                });
              },
            ),
          ),
        ),
        Center(
          child: Text(
            'We recommend you to add a vicinity location',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            alignment: Alignment.center,
            child: RaisedButton(
              // color: Colors.blue,
              color: Colors.red,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // If the form is valid, we want to show a Snackbar
                }
              },
              child: Text(
                'Create ${FlavorConfig.values.timebankTitle}',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              textColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Future _getLocation() async {
    if (location == null) return;
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    log('_getLocation: $address');
    setState(() {
      this.selectedAddress = address;
    });
  }

  void showDialogForSuccess({String dialogTitle}) {
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
}
