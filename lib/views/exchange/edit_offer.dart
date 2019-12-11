import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/main.dart' as prefix0;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';

class UpdateOffer extends StatelessWidget {
  final String timebankId;
  OfferModel offerModel;
  UpdateOffer({this.timebankId, this.offerModel});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Update volunteer offer",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: MyCustomOfferForm(
        timebankId: timebankId,
        offerModel: offerModel,
      ),
    );
  }
}

// Create a Form Widget
class MyCustomOfferForm extends StatefulWidget {
  final String timebankId;
  OfferModel offerModel;
  MyCustomOfferForm({this.timebankId, this.offerModel});
  @override
  MyCustomOfferFormState createState() {
    return MyCustomOfferFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class MyCustomOfferFormState extends State<MyCustomOfferForm> {
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
  String _selectedTimebankId;
  OfferModel offerModel;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    //this.offerModel.timebankId = _selectedTimebankId;
    this.location = widget.offerModel.location;
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
        location: location);
    await FirestoreManager.createOffer(offerModel: model);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
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
                initialValue: widget.offerModel.title,
                keyboardType: TextInputType.text,
                style: textStyle,
                onChanged: (value) {
                  widget.offerModel.title = value;
                },
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
                initialValue: widget.offerModel.description,
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
                onChanged: (value) {
                  widget.offerModel.description = value;
                },
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
                initialValue: widget.offerModel.schedule,
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
                onChanged: (value) {
                  widget.offerModel.schedule = value;
                },
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
                          ? '${this._getLocation()}'
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
                      if (location != null) {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Update Offer')),
                          );
                          widget.offerModel.location = this.location;
                          //_writeToDB();
                          this.updateOffer(offerModel: widget.offerModel);
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
                          'Update volunteer offer',
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

  Future<void> updateOffer({
    @required OfferModel offerModel,
  }) async {
    print(offerModel.toMap());

    return await Firestore.instance
        .collection('offers')
        .document(offerModel.id)
        .updateData(offerModel.toMap());
  }

  Future _getLocation() async {
    
    print("-------->>>>.  $location ");
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
    log('_getLocation: $address');

    print("Geo Location is $address");

    setState(() {
      this.selectedAddress = address;
    });
  }
}
