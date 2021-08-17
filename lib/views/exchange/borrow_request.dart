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
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/select_borrow_item.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_request/project_selection.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class BorrowRequest extends StatefulWidget {
  GeoFirePoint location;
  String selectedAddress;
  Widget categoryWidget;
  final Widget requestDescription;
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

  BorrowRequest(
      {this.requestDescription,
      this.selectedAddress,
      this.location,
      this.categoryWidget,
      this.isOfferRequest,
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
      this.instructorAdded});

  @override
  _BorrowRequestState createState() => _BorrowRequestState();
}

class _BorrowRequestState extends State<BorrowRequest> {
  final profanityDetector = ProfanityDetector();
  int roomOrTool = 0;
  bool isPublicCheckboxVisible = false;
  RequestUtils requestUtils = RequestUtils();

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
                          createEvent: widget.createEvent,
                          requestModel: widget.requestModel,
                          projectModelList: widget.projectModelList,
                          selectedProject: null,
                          admin: isAccessAvailable(
                              widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                        ),
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
        initialValue: widget.offer != null && widget.isOfferRequest
            ? getOfferTitle(
                offerDataModel: widget.offer,
              )
            : "",
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
          SizedBox(height: 12),
          Text(
            S.of(context).borrow,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          CupertinoSegmentedControl<int>(
            unselectedColor: Colors.grey[200],
            selectedColor: Theme.of(context).primaryColor,
            children: {
              0: Padding(
                padding: EdgeInsets.only(left: 14, right: 14),
                child: Text(
                  L.of(context).place,
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.only(left: 14, right: 14),
                child: Text(
                  L.of(context).items,
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
                    roomOrTool = 0;
                  } else {
                    roomOrTool = 1;
                  }
                  roomOrTool = val;
                });
                log('Room or Tool: ' + roomOrTool.toString());
              }
            },
            //groupValue: sharedValue,
          ),
          SizedBox(height: 20),
          HideWidget(
            hide: roomOrTool == 0,
            child: Text(
              L.of(context).select_a_item_lending,
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
      ),
      RepeatWidget(),
      SizedBox(height: 15),
      widget.requestDescription,
      SizedBox(height: 20),
      //Same hint for Room and Tools ?
      // Choose Category and Sub Category
      widget.categoryWidget,
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
        L.of(context).provide_address,
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
          selectedAddress: widget.selectedAddress,
          location: widget.location,
          onChanged: (LocationDataModel dataModel) {
            log("received data model");
            setState(() {
              widget.location = dataModel.geoPoint;
              widget.selectedAddress = dataModel.location;
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
