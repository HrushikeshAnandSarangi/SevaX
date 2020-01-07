import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/community/constants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class CreateEditCommunityView extends StatelessWidget {
  final String timebankId;

  CreateEditCommunityView({@required this.timebankId});

  @override
  Widget build(BuildContext context) {
    var title = 'Create your Community';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.5,
        backgroundColor: Color(0xFFFFFFFF),
        leading: BackButton(color: Colors.black54),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.black54, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: CreateEditCommunityViewForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class CreateEditCommunityViewForm extends StatefulWidget {
  final String timebankId;

  CreateEditCommunityViewForm({@required this.timebankId});

  @override
  CreateEditCommunityViewFormState createState() {
    return CreateEditCommunityViewFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class CreateEditCommunityViewFormState
    extends State<CreateEditCommunityViewForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  TimebankModel timebankModel = TimebankModel({});
  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress = '';

  var scollContainer = ScrollController();
  PanelController _pc = new PanelController();
  BillingDetailsModel billingDetails = BillingDetailsModel();
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  GlobalKey<FormState> _stateSelectorKey = GlobalKey();

  String selectedCountryValue = "Select your country";

  var stateFocus = FocusNode();
  var pincodeFocus = FocusNode();
  var companyNameFocus = FocusNode();
  var streetAddressFocus = FocusNode();
  var additionalNotesFocus = FocusNode();
  var streetAddressTwoFocus = FocusNode();

  var scrollIsOpen = false;

  void initState() {
    super.initState();

    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();
    if (FlavorConfig.appFlavor == Flavor.APP) {
      fetchCurrentlocation();
    }
  }

  HashMap<String, UserModel> selectedUsers = HashMap();

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: 0,
      maxHeight: 400,
      color: Colors.white,
      parallaxEnabled: true,
      backdropEnabled: true,
      controller: _pc,
      panel: _scrollingList(),
      body: Form(
        key: _formKey,
        child: createSevaX,
      ),
    );
  }

  Widget get createSevaX {
    var colums = StreamBuilder(
        stream: createEditCommunityBloc.createEditCommunity,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if ((selectedAddress.length > 0 &&
                    snapshot.data.timebank.address.length == 0) ||
                (snapshot.data.timebank.address != selectedAddress)) {
              print('location updated');
              snapshot.data.timebank
                  .updateValueByKey('address', selectedAddress);
              createEditCommunityBloc.onChange(snapshot.data);
            }
            return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Community is where you can collaborate with your organization',
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
                    ),
                  ),
                  headingText('Name your Community'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Ex: Pets-in-town, Citizen collab",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    initialValue: snapshot.data.community.name,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Community name cannot be empty';
                      } else {
                        snapshot.data.community.updateValueByKey('name', value);
                        createEditCommunityBloc.onChange(snapshot.data);
                      }
                      return "";
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
                        return 'Tell us more about your community.';
                      }
                      snapshot.data.timebank.updateValueByKey('about', value);
                      createEditCommunityBloc.onChange(snapshot.data);
                      return "";
                    },
                  ),
                  Row(
                    children: <Widget>[
                      headingText('Private team'),
                      Column(
                        children: <Widget>[
                          Divider(),
                          Checkbox(
                            value: snapshot.data.timebank.protected,
                            onChanged: (bool value) {
                              print(value);
                              snapshot.data.timebank
                                  .updateValueByKey('protected', value);
                              createEditCommunityBloc.onChange(snapshot.data);
                              return "";
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
                  headingText('Where is your community located at?'),
                  Center(
                    child: FlatButton.icon(
                      icon: Icon(Icons.add_location),
                      label: Text(
                        (snapshot.data.timebank.address == null ||
                                    snapshot.data.timebank.address.isEmpty) &&
                                selectedAddress == ''
                            ? 'Add Location'
                            : snapshot.data.timebank.address,
                      ),
                      color: Colors.grey[200],
                      onPressed: () {
                        print("Location opened : $location");
                        Navigator.push(
                          context,
                          MaterialPageRoute<GeoFirePoint>(
                            builder: (context) => LocationPicker(
                              selectedLocation: location,
                            ),
                          ),
                        ).then((point) {
                          if (point != null) {
                            location = snapshot.data.timebank.location = point;
                            print(
                                "Locatyion is iAKSDbkjwdsc:(${location.latitude},${location.longitude})");
                          }
                          _getLocation(snapshot.data);
                          print(
                              'ReceivedLocation: $snapshot.data.timebank.address');
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
                            future:
                                getTimeBankForId(timebankId: widget.timebankId),
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
//                                _writeToDB();
                                    // return;
//
//                                if (parentTimebank.children == null)
//                                  parentTimebank.children = [];
//                                parentTimebank.children.add(timebankModel.id);
//                                updateTimebank(timebankModel: parentTimebank);
                                    Navigator.pop(context);
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)),
                                child: Text(
                                  'Create Community',
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                                textColor: Colors.blue,
                              );
                            })),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                      ))
                ]));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Text("");
        });
    var contain = Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: colums,
    );
    return SingleChildScrollView(
      child: contain,
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
    return GestureDetector(
      onTap: () {
        _pc.open();
        scrollIsOpen = true;
      },
      child: Container(
        width: double.infinity,
        height: 20,
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
      ),
    );
  }

  Widget get tappableFindYourTeam {
    return GestureDetector(
      onTap: () {},
      child: Text(
        'Find your team',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future _getLocation(data) async {
    print('Timebank value:$data');
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );
//    setState(() {
//      this.selectedAddress = address;
//    });
//    timebank.updateValueByKey('locationAddress', address);
    print('_getLocation: $address');
    data.timebank.updateValueByKey('address', address);
    createEditCommunityBloc.onChange(data);
  }

  void fetchCurrentlocation() {
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

  Widget get _widgetCountrySelector {
    // var countryList = CommunityConstants.COUNTRY_LIST;
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: Colors.green,
          style: BorderStyle.solid,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.fromLTRB(12, 12, 10, 5),
      alignment: Alignment.center,
      width: double.infinity,
      child: new DropdownButton<String>(
        key: _stateSelectorKey,
        items: CommunityConstants.COUNTRY_LIST.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        // isExpanded: true,
        // validator: (val) {
        //   // return "lkaknnsndlkns";
        //   // return billingDetails.countryName == "Select your country"
        //   //     // ? "Please select your country"
        //   //     ? "null"
        //   //     : "null";
        // },
        hint: Text(selectedCountryValue),
        onChanged: (value) {
          selectedCountryValue = value;
          billingDetails.countryName = value;
          setState(() {
            print(selectedCountryValue);
          });
        },
      ),
    );
  }

  Widget get _stateWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(pincodeFocus);
        },
        onChanged: (value) {
          billingDetails.stateName = value;
        },
        initialValue:
            billingDetails.stateName != null ? billingDetails.stateName : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: stateFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "State",
        ),
      ),
    );
  }

  Widget get _pinCodeWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
          validator: BillingDetailsModel.billingValidator,
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(streetAddressFocus);
          },
          onChanged: (value) {
            billingDetails.pinCode = value;
          },
          initialValue:
              billingDetails.pinCode != null ? billingDetails.pinCode : '',
          focusNode: pincodeFocus,
          textInputAction: TextInputAction.next,
          decoration: BillingDetailsModel.getInputDecoration(
            fieldTitle: "Pincode",
          )),
    );
  }

  Widget get _additionalNotesWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          scrollToBottom();
        },
        onChanged: (value) {
          billingDetails.additionalNotes = value;
        },
        initialValue: billingDetails.additionalNotes != null
            ? billingDetails.additionalNotes
            : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: additionalNotesFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Additional Notes",
        ),
      ),
    );
  }

  InputDecoration getData(String fieldValue) {
    return new InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 5.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      border: OutlineInputBorder(
        gapPadding: 0.0,
        borderRadius: BorderRadius.circular(1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      hintText: fieldValue,
      alignLabelWithHint: false,
    );
  }

  Widget get _companyNameWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(additionalNotesFocus);
        },
        onChanged: (value) {
          billingDetails.companyName = value;
        },
        initialValue: billingDetails.companyName != null
            ? billingDetails.companyName
            : '',
        validator: BillingDetailsModel.billingValidator,
        focusNode: companyNameFocus,
        textInputAction: TextInputAction.next,
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Company Name",
        ),
      ),
    );
  }

  Widget get _billingDetailsTitle {
    return Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(''),
                Text(
                  'Billing Details',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(''),
                GestureDetector(
                  onTap: () {
                    _pc.close();
                  },
                  child: Text(
                    ''' x ''',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget get _streetAddressWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        onFieldSubmitted: (input) {
          FocusScope.of(context).requestFocus(streetAddressTwoFocus);
        },
        onChanged: (value) {
          billingDetails.streetAddressOne = value;
        },
        validator: BillingDetailsModel.billingValidator,
        focusNode: streetAddressFocus,
        textInputAction: TextInputAction.next,
        initialValue: billingDetails.streetAddressOne != null
            ? billingDetails.streetAddressOne
            : '',
        decoration: BillingDetailsModel.getInputDecoration(
          fieldTitle: "Street Address 1",
        ),
      ),
    );
  }

  Widget get _streetAddressTwoWidget {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(companyNameFocus);
          },
          onChanged: (value) {
            billingDetails.streetAddressTwo = value;
          },
          validator: BillingDetailsModel.billingValidator,
          focusNode: streetAddressTwoFocus,
          textInputAction: TextInputAction.next,
          initialValue: billingDetails.streetAddressTwo != null
              ? billingDetails.streetAddressTwo
              : '',
          decoration: BillingDetailsModel.getInputDecoration(
            fieldTitle: "Street Address 2",
          )),
    );
  }

  Widget get _continueBtn {
    return Container(
      margin: EdgeInsets.all(10),
      child: RaisedButton(
        child: Text("Continue"),
        color: Colors.orange,
        onPressed: () {
          if (_billingInformationKey.currentState.validate()) {
            if (billingDetails.countryName == null) {
              scrollToTop();
            } else {
              print("All Good");
              _pc.close();
              scrollIsOpen = false;
            }
          }
          print("Here are the billing details $billingDetails");
        },
      ),
    );
  }

  Widget _scrollingList() {
    return Container(
        // var scrollController = Sc
        //adding a margin to the top leaves an area where the user can swipe
        //to open/close the sliding panel
        margin: const EdgeInsets.only(top: 36.0),
        color: Colors.white,
        child: Form(
          key: _billingInformationKey,
          child: ListView(
            controller: scollContainer,
            children: <Widget>[
              _billingDetailsTitle,
              _stateWidget,
              _pinCodeWidget,
              _streetAddressWidget,
              _streetAddressTwoWidget,
              _companyNameWidget,
              _additionalNotesWidget,
              _continueBtn,
            ],
          ),
        ));
  }

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class BillingDetailsModel {
  String countryName;
  String stateName;
  String pinCode;
  String streetAddressOne;
  String streetAddressTwo;
  String companyName;
  String additionalNotes;

  @override
  String toString() {
    return "Billing information provided : {countryName : $countryName, stateName : $stateName, pincode : $pinCode, streetAddressOne : $streetAddressOne, streetAddressTwo : $streetAddressTwo, companyName  : $companyName, additionalNotes : $additionalNotes }";
  }

  static String billingValidator(String value) {
    return value.isEmpty ? 'Field cannot be left blank' : null;
  }

  static InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
      ),
      border: OutlineInputBorder(
          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
      ),
      hintText: fieldTitle,
      alignLabelWithHint: false,
    );
  }
}
