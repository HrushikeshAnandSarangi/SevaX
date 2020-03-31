import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';

class CreateEditProject extends StatefulWidget {
  final bool isCreateProject;
  final String timebankId;

  CreateEditProject({this.isCreateProject, this.timebankId});

  @override
  _CreateEditProjectState createState() => _CreateEditProjectState();
}

class _CreateEditProjectState extends State<CreateEditProject> {
  final _formKey = GlobalKey<FormState>();
  String communityImageError = '';
  TextEditingController searchTextController = new TextEditingController();
  String errTxt;
  ProjectModel projectModel = ProjectModel();
  GeoFirePoint location;
  String selectedAddress = '';
  TimebankModel timebankModel = TimebankModel({});
  BuildContext dialogContext;
  String dateTimeEroor = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          widget.isCreateProject ? 'Create a Project' : 'Edit Project',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: createProjectForm,
      ),
    );
  }

  Widget get createProjectForm {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    widget.isCreateProject
                        ? TimebankAvatar()
                        : TimebankAvatar(
                            photoUrl: defaultCameraImageURL,
                          ),
                    Text(''),
                    Text(
                      'Project Logo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      communityImageError,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            headingText('Project Name'),
            TextFormField(
              controller: searchTextController,
              onChanged: (value) {
                //  enteredName = value;
                print("name ------ $value");
                //communityModel.name = value;
                //timebankModel.name = value;
              },
              decoration: InputDecoration(
                errorText: errTxt,
                hintText: "Ex: Pets-in-town, Citizen collab",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              //initialValue: snapshot.data.community.name ?? '',

              onSaved: (value) {
                projectModel.name = value;
              },
              // onSaved: (value) => enteredName = value,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Project name cannot be empty';
                } else {
                  projectModel.name = value;
                }

                return null;
              },
            ),
            OfferDurationWidget(
              title: ' Project duration',
              //startTime: CalendarWidgetState.startDate,
              //endTime: CalendarWidgetState.endDate
            ),
            Text(
              dateTimeEroor,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            headingText('Mission Statement'),
            TextFormField(
              decoration: InputDecoration(
                hintText:
                    'Ex: A bit more about your project which will help to associate with',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              //  initialValue: timebankModel.missionStatement,
              onChanged: (value) {
                projectModel.description = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Mission statement cannot be empty.';
                } else {
                  projectModel.description = value;
                }
//                      snapshot.data.community.updateValueByKey('about', value);
//
//                      snapshot.data.timebank
//                          .updateValueByKey('missionStatement', value);
//                      createEditCommunityBloc.onChange(snapshot.data);
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText('Email'),
            TextFormField(
              style: textStyle,
              cursorColor: Colors.black54,
              validator: _validateEmailId,
              onSaved: (value) {
                projectModel.emailId = value;
              },
              onChanged: (value) {
                projectModel.emailId = value;
              },
              initialValue: widget.isCreateProject
                  ? SevaCore.of(context).loggedInUser.email
                  : '',
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                hintText: 'example@example.com',
                hintStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText('Phone Number'),
            TextFormField(
              style: textStyle,
              cursorColor: Colors.black54,
              //  validator: _validateEmailId,
              keyboardType: TextInputType.number,
              onSaved: (value) {
                projectModel.phoneNumber = value;
              },
              onChanged: (value) {
                projectModel.phoneNumber = value;
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                hintText: '+1 123456789',
                hintStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText('Your timebank location.'),
            Text(
              'Project location will help your members to locate',
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
                    selectedAddress == '' ? 'Add Location' : selectedAddress,
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
                      location = point;
                      print(
                          "Locatsion is iAKSDbkjwdsc:(${location.latitude},${location.longitude})");
                    }
                    _getLocation(location);
                    //print('ReceivedLocation: $snapshot.data.timebank.address');
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    // show a dialog
                    if (widget.isCreateProject) {
//                            if (!firebaseUser.isEmailVerified) {
//                              _showVerificationAndLogoutDialogue();
//                            }

                      print(_formKey.currentState.validate());

//                            communityFound =
//                                await isCommunityFound(enteredName);
//                            if (communityFound) {
//                              print("Found:$communityFound");
//                              return;
//                            }
                      if (_formKey.currentState.validate()) {
                        projectModel.startTime =
                            OfferDurationWidgetState.starttimestamp;
                        projectModel.endTime =
                            OfferDurationWidgetState.endtimestamp;
                        projectModel.communityId =
                            SevaCore.of(context).loggedInUser.currentCommunity;
                        projectModel.completedRequests = [];
                        projectModel.pendingRequests = [];
                        projectModel.timebankId = widget.timebankId;
                        projectModel.photoUrl = globals.timebankAvatarURL;
                        projectModel.mode = 'TimeBank';
                        projectModel.emailId =
                            SevaCore.of(context).loggedInUser.email;
                        int timestamp = DateTime.now().millisecondsSinceEpoch;
                        projectModel.createdAt = timestamp;

                        projectModel.creatorId =
                            SevaCore.of(context).loggedInUser.sevaUserID;
                        projectModel.members = [];
                        projectModel.id = Utils.getUuid();
                        if (globals.timebankAvatarURL == null) {
                          setState(() {
                            this.communityImageError =
                                'Timebank logo is mandatory';
                          });
                        }

                        if (projectModel.startTime == null ||
                            projectModel.endTime == null) {
                          setState(() {
                            this.communityImageError = 'Duration is Mandatory';
                          });
                        }

                        showProgressDialog('Creating project');
                        await FirestoreManager.createProject(
                            projectModel: projectModel);
                        if (dialogContext != null) {
                          Navigator.pop(dialogContext);
                        }
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                      } else {}
                    } else {
                      showProgressDialog('Updating project');

                      if (dialogContext != null) {
                        Navigator.pop(dialogContext);
                      }
                      _formKey.currentState.reset();
                      Navigator.of(context).pop();
                    }
                  },
                  shape: StadiumBorder(),
                  child: Text(
                    widget.isCreateProject ? 'Next' : 'Save',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  textColor: FlavorConfig.values.buttonTextColor,
                ),
              ),
            ),
            SizedBox(height: 100),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text(
                '',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    projectModel.address = address;
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  String _validateEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return 'Enter email';
    if (!emailPattern.hasMatch(value)) return 'Email is not valid';
    return null;
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.black54,
    );
  }
}
