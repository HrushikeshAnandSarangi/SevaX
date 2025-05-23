import 'dart:developer';

import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_createRequest.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
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
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class GoodsRequest extends StatefulWidget {
  final RequestModel? requestModel;
  final List<ProjectModel>? projectModelList;
  final bool? isOfferRequest;
  final OfferModel? offer;
  final String? timebankId;
  final ComingFrom? comingFrom;
  final TimebankModel? timebankModel;
  final String? projectId;
  final Function? onCreateEventChanged;
  final RequestFormType? formType;
  final formKey;
  final dateKey;
  final bool? createEvent;
  bool? instructorAdded;

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
      required this.formType,
      required this.formKey,
      required this.dateKey});

  @override
  _GoodsRequestState createState() => _GoodsRequestState();
}

class _GoodsRequestState extends State<GoodsRequest> {
  final profanityDetector = ProfanityDetector();
  bool isPublicCheckboxVisible = false;
  RequestUtils requestUtils = RequestUtils();
  final _debouncer = Debouncer(milliseconds: 500);
  List<CategoryModel> selectedCategoryModels = [];
  String? categoryMode;
  TextEditingController titleController = TextEditingController(),
      descriptionController = TextEditingController(),
      addressController = TextEditingController();

  Widget addToProjectContainer() {
    if (requestUtils.isFromRequest(projectId: widget.projectId!)) {
      if (isAccessAvailable(widget.timebankModel!,
              SevaCore.of(context).loggedInUser.sevaUserID!) &&
          widget.requestModel!.requestMode == RequestMode.TIMEBANK_REQUEST) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.requestModel!.requestType ==
                        RequestType.ONE_TO_MANY_REQUEST &&
                    widget.createEvent!)
                ? Container()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: ProjectSelection(
                            setcreateEventState: () {
                              bool newValue = !widget.createEvent!;
                              widget.onCreateEventChanged!(newValue);
                              setState(() {});
                            },
                            selectedProject: (widget.requestModel!.projectId !=
                                        null &&
                                    widget.requestModel!.projectId!.isNotEmpty)
                                ? widget.projectModelList!.firstWhere(
                                    (element) =>
                                        element.id ==
                                        widget.requestModel!.projectId,
                                    orElse: () => null!)
                                : null,
                            createEvent:
                                widget.formType == RequestFormType.CREATE
                                    ? widget.createEvent
                                    : false,
                            requestModel: widget.requestModel,
                            projectModelList: widget.projectModelList,
                            admin: isAccessAvailable(widget.timebankModel!,
                                SevaCore.of(context).loggedInUser.sevaUserID!),
                            updateProjectIdCallback: (String projectid) {
                              //widget.requestModel.projectId = projectid;
                              widget.requestModel!.projectId = projectid;
                              setState(() {});
                            }),
                      ),
                    ],
                  ),
            widget.createEvent!
                ? GestureDetector(
                    onTap: () {
                      bool newValue = !widget.createEvent!;
                      widget.onCreateEventChanged!(newValue);
                      widget.requestModel!.projectId = '';
                      log('projectId2:  ' +
                          widget.requestModel!.projectId.toString());
                      log('createEvent2:  ' + widget.createEvent.toString());
                      setState(() {});
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
        widget.requestModel!.requestMode = RequestMode.PERSONAL_REQUEST;
        //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
        widget.instructorAdded = false;
        widget.requestModel!.selectedInstructor = null;

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
        : widget.requestModel!.title;
    descriptionController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialDescription(
            widget.offer, widget.isOfferRequest)
        : widget.requestModel!.description;
    addressController.text =
        widget.requestModel!.goodsDonationDetails?.address ?? '';

    if (widget.formType == RequestFormType.EDIT) {
      getCategoryModels(widget.requestModel!.categories!).then((value) {
        selectedCategoryModels = value;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoseForm(
      formKey: widget.formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value!.trimLeft().isEmpty) {
                  return S.of(context).request_subject;
                } else if (profanityDetector.isProfaneString(value)) {
                  return S.of(context).profanity_text_alert;
                } else if (value.substring(0, 1).contains('_') &&
                    !AppConfig.testingEmails
                        .contains(AppConfig.loggedInEmail)) {
                  return S
                      .of(context)
                      .creating_request_with_underscore_not_allowed;
                } else {
                  widget.requestModel!.title = value;
                  return null;
                }
              },
            ),
            SizedBox(height: 30),
            OfferDurationWidget(
              key: widget.dateKey,
              title: "${S.of(context).request_duration} *",
              startTime: widget.formType == RequestFormType.EDIT
                  ? getUpdatedDateTimeAccToUserTimezone(
                      timezoneAbb: SevaCore.of(context).loggedInUser.timezone!,
                      dateTime: DateTime.fromMillisecondsSinceEpoch(
                          widget.requestModel!.requestStart!))
                  : null,
              endTime: widget.formType == RequestFormType.EDIT
                  ? getUpdatedDateTimeAccToUserTimezone(
                      timezoneAbb: SevaCore.of(context).loggedInUser.timezone!,
                      dateTime: DateTime.fromMillisecondsSinceEpoch(
                          widget.requestModel!.requestEnd!))
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
            DoseTextField(
              isRequired: true,
              controller: descriptionController,
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

              keyboardType: TextInputType.multiline,
              maxLines: 1,
              // ignore: missing_return
              validator: (value) {
                if (value!.trimLeft().isEmpty) {
                  return S.of(context).validation_error_general_text;
                }
                if (profanityDetector.isProfaneString(value)) {
                  return S.of(context).profanity_text_alert;
                }
                widget.requestModel!.description = value;
              },
            ),
            SizedBox(height: 20),
            CategoryWidget(
              requestModel: widget.requestModel!,
              onDone: () {
                setState(() {});
              },
              initialSelectedCategories: selectedCategoryModels,
              initialCategoryMode: categoryMode ?? '',
            ),
            SizedBox(height: 10),
            AddImagesForRequest(
              onLinksCreated: (List<String> imageUrls) {
                widget.requestModel!.imageUrls = imageUrls;
              },
              selectedList: widget.requestModel!.imageUrls ?? [],
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
            GoodsDynamicSelection(
              selectedGoods:
                  widget.requestModel!.goodsDonationDetails!.requiredGoods!,
              onSelectedGoods: (goods) => {
                widget.requestModel!.goodsDonationDetails!.requiredGoods =
                    Map<String, String>.from(goods)
              },
              onRemoveGoods: (goods) {
                // Implement your logic for removing goods here, for example:
                widget.requestModel!.goodsDonationDetails!.requiredGoods
                    .remove(goods);
                setState(() {});
              },
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
            DoseTextField(
              isRequired: true,
              controller: addressController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // initialValue: ,
              onChanged: (value) {
                requestUtils.updateExitWithConfirmationValue(context, 2, value);
              },
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                errorMaxLines: 2,
                hintText: S.of(context).request_goods_address_inputhint,
                hintStyle: requestUtils.hintTextStyle,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: (value) {
                if (value!.trimLeft().isEmpty) {
                  return S.of(context).validation_error_general_text;
                } else {
                  widget.requestModel!.goodsDonationDetails!.address = value;
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
                  role: MemberType.MEMBER,
                  child: OpenScopeCheckBox(
                      infoType: InfoType.VirtualRequest,
                      isChecked: widget.requestModel!.virtualRequest!,
                      checkBoxTypeLabel: CheckBoxType.type_VirtualRequest,
                      onChangedCB: (bool? val) {
                        if (widget.requestModel != null &&
                            widget.requestModel!.virtualRequest != val) {
                          widget.requestModel!.virtualRequest = val ?? false;

                          if (!(val ?? false)) {
                            widget.requestModel!.public = false;
                            isPublicCheckboxVisible = false;
                          } else {
                            isPublicCheckboxVisible = true;
                          }

                          setState(() {});
                        }
                      }),
                ),
              ),
              secondChild: SizedBox.shrink(),
            ),
            HideWidget(
              hide: !isPublicCheckboxVisible ||
                  widget.requestModel!.requestMode! ==
                      RequestMode.PERSONAL_REQUEST ||
                  widget.timebankId == FlavorConfig.values.timebankId,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TransactionsMatrixCheck(
                  comingFrom: widget.comingFrom!,
                  upgradeDetails:
                      AppConfig.upgradePlanBannerModel!.public_to_sevax_global!,
                  transaction_matrix_type: 'create_public_request',
                  child: ConfigurationCheck(
                    actionType: 'create_public_request',
                    role: MemberType.MEMBER,
                    child: OpenScopeCheckBox(
                        infoType: InfoType.OpenScopeEvent,
                        isChecked: widget.requestModel!.public!,
                        checkBoxTypeLabel: CheckBoxType.type_Requests,
                        onChangedCB: (bool? val) {
                          if (widget.requestModel != null &&
                              widget.requestModel!.public != val) {
                            widget.requestModel!.public = val ?? false;
                            setState(() {});
                          }
                        }),
                  ),
                ),
              ),
              secondChild: SizedBox.shrink(),
            ),
          ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
  }
}
