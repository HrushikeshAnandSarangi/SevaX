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

class CommunityCreate extends StatelessWidget {
  final String timebankId;
  CommunityCreate({@required this.timebankId});
  @override
  Widget build(BuildContext context) {
    var title = 'Create your Community';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Color(0xFFFFFFFF),
        leading: BackButton(color: Colors.black54),
        title: Text(
          title,
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: CommunityCreateForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class CommunityCreateForm extends StatefulWidget {
  final String timebankId;
  CommunityCreateForm({@required this.timebankId});
  @override
  CommunityCreateFormState createState() {
    return CommunityCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class CommunityCreateFormState extends State<CommunityCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  TimebankModel timebankModel = TimebankModel();
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
              child: createSevaX ,
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
              'Team is where you can collaborate with your organization',
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
                      'Your Logo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              )
          ),
          headingText('Name your team'),
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
              hintText: 'Ex: A bit more about your team',
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
          Row(
            children: <Widget>[
              headingText('Private team'),
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
            'With private team, new members needs yor approval to join team',
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
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: tappableAddBillingDetails,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Looking for existing team ',
                  style: TextStyle(

                    color: Colors.grey,
                  ),
                ),
                tappableFindYourTeam,
              ],
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
                            // If the form is valid, we want to show a Snackbar
                            _writeToDB();
                            // return;

                            if (parentTimebank.children == null)
                              parentTimebank.children = [];
                            parentTimebank.children.add(timebankModel.id);
                            updateTimebank(timebankModel: parentTimebank);
                            Navigator.pop(context);
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)
                        ),
                        child: Text(
                          'Next',
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


  Widget get tappableAddBillingDetails {
    return  GestureDetector(
      onTap: () async {

      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Configure billing details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Divider(),
          Text(
            '+',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget get tappableFindYourTeam {
    return  GestureDetector(
      onTap: () async {

      },
      child: Text(
        'Find your team',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
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