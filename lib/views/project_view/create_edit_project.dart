//import 'dart:html';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:doseform/doseform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/module/index.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/components/sevaavatar/projects_avtaar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/project_template_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/sponsors/sponsors_widget.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/watchdog.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
import 'package:sevaexchange/components/sevaavatar/project_cover_photo.dart';

import '../../flavor_config.dart';

class CreateEditProject extends StatefulWidget {
  final bool isCreateProject;
  final String timebankId;
  final String projectId;
  final ProjectTemplateModel projectTemplateModel;

  CreateEditProject(
      {this.isCreateProject, this.timebankId, this.projectId, this.projectTemplateModel});

  @override
  _CreateEditProjectState createState() => _CreateEditProjectState();
}

class _CreateEditProjectState extends State<CreateEditProject> {
  final _formKey = GlobalKey<DoseFormState>();
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
  var focusNodes = List.generate(5, (_) => FocusNode());

  bool templateFound = false;
  final profanityDetector = ProfanityDetector();
  bool makePublicBool = false;

  // bool isPulicCheckboxVisible = false;
  CommunityModel communityModel;
  End end = End();

  bool wasCreatedFromRecurring = false;

  final _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();

    if (!widget.isCreateProject) {
      getData();
    } else {
      setState(() {
        if (widget.projectTemplateModel != null) {
          this.projectModel.mode = widget.projectTemplateModel.mode;
          this.projectModel.mode == ProjectMode.TIMEBANK_PROJECT
              ? sharedValue = 0
              : sharedValue = 1;
        } else {
          this.projectModel.mode = ProjectMode.TIMEBANK_PROJECT;
        }
        projectModel.public = false;
      });
    }

    getCommunity();
    setState(() {});

    searchTextController.addListener(() {
      _debouncer.run(() {
        if (searchTextController.text.isEmpty) {
          setState(() {});
        } else {
          if (templateName != searchTextController.text) {
            SearchManager.searchTemplateForDuplicate(queryString: searchTextController.text)
                .then((commFound) {
              if (commFound) {
                setState(() {
                  templateFound = true;
                });
              } else {
                setState(() {
                  templateFound = false;
                });
              }
            });
          }
        }
      });
    });
  }

  Future<void> getCommunity() async {
    timebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );
    communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: timebankModel.communityId);
    if (widget.isCreateProject) {
      location = communityModel.location;
      selectedAddress = timebankModel.address;
    } else {
      if (projectModel.location == null ||
          projectModel.address == null ||
          projectModel.address == '') {
        location = communityModel.location;
        selectedAddress = timebankModel.address;
      }
    }
    setState(() {});
  }

  void getData() async {
    await FirestoreManager.getProjectFutureById(projectId: widget.projectId).then((onValue) {
      projectModel = onValue;
      wasCreatedFromRecurring = projectModel.isRecurring || projectModel.autoGenerated;

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
          dateTime: DateTime.fromMillisecondsSinceEpoch(projectModel.startTime));
      endDate = getUpdatedDateTimeAccToUserTimezone(
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
          dateTime: DateTime.fromMillisecondsSinceEpoch(projectModel.endTime));
    }

    return ExitWithConfirmation(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              globals.projectsAvtaarURL = null;
              globals.projectsCoverURL = null;
              Navigator.of(context).pop();
            },
          ),
          elevation: 0.5,
          // automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(
            widget.isCreateProject ? S.of(context).create_project : S.of(context).edit_project,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: widget.isCreateProject
            ? DoseForm(
          formKey: _formKey,
                child: createProjectForm,
              )
            : isDataLoaded
                ? DoseForm(
          formKey: _formKey,
                    child: createProjectForm,
                  )
                : LoadingIndicator(),
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
        if (isAccessAvailable(snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID)) {
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            width: double.infinity,
            child: CupertinoSegmentedControl<int>(
              selectedColor: Theme.of(context).primaryColor,
              children: {
                0: Text(
                  timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                      ? S.of(context).seva_community_event
                      : S.of(context).seva + timebankModel.name + S.of(context).event,
                  style: TextStyle(fontSize: 10.0),
                ),
                1: Text(
                  S.of(context).personal_event,
                  style: TextStyle(fontSize: 10.0),
                ),
              },
              borderColor: Colors.grey,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              groupValue: sharedValue,
              onValueChanged: (int val) {
                if (val != sharedValue) {
                  setState(() {
                    if (val == 0) {
                      projectModel.mode = ProjectMode.TIMEBANK_PROJECT;
                    } else {
                      projectModel.mode = ProjectMode.MEMBER_PROJECT;
                    }
                    sharedValue = val;
                  });
                }
              },
              //groupValue: sharedValue,
            ),
          );
        } else {
          this.projectModel.mode = ProjectMode.MEMBER_PROJECT;
          return Container();
        }
      },
    );
  }

  Widget get createProjectForm {
    return Column(
      children: [
        Builder(
          builder: (context) => SingleChildScrollView(
            controller: _controller,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // widget.isCreateProject ? projectSwitch : Container(),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          widget.isCreateProject
                              ? widget.projectTemplateModel != null
                                  ? ProjectCoverPhoto(
                                      cover_url: widget.projectTemplateModel.cover_url ??
                                          defaultProjectImageURL)
                                  : ProjectCoverPhoto()
                              : ProjectCoverPhoto(
                                  cover_url: projectModel.cover_url != null
                                      ? projectModel.cover_url ?? defaultProjectImageURL
                                      : defaultProjectImageURL,
                                ),
                          Text(''),
                          !widget.isCreateProject
                              ? Text(
                                  "${S.of(context).cover_picture_label_event}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 25),
                          widget.isCreateProject
                              ? widget.projectTemplateModel != null
                                  ? ProjectAvtaar(
                                      photoUrl: widget.projectTemplateModel.photoUrl ??
                                          defaultProjectImageURL)
                                  : ProjectAvtaar()
                              : ProjectAvtaar(
                                  photoUrl: projectModel.photoUrl != null
                                      ? projectModel.photoUrl ?? defaultProjectImageURL
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
                  headingText("${S.of(context).project_name} *"),
                  DoseTextField(
                    isRequired: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      ExitWithConfirmation.of(context).fieldValues[1] = value;
                      projectModel.name = value;
                    },
                    textCapitalization: TextCapitalization.sentences,
                    // inputFormatters: <TextInputFormatter>[
                    //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
                    // ],
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
                      } else if (value.substring(0, 1).contains('_') &&
                          !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
                        return 'Creating event with "_" is not allowed';
                      } else {
                        projectModel.name = value;
                      }

                      return null;
                    },
                  ),
                  widget.isCreateProject
                      ? widget.projectTemplateModel != null
                          ? OfferDurationWidget(
                              title: ' ${S.of(context).project_duration} *',
                              startTime: startDate,
                              endTime: endDate,
                            )
                          : OfferDurationWidget(
                              title: ' ${S.of(context).project_duration} *',
                              //startTime: CalendarWidgetState.startDate,
                              //endTime: CalendarWidgetState.endDate
                            )
                      : OfferDurationWidget(
                          title: ' ${S.of(context).project_duration}',
                          startTime: startDate,
                          endTime: endDate,
                        ),

                  widget.isCreateProject
                      ? RepeatWidget()
                      : projectModel.isRecurring || projectModel.autoGenerated
                          ? Container()
                          : RepeatWidget(),

                  Text(
                    dateTimeEroor,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  headingText(S.of(context).event_description + " *"),
                  DoseTextField(
                    isRequired: true,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      hintText: S.of(context).project_mission_statement_hint,
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(focusNodes[2]);
                    },
                    textInputAction: TextInputAction.next,
                    currentNode: focusNodes[1],
                    initialValue: widget.isCreateProject
                        ? widget.projectTemplateModel != null
                            ? widget.projectTemplateModel.description
                            : ""
                        : projectModel.description ?? "",
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    //  initialValue: timebankModel.missionStatement,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      ExitWithConfirmation.of(context).fieldValues[2] = value;

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

                      return null;
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.all(8),
                  ),

                  headingText(S.of(context).registration_link),
                  DoseTextField(
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      hintText: S.of(context).registration_link_hint,
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(focusNodes[3]);
                    },
                    textInputAction: TextInputAction.next,
                    currentNode: focusNodes[2],
                    initialValue: widget.isCreateProject
                        ? widget.projectTemplateModel != null
                            ? widget.projectTemplateModel.registrationLink
                            : ""
                        : projectModel.registrationLink ?? "",
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (value) {
                      projectModel.registrationLink = value;
                    },
                    onChanged: (value) {
                      ExitWithConfirmation.of(context).fieldValues[3] = value;

                      projectModel.registrationLink = value;
                    },
                    validator: (value) {
                      RegExp regExp = RegExp(
                        r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
                        caseSensitive: false,
                        multiLine: false,
                      );
                      if (value.isNotEmpty && !regExp.hasMatch(value)) {
                        return 'Add valid registration url';
                      } else {
                        projectModel.registrationLink = value;
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  headingText(
                    S.of(context).email.firstWordUpperCase(),
                  ),
                  DoseTextField(
                    isRequired: true,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(focusNodes[4]);
                    },
                    textInputAction: TextInputAction.next,
                    currentNode: focusNodes[3],
                    // cursorColor: Colors.black54,
                    validator: _validateEmailId,
                    onSaved: (value) {
                      ExitWithConfirmation.of(context).fieldValues[4] = value;
                      projectModel.emailId = value;
                    },
                    onChanged: (value) {
                      projectModel.emailId = value;
                    },
                    initialValue: widget.isCreateProject
                        ? widget.projectTemplateModel != null
                            ? widget.projectTemplateModel.emailId ??
                                SevaCore.of(context).loggedInUser.email
                            : projectModel.emailId ?? SevaCore.of(context).loggedInUser.email
                        : SevaCore.of(context).loggedInUser.email,
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
                  SizedBox(
                    height: 10,
                  ),
                  SponsorsWidget(
                    title: S.of(context).add_event_sponsors_text,
                    sponsorsMode: widget.isCreateProject ? SponsorsMode.CREATE : SponsorsMode.EDIT,
                    sponsors: projectModel.sponsors,
                    isAdminVerified: false,
                    onSponsorsAdded: (
                      List<SponsorDataModel> sponsorsData,
                      SponsorDataModel addedSponsors,
                    ) {
                      setState(() {
                        projectModel.sponsors = sponsorsData;
                      });
                      logger.i(
                          'Added Sponsors in Event:\n Name:${addedSponsors.name}\nLogo:${addedSponsors.logo}\nCreatedBy:${addedSponsors.createdBy}\nCreatedAt:${addedSponsors.createdAt}\n----------------------------------------------------------\n');
                    },
                    onSponsorsRemoved: (
                      List<SponsorDataModel> sponsorsData,
                      SponsorDataModel removedSponsors,
                    ) {
                      setState(() {
                        projectModel.sponsors = sponsorsData;
                      });

                      logger.i(
                          'Remove Sponsors from Event:\n Name:${removedSponsors.name}\nLogo:${removedSponsors.logo}\nCreatedBy:${removedSponsors.createdBy}\nCreatedAt:${removedSponsors.createdAt}\n----------------------------------------------------------\n');
                    },
                    onError: (error) {
                      logger.e(error);
                    },
                  ),
                  SizedBox(
                    height: 10,
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
                      selectedAddress: widget.isCreateProject ? selectedAddress : selectedAddress,
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
                            headingText(S.of(context).save_as_template),
                          ],
                        )
                      : Offstage(),
                  HideWidget(
                    hide: AppConfig.isTestCommunity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ConfigurationCheck(
                        actionType: 'create_virtual_event',
                        role:
                            memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                        child: OpenScopeCheckBox(
                            infoType: InfoType.VirtualRequest,
                            isChecked: projectModel.virtualProject,
                            checkBoxTypeLabel: CheckBoxType.type_VirtualRequest,
                            onChangedCB: (bool val) {
                              if (projectModel.virtualProject != val) {
                                this.projectModel.virtualProject = val;

                                // if (!val) {
                                //   projectModel.public = false;
                                //   isPulicCheckboxVisible = false;
                                // } else {
                                //   isPulicCheckboxVisible = true;
                                // }

                                setState(() {});
                              }
                            }),
                      ),
                    ),
                  ),

                  // HideWidget(
                  //   hide: !isPulicCheckboxVisible,
                  //   child:
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: TransactionsMatrixCheck(
                      comingFrom: ComingFrom.Projects,
                      upgradeDetails: AppConfig.upgradePlanBannerModel.public_to_sevax_global,
                      transaction_matrix_type: 'create_public_event',
                      child: ConfigurationCheck(
                        actionType: 'create_public_event',
                        role:
                            memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                        child: OpenScopeCheckBox(
                            infoType: InfoType.OpenScopeEvent,
                            isChecked: projectModel.public,
                            checkBoxTypeLabel: CheckBoxType.type_Events,
                            onChangedCB: (bool val) {
                              if (projectModel.public != val) {
                                this.projectModel.public = val;
                                log('value ${projectModel.public}');
                                setState(() {});
                              }
                            }),
                      ),
                    ),
                  ),
                  // ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   child: OpenScopeCheckBox(
                  //       infoType: InfoType.VirtualRequest,
                  //       isChecked: projectModel.virtualProject,
                  //       checkBoxTypeLabel: CheckBoxType.type_VirtualRequest,
                  //       onChangedCB: (bool val) {
                  //         if (projectModel.virtualProject != val) {
                  //           this.projectModel.virtualProject = val;
                  //           setState(() {});
                  //         }
                  //       }),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: CustomElevatedButton(
                        onPressed: () async {
                          var connResult = await Connectivity().checkConnectivity();
                          if (connResult == ConnectivityResult.none) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).check_internet),
                                action: SnackBarAction(
                                  label: S.of(context).dismiss,
                                  onPressed: () =>
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                ),
                              ),
                            );
                            return;
                          }

                          FocusScope.of(context).requestFocus(FocusNode());
                          // show a dialog
                          projectModel.startTime = OfferDurationWidgetState.starttimestamp;
                          projectModel.endTime = OfferDurationWidgetState.endtimestamp;
                          if (widget.isCreateProject) {
                            if (_formKey.currentState.validate()) {
                              if (projectModel.startTime == 0 || projectModel.endTime == 0) {
                                showDialogForTitle(
                                  dialogTitle: S.of(context).validation_error_no_date,
                                );
                                return;
                              }
                              projectModel.liveMode = !AppConfig.isTestCommunity;
                              if (projectModel.public) {
                                projectModel.timebanksPosted = [
                                  widget.timebankId,
                                  FlavorConfig.values.timebankId
                                ];
                              } else {
                                projectModel.timebanksPosted = [
                                  widget.timebankId,
                                ];
                              }

                              projectModel.communityId =
                                  SevaCore.of(context).loggedInUser.currentCommunity;
                              projectModel.completedRequests = [];
                              projectModel.pendingRequests = [];
                              projectModel.timebankId = widget.timebankId;
                              projectModel.photoUrl = globals.projectsAvtaarURL;
                              projectModel.cover_url = globals.projectsCoverURL;
                              projectModel.emailId =
                                  projectModel.emailId ?? SevaCore.of(context).loggedInUser.email;
                              projectModel.location = location;
                              int timestamp = DateTime.now().millisecondsSinceEpoch;
                              projectModel.createdAt = timestamp;

                              projectModel.creatorId = SevaCore.of(context).loggedInUser.sevaUserID;
                              projectModel.members = [];
                              projectModel.address = selectedAddress;
                              projectModel.id = Utils.getUuid();
                              projectModel.softDelete = false;
                              projectModel.communityName =
                                  communityModel.name ?? timebankModel.name;
                              projectModel.parentEventId = projectModel.id;

                              if (saveAsTemplate) {
                                projectTemplateModel.communityId = projectModel.communityId;
                                projectTemplateModel.timebankId = projectModel.timebankId;
                                projectTemplateModel.id = Utils.getUuid();
                                projectTemplateModel.name = projectModel.name;
                                projectTemplateModel.templateName = templateName;
                                projectTemplateModel.photoUrl = projectModel.photoUrl;
                                projectTemplateModel.cover_url = projectModel.cover_url;
                                projectTemplateModel.description = projectModel.description;
                                projectTemplateModel.registrationLink =
                                    projectModel.registrationLink;
                                projectTemplateModel.creatorId = projectModel.creatorId;
                                projectTemplateModel.createdAt = projectModel.createdAt;
                                projectTemplateModel.mode = projectModel.mode;
                                projectTemplateModel.softDelete = false;
                                projectTemplateModel.emailId = projectModel.emailId;

                                await FirestoreManager.createProjectTemplate(
                                    projectTemplateModel: projectTemplateModel);
                              }

                              if (RepeatWidgetState.isRecurring) {
                                projectModel.isRecurring = true;
                                projectModel.recurringDays = RepeatWidgetState.getRecurringdays();
                                projectModel.occurenceCount = 1;
                                end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
                                end.on = end.endType == "on"
                                    ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
                                    : null;
                                end.after = (end.endType == "after"
                                    ? int.parse(RepeatWidgetState.after)
                                    : null);
                                projectModel.end = end;

                                String messagingRoomId =
                                    await ProjectMessagingRoomHelper.createMessagingRoomForEvent(
                                  projectModel: projectModel,
                                  projectCreator: SevaCore.of(context).loggedInUser,
                                );

                                projectModel.associatedMessaginfRoomId = messagingRoomId;

                                if (projectModel.isRecurring &&
                                    projectModel.recurringDays.length == 0) {
                                  showDialogForTitle(
                                      dialogTitle:
                                          S.of(context).validation_error_empty_recurring_days);
                                  return;
                                }
                                showProgressDialog(S.of(context).creating_project);

                                await WatchDog.createRecurringEvents(projectModel: projectModel);
                              } else {
                                await ProjectMessagingRoomHelper.createProjectWithMessaging(
                                  projectModel: projectModel,
                                  projectCreator: SevaCore.of(context).loggedInUser,
                                );
                              }

                              globals.projectsAvtaarURL = null;
                              globals.projectsCoverURL = null;
                              globals.webImageUrl = null;

                              if (dialogContext != null) {
                                Navigator.pop(dialogContext);
                              }
                              //TODO rest
                              _formKey.currentState.reset();

                              KloudlessWidgetManager<CreateMode, ProjectModel>().syncCalendar(
                                context: context,
                                builder:
                                    KloudlessWidgetBuilder().fromContext<CreateMode, ProjectModel>(
                                  context: context,
                                  model: projectModel,
                                  id: projectModel.id,
                                ),
                              );

                              // Stay Adding calendar Integration
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } else {}
                          } else {
                            // return;

                            if (_formKey.currentState.validate()) {
                              projectModel.startTime = OfferDurationWidgetState.starttimestamp;
                              projectModel.endTime = OfferDurationWidgetState.endtimestamp;
                              projectModel.address = selectedAddress;
                              projectModel.location = location;
                              if (projectModel.public) {
                                projectModel.timebanksPosted = [
                                  projectModel.timebankId,
                                  FlavorConfig.values.timebankId
                                ];
                              } else {
                                projectModel.timebanksPosted = [projectModel.timebankId];
                              }

                              if (globals.projectsAvtaarURL != null) {
                                projectModel.photoUrl = globals.projectsAvtaarURL;
                              }

                              if (globals.projectsCoverURL != null) {
                                projectModel.cover_url = globals.projectsCoverURL;
                              }

                              if (projectModel.startTime == 0 || projectModel.endTime == 0) {
                                showDialogForTitle(
                                    dialogTitle: S.of(context).validation_error_no_date);
                                return;
                              }

                              if (projectModel.address == null || this.selectedAddress == null) {
                                this.locationError =
                                    S.of(context).validation_error_location_mandatory;
                                showDialogForTitle(
                                  dialogTitle: S.of(context).validation_error_add_project_location,
                                );
                                return;
                              }

                              // showProgressDialog(S.of(context).updating_project);
                              //THIS CONDITION CHECKS IF THE EVENT WAS PREVIOUS NON RECURRING AND IS NOW MADE AS RECURRING
                              if (!wasCreatedFromRecurring && RepeatWidgetState.isRecurring) {
                                projectModel.isRecurring = true;
                                projectModel.recurringDays = RepeatWidgetState.getRecurringdays();
                                projectModel.occurenceCount = 1;
                                end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
                                end.on = end.endType == "on"
                                    ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
                                    : null;
                                end.after = (end.endType == "after"
                                    ? int.parse(RepeatWidgetState.after)
                                    : null);
                                projectModel.end = end;

                                //CHECK TO SEE IF ADMIN WANTS TO CLONE ALL THE REQUESTS INSIDE OR JUST CREATE EMPTY

                                await DialogsManager.showDilaogWithTitle(
                                  negativeTitle: S.of(context).do_not_copy,
                                  positiveTitle: S.of(context).proceed_with_copying,
                                  context: context,
                                  title: S.of(context).copy_requests_in_events,
                                ).then((value) async {
                                  if (value)
                                    await WatchDog.cloneAndCreateRecurringEventsFromExisting(
                                            eventModel: projectModel)
                                        .then((value) => logger.d(""))
                                        .catchError((onError) => {
                                              logger.d(onError.toString()),
                                            });
                                  else
                                    await WatchDog.createRecurringEventsFromExisting(projectModel);
                                }).catchError((onError) {
                                  logger.e("Error " + onError.toString());
                                });
                              } else {
                                //FOLLOW NORMAL PROCEDURE
                                //This segment updates events
                                if (projectModel.isRecurring || projectModel.autoGenerated) {
                                  WatchDog.showDialogForUpdation(
                                      context: context,
                                      updateSingleEvent: () async {
                                        await FirestoreManager.updateProject(
                                          projectModel: projectModel,
                                        );
                                      },
                                      updateSubsequentEvents: () async {
                                        WatchDog.updateSubsequentEvents(projectModel);
                                      });
                                } else {
                                  await FirestoreManager.updateProject(
                                    projectModel: projectModel,
                                  );
                                }
                              }
                              // return;
                              //ENDS HERE

                              globals.projectsAvtaarURL = null;
                              globals.projectsCoverURL = null;
                              globals.webImageUrl = null;

                              if (dialogContext != null) {
                                Navigator.pop(dialogContext);
                              }
                              //TODO reset
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
          ),
        ),
      ],
    );
  }

  void moveToTop() {
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
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
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
//     String address = await LocationUtility().getFormattedAddress(
//       location.latitude,
//       location.longitude,
//     );
//     setState(() {
//       this.selectedAddress = address;
//     });
// //    timebank.updateValueByKey('locationAddress', address);
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
    RegExp emailPattern =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return S.of(context).validation_error_invalid_email;
    if (!emailPattern.hasMatch(value)) return S.of(context).validation_error_invalid_email;
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
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Europa'),
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
                          contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                          hintText: S.of(context).template_hint,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(fontSize: 17.0),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        onChanged: (value) {
                          ExitWithConfirmation.of(context).fieldValues[5] = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return S.of(context).validation_error_template_name;
                          } else if (templateFound) {
                            return S.of(context).validation_error_template_name_exists;
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
                      CustomTextButton(
                        color: HexColor("#d2d2d2"),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(viewContext);
                        },
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      CustomTextButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(S.of(context).save,
                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
                        onPressed: () async {
                          if (!_formDialogKey.currentState.validate()) {
                            return;
                          }
                          Navigator.pop(viewContext, templateName);
                        },
                      ),
                      SizedBox(
                        width: 10.0,
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
