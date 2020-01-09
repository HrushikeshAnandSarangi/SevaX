import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';


class CreateOffer extends StatelessWidget {
  final String timebankId;
  CreateOffer({this.timebankId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Create volunteer offer',
          // style: TextStyle(
          //     color: Colors.white
          // ),
        ),
        centerTitle: false,
      ),
      body: MyCustomForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class MyCustomForm extends StatefulWidget {
  final String timebankId;
  MyCustomForm({this.timebankId});
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String schedule = '';
  String description = '';
  GeoFirePoint location = GeoFirePoint(40.754387, -73.984291);
  String selectedAddress;
  String timebankId;

  String _selectedTimebankId;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.timebankId = _selectedTimebankId;
  }

  void _writeToDB() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    OfferModel model = OfferModel(
      email: SevaCore.of(context).loggedInUser.email,
      fullName: SevaCore.of(context).loggedInUser.fullname,
      title: title,
      id: '${SevaCore.of(context).loggedInUser.email}*$timestampString',
      sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      description: description,
      schedule: schedule,
      timebankId: widget.timebankId,
      timestamp: timestamp,
      location:
          location == null ? GeoFirePoint(40.754387, -73.984291) : location,
    );
    await createOffer(offerModel: model);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    TextStyle finalStyle = TextStyle(
        fontSize: 18,
        color: textStyle.color,
        decoration: textStyle.decoration,
    );
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(' '),
              TextFormField(
                decoration: InputDecoration(hintText: 'Volunteer offer title'),
                keyboardType: TextInputType.text,
                style: finalStyle,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the subject of your Offer';
                  }
                  title = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Your offer and any #hashtags',
                  labelText: 'Volunteer offer description',
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
                  description = value;
                },
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Describe My Availability',
                  labelText: 'Availability',
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
                maxLines: 4,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  schedule = value;
                },
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      //if (location != null) {
                      if (_formKey.currentState.validate()) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Creating Offer')),
                        );
                        _writeToDB();
                        Navigator.pop(context);
                      }
//                      } else {
//                        Scaffold.of(context).showSnackBar(SnackBar(
//                          content: Text('Location not added'),
//                        ));
//                      }
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
                          'Create volunteer offer',
                          style: TextStyle(
                            color: FlavorConfig.values.buttonTextColor,
                          ),
                        ),
                      ],
                    ),
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
}
