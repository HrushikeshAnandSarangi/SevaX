import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/location_model.dart';
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

  static TextStyle titleStyle = TextStyle(
    fontSize: 16,
    // fontWeight: FontWeight.bold,
    fontFamily: 'Europa',
    color: Colors.black,
  );
  static TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: titleStyle.color,
  );

  String selectedAddress;
  String timebankId;

  GeoFirePoint location;

  OfferType offerType;
  GroupOfferDataModel groupOfferDataModel;
  IndividualOfferDataModel individualOfferDataModel;

  String _selectedTimebankId;

  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    offerType = OfferType.INDIVIDUAL_OFFER;
    groupOfferDataModel = GroupOfferDataModel();
    individualOfferDataModel = IndividualOfferDataModel();

    this.timebankId = _selectedTimebankId;
    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      _fetchCurrentlocation;
    }
  }

  void _writeToDB({OfferModel model}) async {
    print("offer mdoel ----> ${model.toMap()}");
    // return;
    await createOffer(offerModel: model);
  }

  Widget getSwitchForGroupOffer() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: logoWidgets,
        borderColor: Colors.grey,

        padding: EdgeInsets.only(left: 0.0, right: 0),
        groupValue: sharedValue,
        onValueChanged: (int val) {
          print(val);
          if (val != sharedValue) {
            setState(() {
              print("$sharedValue -- $val");
              if (sharedValue == 0) {
                offerType = OfferType.GROUP_OFFER;
                groupOfferDataModel =
                    groupOfferDataModel ?? GroupOfferDataModel();
              } else {
                offerType = OfferType.INDIVIDUAL_OFFER;
                individualOfferDataModel =
                    individualOfferDataModel ?? IndividualOfferDataModel();
              }
              sharedValue = val;
            });
          }
        },
        //groupValue: sharedValue,
      ),
    );
  }

  int sharedValue = 0;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Individual offer',
      style: TextStyle(fontSize: 15.0),
    ),
    1: Text(
      'One to many',
      style: TextStyle(fontSize: 15.0),
    ),
  };

  Widget getIndividualOffer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Title*',
          style: titleStyle,
          // style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'Ex: babysitting..'),
          keyboardType: TextInputType.text,
          style: subTitleStyle,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
          ],
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter the subject of your Offer';
            }
            individualOfferDataModel.title = value;
          },
        ),
        SizedBox(height: 40),
        Text(
          'Offer description*',
          style: titleStyle,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
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
            individualOfferDataModel.description = value;
          },
        ),
        SizedBox(height: 20),
        Text('Availability', style: titleStyle),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
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
            individualOfferDataModel.schedule = value;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                getSwitchForGroupOffer(),
                offerType == OfferType.GROUP_OFFER
                    ? getGroupAttributes()
                    : getIndividualOffer(),
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
                          this.selectedAddress = dataModel.location;
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
                            if (location == null) {
                              showDialogForDate(
                                  dialogTitle:
                                      "Please add location to your offer");
                              return;
                            }
                            OfferModel model;
                            switch (offerType) {
                              case OfferType.INDIVIDUAL_OFFER:
                                model = gatherIndividualOfferData();
                                break;

                              case OfferType.GROUP_OFFER:
                                if (!isClassStartDateSelected()) {
                                  return;
                                }
                                print("--------------- $groupOfferDataModel");
                                model = gatherGroupOffer();
                                break;
                            }

                            Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Creating Offer')),
                            );
                            _writeToDB(model: model);
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

  Widget getDurationWidget() {
    return OfferDurationWidget(
      title: ' Offer duration',
      //startTime: CalendarWidgetState.startDate,
      //endTime: CalendarWidgetState.endDate
    );
  }

  void showDialogForDate({String dialogTitle}) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle ?? "Please enter start and end date"),
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

  Widget getGroupAttributes() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getClassTitle(),
        getDurationWidget(),
        SizedBox(height: 30),
        getPreperatiionTime(),
        getNumberOfClassHours(),
        getClassDesciption(),
      ],
    );
  }

  int preperationTime;
  TextStyle textStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  Widget getClassTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Text(
          'Title*',
          style: titleStyle,
          // style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,

          decoration: InputDecoration(hintText: 'Ex: babysitting..'),
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
          ],
          // style: finalStyle,
          style: subTitleStyle,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter the subject of your Offer';
            }
            groupOfferDataModel.classTitle = value;
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget getClassDesciption() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Text(
          'Class description*',
          style: titleStyle,
        ),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          maxLength: 500,
          style: subTitleStyle,
          decoration: InputDecoration(
            hintText: 'Please enter some class decription',
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            groupOfferDataModel.classDescription = value;
          },
        ),
      ],
    );
  }

  Widget getPreperatiionTime() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'No. of preperation hours *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.grey,
          ),
        ),
        TextFormField(
            decoration: InputDecoration(
              hintText: 'No. of preperation hours required',
              hintStyle: textStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the your preperation time';
              } else {
                groupOfferDataModel.numberOfPreperationHours = int.parse(value);
                return null;
              }
            }),
        SizedBox(height: 20),
      ],
    );
  }

  Widget getNumberOfClassHours() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Text(
          'No. of class hours *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.grey,
          ),
        ),
        TextFormField(
            decoration: InputDecoration(
              hintText: 'No. of class hours',
              hintStyle: textStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'No. of class hours';
              } else {
                groupOfferDataModel.numberOfClassHours = int.parse(value);
                return null;
              }
            }),
        SizedBox(height: 20),
      ],
    );
  }

  // Future _getLocation() async {
  //   String address = await LocationUtility().getFormattedAddress(
  //     location.latitude,
  //     location.longitude,
  //   );
  //   log('_getLocation: $address');
  //   setState(() {
  //     this.selectedAddress = address;
  //   });
  // }

  void get _fetchCurrentlocation async {
    try {
      Location templocation = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
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
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
    }
  }

  OfferModel gatherIndividualOfferData() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var id = '${SevaCore.of(context).loggedInUser.email}*$timestamp';

    return OfferModel(
      id: id,
      email: SevaCore.of(context).loggedInUser.email,
      fullName: SevaCore.of(context).loggedInUser.fullname,
      sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      timebankId: widget.timebankId,
      selectedAdrress: selectedAddress,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      location:
          location == null ? GeoFirePoint(40.754387, -73.984291) : location,
      groupOfferDataModel: GroupOfferDataModel(),
      individualOfferDataModel: individualOfferDataModel,
      offerType: OfferType.INDIVIDUAL_OFFER,
    );
  }

  OfferModel gatherGroupOffer() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var id = '${SevaCore.of(context).loggedInUser.email}*$timestamp';

    groupOfferDataModel.startDate = OfferDurationWidgetState.starttimestamp;
    groupOfferDataModel.endDate = OfferDurationWidgetState.endtimestamp;

    return OfferModel(
      id: id,
      email: SevaCore.of(context).loggedInUser.email,
      fullName: SevaCore.of(context).loggedInUser.fullname,
      sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      timebankId: widget.timebankId,
      selectedAdrress: selectedAddress,
      timestamp: timestamp,
      location:
          location == null ? GeoFirePoint(40.754387, -73.984291) : location,
      groupOfferDataModel: groupOfferDataModel,
      individualOfferDataModel: IndividualOfferDataModel(),
      offerType: OfferType.GROUP_OFFER,
    );
  }

  bool isClassStartDateSelected() {
    if (OfferDurationWidgetState.starttimestamp == 0) {
      showDialogForDate(dialogTitle: "Please mention the start and end date");
      return false;
    }
    return true;
  }
}
