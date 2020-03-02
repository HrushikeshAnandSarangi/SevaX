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
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CreateEditCommunityView extends StatelessWidget {
  final String timebankId;
  final bool isFromFind;
  final bool isCreateTimebank;

  CreateEditCommunityView({
    @required this.timebankId,
    this.isFromFind,
    this.isCreateTimebank,
  });

  @override
  Widget build(BuildContext context) {
    var title = 'Create a Timebank';
    return Scaffold(
      appBar: isCreateTimebank
          ? AppBar(
              elevation: 0.5,
              automaticallyImplyLeading: true,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : null,
      body: CreateEditCommunityViewForm(
        timebankId: timebankId,
        isFromFind: isFromFind,
        isCreateTimebank: isCreateTimebank,
      ),
    );
  }
}

// Create a Form Widget
class CreateEditCommunityViewForm extends StatefulWidget {
  final String timebankId;
  final bool isFromFind;
  final bool isCreateTimebank;

  CreateEditCommunityViewForm(
      {@required this.timebankId, this.isFromFind, this.isCreateTimebank});

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

  CommunityModel communityModel = CommunityModel({});
  CommunityModel editCommunityModel = CommunityModel({});
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchTextController = new TextEditingController();
  TimebankModel timebankModel = TimebankModel({});
  TimebankModel editTimebankModel = TimebankModel({});
  String memberAssignment = "+ Add Members";
  List members = [];

  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress = '';
  String _billingDetailsError = '';
  String communityImageError = '';
  String enteredName = '';

  var scollContainer = ScrollController();
  PanelController _pc = new PanelController();
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  // GlobalKey<FormState> _stateSelectorKey = GlobalKey();

  String selectedCountryValue = "Select your country";

  var scrollIsOpen = false;
  var communityFound = false;
  List<FocusNode> focusNodes;
  String errTxt;
  int totalMembersCount = 0;

  void initState() {
    super.initState();
    var _searchText = "";
    Future.delayed(Duration.zero, () {
      createEditCommunityBloc.getChildTimeBanks(context);
    });
    if (widget.isCreateTimebank == false) {
      getModelData();
    }
    final _textUpdates = StreamController<String>();

    focusNodes = List.generate(6, (_) => FocusNode());
    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();
    if (FlavorConfig.appFlavor == Flavor.APP) {
      fetchCurrentlocation();
    }

    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));

    // print('nsdjfjsdf ${widget.loggedInUser.toString()}');
    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        SearchManager.searchCommunityForDuplicate(queryString: s).then((v) {
          if (v) {
            setState(() {
              communityFound = true;
              errTxt = 'Timebank name already exist';
            });
          } else {
            setState(() {
              communityFound = false;
              errTxt = null;
            });
          }
        });
      }
    });
  }

  void getModelData() async {
    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: SevaCore.of(context).loggedInUser.currentCommunity)
          .then((onValue) {
        communityModel = onValue;
        searchTextController.text = communityModel.name;
      });
    });

    timebankModel =
        await FirestoreManager.getTimeBankForId(timebankId: widget.timebankId);

    totalMembersCount = await FirestoreManager.getMembersCountOfAllMembers(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity);
//    setState(() {
//      searchTextController =
//          new TextEditingController(text: communityModel.name);
//
//      //  searchTextController.text = communityModel.name;
//    });
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
      panel: _scrollingList(focusNodes),
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
          if (snapshot.hasData && snapshot.data != null) {
            print(snapshot.data.timebank.address);
            if ((selectedAddress.length > 0 &&
                    snapshot.data.timebank.address.length == 0) ||
                (snapshot.data.timebank.address != selectedAddress)) {
              snapshot.data.timebank
                  .updateValueByKey('address', selectedAddress);
              createEditCommunityBloc.onChange(snapshot.data);
            }
            print("  snapshots data   ${snapshot.data.timebanks}");

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Timebank is where you can collaborate with your organization',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          widget.isCreateTimebank
                              ? TimebankAvatar()
                              : TimebankAvatar(
                                  photoUrl: communityModel.logo_url,
                                ),
                          Text(''),
                          Text(
                            'Timebank Logo',
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
                  headingText('Name your timebank'),
                  TextFormField(
                    controller: searchTextController,
                    onChanged: (value) {
                      enteredName = value;
                      print("name ------ $value");
                      communityModel.name = value;
                      timebankModel.name = value;
                    },
                    decoration: InputDecoration(
                      errorText: errTxt,
                      hintText: "Ex: Pets-in-town, Citizen collab",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    //initialValue: snapshot.data.community.name ?? '',

                    onSaved: (value) {
                      enteredName = value;
                    },
                    // onSaved: (value) => enteredName = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Timebank name cannot be empty';
                      } else if (communityFound) {
                        return 'Timebank name already exist';
                      } else {
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
                      hintText: 'Ex: A bit more about your timebank',
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    initialValue: timebankModel.missionStatement,
                    onChanged: (value) {
                      timebankModel.missionStatement = value;
                      communityModel.about = value;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Tell us more about your timebank.';
                      }
                      snapshot.data.community.updateValueByKey('about', value);

                      snapshot.data.timebank
                          .updateValueByKey('missionStatement', value);
                      createEditCommunityBloc.onChange(snapshot.data);
                      return null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),

                  Offstage(
                    offstage: widget.isCreateTimebank,
                    child: Row(
                      children: <Widget>[
                        headingText('Timebank Members'),
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          child: IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                            ),
                            onPressed: () {
                              addVolunteers();
                              print("clicked");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: widget.isCreateTimebank,
                    child: Row(
                      children: <Widget>[
                        Text(
                          totalMembersCount.toString() ?? "0",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa'),
                        ),
                        FlatButton(
                          onPressed: () {
                            print("clicked");
                          },
                          child: Text(
                            "manage",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Europa',
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      headingText('Protected Timebank'),
                      Column(
                        children: <Widget>[
                          Divider(),
                          Checkbox(
                            value: widget.isCreateTimebank
                                ? snapshot.data.timebank.protected
                                : timebankModel.protected,
                            onChanged: (bool value) {
                              print(value);
                              timebankModel.protected = value;
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
                    'With protected timebank, user to user transactions are disabled.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  headingText('Your timebank location.'),
                  Text(
                    'Timebank location will help your members to locate',
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
                      label: Container(
                        child: Text(
                          (snapshot.data.timebank.address == null ||
                                      snapshot.data.timebank.address.isEmpty) &&
                                  selectedAddress == ''
                              ? 'Add Location'
                              : snapshot.data.timebank.address,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      color: Colors.grey[200],
                      onPressed: () async {
                        print("Location opened : $location");
                        await Navigator.push(
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
                  widget.isCreateTimebank
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: tappableAddBillingDetails,
                        )
                      : Container(),
//                  Offstage(
//                    offstage: !widget.isCreateTimebank,
//                    child: Padding(
//                      padding: const EdgeInsets.symmetric(vertical: 10.0),
//                      child: tappableAddBillingDetails,
//                    ),
//                  ),
                  widget.isCreateTimebank
                      ? Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Looking for existing timebank',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                tappableFindYourTeam,
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        onPressed: () async {
                          // show a dialog
                          if (widget.isCreateTimebank) {
                            print(_formKey.currentState.validate());

//                            communityFound =
//                                await isCommunityFound(enteredName);
//                            if (communityFound) {
//                              print("Found:$communityFound");
//                              return;
//                            }
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
                                        'Timebank logo is mandatory';
                                  });
                                } else {
                                  showProgressDialog('Creating timebank');

                                  setState(() {
                                    this.communityImageError = '';
                                  });

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
                                    'communities': FieldValue.arrayUnion(
                                        [snapshot.data.community.id]),
                                    'currentCommunity':
                                        snapshot.data.community.id
                                  });

                                  setState(() {
                                    SevaCore.of(context)
                                            .loggedInUser
                                            .currentCommunity =
                                        snapshot.data.community.id;
                                  });

                                  Navigator.pop(dialogContext);
                                  _formKey.currentState.reset();
                                  _billingInformationKey.currentState.reset();
                                  UserModel user =
                                      SevaCore.of(context).loggedInUser;
                                  Navigator.pop(dialogContext);
                                  _formKey.currentState.reset();
                                  _billingInformationKey.currentState.reset();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BillingPlanDetails(user: user),
                                    ),
                                  );
                                  //Navigator.of(context).pushAndRemoveUntil(
                                  //    MaterialPageRoute(
                                  //      builder: (context1) => MainApplication(
                                  //        skipToHomePage: true,
                                  //      ),
                                  //    ),
                                  //    (Route<dynamic> route) => false);
                                }
                              } else {
                                setState(() {
                                  this._billingDetailsError =
                                      'Please configure your billing details';
                                });
                              }
                            } else {}
                          } else {
                            showProgressDialog('Updating timebank');
                            if (globals.timebankAvatarURL != null) {
                              communityModel.logo_url =
                                  globals.timebankAvatarURL;
                              timebankModel.photoUrl =
                                  globals.timebankAvatarURL;
                            }

//                            print("comm ${communityModel}");
//
//                            print("time add${timebankModel.address}");
                            timebankModel.location = location;
                            if (selectedUsers != null) {
                              selectedUsers.forEach((key, user) {
                                print("Selected member with key $key");
                                if (timebankModel.members
                                    .contains(user.sevaUserID)) {
                                  selectedUsers.remove(user);
                                }
                              });
                              selectedUsers.forEach((key, user) {
                                print("Selected member with key $key");

                                members.add(user.sevaUserID);
                              });
                            }

                            print("time ${timebankModel.photoUrl}");
                            print("time ${communityModel.logo_url}");
                            // creation of community;

                            // updating timebank with latest values
                            await FirestoreManager.updateTimebankDetails(
                                    timebankModel: timebankModel,
                                    members: members)
                                .then((onValue) {
                              print("timebank updated");
                            });

//                            //updating community with latest values
                            await FirestoreManager.updateCommunityDetails(
                                    communityModel: communityModel)
                                .then((onValue) {
                              print("community updated");
                            });
//
//
//
                            if (dialogContext != null) {
                              Navigator.pop(dialogContext);
                            }
                            _formKey.currentState.reset();
                            Navigator.of(context).pop();
                          }
                        },
                        shape: StadiumBorder(),
                        child: Text(
                          widget.isCreateTimebank
                              ? 'Create a Timebank'
                              : 'Save',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        textColor: FlavorConfig.values.buttonTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            );
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

  BuildContext dialogContext;

  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
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
        FocusScope.of(context).requestFocus(new FocusNode());
        _pc.open();
        scrollIsOpen = true;
      },
      child: Container(
          margin: EdgeInsets.only(top: 20),
          width: double.infinity,
          height: 50,
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Configure billing details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
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
              mainAxisAlignment: MainAxisAlignment.center,
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
      onTap: () {
        if (widget.isFromFind) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return FindCommunitiesView(
                  keepOnBackPress: true,
                  loggedInUser: SevaCore.of(context).loggedInUser,
                  showBackBtn: true,
                );
              },
            ),
          );
        }
      },
      child: Text(
        ' Find your Timebank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          decoration: TextDecoration.underline,
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
    timebankModel.address = address;
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
//        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'Billing Details',
                  style: TextStyle(
                      color: FlavorConfig.values.theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _pc.close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      ''' x ''',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
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
//      focusedBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
//      ),
//      border: OutlineInputBorder(
//          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
//      enabledBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.green, width: 1.0),
//      ),
      hintText: fieldTitle,
      alignLabelWithHint: false,
    );
  }

  Widget _scrollingList(List<FocusNode> focusNodes) {
    print(focusNodes);
    Widget _stateWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
          onChanged: (value) {
            print(controller.community.billing_address);
            controller.community.billing_address
                .updateValueByKey('state', value);
            createEditCommunityBloc.onChange(controller);
          },
//          initialValue: controller.community.billing_address.state != null
//              ? controller.community.billing_address.state
//              : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: focusNodes[0],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "State",
          ),
        ),
      );
    }

    Widget _pinCodeWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[2]);
          },
          onChanged: (value) {
            print(value);
            controller.community.billing_address
                .updateValueByKey('pincode', int.parse(value));
            createEditCommunityBloc.onChange(controller);
          },
//          initialValue: controller.community.billing_address.pincode != null
//              ? controller.community.billing_address.pincode.toString()
//              : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: focusNodes[1],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 15,
          decoration: getInputDecoration(
            fieldTitle: "ZIP Code",
          ),
        ),
      );
    }

    Widget _additionalNotesWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            scrollToBottom();
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('additionalnotes', value);
            createEditCommunityBloc.onChange(controller);
          },
//          initialValue:
//              controller.community.billing_address.additionalnotes != null
//                  ? controller.community.billing_address.additionalnotes
//                  : '',
//          validator: (value) {
//            return value.isEmpty ? 'Field cannot be left blank' : null;
//          },
          // onSaved: (value) {

          // },
          focusNode: focusNodes[5],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Additional Notes",
          ),
        ),
      );
    }

    Widget _streetAddressWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[3]);
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('street_address1', value);
            createEditCommunityBloc.onChange(controller);
          },
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank' : null;
          },
          focusNode: focusNodes[2],
          textInputAction: TextInputAction.next,
//          initialValue:
//              controller.community.billing_address.street_address1 != null
//                  ? controller.community.billing_address.street_address1
//                  : '',
          decoration: getInputDecoration(
            fieldTitle: "Street Address 1",
          ),
        ),
      );
    }

    Widget _streetAddressTwoWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
            onFieldSubmitted: (input) {
              FocusScope.of(context).requestFocus(focusNodes[4]);
            },
            onChanged: (value) {
              controller.community.billing_address
                  .updateValueByKey('street_address2', value);
              createEditCommunityBloc.onChange(controller);
            },
            focusNode: focusNodes[3],
            textInputAction: TextInputAction.next,
//            initialValue:
//                controller.community.billing_address.street_address2 != null
//                    ? controller.community.billing_address.street_address2
//                    : '',
            decoration: getInputDecoration(
              fieldTitle: "Street Address 2",
            )),
      );
    }

    Widget _companyNameWidget(controller) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(context).requestFocus(focusNodes[5]);
          },
          onChanged: (value) {
            controller.community.billing_address
                .updateValueByKey('companyname', value);
            createEditCommunityBloc.onChange(controller);
          },
//          initialValue: controller.community.billing_address.companyname != null
//              ? controller.community.billing_address.companyname
//              : '',
          // validator: (value) {
          //   return value.isEmpty ? 'Field cannot be left blank' : null;
          // },
          focusNode: focusNodes[4],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Company Name",
          ),
        ),
      );
    }

    Widget _continueBtn(controller) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
        child: RaisedButton(
          child: Text(
            "Continue",
            style: Theme.of(context).primaryTextTheme.button,
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
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
        margin: const EdgeInsets.only(top: 15.0),
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

  Future<bool> isCommunityFound(String enteredName) async {
    List<CommunityModel> communities = List<CommunityModel>();
    var communitiesFound =
        await searchCommunityByName(enteredName, communities);

    if (communities == null || communities == null || communities.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<List<CommunityModel>> searchCommunityByName(
      String name, List<CommunityModel> communities) async {
    communities.clear();
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

  void addVolunteers() async {
    print(
        " Selected users before ${selectedUsers.length} with timebank id as ${SevaCore.of(context).loggedInUser.currentTimebank}");

    onActivityResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectMembersInGroup(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          userSelected:
              selectedUsers == null ? selectedUsers = HashMap() : selectedUsers,
          userEmail: SevaCore.of(context).loggedInUser.email,
          listOfalreadyExistingMembers: [],
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
          memberAssignment = "${selectedUsers.length} volunteers selected";
      });
      print("Data is present Selected users ${selectedUsers.length}");
    } else {
      print("No users where selected");
      //no users where selected
    }
  }
}
