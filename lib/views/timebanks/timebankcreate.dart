import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/location_picker.dart';

import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views//membersadd.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';

class TimebankCreate extends StatelessWidget {
  final String timebankId;
  TimebankCreate({@required this.timebankId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Color(0xFFFFFFFF),
        leading: BackButton(color: Colors.black54),
        title: Text(
          'Create a ${FlavorConfig.values.timebankTitle}',
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: TimebankCreateForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class TimebankCreateForm extends StatefulWidget {
  final String timebankId;
  TimebankCreateForm({@required this.timebankId});
  @override
  TimebankCreateFormState createState() {
    return TimebankCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class TimebankCreateFormState extends State<TimebankCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  TimebankModel timebankModel = TimebankModel({});
  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress;

  void initState() {
    super.initState();

    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();
    if(FlavorConfig.appFlavor == Flavor.APP){
      fetchCurrentlocation();
    }
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment = "+ Add Members";

  void _writeToDB() {
    // _checkTimebankName();
    // if (!_exists) {

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    List<String> members = [SevaCore.of(context).loggedInUser.sevaUserID];
    globals.addedMembersId.forEach((m) {
      members.add(m);
    });

    selectedUsers.forEach((key, user) {
      print("Selected member with key $key");
      members.add(user.sevaUserID);
    });

    print("Final arrray $members");

    timebankModel.id = Utils.getUuid();
    timebankModel.communityId = SevaCore.of(context).loggedInUser.currentCommunity;
    timebankModel.creatorId = SevaCore.of(context).loggedInUser.sevaUserID;
    timebankModel.photoUrl = globals.timebankAvatarURL;
    timebankModel.createdAt = timestamp;
    timebankModel.admins = [SevaCore.of(context).loggedInUser.sevaUserID];
    timebankModel.coordinators = [];
    timebankModel.members = members;
    timebankModel.children = [];
    timebankModel.balance = 0;
    timebankModel.protected = protectedVal;
    timebankModel.parentTimebankId = widget.timebankId;
    timebankModel.rootTimebankId = FlavorConfig.values.timebankId;
    timebankModel.address = selectedAddress;
    timebankModel.location =
    location == null ? GeoFirePoint(40.754387, -73.984291) : location;

    createTimebank(timebankModel: timebankModel);

    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
  }

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
            child: SingleChildScrollView(
              child: FlavorConfig.appFlavor == Flavor.APP? createSevaX : createTimebankHumanityFirst,
            )
        )
    );
  }

  Widget get createSevaX {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Text(
              'Timebank is where you can create requests and get offers with in your timebank.',
              textAlign: TextAlign.center,
            ),
          ),
          Center(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    TimebankAvatar(),
                    Text(''),
                    Text(
                      'Timebank cover',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              )
          ),
          headingText('Name your timebank'),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Ex: Pets-in-town, Citizen collab",
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              timebankModel.name = value;
            },
          ),
          headingText('About'),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Ex: A bit more about your timebank',
              ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              timebankModel.missionStatement = value;
            },
          ),
          tappableInviteMembers,
          Row(
            children: <Widget>[
              headingText('Private timebank'),
              Column(
                children: <Widget>[
                  Divider(),
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
            ],
          ),

          Text(
            'With private timebank, new members needs yor approval to join timebank',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          headingText('Is this pin at a right place?'),

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
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
                alignment: Alignment.center,
                child: FutureBuilder<Object>(
                    future: getTimeBankForId(timebankId: widget.timebankId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text('Error');
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) return Offstage();
                      TimebankModel parentTimebank = snapshot.data;
                      return RaisedButton(
                        // color: Colors.blue,
                        color: Colors.red,
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          //if (location != null) {
                          if (_formKey.currentState.validate()) {
//                            print("Hello");
//                            // If the form is valid, we want to show a Snackbar
                            _writeToDB();
//                            // return;
//
                            try{

                              parentTimebank.children.add(timebankModel.id);
                            }catch(e){
                              print("Error:$e");
                            }
                            updateTimebank(timebankModel: parentTimebank);
                            Navigator.pop(context);
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)
                        ),
                        child: Text(
                          'Create Timebank',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.white),
                        ),
                        textColor: Colors.blue,
                      );
                    })),
          ),
      ]
    );
  }

  Widget headingText(String name) {
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
          decoration: InputDecoration(
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
            timebankModel.name = value;
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
            timebankModel.missionStatement = value;
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
            timebankModel.emailId = value;
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
            timebankModel.phoneNumber = value;
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
            timebankModel.address = value;
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
        tappableInviteMembers,
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: _showMembers(),
        ),
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
        ),
        Center(
          child: Text(
            'We recommend you to add a vicinity location',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),

//              Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: GestureDetector(
//                  onTap: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute<GeoFirePoint>(
//                          builder: (context) => LocationPicker(
//                              selectedLocation: location
//                          )),
//                    ).then((point) {
//                      if (point != null) location = point;
//                      _getLocation();
//                      //log('ReceivedLocation: $selectedAddress');
//                    });
//                  },
//                  child: SizedBox(
//                    width: 140,
//                    height: 30,
//                    child: Container(
//                      color: Colors.grey[200],
//                      child: Row(
//                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.all(2.0),
//                            child: Icon(Icons.add_location),
//                          ),
//                          Text('  '),
//                          Text(
//                            selectedAddress == null || selectedAddress.isEmpty
//                                ? 'Add Location'
//                                : selectedAddress,
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
//              ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
              alignment: Alignment.center,
              child: FutureBuilder<Object>(
                  future: getTimeBankForId(timebankId: widget.timebankId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text('Error');
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) return Offstage();
                    TimebankModel parentTimebank = snapshot.data;
                    return RaisedButton(
                      // color: Colors.blue,
                      color: Colors.red,
                      onPressed: () {

                        if (_formKey.currentState.validate()) {
                          // If the form is valid, we want to show a Snackbar
                          try{
                            _writeToDB();
                            if (parentTimebank.children == null)
                              parentTimebank.children = [];
                            parentTimebank.children.add(timebankModel.id);
                            updateTimebank(timebankModel: parentTimebank);
                          }catch(e){
                            print("Error is:$e");
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Create ${FlavorConfig.values.timebankTitle}',
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.white),
                      ),
                      textColor: Colors.blue,
                    );
                  })),
        ),
      ],
    );
  }

  void addVolunteers() async {
    print(
        " Selected users before ${selectedUsers.length} with timebank id as ${SevaCore.of(context).loggedInUser.currentTimebank}");

    onActivityResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectMembersInGroup(
          timebankId: SevaCore.of(context)
              .loggedInUser
              .currentTimebank,
          userSelected: selectedUsers == null
              ? selectedUsers = HashMap()
              : selectedUsers,
          userEmail: SevaCore.of(context).loggedInUser.email,
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
      print(
          "Data is present Selected users ${selectedUsers.length}");
    } else {
      print("No users where selected");
      //no users where selected
    }
  }

  Widget get tappableInviteMembers {
    return FlavorConfig.appFlavor == Flavor.APP ?
      GestureDetector(
        onTap: () async {
          addVolunteers();
        },
        child: Padding(
        padding: EdgeInsets.only(top: 15),
          child: Text(
          'Invite members +',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      )
      )
      : Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: FlatButton(
            onPressed: () async {
              addVolunteers();
            },
            child: Text(
              memberAssignment,
              style: TextStyle(fontSize: 16.0, color: Colors.blue),
            ),
          )
      );
  }

  Future _getLocation() async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    log('_getLocation: $address');
    setState(() {
      this.selectedAddress = address;
    });
  }

  _showMembers() {
    if (globals.addedMembersId == []) {
      Text('');
    } else {
      Text(globals.addedMembersId.toString());
    }
  }

  void fetchCurrentlocation(){
    Location().getLocation().then((onValue){
      print("Location1:$onValue");
        location = GeoFirePoint(onValue.latitude,onValue.longitude);
      LocationUtility().getFormattedAddress(
        location.latitude,
        location.longitude,
      ).then((address){
        setState(() {
          this.selectedAddress = address;
        });
      });
    });
  }
}