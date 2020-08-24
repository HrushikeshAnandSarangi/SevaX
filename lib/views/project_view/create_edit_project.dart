//import 'dart:html';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/sevaavatar/projects_avtaar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/project_template_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

import '../../flavor_config.dart';

class CreateEditProject extends StatefulWidget {
  final bool isCreateProject;
  final String timebankId;
  final String projectId;
  final ProjectTemplateModel projectTemplateModel;

  CreateEditProject(
      {this.isCreateProject,
      this.timebankId,
      this.projectId,
      this.projectTemplateModel});

  @override
  _CreateEditProjectState createState() => _CreateEditProjectState();
}

class _CreateEditProjectState extends State<CreateEditProject> {
  final _formKey = GlobalKey<FormState>();
  final _formDialogKey = GlobalKey<FormState>();
  String communityImageError = '';
  TextEditingController searchTextController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String errTxt;
  ProjectModel projectModel = ProjectModel();
  ProjectTemplateModel projectTemplateModel = ProjectTemplateModel();
  GeoFirePoint location;
  String selectedAddress = '';
  String templateName = '';
  bool saveAsTemplate = false;
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
  final _textUpdates = StreamController<String>();
  bool templateFound = false;
  String templateError = '';
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isCreateProject) {
      getData();
    } else {
      setState(() {
        if (widget.projectTemplateModel != null) {
          this.projectModel.mode = widget.projectTemplateModel.mode;
          this.projectModel.mode == 'Timebank'
              ? sharedValue = 0
              : sharedValue = 1;
        } else {
          this.projectModel.mode = 'Timebank';
        }
      });
    }

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );

    setState(() {});

    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));

    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          templateError = null;
        });
      } else {
        if (templateName != s) {
          SearchManager.searchTemplateForDuplicate(queryString: s)
              .then((commFound) {
            print("querystring is  ${s} and templateName is ${templateName}");
            if (commFound) {
              setState(() {
                templateFound = true;
                templateError = 'Template name already exists';
              });
            } else {
              setState(() {
                templateFound = false;
                templateError = null;
              });
            }
          });
        }
      }
    });
  }

  void getData() async {
    await FirestoreManager.getProjectFutureById(projectId: widget.projectId)
        .then((onValue) {
      projectModel = onValue;
      print("projectttttt ${projectModel}");
      selectedAddress = projectModel.address;
      location = projectModel.location;
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
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          widget.isCreateProject
              ? S.of(context).create_project
              : S.of(context).edit_project,
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
              : LoadingIndicator(),
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
              children: {
                0: Text(
                  S.of(context).timebank_project(1),
                  style: TextStyle(fontSize: 10.0),
                ),
                1: Text(
                  S.of(context).personal_project(1),
                  style: TextStyle(fontSize: 10.0),
                ),
              },
              borderColor: Colors.grey,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              groupValue: sharedValue,
              onValueChanged: (int val) {
                print(val);
                if (val != sharedValue) {
                  setState(() {
                    print("$sharedValue -- $val");
                    if (val == 0) {
                      projectModel.mode = 'Timebank';
                    } else {
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
                        ? widget.projectTemplateModel != null
                            ? ProjectAvtaar(
                                photoUrl:
                                    widget.projectTemplateModel.photoUrl ??
                                        defaultProjectImageURL)
                            : ProjectAvtaar()
                        : ProjectAvtaar(
                            photoUrl: projectModel.photoUrl != null
                                ? projectModel.photoUrl ??
                                    defaultProjectImageURL
                                : defaultProjectImageURL,
                          ),
                    Text(''),
                    Text(
                      S.of(context).project_logo,
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
            headingText(S.of(context).project_name),
            TextFormField(
              autovalidate: autoValidateText,
              onChanged: (value) {
                print("name ------ $value");
                if (value.length > 1) {
                  setState(() {
                    autoValidateText = true;
                  });
                } else {
                  setState(() {
                    autoValidateText = false;
                  });
                }
                projectModel.name = value;
              },
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
              ],
              initialValue: widget.isCreateProject
                  ? widget.projectTemplateModel != null
                      ? widget.projectTemplateModel.name
                      : ""
                  : projectModel.name ?? "",
              decoration: InputDecoration(
                errorMaxLines: 2,
                errorText: errTxt,
                hintText: S.of(context).name_hint,
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
                  return S.of(context).validation_error_project_name_empty;
                } else if (profanityDetector.isProfaneString(value)) {
                  return S.of(context).profanity_text_alert;
                } else {
                  projectModel.name = value;
                }

                return null;
              },
            ),
            widget.isCreateProject
                ? widget.projectTemplateModel != null
                    ? OfferDurationWidget(
                        title: ' ${S.of(context).project_duration}',
                        startTime: startDate,
                        endTime: endDate,
                      )
                    : OfferDurationWidget(
                        title: ' ${S.of(context).project_duration}',
                        //startTime: CalendarWidgetState.startDate,
                        //endTime: CalendarWidgetState.endDate
                      )
                : OfferDurationWidget(
                    title: ' ${S.of(context).project_duration}',
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
            headingText(S.of(context).mission_statement),
            TextFormField(
              decoration: InputDecoration(
                errorMaxLines: 2,
                hintText: S.of(context).project_mission_statement_hint,
              ),
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(focusNodes[2]);
              },
              textInputAction: TextInputAction.next,
              focusNode: focusNodes[1],
              initialValue: widget.isCreateProject
                  ? widget.projectTemplateModel != null
                      ? widget.projectTemplateModel.description
                      : ""
                  : projectModel.description ?? "",
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,

              //  initialValue: timebankModel.missionStatement,
              autovalidate: autoValidateText,
              onChanged: (value) {
                if (value.length > 1) {
                  setState(() {
                    autoValidateText = true;
                  });
                } else {
                  setState(() {
                    autoValidateText = false;
                  });
                }

                projectModel.description = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return S.of(context).validation_error_mission_empty;
                } else if (profanityDetector.isProfaneString(value)) {
                  return S.of(context).profanity_text_alert;
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
            headingText(
              S.of(context).email.firstWordUpperCase(),
            ),
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
                hintText: S.of(context).email_hint,
                hintStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText(S.of(context).phone_number),
            TextFormField(
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },

              cursorColor: Colors.black54,
              focusNode: focusNodes[3],
              textInputAction: TextInputAction.done,

              //  validator: _validateEmailId,
              onSaved: (value) {
                projectModel.phoneNumber = '+' + value;
              },
              onChanged: (value) {
                projectModel.phoneNumber = '+' + value;
              },
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp("[0-9]")),
              ],

              validator: (value) {
                if (value.isEmpty) {
                  return null;
                } else {
                  projectModel.phoneNumber = '+' + value;
                }
                return null;
              },
              maxLength: 15,
              initialValue: widget.isCreateProject
                  ? ""
                  : projectModel.phoneNumber != null
                      ? projectModel.phoneNumber.replaceAll('+', '') ?? ""
                      : '',
              decoration: InputDecoration(
//                icon: Icon(
//                  Icons.add,
//                  color: Colors.black,
//                  size: 13,
//                ),
//                prefixIcon: Icon(
//                  Icons.add,
//                  color: Colors.black,
//                  size: 13,
//                ),
                prefix: Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 13,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                hintText: "123456789",
                hintStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText(
              S.of(context).project_location,
            ),
            Text(
              S.of(context).project_location_hint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
            ),
            Center(
              child: LocationPickerWidget(
                selectedAddress:
                    widget.isCreateProject ? selectedAddress : selectedAddress,
                location: widget.isCreateProject ? location : location,
                onChanged: (LocationDataModel dataModel) {
                  log("received data model");
                  setState(() {
                    location = dataModel.geoPoint;
                    this.selectedAddress = dataModel.location;
                  });
                },
              ),
            ),
            // Center(
            //   child: FlatButton.icon(
            //     icon: Icon(Icons.add_location),
            //     label: Container(
            //       child: Text(
            //         selectedAddress == '' || selectedAddress == null
            //             ? 'Add Location'
            //             : selectedAddress ?? "",
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //     color: Colors.grey[200],
            //     onPressed: () async {
            //       print("Location opened : $location");
            //       await Navigator.push(
            //         context,
            //         MaterialPageRoute<LocationDataModel>(
            //           builder: (context) => LocationPicker(
            //             selectedLocation: location,
            //             selectedAddress: selectedAddress,
            //           ),
            //         ),
            //       ).then((dataModel) {
            //         if (dataModel != null) {
            //           location = dataModel.geoPoint;
            //           print(
            //               "Locatsion is iAKSDbkjwdsc:(${location.latitude},${location.longitude})");
            //           setState(() {
            //             this.selectedAddress = dataModel.location;
            //           });
            //           log("Adderess   ${dataModel.location}");
            //         }
            //       });
            //     },
            //   ),
            // ),
            Text(
              locationError,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            widget.isCreateProject
                ? Row(
                    children: <Widget>[
                      headingText(S.of(context).save_as_template),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Checkbox(
                          value: saveAsTemplate,
                          onChanged: (bool value) {
                            if (saveAsTemplate) {
                              setState(() {
                                saveAsTemplate = false;
                              });
                            } else {
                              _showSaveAsTemplateDialog().then((templateName) {
                                if (templateName != null) {
                                  setState(() {
                                    saveAsTemplate = true;
                                  });
                                } else {
                                  setState(() {
                                    saveAsTemplate = false;
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ),
//                Column(
//                  children: <Widget>[
//
//                  ],
//                ),
                    ],
                  )
                : Offstage(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () async {
                    print('project phone ${projectModel.phoneNumber}');

                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).check_internet),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }

                    print('project mode ${projectModel.mode}');
                    FocusScope.of(context).requestFocus(FocusNode());
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
                            dialogTitle: S.of(context).validation_error_no_date,
                          );
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
                        projectModel.location = location;
                        int timestamp = DateTime.now().millisecondsSinceEpoch;
                        projectModel.createdAt = timestamp;

                        projectModel.creatorId =
                            SevaCore.of(context).loggedInUser.sevaUserID;
                        projectModel.members = [];
                        projectModel.address = selectedAddress;
                        projectModel.id = Utils.getUuid();
                        projectModel.softDelete = false;

                        if (saveAsTemplate) {
                          projectTemplateModel.communityId =
                              projectModel.communityId;
                          projectTemplateModel.timebankId =
                              projectModel.timebankId;
                          projectTemplateModel.id = Utils.getUuid();
                          projectTemplateModel.name = projectModel.name;
                          projectTemplateModel.templateName = templateName;
                          projectTemplateModel.photoUrl = projectModel.photoUrl;
                          projectTemplateModel.description =
                              projectModel.description;
                          projectTemplateModel.creatorId =
                              projectModel.creatorId;
                          projectTemplateModel.createdAt =
                              projectModel.createdAt;
                          projectTemplateModel.mode = projectModel.mode;
                          projectTemplateModel.softDelete = false;

                          await FirestoreManager.createProjectTemplate(
                              projectTemplateModel: projectTemplateModel);
                        }

                        // if (globals.projectsAvtaarURL == null) {
                        //   setState(() {
                        //     this.communityImageError =
                        //         'Project logo is mandatory';
                        //     //   moveToTop();
                        //   });

                        // }
                        showProgressDialog(S.of(context).creating_project);
//                          setState(() {
//                            this.communityImageError = '';
//                          });
                        await FirestoreManager.createProject(
                            projectModel: projectModel);
                        globals.projectsAvtaarURL = null;
                        globals.webImageUrl = null;

                        if (dialogContext != null) {
                          Navigator.pop(dialogContext);
                        }
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else {}
                    } else {
                      if (_formKey.currentState.validate()) {
                        projectModel.startTime =
                            OfferDurationWidgetState.starttimestamp;
                        projectModel.endTime =
                            OfferDurationWidgetState.endtimestamp;
                        projectModel.address = selectedAddress;
                        projectModel.location = location;

                        if (globals.projectsAvtaarURL != null) {
                          projectModel.photoUrl = globals.projectsAvtaarURL;
                        }

                        if (projectModel.startTime == 0 ||
                            projectModel.endTime == 0) {
                          showDialogForTitle(
                              dialogTitle:
                                  S.of(context).validation_error_no_date);
                          return;
                        }

                        if (projectModel.address == null ||
                            this.selectedAddress == null) {
                          this.locationError =
                              S.of(context).validation_error_location_mandatory;
                          showDialogForTitle(
                              dialogTitle: S
                                  .of(context)
                                  .validation_error_add_project_location);
                          return;
                        }
                        showProgressDialog(S.of(context).updating_project);
                        await FirestoreManager.updateProject(
                            projectModel: projectModel);
                        globals.projectsAvtaarURL = null;
                        globals.webImageUrl = null;

                        if (dialogContext != null) {
                          Navigator.pop(dialogContext);
                        }
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  shape: StadiumBorder(),
                  child: Text(
                    widget.isCreateProject
                        ? S.of(context).create_project
                        : S.of(context).save,
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

  void moveToTop() {
    print("move to top");
    // _controller.jumpTo(0.0);
    _controller.animateTo(
      -100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  bool hasRegisteredLocation() {
    return location != null || projectModel.address != null;
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

//   Future _getLocation(data) async {
//     print('Timebank value:$data');
//     String address = await LocationUtility().getFormattedAddress(
//       location.latitude,
//       location.longitude,
//     );
//     setState(() {
//       this.selectedAddress = address;
//     });
// //    timebank.updateValueByKey('locationAddress', address);
//     print('_getLocation: $address');
//     projectModel.address = this.selectedAddress;
//   }

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
    if (value.isEmpty) return S.of(context).validation_error_invalid_email;
    if (!emailPattern.hasMatch(value))
      return S.of(context).validation_error_invalid_email;
    return null;
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.black54,
    );
  }

  Future<String> _showSaveAsTemplateDialog() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext viewContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.all(
                //   Radius.circular(25.0),
                // ),
                ),
            child: Form(
              key: _formDialogKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Center(
                      child: Text(
                        S.of(context).template_title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Europa'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      child: TextFormField(
                        controller: searchTextController,
                        decoration: InputDecoration(
                          hintMaxLines: 2,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                          hintText: S.of(context).template_hint,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(fontSize: 17.0),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return S.of(context).validation_error_template_name;
                          } else if (templateFound) {
                            return S
                                .of(context)
                                .validation_error_template_name_exists;
                          } else {
                            templateName = value;
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(viewContext);
                        },
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa'),
                        ),
                        textColor: Colors.grey,
                      ),
                      FlatButton(
                        child: Text(S.of(context).save,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa')),
                        textColor: FlavorConfig.values.theme.primaryColor,
                        onPressed: () async {
                          if (!_formDialogKey.currentState.validate()) {
                            return;
                          }
                          Navigator.pop(viewContext, templateName);
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
        });
  }
}
