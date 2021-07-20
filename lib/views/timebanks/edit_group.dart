import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/components/sevaavatar/timebankcoverphoto.dart';
import '../core.dart';
import 'package:sevaexchange/labels.dart';

class EditGroupView extends StatelessWidget {
  final TimebankModel timebankModel;
  EditGroupView({@required this.timebankModel});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EditGroupForm(
        timebankModel: timebankModel,
      ),
    );
  }
}

// Create a Form Widget
class EditGroupForm extends StatefulWidget {
  final TimebankModel timebankModel;
  EditGroupForm({@required this.timebankModel});
  @override
  EditGroupFormState createState() {
    return EditGroupFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class EditGroupFormState extends State<EditGroupForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  bool protectedVal = false;
  GeoFirePoint location;
  String selectedAddress;
  TextEditingController searchTextController;
  TimebankModel parentTimebankModel = TimebankModel({});

  var _searchText = "";
  String errTxt;
  final _textUpdates = StreamController<String>();
  final profanityDetector = ProfanityDetector();
  final _debouncer = Debouncer(milliseconds: 400);

  void initState() {
    super.initState();
    getParentTimebank();

    if (widget.timebankModel.location != null) {
      location = widget.timebankModel.location;
      selectedAddress = widget.timebankModel.address;
    } else {
      location = parentTimebankModel.location;
      selectedAddress = parentTimebankModel.address;
    }

    searchTextController =
        TextEditingController(text: widget.timebankModel.name);

    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;

        if (s.isEmpty) {
          setState(() {
            _searchText = "";
          });
        } else {
          if (widget.timebankModel.name != s) {
            SearchManager.searchGroupForDuplicate(
                    queryString: s.trim(),
                    communityId:
                        SevaCore.of(context).loggedInUser.currentCommunity)
                .then((groupFound) {
              if (groupFound) {
                setState(() {
                  errTxt = 'Group name already exists';
                });
              } else {
                setState(() {
                  groupFound = false;
                  errTxt = null;
                });
              }
            });
          }
        }
      });
    });
  }

  Future<void> getParentTimebank() async {
    Future.delayed(Duration.zero, () async {
      parentTimebankModel = await FirestoreManager.getTimeBankForId(
          timebankId: widget.timebankModel.parentTimebankId);
    });
    setState(() {});
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment;
  void updateGroupDetails() {
    widget.timebankModel.photoUrl =
        globals.timebankAvatarURL ?? widget.timebankModel.photoUrl;
    widget.timebankModel.cover_url =
        globals.timebankCoverURL ?? widget.timebankModel.cover_url;
    // widget.timebankModel.protected = protectedVal;
    widget.timebankModel.address = selectedAddress;
    widget.timebankModel.location =
        location == null ? GeoFirePoint(40.754387, -73.984291) : location;
    if (widget.timebankModel.sponsored == true &&
        !isAccessAvailable(parentTimebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID) &&
        parentTimebankModel.creatorId !=
            SevaCore.of(context).loggedInUser.sevaUserID) {
      widget.timebankModel.sponsored = false;

      assembleAndSendRequest(
          creatorId: widget.timebankModel.creatorId,
          timebankName: widget.timebankModel.name,
          adminId: parentTimebankModel.creatorId,
          subTimebankId: widget.timebankModel.id,
          targetTimebankId: parentTimebankModel.id,
          timebankPhotoUrl: widget.timebankModel.photoUrl,
          timebankCoverUrl: widget.timebankModel.cover_url,
          creatorName: SevaCore.of(context).loggedInUser.fullname,
          creatorPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
          communityId: widget.timebankModel.communityId);
    }
    updateTimebank(timebankModel: widget.timebankModel).then((onValue) {
      showDialogForSuccess(dialogTitle: S.of(context).details_updated_success);
    });
    globals.timebankAvatarURL = null;
    globals.webImageUrl = null;
  }

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    memberAssignment = "+ ${S.of(context).add_members}";
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: SingleChildScrollView(child: createSevaX
            // : createTimebankHumanityFirst,
            ),
      ),
    );
  }

//umesha@uipep.com
//upnsd143 uipep
  Widget get createSevaX {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  TimebankCoverPhoto(
                      coverUrl: widget.timebankModel.cover_url ?? null),
                  SizedBox(height: 10),
                  Text(
                    "${L.of(context).cover_picture_label_group}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 25),
                  TimebankAvatar(
                    photoUrl: widget.timebankModel.photoUrl ?? null,
                  ),
                  SizedBox(height: 5),
                  Text(
                    S.of(context).group_logo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          headingText(S.of(context).name_your_group, true),
          TextFormField(
            textInputAction: TextInputAction.done,
            controller: searchTextController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              errorMaxLines: 2,
              errorText: errTxt,
              hintText: S.of(context).timebank_name_hint,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              } else {
                widget.timebankModel.name = value.trim();
                return null;
              }
            },
          ),
          headingText(S.of(context).about, true),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.timebankModel.missionStatement ?? "",
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).bit_more_about_group,
            ),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              } else {
                widget.timebankModel.missionStatement = value;
                return null;
              }
            },
          ),
          Row(
            children: <Widget>[
              headingText(
                S.of(context).prevent_accidental_delete,
                false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                child: Checkbox(
                  value: widget.timebankModel.preventAccedentalDelete,
                  onChanged: (bool value) {
                    setState(() {
                      widget.timebankModel.preventAccedentalDelete = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              headingText(S.of(context).private_group, false),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                child: infoButton(
                  context: context,
                  key: GlobalKey(),
                  type: InfoType.PRIVATE_GROUP,
                ),
              ),
              Column(
                children: <Widget>[
                  Divider(),
                  Checkbox(
                    value: widget.timebankModel.private,
                    onChanged: (bool value) {
                      setState(() {
                        widget.timebankModel.private = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          headingText(S.of(context).is_pin_at_right_place, false),
          Container(
            margin: EdgeInsets.all(20),
            child: Center(
              child: LocationPickerWidget(
                selectedAddress: selectedAddress,
                location: location,
                onChanged: (LocationDataModel dataModel) {
                  setState(() {
                    location = dataModel.geoPoint;
                    this.selectedAddress = dataModel.location;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TransactionsMatrixCheck(
            comingFrom: ComingFrom.Groups,
            upgradeDetails: AppConfig.upgradePlanBannerModel.sponsored_groups,
            transaction_matrix_type: "sponsored_groups",
            child: Row(
              children: <Widget>[
                headingText(S.of(context).save_as_sponsored, false),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                  child: infoButton(
                    context: context,
                    key: GlobalKey(),
                    type: InfoType.SPONSORED,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Divider(),
                    Checkbox(
                      value: widget.timebankModel.sponsored,
                      onChanged: (bool value) {
                        if (!widget.timebankModel.sponsored) {
                          setState(() {
                            widget.timebankModel.sponsored =
                                !widget.timebankModel.sponsored;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              alignment: Alignment.center,
              child: CustomElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate() &&
                      (errTxt == null || errTxt == "")) {
                    updateGroupDetails();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    S.of(context).update,
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                ),
                textColor: Colors.blue,
              ),
            ),
          ),
        ]);
  }

  Widget headingText(String name, bool isMandatory) {
    name = name ?? "";

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

  // Widget get createTimebankHumanityFirst {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Center(
  //           child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: TimebankAvatar(),
  //       )),
  //       Padding(
  //         padding: EdgeInsets.all(15.0),
  //       ),
  //       TextFormField(
  //         controller: searchTextController,
  //         decoration: InputDecoration(
  //           errorText: errTxt,
  //           hintText: FlavorConfig.values.timebankName == "Yang 2020"
  //               ? "Yang Gang Chapter"
  //               : "Timebank Name",
  //           labelText: FlavorConfig.values.timebankName == "Yang 2020"
  //               ? "Yang Gang Chapter"
  //               : "Timebank Name",
  //           // labelStyle: textStyle,
  //           // labelStyle: textStyle,
  //           // labelText: 'Description',
  //           border: OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(20.0),
  //             ),
  //             borderSide: new BorderSide(
  //               color: Colors.black,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //         keyboardType: TextInputType.multiline,
  //         maxLines: 1,
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter some text';
  //           }
  //           widget.timebankModel.name = value;
  //           return "";
  //         },
  //       ),
  //       Text(' '),
  //       TextFormField(
  //         decoration: InputDecoration(
  //           hintText: 'What you are about',
  //           labelText: 'Mission Statement',
  //           // labelStyle: textStyle,
  //           // labelStyle: textStyle,
  //           // labelText: 'Description',
  //           border: OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(20.0),
  //             ),
  //             borderSide: new BorderSide(
  //               color: Colors.black,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //         keyboardType: TextInputType.multiline,
  //         maxLines: null,
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter some text';
  //           }
  //           widget.timebankModel.missionStatement = value;
  //           return "";
  //         },
  //       ),
  //       Text(''),
  //       TextFormField(
  //         decoration: InputDecoration(
  //           hintText: 'The Timebank\'s primary email',
  //           labelText: 'Email',
  //           // labelStyle: textStyle,
  //           // labelStyle: textStyle,
  //           // labelText: 'Description',
  //           border: OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(20.0),
  //             ),
  //             borderSide: new BorderSide(
  //               color: Colors.black,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //         keyboardType: TextInputType.multiline,
  //         maxLines: 1,
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter some text';
  //           }
  //           widget.timebankModel.emailId = value;
  //           return "";
  //         },
  //       ),
  //       Text(''),
  //       TextFormField(
  //         decoration: InputDecoration(
  //           hintText: 'The Timebanks primary phone number',
  //           labelText: 'Phone Number',
  //           // labelStyle: textStyle,
  //           // labelStyle: textStyle,
  //           // labelText: 'Description',
  //           border: OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(20.0),
  //             ),
  //             borderSide: new BorderSide(
  //               color: Colors.black,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //         keyboardType: TextInputType.multiline,
  //         maxLines: 1,
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter some text';
  //           }
  //           widget.timebankModel.phoneNumber = value;
  //           return "";
  //         },
  //       ),
  //       Text(''),
  //       TextFormField(
  //         decoration: InputDecoration(
  //           hintText: 'Your main address',
  //           labelText: 'Address',
  //           // labelStyle: textStyle,
  //           // labelStyle: textStyle,
  //           // labelText: 'Description',
  //           border: OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(20.0),
  //             ),
  //             borderSide: new BorderSide(
  //               color: Colors.black,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //         keyboardType: TextInputType.multiline,
  //         maxLines: null,
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter some text';
  //           }
  //           widget.timebankModel.address = value;
  //           return "";
  //         },
  //       ),
  //       Row(
  //         children: <Widget>[
  //           Padding(
  //             padding: EdgeInsets.all(5),
  //           ),
  //           Text(
  //             'Closed :',
  //             style: TextStyle(fontSize: 18),
  //           ),
  //           Checkbox(
  //             value: protectedVal,
  //             onChanged: (bool value) {
  //               setState(() {
  //                 protectedVal = value;
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //       // Text(sevaUserID),
  //       Center(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: CustomTextButton.icon(
  //             icon: Icon(Icons.add_location),
  //             label: Text(
  //               selectedAddress == null || selectedAddress.isEmpty
  //                   ? 'Add Location'
  //                   : selectedAddress,
  //             ),
  //             color: Colors.grey[200],
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute<LocationDataModel>(
  //                   builder: (context) => LocationPicker(
  //                     selectedLocation: location,
  //                   ),
  //                 ),
  //               ).then((dataModel) {
  //                 if (dataModel != null) location = dataModel.geoPoint;
  //                 // _getLocation();
  //                 setState(() {
  //                   this.selectedAddress = dataModel.location;
  //                 });
  //                 log('ReceivedLocation: $selectedAddress');
  //               });
  //             },
  //           ),
  //         ),
  //       ),
  //       Center(
  //         child: Text(
  //           'We recommend you to add a vicinity location',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontStyle: FontStyle.italic),
  //         ),
  //       ),
  //       Divider(),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 5.0),
  //         child: Container(
  //           alignment: Alignment.center,
  //           child: CustomElevatedButton(
  //             // color: Colors.blue,
  //             color: Colors.red,
  //             onPressed: () {
  //               if (_formKey.currentState.validate()) {
  //                 // If the form is valid, we want to show a Snackbar
  //               }
  //             },
  //             child: Text(
  //               'Create ${FlavorConfig.values.timebankTitle}',
  //               style: TextStyle(fontSize: 16.0, color: Colors.white),
  //             ),
  //             textColor: Colors.blue,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Future _getLocation() async {
  //   if (location == null) return;
  //   String address = await LocationUtility().getFormattedAddress(
  //     location.latitude,
  //     location.longitude,
  //   );
  //   log('_getLocation: $address');
  //   setState(() {
  //     this.selectedAddress = address;
  //   });
  // }

  void showDialogForSuccess({String dialogTitle}) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actions: <Widget>[
              CustomTextButton(
                child: Text(
                  S.of(context).ok,
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
}
