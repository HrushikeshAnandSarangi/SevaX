import 'dart:developer';

import 'package:doseform/doseform.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/request/widgets/skills_for_requests_widget.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/widgets/category_widget.dart';
import 'package:sevaexchange/views/exchange/widgets/project_selection.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/views/requests/onetomany_request_instructor_card.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

class TimeRequest extends StatefulWidget {
  final RequestModel requestModel;
  final bool isOfferRequest;
  final OfferModel offer;
  final bool isAdmin;
  final String timebankId;
  final ComingFrom comingFrom;
  final List<ProjectModel> projectModelList;
  final String projectId;
  final Function onCreateEventChanged;
  final RequestFormType formType;
  final TimebankModel timebankModel;
  UserModel selectedInstructorModel;
  final Function selectedInstructorModelChanged;
  bool instructorAdded;
  bool createEvent;
  final formKey;
  final RequestType requestType;
  final dateKey;

  TimeRequest(
      {this.requestModel,
      this.isOfferRequest,
      this.offer,
      this.timebankModel,
      this.isAdmin,
      this.selectedInstructorModel,
      this.timebankId,
      this.comingFrom,
      this.projectModelList,
      this.projectId,
      this.onCreateEventChanged,
      this.instructorAdded,
      this.createEvent,
      this.formType,
      this.selectedInstructorModelChanged,
      @required this.formKey,
      @required this.requestType,
      this.dateKey});

  @override
  _TimeRequestState createState() => _TimeRequestState();
}

class _TimeRequestState extends State<TimeRequest> {
  final _debouncer = Debouncer(milliseconds: 500);
  final profanityDetector = ProfanityDetector();
  Map<String, dynamic> _selectedSkillsMap = {};
  final TextEditingController searchTextController = TextEditingController();
  final searchOnChange = BehaviorSubject<String>();
  bool isPublicCheckboxVisible = false;
  RequestUtils requestUtils = RequestUtils();
  List<CategoryModel> selectedCategoryModels = [];
  String categoryMode;
  TextEditingController titleController = TextEditingController(),
      descriptionController = TextEditingController(),
      creditsController = TextEditingController(),
      volunteersController = TextEditingController();
  List<FocusNode> focusNodeList = List.generate(4, (_) => FocusNode());

  Widget addToProjectContainer() {
    if (requestUtils.isFromRequest(projectId: widget.projectId)) {
      if (isAccessAvailable(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID) &&
          widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
                    widget.createEvent)
                ? Container()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: ProjectSelection(
                            requestModel: widget.requestModel,
                            projectModelList: widget.projectModelList,
                            createEvent: widget.formType == RequestFormType.CREATE
                                ? widget.createEvent
                                : false,
                            selectedProject: (widget.requestModel.projectId != null &&
                                    widget.requestModel.projectId.isNotEmpty)
                                ? widget.projectModelList.firstWhere(
                                    (element) => element.id == widget.requestModel.projectId,
                                    orElse: () => null)
                                : null,
                            admin: isAccessAvailable(
                                widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                            setcreateEventState: () {
                              widget.createEvent = !widget.createEvent;
                              logger.d("SELECTED PROJECT ${widget.requestModel.projectId}");
                              setState(() {});
                              widget.onCreateEventChanged(widget.createEvent);
                            },
                            updateProjectIdCallback: (String projectid) {
                              widget.requestModel.projectId = projectid;
                              setState(() {});
                            }),
                      ),
                    ],
                  ),
            widget.createEvent
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.createEvent = !widget.createEvent;
                        widget.requestModel.projectId = '';
                        log('projectId2:  ' + widget.requestModel.projectId.toString());
                        log('createEvent2:  ' + widget.createEvent.toString());
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.check_box, size: 19, color: Colors.green),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            S.of(context).onetomanyrequest_create_new_event,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        );
      } else {
        widget.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
        widget.instructorAdded = false;
        widget.requestModel.selectedInstructor = null;

        return Container();
      }
    }
    return Container();
  }

  @override
  void initState() {
    super.initState();

    titleController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialTitle(widget.offer, widget.isOfferRequest)
        : widget.requestModel.title;
    descriptionController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialDescription(widget.offer, widget.isOfferRequest)
        : widget.requestModel.description;
    creditsController.text =
        widget.formType == RequestFormType.EDIT ? widget.requestModel.maxCredits.toString() : '';
    volunteersController.text = widget.formType == RequestFormType.EDIT
        ? widget.requestModel.numberOfApprovals.toString()
        : '';

    if (widget.formType == RequestFormType.EDIT) {
      getCategoryModels(widget.requestModel.categories).then((value) {
        selectedCategoryModels = value;
        setState(() {});
      });
    }
    // logger.d("TIME REQUEST selectedCategoryModels ${selectedCategoryModels.length}");
  }

  @override
  Widget build(BuildContext context) {
    return DoseForm(
      formKey: widget.formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(
          "${S.of(context).request_title}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        DoseTextField(
          isRequired: true,
          controller: titleController,
          currentNode: focusNodeList[0],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            requestUtils.updateExitWithConfirmationValue(context, 1, value);
          },
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: widget.requestType == RequestType.TIME
                ? S.of(context).request_title_hint
                : S.of(context).onetomanyrequest_title_hint,
            hintStyle: requestUtils.hintTextStyle,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          /*   initialValue: widget.formType == RequestFormType.CREATE
              ? requestUtils.getInitialTitle(widget.offer, widget.isOfferRequest)
              : widget.requestModel.title,*/
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).request_subject;
            } else if (profanityDetector.isProfaneString(value)) {
              return S.of(context).profanity_text_alert;
            } else if (value.substring(0, 1).contains('_') &&
                !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
              return S.of(context).creating_request_with_underscore_not_allowed;
            } else {
              widget.requestModel.title = value;
              return null;
            }
          },
        ),
        widget.instructorAdded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    S.of(context).selected_speaker,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Europa',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // SizedBox(
                        //   height: 15,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            UserProfileImage(
                              photoUrl: widget.requestModel.selectedInstructor.photoURL,
                              email: widget.requestModel.selectedInstructor.email,
                              userId: widget.requestModel.selectedInstructor.sevaUserID,
                              height: 75,
                              width: 75,
                              timebankModel: widget.timebankModel,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                widget.requestModel.selectedInstructor.fullname ??
                                    S.of(context).name_not_available,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                              height: 37,
                              padding: EdgeInsets.only(bottom: 0),
                              child: InkWell(
                                child: Icon(
                                  Icons.cancel_rounded,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  setState(() {
                                    widget.instructorAdded = false;
                                    widget.requestModel.selectedInstructor = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(height: 20),
                    Text(
                      S.of(context).select_a_speaker,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      controller: searchTextController,
                      onChanged: _search,
                      autocorrect: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                searchTextController.clear();
                              });
                            }),
                        alignLabelWithHint: true,
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                        filled: true,
                        fillColor: Colors.grey[200],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(15.7),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15.7)),
                        hintText: S.of(context).select_speaker_hint,
                        hintStyle: TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    Container(
                        child: Column(children: [
                      StreamBuilder<List<UserModel>>(
                        stream: SearchManager.searchUserInSevaX(
                          queryString: searchTextController.text,
                          //validItems: validItems,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            Text(snapshot.error.toString());
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                height: 48,
                                width: 40,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 12.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          List<UserModel> userList = snapshot.data;
                          userList.removeWhere((user) =>
                              user.sevaUserID == SevaCore.of(context).loggedInUser.sevaUserID ||
                              user.sevaUserID == widget.requestModel.sevaUserId);

                          if (userList.length == 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.transparent, width: 0),
                                      borderRadius:
                                          BorderRadius.vertical(bottom: Radius.circular(7.0)),
                                    ),
                                    borderOnForeground: false,
                                    shadowColor: Colors.white24,
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0, top: 11.0),
                                      child: Text(
                                        S.of(context).no_member_found,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          if (searchTextController.text.trim().length < 3) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.transparent, width: 0),
                                      borderRadius:
                                          BorderRadius.vertical(bottom: Radius.circular(7.0)),
                                    ),
                                    borderOnForeground: false,
                                    shadowColor: Colors.white24,
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0, top: 11.0),
                                      child: Text(
                                        S.of(context).validation_error_search_min_characters,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Scrollbar(
                              child: Center(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.transparent, width: 0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  borderOnForeground: false,
                                  shadowColor: Colors.white24,
                                  elevation: 5,
                                  child: LimitedBox(
                                    maxHeight: MediaQuery.of(context).size.width * 0.55,
                                    maxWidth: 90,
                                    child: ListView.separated(
                                        primary: false,
                                        //physics: NeverScrollableScroflutter card bordellPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: userList.length,
                                        separatorBuilder: (BuildContext context, int index) =>
                                            Divider(),
                                        itemBuilder: (context, index) {
                                          UserModel user = userList[index];

                                          List<String> timeBankIds =
                                              snapshot.data[index].favoriteByTimeBank ?? [];
                                          List<String> memberId = user.favoriteByMember ?? [];

                                          return OneToManyInstructorCard(
                                            userModel: user,
                                            timebankModel: widget.timebankModel,
                                            isAdmin: widget.isAdmin,
                                            //refresh: refresh,
                                            currentCommunity:
                                                SevaCore.of(context).loggedInUser.currentCommunity,
                                            loggedUserId:
                                                SevaCore.of(context).loggedInUser.sevaUserID,
                                            isFavorite: widget.isAdmin
                                                ? timeBankIds
                                                    .contains(widget.requestModel.timebankId)
                                                : memberId.contains(
                                                    SevaCore.of(context).loggedInUser.sevaUserID),
                                            addStatus: S.of(context).add,
                                            onAddClick: () {
                                              setState(() {
                                                // logger.d("#111 ${user.fullname}");
                                                widget.selectedInstructorModelChanged(user);
                                                widget.instructorAdded = true;
                                                widget.requestModel.selectedInstructor =
                                                    BasicUserDetails(
                                                  fullname: user.fullname,
                                                  email: user.email,
                                                  photoURL: user.photoURL,
                                                  sevaUserID: user.sevaUserID,
                                                );
                                              });
                                            },
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ])),
                  ])
                : Container(height: 0, width: 0),
        SizedBox(height: 30),
        OfferDurationWidget(
          key: widget.dateKey,
          title: "${S.of(context).request_duration} *",
          startTime: widget.formType == RequestFormType.EDIT
              ? getUpdatedDateTimeAccToUserTimezone(
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                  dateTime: DateTime.fromMillisecondsSinceEpoch(widget.requestModel.requestStart))
              : null,
          endTime: widget.formType == RequestFormType.EDIT
              ? getUpdatedDateTimeAccToUserTimezone(
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                  dateTime: DateTime.fromMillisecondsSinceEpoch(widget.requestModel.requestEnd))
              : null,
        ),
        HideWidget(hide: widget.formType == RequestFormType.EDIT, child: RepeatWidget()),
        SizedBox(height: 20),

        Text(
          "${S.of(context).request_description}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        DoseTextField(
          isRequired: true,
          controller: descriptionController,
          currentNode: focusNodeList[1],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            if (value != null && value.length > 5) {
              _debouncer.run(() async {
                selectedCategoryModels = await getCategoriesFromApi(value);
                categoryMode = S.of(context).suggested_categories;
                setState(() {});
              });
            }
            requestUtils.updateExitWithConfirmationValue(context, 9, value);
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                ? S.of(context).request_descrip_hint_text
                : S.of(context).request_description_hint,
            hintStyle: requestUtils.hintTextStyle,
          ),
          /*initialValue: widget.formType == RequestFormType.CREATE
              ? requestUtils.getInitialDescription(widget.offer, widget.isOfferRequest)
              : widget.requestModel.description,*/
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            }
            if (profanityDetector.isProfaneString(value)) {
              return S.of(context).profanity_text_alert;
            }
            widget.requestModel.description = value;
          },
        ),

        SizedBox(height: 20),
        // Choose Category and Sub Category
        CategoryWidget(
          requestModel: widget.requestModel,
          selectedCategoryModels: selectedCategoryModels,
          categoryMode: categoryMode,
        ),
        SizedBox(height: 20),
        HideWidget(
          hide: widget.formType == RequestFormType.EDIT,
          child: Text(
            S.of(context).provide_skills,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
        ),
        HideWidget(
          hide: widget.formType == RequestFormType.EDIT,
          child: SkillsForRequests(
            languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
            selectedSkills: _selectedSkillsMap,
            onSelectedSkillsMap: (skillMap) {
              if (skillMap.values != null && skillMap.values.length > 0) {
                _selectedSkillsMap = skillMap;
                // setState(() {});
              }
            },
          ),
        ),
        SizedBox(height: 20),
        addToProjectContainer(),
        SizedBox(height: 20),
        Text(
          S.of(context).max_credits,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DoseTextField(
                isRequired: true,
                controller: creditsController,
                currentNode: focusNodeList[2],
                onChanged: (v) {
                  requestUtils.updateExitWithConfirmationValue(context, 10, v);
                  if (v.isNotEmpty && int.parse(v) >= 0) {
                    widget.requestModel.maxCredits = int.parse(v);
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                      ? S.of(context).onetomanyrequest_participants_or_credits_hint
                      : S.of(context).max_credit_hint,
                  hintStyle: requestUtils.hintTextStyle,
                  // labelText: 'No. of volunteers',
                ),
/*
                initialValue: widget.formType == RequestFormType.EDIT
                    ? widget.requestModel.maxCredits.toString()
                    : '',
*/
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return S.of(context).enter_max_credits;
                  } else if (int.parse(value) < 0) {
                    return S.of(context).enter_max_credits;
                  } else if (int.parse(value) == 0) {
                    return S.of(context).enter_max_credits;
                  } else {
                    widget.requestModel.maxCredits = int.parse(value);
                    setState(() {});
                    return null;
                  }
                },
              ),
            ),
            infoButton(
              context: context,
              key: GlobalKey(),
              type: InfoType.MAX_CREDITS,
            ),
          ],
        ),
        SizedBox(height: 20),
        widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
            ? Text(
                S.of(context).total_no_of_participants,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              )
            : Text(
                S.of(context).number_of_volunteers,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
        DoseTextField(
          isRequired: true,
          controller: volunteersController,
          currentNode: focusNodeList[3],
          onChanged: (v) {
            requestUtils.updateExitWithConfirmationValue(context, 11, v);
            if (v.isNotEmpty && int.parse(v) >= 0) {
              widget.requestModel.numberOfApprovals = int.parse(v);
              setState(() {});
            }
          },
          decoration: InputDecoration(
            hintText: widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                ? S.of(context).onetomanyrequest_participants_or_credits_hint
                : S.of(context).number_of_volunteers,
            hintStyle: requestUtils.hintTextStyle,
            // labelText: 'No. of volunteers',
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_volunteer_count;
            } else if (int.parse(value) < 0) {
              return S.of(context).validation_error_volunteer_count_negative;
            } else if (int.parse(value) == 0) {
              return S.of(context).validation_error_volunteer_count_zero;
            } else {
              widget.requestModel.numberOfApprovals = int.parse(value);
              setState(() {});
              return null;
            }
          },
        ),
        CommonUtils.TotalCredits(
          context: context,
          requestModel: widget.requestModel,
          requestCreditsMode: TotalCreditseMode.CREATE_MODE,
        ),
        SizedBox(height: 15),
        AddImagesForRequest(
          onLinksCreated: (List<String> imageUrls) {
            widget.requestModel.imageUrls = imageUrls;
          },
          selectedList: widget.requestModel.imageUrls ?? [],
        ),
        Center(
          child: LocationPickerWidget(
            selectedAddress: widget.requestModel.address,
            location: widget.requestModel.location,
            onChanged: (LocationDataModel dataModel) {
              log("received data model");
              setState(() {
                widget.requestModel.location = dataModel.geoPoint;
                widget.requestModel.address = dataModel.location;
              });
            },
          ),
        ),
        HideWidget(
          hide: AppConfig.isTestCommunity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ConfigurationCheck(
              actionType: 'create_virtual_request',
              role: memberType(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
              child: OpenScopeCheckBox(
                  infoType: InfoType.VirtualRequest,
                  isChecked: widget.requestModel.virtualRequest,
                  checkBoxTypeLabel: CheckBoxType.type_VirtualRequest,
                  onChangedCB: (bool val) {
                    if (widget.requestModel.virtualRequest != val) {
                      widget.requestModel.virtualRequest = val;

                      if (!val) {
                        widget.requestModel.public = false;
                        isPublicCheckboxVisible = false;
                      } else {
                        isPublicCheckboxVisible = true;
                      }

                      setState(() {});
                    }
                  }),
            ),
          ),
        ),
        HideWidget(
          hide: !isPublicCheckboxVisible ||
              widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST ||
              widget.timebankId == FlavorConfig.values.timebankId,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TransactionsMatrixCheck(
              comingFrom: widget.comingFrom,
              upgradeDetails: AppConfig.upgradePlanBannerModel.public_to_sevax_global,
              transaction_matrix_type: 'create_public_request',
              child: ConfigurationCheck(
                actionType: 'create_public_request',
                role:
                    memberType(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                child: OpenScopeCheckBox(
                    infoType: InfoType.OpenScopeEvent,
                    isChecked: widget.requestModel.public,
                    checkBoxTypeLabel: CheckBoxType.type_Requests,
                    onChangedCB: (bool val) {
                      if (widget.requestModel.public != val) {
                        widget.requestModel.public = val;
                        setState(() {});
                      }
                    }),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    creditsController.dispose();
    volunteersController.dispose();
    searchTextController.dispose();
  }

  void _search(String queryString) {
    if (queryString.length == 3) {
      setState(() {
        searchOnChange.add(queryString);
      });
    } else {
      searchOnChange.add(queryString);
    }
  }
}
