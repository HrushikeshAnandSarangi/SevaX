import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/select_borrow_item.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/widgets/category_widget.dart';
import 'package:sevaexchange/views/exchange/widgets/project_selection.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class BorrowRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final String timebankId;
  final ComingFrom comingFrom;
  final Function onCreateEventChanged;
  final List<ProjectModel> projectModelList;
  final String projectId;
  final Function onDescriptionChanged;
  bool instructorAdded;
  bool createEvent;
  final RequestFormType formType;

  BorrowRequest(
      {this.isOfferRequest,
      this.offer,
      this.requestModel,
      this.timebankModel,
      this.timebankId,
      this.comingFrom,
      this.onCreateEventChanged,
      this.projectModelList,
      this.projectId,
      this.onDescriptionChanged,
      this.createEvent,
      this.instructorAdded,
      @required this.formType});

  @override
  _BorrowRequestState createState() => _BorrowRequestState();
}

class _BorrowRequestState extends State<BorrowRequest> {
  final profanityDetector = ProfanityDetector();
  int roomOrTool = 0;
  bool isPublicCheckboxVisible = false;
  RequestUtils requestUtils = RequestUtils();
  final _debouncer = Debouncer(milliseconds: 500);
  List<CategoryModel> selectedCategoryModels = [];
  String categoryMode;

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
                            setcreateEventState: () {
                              widget.createEvent = !widget.createEvent;
                              setState(() {});
                              widget.onCreateEventChanged(widget.createEvent);
                            },
                            createEvent: widget.formType == RequestFormType.CREATE
                                ? widget.createEvent
                                : false,
                            selectedProject: (widget.requestModel.projectId != null &&
                                    widget.requestModel.projectId.isNotEmpty)
                                ? widget.projectModelList.firstWhere(
                                    (element) => element.id == widget.requestModel.projectId,
                                    orElse: () => null)
                                : null,
                            requestModel: widget.requestModel,
                            projectModelList: widget.projectModelList,
                            admin: isAccessAvailable(
                                widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
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
    if (widget.formType == RequestFormType.EDIT) {
      if (widget.requestModel.roomOrTool == LendingType.ITEM.readable) {
        if (widget.requestModel.virtualRequest == true) {
          isPublicCheckboxVisible = true;
        }
        roomOrTool = 1;
      } else {
        isPublicCheckboxVisible = true;
        roomOrTool = 0;
      }

      getCategoryModels(widget.requestModel.categories).then((value) {
        selectedCategoryModels = value;
        setState(() {});
      });
    } else {
      //When creating request and switch is not touched (initialize as place)
      isPublicCheckboxVisible = true;
      widget.requestModel.roomOrTool = LendingType.PLACE.readable;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(
        "${S.of(context).request_title}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          requestUtils.updateExitWithConfirmationValue(context, 1, value);
        },
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: S.of(context).request_title_hint,
          hintStyle: requestUtils.hintTextStyle,
        ),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        initialValue: widget.formType == RequestFormType.CREATE
            ? requestUtils.getInitialTitle(widget.offer, widget.isOfferRequest)
            : widget.requestModel.title,
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
      SizedBox(height: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HideWidget(
            hide: widget.formType == RequestFormType.EDIT,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                S.of(context).borrow,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
            ),
          ),
          HideWidget(
            hide: widget.formType == RequestFormType.EDIT,
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: CupertinoSegmentedControl<int>(
                unselectedColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor,
                children: {
                  0: Padding(
                    padding: EdgeInsets.only(left: 14, right: 14),
                    child: Text(
                      S.of(context).place_text,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.only(left: 14, right: 14),
                    child: Text(
                      S.of(context).items,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                },
                borderColor: Colors.grey,
                padding: EdgeInsets.only(left: 0.0, right: 0.0),
                groupValue: roomOrTool,
                onValueChanged: (int val) {
                  if (val != roomOrTool) {
                    setState(() {
                      if (val == 0) {
                        widget.requestModel.roomOrTool = LendingType.PLACE.readable;
                        isPublicCheckboxVisible = true;
                      } else {
                        isPublicCheckboxVisible = false;
                        widget.requestModel.roomOrTool = LendingType.ITEM.readable;
                      }
                      roomOrTool = val;
                    });
                    log('Room or Tool: ' + roomOrTool.toString());
                  }
                },
                //groupValue: sharedValue,
              ),
            ),
          ),
          HideWidget(
            hide: roomOrTool == 0,
            child: Text(
              S.of(context).select_a_item_lending,
              style: TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          HideWidget(
            hide: roomOrTool == 0,
            child: SelectBorrowItem(
              selectedItems: widget.requestModel.borrowModel.requiredItems ?? {},
              onSelectedItems: (items) => {widget.requestModel.borrowModel.requiredItems = items},
            ),
          ),
        ],
      ),
      SizedBox(height: 30),
      OfferDurationWidget(
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
      SizedBox(height: 15),
      (widget.requestModel.requestType == RequestType.BORROW && roomOrTool == 1)
          ? Text(
              S.of(context).request_description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            )
          : Text(
              "${S.of(context).request_description}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            ),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          if (value != null && value.length > 5) {
            _debouncer.run(() async {
              selectedCategoryModels = await getCategoriesFromApi(value);
              categoryMode = S.of(context).suggested_categories;
            });
          }
          requestUtils.updateExitWithConfirmationValue(context, 9, value);
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: S.of(context).request_descrip_hint_text,
          hintStyle: requestUtils.hintTextStyle,
        ),
        initialValue: widget.formType == RequestFormType.CREATE
            ? requestUtils.getInitialDescription(widget.offer, widget.isOfferRequest)
            : widget.requestModel.description,
        keyboardType: TextInputType.multiline,
        maxLines: 1,
        // ignore: missing_return
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
      CategoryWidget(
        requestModel: widget.requestModel,
        selectedCategoryModels: selectedCategoryModels,
        categoryMode: categoryMode,
      ),
      SizedBox(height: 20),
      addToProjectContainer(),
      SizedBox(height: 15),
      Text(
        S.of(context).city + '/' + S.of(context).state,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      SizedBox(height: 10),
      Text(
        S.of(context).provide_address,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.grey,
        ),
      ),
      SizedBox(height: 10),
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
        hide: AppConfig.isTestCommunity || roomOrTool == 0,
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
              role: memberType(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
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
    ]);
  }
}
