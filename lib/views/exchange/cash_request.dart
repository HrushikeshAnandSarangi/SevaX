import 'dart:convert';
import 'dart:developer';

import 'package:doseform/doseform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/constants/dropdown_currency_constants.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/currency_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/payment_detail_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/payment_detail/capture_payment_detail_widget.dart';
import 'package:sevaexchange/views/exchange/widgets/category_widget.dart';
import 'package:sevaexchange/views/exchange/widgets/project_selection.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/widgets/custom_drop_down.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class CashRequest extends StatefulWidget {
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
  final formKey;
  final dateKey;


  CashRequest({
    this.projectModelList,
    this.isOfferRequest,
    this.offer,
    this.requestModel,
    this.timebankId,
    this.comingFrom,
    this.timebankModel,
    this.projectId,
    this.createEvent,
    this.instructorAdded,
    this.onCreateEventChanged,
    @required this.formType,
    @required this.formKey, this.dateKey,
  });

  @override
  _CashRequestState createState() => _CashRequestState();
}

class _CashRequestState extends State<CashRequest> {
  final profanityDetector = ProfanityDetector();
  bool isPublicCheckboxVisible = false;
  RequestUtils requestUtils = RequestUtils();
  final _debouncer = Debouncer(milliseconds: 500);
  List<CategoryModel> selectedCategoryModels = [];
  String categoryMode;
  PaymentDetailModel paymentDetailModel;
  final LayerLink _layerLink = LayerLink();
  List<CurrencyModel> currencyList = CurrencyModel().getCurrency();
  int indexSelected = -1;
  bool isDropdownOpened = false;
  bool isNeedCloseDropDown = false;
  String currencyCode = 'USD';
  String defaultFlagUrl = kDefaultFlagImageUrl;
  TextEditingController titleController = TextEditingController(),
      descriptionController = TextEditingController(),
      targetDonationController = TextEditingController(),
      minimumAmountController = TextEditingController();
  FocusNode _titleNode = FocusNode(), _descriptionNode = FocusNode(), _targetDonationNode = FocusNode(),minimumNode = FocusNode();
  Widget addToProjectContainer() {
    if (requestUtils.isFromRequest(projectId: widget.projectId)) {
      if (isAccessAvailable(widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID) &&
          widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      createEvent:
                          widget.formType == RequestFormType.CREATE ? widget.createEvent : false,
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
    paymentDetailModel =
        requestUtils.initializePaymentModel(cashModel: widget.requestModel.cashModel);

    titleController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialTitle(widget.offer, widget.isOfferRequest)
        : widget.requestModel.title;
    descriptionController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialDescription(widget.offer, widget.isOfferRequest)
        : widget.requestModel.description;
    targetDonationController.text = widget.formType == RequestFormType.CREATE
        ? requestUtils.getInitialAmount(widget.offer, widget.isOfferRequest)
        : widget.requestModel.cashModel.targetAmount.toString();
    minimumAmountController.text = minimumAmountController.text =
        widget.formType == RequestFormType.CREATE
            ? ''
            : widget.requestModel.cashModel.minAmount.toString();

    if (widget.formType == RequestFormType.EDIT) {
      currencyCode = widget.requestModel.cashModel.requestCurrencyType;
      defaultFlagUrl = widget.requestModel.cashModel.requestCurrencyFlag;
      getCategoryModels(widget.requestModel.categories).then((value) {
        selectedCategoryModels = value;
        setState(() {});
      });
    } else if (widget.formType == RequestFormType.CREATE) {
      widget.requestModel.cashModel.requestCurrencyType = currencyCode;
      widget.requestModel.cashModel.requestCurrencyFlag = defaultFlagUrl;
    }
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
          currentNode: _titleNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            requestUtils.updateExitWithConfirmationValue(context, 1, value);
          },
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: S.of(context).cash_request_title_hint,
            hintStyle: requestUtils.hintTextStyle,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
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
          currentNode: _descriptionNode,
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
            hintText: S.of(context).cash_request_data_hint_text,
            hintStyle: requestUtils.hintTextStyle,
          ),
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
        AddImagesForRequest(
          onLinksCreated: (List<String> imageUrls) {
            widget.requestModel.imageUrls = imageUrls;
          },
          selectedList: widget.requestModel.imageUrls ?? [],
        ),
        SizedBox(height: 20),
        Text(
          S.of(context).request_target_donation,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        DoseTextField(
          isRequired: true,
          controller: targetDonationController,
          decoration: InputDecoration(
            hintText: 'Ex: $currencyCode 100',
            hintStyle: requestUtils.hintTextStyle,
            prefixIcon: Container(
              width: 90,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: CustomDropdownView(
                  layerLink: _layerLink,
                  isNeedCloseDropdown: isNeedCloseDropDown,
                  elevationShadow: 20,
                  decorationDropdown: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  defaultWidget: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          indexSelected != -1
                              ? "${currencyList[indexSelected].code}"
                              : currencyCode,
                          style: kDropDownChildCurrencyCode,
                        ),
                        SizedBox(width: 8),
                        Container(
                          height: kFlagImageContainerHeight,
                          width: kFlagImageContainerWidth,
                          child: Image.network(
                            defaultFlagUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8),
                        isDropdownOpened
                            ? Icon(
                                Icons.keyboard_arrow_up,
                                color: Color(0xFF737579),
                              )
                            : kDropDownArrowIcon,
                      ],
                    ),
                  ),
                  onTapDropdown: (bool _isDropdownOpened) async {
                    await Future.delayed(Duration.zero);
                    setState(() {
                      isDropdownOpened = _isDropdownOpened;
                      if (_isDropdownOpened == false) isNeedCloseDropDown = false;
                    });
                  },
                  listWidgetItem: List.generate(currencyList.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          indexSelected = index;
                          isNeedCloseDropDown = true;
                          currencyCode = currencyList[indexSelected].code;
                          defaultFlagUrl = currencyList[indexSelected].imagePath;
                          widget.requestModel.cashModel.requestCurrencyType = currencyCode;
                          widget.requestModel.cashModel.requestCurrencyFlag = defaultFlagUrl;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: index == 0 ? Radius.circular(4) : Radius.zero,
                            bottom:
                                index == currencyList.length - 1 ? Radius.circular(4) : Radius.zero,
                          ),
                          color: indexSelected == index ? Color(0xFFE8EFFF) : Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 12,
                                    width: 16,
                                    child: Image.network(
                                      "${currencyList[index].imagePath}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "${currencyList[index].code}",
                                    style: kDropDownChildCurrencyCode,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "${currencyList[index].name}",
                                    style: kDropDownChildCurrencyName,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 9,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          currentNode: _targetDonationNode,
          // inputFormatters: [FilteringTextInputFormatter.allow((RegExp("[0-9]")))],
          onChanged: (v) {
            requestUtils.updateExitWithConfirmationValue(context, 12, v);
            if (v.isNotEmpty && int.parse(v) >= 0) {
              widget.requestModel.cashModel.targetAmount = int.parse(v);
              setState(() {});
            }
          },
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_target_donation_count;
            } else if (int.parse(value) < 0) {
              return S.of(context).validation_error_target_donation_count_negative;
            } else if (int.parse(value) == 0) {
              return S.of(context).validation_error_target_donation_count_zero;
            } else {
              widget.requestModel.cashModel.targetAmount = int.parse(value);
              setState(() {});
              return null;
            }
          },
        ),
        SizedBox(height: 20),
        Text(
          S.of(context).request_min_donation,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        DoseTextField(
          isRequired: true,
          controller: minimumAmountController,
          currentNode: minimumNode,
          decoration: InputDecoration(
            hintText: 'Ex: $currencyCode 10',
            hintStyle: requestUtils.hintTextStyle,
            // labelText: 'No. of volunteers',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 1, right: 5),
              child: Container(
                width: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(currencyCode, style: TextStyle(fontSize: 16)),
                    SizedBox(width: 5),
                    Container(
                      height: kFlagImageContainerHeight,
                      width: kFlagImageContainerWidth,
                      child: Image.network(defaultFlagUrl, fit: BoxFit.cover),
                    )
                  ],
                ),
              ),
            ),
          ),
          /*  inputFormatters: [
            FilteringTextInputFormatter.allow(
              (RegExp("[0-9]")),
            ),
          ],*/
          onChanged: (v) {
            requestUtils.updateExitWithConfirmationValue(context, 13, v);
            if (v.isNotEmpty && int.parse(v) >= 0) {
              widget.requestModel.cashModel.minAmount = int.parse(v);
              setState(() {});
            }
          },
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_min_donation_count;
            } else if (int.parse(value) < 0) {
              return S.of(context).validation_error_min_donation_count_negative;
            } else if (int.parse(value) == 0) {
              return S.of(context).validation_error_min_donation_count_zero;
            } else if (widget.requestModel.cashModel.targetAmount != null &&
                widget.requestModel.cashModel.targetAmount < int.parse(value)) {
              return S.of(context).target_amount_less_than_min_amount;
            } else {
              widget.requestModel.cashModel.minAmount = int.parse(value);
              setState(() {});
              return null;
            }
          },
        ),
        SizedBox(height: 20),
        addToProjectContainer(),
        SizedBox(height: 20),
        CapturePaymentDetailWidget(
          onTap: () {
            if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
          },
          capturePaymentFrom: CapturePaymentFrom.CREATE_REQUEST,
          paymentDetailModel: paymentDetailModel,
          onPaymentEventChanged: (event) {
            if (event is ZellePayment) {
              widget.requestModel.cashModel.zelleId = event.zelleId;
            } else if (event is ACHPayment) {
              widget.requestModel.cashModel.achdetails.bank_name = event.bank_name;
              widget.requestModel.cashModel.achdetails.bank_address = event.bank_address;
              widget.requestModel.cashModel.achdetails.account_number = event.account_number;
              widget.requestModel.cashModel.achdetails.routing_number = event.routing_number;
            } else if (event is PayPalPayment) {
              widget.requestModel.cashModel.paypalId = event.paypalId;
            } else if (event is VenmoPayment) {
              widget.requestModel.cashModel.venmoId = event.venmoId;
            } else if (event is SwiftPayment) {
              widget.requestModel.cashModel.swiftId = event.swiftId;
            } else if (event is OtherPayment) {
              widget.requestModel.cashModel.others = event.others;
              widget.requestModel.cashModel.other_details = event.other_details;
            }
            logger.d("DATA MODEL CHANGED ${jsonEncode(widget.requestModel.cashModel.toMap())}");
          },
          onDropDownChanged: (value) {
            switch (value) {
              case PaymentMode.ACH:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.ACH;
                break;
              case PaymentMode.ZELLEPAY:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.ZELLEPAY;
                break;
              case PaymentMode.PAYPAL:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.PAYPAL;
                break;
              case PaymentMode.VENMO:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.VENMO;
                break;
              case PaymentMode.SWIFT:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.SWIFT;
                break;
              case PaymentMode.OTHER:
                widget.requestModel.cashModel.paymentType = RequestPaymentType.OTHER;
                break;
            }
            // requestModel.cashModel.paymentType = value;
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
}
