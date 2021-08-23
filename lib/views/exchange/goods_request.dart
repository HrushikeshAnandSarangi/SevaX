import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_createRequest.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/category_widget.dart';
import 'package:sevaexchange/views/exchange/create_request/project_selection.dart';
import 'package:sevaexchange/views/exchange/create_request/request_enums.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class GoodsRequest extends StatefulWidget {
  final RequestModel requestModel;
  final List<ProjectModel> projectModelList;
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final ComingFrom comingFrom;
  final TimebankModel timebankModel;
  final String projectId;
  bool createEvent;
  bool instructorAdded;
  final Function onCreateEventChanged;
  final RequestFormType formType;

  GoodsRequest(
      {this.requestModel,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.comingFrom,
      this.timebankModel,
      this.projectId,
      this.onCreateEventChanged,
      this.createEvent,
      this.instructorAdded,
      this.projectModelList,
      @required this.formType});

  @override
  _GoodsRequestState createState() => _GoodsRequestState();
}

class _GoodsRequestState extends State<GoodsRequest> {
  final profanityDetector = ProfanityDetector();
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
                            selectedProject: (widget.requestModel.projectId != null &&
                                    widget.requestModel.projectId.isNotEmpty)
                                ? widget.projectModelList.firstWhere(
                                    (element) => element.id == widget.requestModel.projectId,
                                    orElse: () => null)
                                : null,
                            createEvent: widget.formType == RequestFormType.CREATE
                                ? widget.createEvent
                                : false,
                            requestModel: widget.requestModel,
                            projectModelList: widget.projectModelList,
                            admin: isAccessAvailable(
                                widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                            updateProjectIdCallback: (String projectid) {
                              //widget.requestModel.projectId = projectid;
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
      getCategoryModels(widget.requestModel.categories).then((value) {
        selectedCategoryModels = value;
        setState(() {});
      });
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
          hintText: S.of(context).request_goods_title_hint,
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
      TextFormField(
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
          hintText: S.of(context).goods_request_data_hint_text,
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
      SizedBox(height: 10),
      AddImagesForRequest(
        onLinksCreated: (List<String> imageUrls) {
          widget.requestModel.imageUrls = imageUrls;
        },
        selectedList: widget.requestModel.imageUrls ?? [],
      ),
      SizedBox(height: 20),
      addToProjectContainer(),
      SizedBox(height: 20),
      Text(
        S.of(context).request_goods_description,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      //TODO NOTE: 2 different [GoodsDynamicSelection] for edit and create
      GoodsDynamicSelection(
        selectedGoods: widget.requestModel.goodsDonationDetails.requiredGoods,
        onSelectedGoods: (goods) =>
            {widget.requestModel.goodsDonationDetails.requiredGoods = goods},
      ),
      SizedBox(height: 20),
      Text(
        S.of(context).request_goods_address,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      Text(
        S.of(context).request_goods_address_hint,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: widget.requestModel.goodsDonationDetails?.address ?? '',
        onChanged: (value) {
          requestUtils.updateExitWithConfirmationValue(context, 2, value);
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: S.of(context).request_goods_address_inputhint,
          hintStyle: requestUtils.hintTextStyle,
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_general_text;
          } else {
            widget.requestModel.goodsDonationDetails.address = value;
          }
          return null;
        },
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
