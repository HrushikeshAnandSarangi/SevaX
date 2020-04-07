import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
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
          'Create Offer',
          style: TextStyle(fontSize: 18),
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
  GeoFirePoint location;
  String selectedAddress;
  String timebankId;

  String _selectedTimebankId;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    this.timebankId = _selectedTimebankId;
    if (FlavorConfig.appFlavor == Flavor.APP) {
      _fetchCurrentlocation;
    }
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
    TextStyle titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'Europa',
      color: Colors.grey,
    );
    TextStyle subTitleStyle = TextStyle(
      fontSize: 14,
      color: titleStyle.color,
    );
    // Build a Form widget using the _formKey we created above
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Title*',
                  style: titleStyle,
                  // style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TextFormField(
                  decoration:
                      InputDecoration(hintText: 'Ex: Tutoring, painting..'),
                  keyboardType: TextInputType.text,
                  // style: finalStyle,
                  style: subTitleStyle,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the subject of your Offer';
                    }
                    title = value;
                  },
                ),
                SizedBox(height: 40),
                Text(
                  'Offer description*',
                  style: titleStyle,
                ),
                TextFormField(
                  maxLength: 500,
                  style: subTitleStyle,
                  decoration: InputDecoration(
                    hintText: 'Your offer and any #hashtags',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    description = value;
                  },
                ),
                SizedBox(height: 20),
                Text('Availability', style: titleStyle),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Describe my availability',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLength: 100,
                  style: subTitleStyle,
                  maxLines: null,
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
                    child: Container(
                      child: RaisedButton(
                        // shape: StadiumBorder(),
                        // color: Theme.of(context).accentColor,
                        onPressed: () {
                          //if (location != null) {
                          if (_formKey.currentState.validate()) {
                            if (!hasRegisteredLocation()) {
                              showDialogForTitle(
                                  dialogTitle:
                                      "Please add location to your offer");
                              return;
                            }

                            Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Creating Offer')),
                            );
                            _writeToDB();
                            Navigator.pop(context);
                          } else {
                            print("Invalid data");
                          }
//                      } else {
//                        Scaffold.of(context).showSnackBar(SnackBar(
//                          content: Text('Location not added'),
//                        ));
//                      }
                        },
                        child: Text(
                          '  Create Offer  ',
                          style: Theme.of(context).primaryTextTheme.button,
                        ),
                        textColor: Colors.white,
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

  bool hasRegisteredLocation() {
    return location != null;
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

  void get _fetchCurrentlocation {
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
  }
}
