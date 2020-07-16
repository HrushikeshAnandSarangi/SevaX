import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class TimebankCreate extends StatelessWidget {
  final String timebankId;
  TimebankCreate({@required this.timebankId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        // leading: BackButton(color: Colors.black54),
        title: Text(
          // 'Create a ${FlavorConfig.values.timebankTitle}',
          AppLocalizations.of(context).translate('groups', 'create_group'),
          style: TextStyle(
            fontSize: 20,
          ),
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
  var groupFound = false;
  TimebankModel timebankModel = TimebankModel({});
  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress;
  TextEditingController searchTextController = new TextEditingController();
  String errTxt;
  final nameNode = FocusNode();
  final aboutNode = FocusNode();
  final _textUpdates = StreamController<String>();

  void initState() {
    super.initState();
    timebankModel.preventAccedentalDelete = true;
    var _searchText = "";
    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();
    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      fetchCurrentlocation();
    }
    // ignore: close_sinks
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
        SearchManager.searchGroupForDuplicate(
                queryString: s.trim(),
                communityId: SevaCore.of(context).loggedInUser.currentCommunity)
            .then((groupFound) {
          if (groupFound) {
            setState(() {
              errTxt =
                  AppLocalizations.of(context).translate('groups', 'exists');
            });
          } else {
            setState(() {
              groupFound = false;
              errTxt = null;
            });
          }
        });
      }
    });
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment;

  void _writeToDB() {
    // _checkTimebankName();
    // if (!_exists) {

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    List<String> members = [SevaCore.of(context).loggedInUser.sevaUserID];

    print("Final arrray $members");

    String id = Utils.getUuid();
    timebankModel.id = id;
    timebankModel.communityId =
        SevaCore.of(context).loggedInUser.currentCommunity;
    timebankModel.creatorId = SevaCore.of(context).loggedInUser.sevaUserID;
    timebankModel.photoUrl = globals.timebankAvatarURL;
    timebankModel.createdAt = timestamp;
    timebankModel.admins = [SevaCore.of(context).loggedInUser.sevaUserID];
    timebankModel.emailId = SevaCore.of(context).loggedInUser.email;
    timebankModel.coordinators = [];
    timebankModel.members = members;
    timebankModel.children = [];
    timebankModel.balance = 0;
    timebankModel.protected = false;
    timebankModel.parentTimebankId = widget.timebankId;
    timebankModel.rootTimebankId = FlavorConfig.values.timebankId;
    timebankModel.address = selectedAddress;
    timebankModel.location =
        location == null ? GeoFirePoint(40.754387, -73.984291) : location;

    createTimebank(timebankModel: timebankModel);

    Firestore.instance
        .collection("communities")
        .document(SevaCore.of(context).loggedInUser.currentCommunity)
        .updateData(
      {
        "timebanks": FieldValue.arrayUnion([id]),
      },
    );
    sendInviteNotification();
    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
  }

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    memberAssignment =
        "+ ${AppLocalizations.of(context).translate('groups', 'add_members')}";
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: SingleChildScrollView(child: FadeAnimation(1.4, createSevaX)),
      ),
    );
  }

  Widget get createSevaX {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          AppLocalizations.of(context).translate('groups', 'group_subset'),
          textAlign: TextAlign.center,
        ),
      ),
      Center(
          child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            TimebankAvatar(),
            SizedBox(height: 5),
            Text(
              AppLocalizations.of(context).translate('groups', 'logo'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            )
          ],
        ),
      )),
      headingText(
          AppLocalizations.of(context).translate('groups', 'name'), true),
      TextFormField(
        textCapitalization: TextCapitalization.sentences,
        focusNode: nameNode,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(aboutNode);
        },
        controller: searchTextController,
        onChanged: (value) {
          print("groupname ------ $value");
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorText: errTxt,
          hintText:
              AppLocalizations.of(context).translate('groups', 'name_group'),
        ),
        // keyboardType: TextInputType.multiline,
        // maxLines: 1,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
        ],
        validator: (value) {
          if (value.isEmpty) {
            return AppLocalizations.of(context)
                .translate('groups', 'please_enter');
          }
          timebankModel.name = value.trim();
        },
      ),
      headingText(
          AppLocalizations.of(context).translate('groups', 'about'), true),
      TextFormField(
        textCapitalization: TextCapitalization.sentences,

        focusNode: aboutNode,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate('groups', 'example'),
        ),
        // keyboardType: TextInputType.multiline,
        maxLines: 1,
        validator: (value) {
          if (value.isEmpty) {
            return AppLocalizations.of(context)
                .translate('groups', 'please_enter');
          }
          timebankModel.missionStatement = value;
        },
      ),
      Row(
        children: <Widget>[
          headingText(
              AppLocalizations.of(context).translate('groups', 'private_group'),
              false),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
            child: infoButton(
              context: context,
              key: GlobalKey(),
              type: InfoType.PRIVATE_GROUP,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
            child: Checkbox(
              value: timebankModel.private,
              onChanged: (bool value) {
                print(value);
                setState(() {
                  timebankModel.private = value;
                });
                print(timebankModel.private);
              },
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          headingText(
              AppLocalizations.of(context)
                  .translate('groups', 'prevent_delete'),
              false),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
            child: Checkbox(
              value: timebankModel.preventAccedentalDelete,
              onChanged: (bool value) {
                print(value);
                setState(() {
                  timebankModel.preventAccedentalDelete = value;
                });
                print(timebankModel.preventAccedentalDelete);
              },
            ),
          ),
        ],
      ),
      tappableInviteMembers,
      headingText(
          AppLocalizations.of(context).translate('groups', 'is_pin_right'),
          false),
      Center(
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
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
            alignment: Alignment.center,
            child: FutureBuilder<Object>(
                future: getTimeBankForId(timebankId: widget.timebankId),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Text(AppLocalizations.of(context)
                        .translate('chat', 'error2'));
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Offstage();
                  TimebankModel parentTimebank = snapshot.data;
                  return RaisedButton(
                    // color: Colors.blue,
                    onPressed: () {
                      if (errTxt != null || errTxt != "") {}
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      //if (location != null) {
                      if (_formKey.currentState.validate() &&
                          (errTxt == null || errTxt == "")) {
//                            print("Hello");
//                            // If the form is valid, we want to show a Snackbar
                        _writeToDB();
//                            // return;
                        try {
                          parentTimebank.children.add(timebankModel.id);
                        } catch (e) {
                          print(
                              "${AppLocalizations.of(context).translate('chat', 'error')}$e");
                        }
                        updateTimebank(timebankModel: parentTimebank);
                        Navigator.pop(context);
                      } else {
                        FocusScope.of(context).requestFocus(nameNode);
                      }
                    },

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('groups', 'create_group'),
                        style: Theme.of(context).primaryTextTheme.button,
                      ),
                    ),
                    textColor: Colors.blue,
                  );
                })),
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

/*  Widget get createTimebankHumanityFirst {
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
          textCapitalization: TextCapitalization.sentences,
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
            timebankModel.name = value;
          },
        ),
        Text(' '),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
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
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          initialValue: SevaCore.of(context).loggedInUser.email,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter email';
            } else if (!validateEmail(value.trim())) {
              return 'Please enter a valid email';
            }
            timebankModel.emailId = value;
          },
        ),
        Text(''),
        TextFormField(
          decoration: InputDecoration(
            prefix: Icon(
              Icons.add,
              color: Colors.black,
              size: 13,
            ),
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
          keyboardType: TextInputType.number,
          maxLines: 1,
          maxLength: 15,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            timebankModel.phoneNumber = value.replaceAll('.', '');
            print(timebankModel.phoneNumber.toString());
          },
        ),
        Text(''),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
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
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Offstage();
                    TimebankModel parentTimebank = snapshot.data;
                    return RaisedButton(
                      // color: Colors.blue,
                      color: FlavorConfig.values.theme.primaryColor,
                      onPressed: () async {
                        var connResult =
                            await Connectivity().checkConnectivity();
                        if (connResult == ConnectivityResult.none) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Please check your internet connection."),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                onPressed: () =>
                                    Scaffold.of(context).hideCurrentSnackBar(),
                              ),
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState.validate()) {
                          // If the form is valid, we want to show a Snackbar
                          try {
                            _writeToDB();
                            if (parentTimebank.children == null)
                              parentTimebank.children = [];
                            parentTimebank.children.add(timebankModel.id);
                            updateTimebank(timebankModel: parentTimebank);
                          } catch (e) {
                            print("Error is:$e");
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Create Group',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    );
                  })),
        ),
      ],
    );
  }*/

  void sendInviteNotification() {
//    globals.addedMembersId.forEach((m) {
//      members.add(m);
//    });
    if (selectedUsers.length > 0) {
      selectedUsers.forEach((key, user) async {
        print("Selected member with key $key");
        GroupInviteUserModel groupInviteUserModel = GroupInviteUserModel(
            timebankId: widget.timebankId,
            timebankName: timebankModel.name,
            timebankImage: timebankModel.photoUrl,
            aboutTimebank: timebankModel.missionStatement,
            adminName: SevaCore.of(context).loggedInUser.fullname,
            groupId: timebankModel.id);

        NotificationsModel notification = NotificationsModel(
            id: utils.Utils.getUuid(),
            timebankId: widget.timebankId,
            data: groupInviteUserModel.toMap(),
            isRead: false,
            type: NotificationType.GroupJoinInvite,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
            senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
            targetUserId: user.sevaUserID);

        await Firestore.instance
            .collection('users')
            .document(user.email)
            .collection("notifications")
            .document(notification.id)
            .setData(notification.toMap());
      });
    }
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
          memberAssignment = AppLocalizations.of(context)
              .translate('groups', 'assign_volunteer');
        else
          memberAssignment =
              "${selectedUsers.length} ${AppLocalizations.of(context).translate('groups', 'selected')}";
      });
      // print("Data is present Selected users ${selectedUsers.length}");
      print("Data is present Selected users ${selectedUsers.toString()}");
    } else {
      print("No users where selected");
      //no users where selected
    }
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  Widget get tappableInviteMembers {
    return (FlavorConfig.appFlavor == Flavor.APP ||
            FlavorConfig.appFlavor == Flavor.SEVA_DEV)
        ? GestureDetector(
            onTap: () async {
              addVolunteers();
            },
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                '${AppLocalizations.of(context).translate('groups', 'invite')} +',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ))
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
            ));
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

  void dispose() {
    super.dispose();
    _textUpdates.close();
  }
}
