//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/location_picker.dart';
import 'package:sevaexchange/components/sevaavatar/projects_avtaar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';

import '../../flavor_config.dart';

class CreateEditProject extends StatefulWidget {
  final bool isCreateProject;
  final String timebankId;
  final String projectId;

  CreateEditProject({this.isCreateProject, this.timebankId, this.projectId});

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
  String locationError = '';
  var startDate;
  var endDate;
  bool isDataLoaded = false;
  int sharedValue = 0;
  ScrollController _controller = ScrollController();
  var focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isCreateProject) {
      getData();
    } else {
      setState(() {
        this.projectModel.mode = 'Timebank';
      });
    }

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );

    setState(() {});
  }

  void getData() async {
    await FirestoreManager.getProjectFutureById(projectId: widget.projectId)
        .then((onValue) {
      projectModel = onValue;
      print("projectttttt ${projectModel}");
      selectedAddress = projectModel.address;
      isDataLoaded = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCreateProject) {
      startDate = getUpdatedDateTimeAccToUserTimezone(
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
          dateTime:
              DateTime.fromMillisecondsSinceEpoch(projectModel.startTime));
      endDate = getUpdatedDateTimeAccToUserTimezone(
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
          dateTime: DateTime.fromMillisecondsSinceEpoch(projectModel.endTime));
    }

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
      body: widget.isCreateProject
          ? Form(
              key: _formKey,
              child: createProjectForm,
            )
          : isDataLoaded
              ? Form(
                  key: _formKey,
                  child: createProjectForm,
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
    );
  }

  Future<TimebankModel> getTimebankAdminStatus;
  TimebankModel timebankModelFuture;

  Widget get projectSwitch {
    return FutureBuilder(
      future: getTimebankAdminStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) return Text(snapshot.error.toString());
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        timebankModel = snapshot.data;
        if (snapshot.data.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            width: double.infinity,
            child: CupertinoSegmentedControl<int>(
              selectedColor: Theme.of(context).primaryColor,
              children: logoWidgets,
              borderColor: Colors.grey,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              groupValue: sharedValue,
              onValueChanged: (int val) {
                print(val);
                if (val != sharedValue) {
                  setState(() {
                    print("$sharedValue -- $val");
                    if (val == 0) {
                      print("TTTTTTTTTtimebank proj");
                      projectModel.mode = 'Timebank';
                    } else {
                      print("pppppppppersonal proj");
                      projectModel.mode = 'Personal';
                    }
                    sharedValue = val;
                  });
                }
              },
              //groupValue: sharedValue,
            ),
          );
        } else {
          this.projectModel.mode = 'Personal';

          return Container();
        }
      },
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Timebank Project',
      style: TextStyle(fontSize: 15.0),
    ),
    1: Text(
      'Personal Project',
      style: TextStyle(fontSize: 15.0),
    ),
  };
  Widget get createProjectForm {
    return SingleChildScrollView(
      controller: _controller,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.isCreateProject ? projectSwitch : Container(),
            Center(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    widget.isCreateProject
                        ? ProjectAvtaar()
                        : ProjectAvtaar(
                            photoUrl: projectModel.photoUrl != null
                                ? projectModel.photoUrl ?? defaultCameraImageURL
                                : defaultCameraImageURL,
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
              onChanged: (value) {
                //  enteredName = value;
                print("name ------ $value");
                projectModel.name = value;
              },
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
              ],
              initialValue:
                  widget.isCreateProject ? "" : projectModel.name ?? "",
              decoration: InputDecoration(
                errorText: errTxt,
                hintText: "Ex: Pets-in-town, Citizen collab",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              //initialValue: snapshot.data.community.name ?? '',
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodes[1]);
              },
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
            widget.isCreateProject
                ? OfferDurationWidget(
                    title: ' Project duration',
                    //startTime: CalendarWidgetState.startDate,
                    //endTime: CalendarWidgetState.endDate
                  )
                : OfferDurationWidget(
                    title: ' Project duration',
                    startTime: startDate,
                    endTime: endDate,
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
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodes[2]);
              },
              textInputAction: TextInputAction.next,
              focusNode: focusNodes[1],
              initialValue:
                  widget.isCreateProject ? "" : projectModel.description ?? "",
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,

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
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodes[3]);
              },
              textInputAction: TextInputAction.next,
              focusNode: focusNodes[2],
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
                  : projectModel.emailId ??
                      SevaCore.of(context).loggedInUser.email,
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
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              cursorColor: Colors.black54,
              focusNode: focusNodes[3],
              textInputAction: TextInputAction.done,
              //  validator: _validateEmailId,
              keyboardType: TextInputType.number,
              onSaved: (value) {
                projectModel.phoneNumber = value;
              },
              onChanged: (value) {
                projectModel.phoneNumber = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Mobile Number cannot be empty.';
                } else {
                  projectModel.phoneNumber = value;
                }
                return null;
              },
              maxLength: 15,
              initialValue:
                  widget.isCreateProject ? "" : projectModel.phoneNumber ?? "",
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
            headingText('Your project location.'),
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
                    selectedAddress == ''
                        ? 'Add Location'
                        : selectedAddress ?? "",
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
            Text(
              locationError,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    print('project mode ${projectModel.mode}');
                    FocusScope.of(context).requestFocus(new FocusNode());
                    // show a dialog
                    projectModel.startTime =
                        OfferDurationWidgetState.starttimestamp;
                    projectModel.endTime =
                        OfferDurationWidgetState.endtimestamp;
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
                        if (projectModel.startTime == 0 ||
                            projectModel.endTime == 0) {
                          showDialogForTitle(
                              dialogTitle:
                                  "Please mention the start and end date of the project");
                          return;
                        }
                        if (!hasRegisteredLocation()) {
                          showDialogForTitle(
                              dialogTitle:
                                  "Please add location to your project");
                          return;
                        }
                        projectModel.communityId =
                            SevaCore.of(context).loggedInUser.currentCommunity;
                        projectModel.completedRequests = [];
                        projectModel.pendingRequests = [];
                        projectModel.timebankId = widget.timebankId;
                        projectModel.photoUrl = globals.projectsAvtaarURL;
                        projectModel.emailId =
                            SevaCore.of(context).loggedInUser.email;
                        int timestamp = DateTime.now().millisecondsSinceEpoch;
                        projectModel.createdAt = timestamp;

                        projectModel.creatorId =
                            SevaCore.of(context).loggedInUser.sevaUserID;
                        projectModel.members = [];
                        projectModel.id = Utils.getUuid();
                        // if (globals.projectsAvtaarURL == null) {
                        //   setState(() {
                        //     this.communityImageError =
                        //         'Project logo is mandatory';
                        //     //   moveToTop();
                        //   });

                        // }
                        showProgressDialog('Creating project');
                        globals.projectsAvtaarURL = null;
//                          setState(() {
//                            this.communityImageError = '';
//                          });
                        await FirestoreManager.createProject(
                            projectModel: projectModel);
                        if (dialogContext != null) {
                          Navigator.pop(dialogContext);
                        }
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                      } else {}
                    } else {
                      if (_formKey.currentState.validate()) {
                        projectModel.startTime =
                            OfferDurationWidgetState.starttimestamp;
                        projectModel.endTime =
                            OfferDurationWidgetState.endtimestamp;

                        projectModel.photoUrl = globals.projectsAvtaarURL;

                        if (projectModel.startTime == 0 ||
                            projectModel.endTime == 0) {
                          showDialogForTitle(
                              dialogTitle:
                                  "Please mention the start and end date of the project");
                          return;
                        }

                        if (projectModel.address == null ||
                            this.selectedAddress == null) {
                          this.locationError = 'Location is Mandatory';
                          showDialogForTitle(
                              dialogTitle:
                                  "Please add location to your project");
                          return;
                        }
                        showProgressDialog('Updating project');
                        globals.projectsAvtaarURL = null;
                        print("final value of modeeeee is " +
                            this.projectModel.mode);
                        await FirestoreManager.updateProject(
                            projectModel: projectModel);
                        if (dialogContext != null) {
                          Navigator.pop(dialogContext);
                        }
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  shape: StadiumBorder(),
                  child: Text(
                    widget.isCreateProject ? 'Create project' : 'Save',
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

  moveToTop() {
    print("move to top");
    // _controller.jumpTo(0.0);
    _controller.animateTo(
      -100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  bool hasRegisteredLocation() {
    print("Location ---========================= ${projectModel.address}");
    return location != null;
  }

  Future<void> showDialogForTitle({String dialogTitle}) async {
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
    projectModel.address = this.selectedAddress;
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
