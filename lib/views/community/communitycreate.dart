import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_page_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CreateEditCommunityView extends StatelessWidget {
  final String timebankId;

  CreateEditCommunityView({@required this.timebankId});

  @override
  Widget build(BuildContext context) {
    var title = 'Create your community';
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
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

  final TextEditingController searchTextController =
  new TextEditingController();





  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  TimebankModel timebankModel = TimebankModel({});
  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress = '';
  String _billingDetailsError = '';
  String communityImageError = '';
  String enteredName ='';

  var scollContainer = ScrollController();
  PanelController _pc = new PanelController();
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  GlobalKey<FormState> _stateSelectorKey = GlobalKey();

  String selectedCountryValue = "Select your country";

  var scrollIsOpen = false;
  var communityFound = false;


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
            print(snapshot.data.timebank.address);
            if ((selectedAddress.length > 0 &&
                    snapshot.data.timebank.address.length == 0) ||
                (snapshot.data.timebank.address != selectedAddress)) {
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
                            'Community Logo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(communityImageError,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 12,
                              ))
                        ],
                      ),
                    ),
                  ),
                  headingText('Name your Community'),
                  TextFormField(
                    onChanged: (value){
                      enteredName=value;
                    },
                    decoration: InputDecoration(
                      hintText: "Ex: Pets-in-town, Citizen collab",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    initialValue: snapshot.data.community.name??'',
                   onSaved: (value) => enteredName=value,
                   validator: (value) {
                      if (value.isEmpty ) {
                        return 'Community name cannot be empty';
                     } else if(communityFound){
                        return 'Community name already exist';
                     }
                      else {
                        enteredName = value;
                        snapshot.data.community.updateValueByKey('name', value);
                        createEditCommunityBloc.onChange(snapshot.data);
                      }

                     return null;
                    },
                  ),

                  headingText('About'),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Ex: A bit more about your community',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    initialValue: snapshot.data.timebank.missionStatement,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Tell us more about your community.';
                      }
                      snapshot.data.timebank
                          .updateValueByKey('missionStatement', value);
                      createEditCommunityBloc.onChange(snapshot.data);
                      return null;
                    },
                  ),
                  Row(
                    children: <Widget>[
                      headingText('Private community'),
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
                    'With private community, new members needs yor approval to join community',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  headingText('Your community location.'),
                  Text(
                    'Community location will help your members to locate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
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
                                "Locatsion is iAKSDbkjwdsc:(${location.latitude},${location.longitude})");
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
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Looking for existing community',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          tappableFindYourTeam,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        alignment: Alignment.center,
                        child: RaisedButton(
                          onPressed: () async {

                            print(_formKey.currentState.validate());

                            if (_formKey.currentState.validate()) {
                              if (_billingInformationKey.currentState
                                  .validate()) {
                                setState(() {
                                  this._billingDetailsError = '';
                                });
                                print(globals.timebankAvatarURL);
                                if (globals.timebankAvatarURL == null) {
                                  setState(() {
                                    this.communityImageError =
                                        'Community logo is mandatory';
                                  });
                                } else {
                                  setState(() {
                                    this.communityImageError = '';
                                  });
                                  communityFound = await isCommunityFound(enteredName);
                                  if(communityFound){
                                    print("Found:$communityFound");
                                    return;
                                  }
                                  // creation of community;
                                  snapshot.data.UpdateCommunityDetails(
                                    SevaCore.of(context).loggedInUser,
                                    globals.timebankAvatarURL,
                                  );
                                  // creation of default timebank;
                                  snapshot.data.UpdateTimebankDetails(
                                    SevaCore.of(context).loggedInUser,
                                    globals.timebankAvatarURL,
                                    widget,
                                  );
                                  // updating the community with default timebank id
                                  snapshot.data.community.timebanks = [
                                    snapshot.data.timebank.id
                                  ].cast<String>();

                                  snapshot.data.community.primary_timebank =
                                      snapshot.data.timebank.id;

                                  createEditCommunityBloc.createCommunity(
                                    snapshot.data,
                                    SevaCore.of(context).loggedInUser,
                                  );

                                  await Firestore.instance
                                      .collection("users")
                                      .document(SevaCore.of(context)
                                          .loggedInUser
                                          .email)
                                      .updateData({
                                    'communities': FieldValue.arrayUnion([
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .sevaUserID
                                    ]),
                                    'currentCommunity':
                                        snapshot.data.community.id
                                  });

                                  setState(() {
                                    SevaCore.of(context)
                                            .loggedInUser
                                            .currentCommunity =
                                        snapshot.data.community.id;
                                  });

                                  // Navigator.of(context).pushReplacement(
                                  //   MaterialPageRoute(
                                  //     builder: (context1) => SevaCore(
                                  //       loggedInUser:
                                  //           SevaCore.of(context).loggedInUser,
                                  //       child: HomePageRouter(
                                  //           // sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
                                  //           ),
                                  //     ),
                                  //   ),
                                  // );

                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context1) => SevaCore(
                                          loggedInUser:
                                              SevaCore.of(context).loggedInUser,
                                          child: HomePageRouter(),
                                        ),
                                      ),
                                      (Route<dynamic> route) => false);
                                }
                              } else {
                                setState(() {
                                  this._billingDetailsError =
                                      'Please configure your billing details';
                                });
                              }
                            } else {}
                          },
                          shape: StadiumBorder(),
                          child: Text(
                            'Create Community',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                          textColor: FlavorConfig.values.buttonTextColor,
                        )),
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
          margin: EdgeInsets.only(top: 20),
          width: double.infinity,
          height: 50,
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Configure billing details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                Divider(),
                Text(
                  '+',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _billingDetailsError,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ])),
    );
  }

  Widget get tappableFindYourTeam {
    return GestureDetector(
      onTap: () {},
      child: Text(
        ' Find your community',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
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
    setState(() {
      this.selectedAddress = address;
    });
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

  Widget _scrollingList() {
    var stateFocus = FocusNode();
    var pincodeFocus = FocusNode();
    var companyNameFocus = FocusNode();
    var streetAddressFocus = FocusNode();
    var additionalNotesFocus = FocusNode();
    var streetAddressTwoFocus = FocusNode();
    Widget _stateWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(pincodeFocus);
          },
          onChanged: (value) {
            print(controller.community.billing_address);
            controller.community.billing_address
                .updateValueByKey('state', value);
            createEditCommunityBloc.onChange(controller);
          },
          initialValue: controller.community.billing_address.state != null
              ? controller.community.billing_address.state
              : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: stateFocus,
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "State",
          ),
        ),
      );
    }

    Widget _pinCodeWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(streetAddressFocus);
          },
          onChanged: (value) {
            print(value);
            controller.community.billing_address
                .updateValueByKey('pincode', int.parse(value));
            createEditCommunityBloc.onChange(controller);
          },
          initialValue: controller.community.billing_address.pincode != null
              ? controller.community.billing_address.pincode.toString()
              : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: pincodeFocus,
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Pincode",
          ),
        ),
      );
    }

    Widget _additionalNotesWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            scrollToBottom();
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('additionalnotes', value);
            createEditCommunityBloc.onChange(controller);
          },
          initialValue:
              controller.community.billing_address.additionalnotes != null
                  ? controller.community.billing_address.additionalnotes
                  : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: additionalNotesFocus,
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Additional Notes",
          ),
        ),
      );
    }

    Widget _streetAddressWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(streetAddressTwoFocus);
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('street_address1', value);
            createEditCommunityBloc.onChange(controller);
          },
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: streetAddressFocus,
          textInputAction: TextInputAction.next,
          initialValue:
              controller.community.billing_address.street_address1 != null
                  ? controller.community.billing_address.street_address1
                  : '',
          decoration: getInputDecoration(
            fieldTitle: "Street Address 1",
          ),
        ),
      );
    }

    Widget _streetAddressTwoWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
            onFieldSubmitted: (input) {
              FocusScope.of(context).requestFocus(companyNameFocus);
            },
            onChanged: (value) {
              controller.community.billing_address
                  .updateValueByKey('street_address2', value);
              createEditCommunityBloc.onChange(controller);
            },
            validator: (value) {
              return value.isEmpty ? 'Field cannot be left blank' : null;
            },
            focusNode: streetAddressTwoFocus,
            textInputAction: TextInputAction.next,
            initialValue:
                controller.community.billing_address.street_address2 != null
                    ? controller.community.billing_address.street_address2
                    : '',
            decoration: getInputDecoration(
              fieldTitle: "Street Address 2",
            )),
      );
    }

    Widget _companyNameWidget(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(additionalNotesFocus);
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('companyname', value);
            createEditCommunityBloc.onChange(controller);
          },
          initialValue: controller.community.billing_address.companyname != null
              ? controller.community.billing_address.companyname
              : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: companyNameFocus,
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Company Name",
          ),
        ),
      );
    }

    Widget _continueBtn(controller) {
      return Container(
        margin: EdgeInsets.all(10),
        child: RaisedButton(
          child: Text("Continue"),
          color: Colors.orange,
          onPressed: () {
            if (_billingInformationKey.currentState.validate()) {
              if (controller.community.billing_address.country == null) {
                scrollToTop();
              } else {
                print("All Good");
                _pc.close();
                scrollIsOpen = false;
              }
            }
          },
        ),
      );
    }

    return Container(
        // var scrollController = Sc
        //adding a margin to the top leaves an area where the user can swipe
        //to open/close the sliding panel
        margin: const EdgeInsets.only(top: 36.0),
        color: Colors.white,
        child: Form(
            key: _billingInformationKey,
            child: StreamBuilder(
                stream: createEditCommunityBloc.createEditCommunity,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      controller: scollContainer,
                      children: <Widget>[
                        _billingDetailsTitle,
                        _stateWidget(snapshot.data),
                        _pinCodeWidget(snapshot.data),
                        _streetAddressWidget(snapshot.data),
                        _streetAddressTwoWidget(snapshot.data),
                        _companyNameWidget(snapshot.data),
                        _additionalNotesWidget(snapshot.data),
                        _continueBtn(snapshot.data),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Text("");
                })));
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

  Future<bool> isCommunityFound(String enteredName) async{
    //ommunityBloc.fetchCommunities(enteredName);
    CommunityListModel communities=CommunityListModel();
    var communitiesFound = await searchCommunityByName(enteredName,communities);
    if(communitiesFound==null||communitiesFound.communities==null || communitiesFound.communities.length==0){
      return false;
    }else{
      return true;
    }

  }
  Future<CommunityListModel> searchCommunityByName(String name,CommunityListModel communities) async {
    communities.removeall();
    if (name.isNotEmpty && name.length > 4) {
      await Firestore.instance
          .collection('communities')
          .where('name', isEqualTo: name)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
          var community = CommunityModel(documentSnapshot.data);
          print("community data ${community.name}");

          communities.add(community);
        });
      });
    }
    return communities;
  }
}

