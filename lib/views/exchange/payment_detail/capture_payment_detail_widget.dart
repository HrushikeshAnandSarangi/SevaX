import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/payment_detail_model.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

enum CapturePaymentFrom { CREATE_REQUEST, EDIT_REQUEST, DONATION }

class CapturePaymentDetailWidget extends StatefulWidget {
  final CapturePaymentFrom? capturePaymentFrom;
  final PaymentDetailModel? paymentDetailModel;
  final Function(PaymentMode paymentMode)? onDropDownChanged;
  final Function(PaymentEventType paymentDetailModel)? onPaymentEventChanged;
  final Function? onTap;
  final RequestUtils requestUtils = RequestUtils();

  CapturePaymentDetailWidget(
      {this.paymentDetailModel,
      this.capturePaymentFrom,
      this.onDropDownChanged,
      this.onPaymentEventChanged,
      this.onTap});

  @override
  _CapturePaymentDetailWidgetState createState() =>
      _CapturePaymentDetailWidgetState();
}

class _CapturePaymentDetailWidgetState
    extends State<CapturePaymentDetailWidget> {
  PaymentDetailModel? paymentDetailModel;
  final profanityDetector = ProfanityDetector();
  PaymentMode? selectedMode;
  ACHPayment? achPayment;
  ZellePayment? zellePayment;
  PayPalPayment? payPalPayment;
  VenmoPayment? venmoPayment;
  SwiftPayment? swiftPayment;
  OtherPayment? otherPayment;
  bool isEdit = false;
  final List<TextInputFormatter> _formatters = [
    FilteringTextInputFormatter.allow(RegExp(r'\S'))
  ];
  TextEditingController zelleController = TextEditingController(),
      venmoController = TextEditingController(),
      paypalController = TextEditingController(),
      swiftController = TextEditingController(),
      bankNameController = TextEditingController(),
      bankAddressController = TextEditingController(),
      routingController = TextEditingController(),
      accountController = TextEditingController(),
      othersController = TextEditingController(),
      otherDetailController = TextEditingController();
  List<FocusNode> focusNodeList = List.generate(10, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    paymentDetailModel = widget.paymentDetailModel;
    selectedMode = paymentDetailModel!.paymentMode;
    _initialize();
    zelleController.text = zellePayment?.zelleId ?? '';
    venmoController.text = venmoPayment?.venmoId ?? '';
    paypalController.text = payPalPayment?.paypalId ?? '';
    swiftController.text = swiftPayment?.swiftId ?? '';
    bankNameController.text = achPayment?.bank_name ?? '';
    bankAddressController.text = achPayment!.bank_address!;
    routingController.text = achPayment?.routing_number ?? '';
    accountController.text = achPayment?.account_number ?? '';
    othersController.text = otherPayment?.others ?? '';
    otherDetailController.text = otherPayment?.other_details ?? '';
  }

  _initialize() {
    switch (selectedMode) {
      case PaymentMode.ZELLEPAY:
        zellePayment = isEdit
            ? ZellePayment(zelleId: '')
            : (paymentDetailModel!.paymentEventType is ZellePayment
                ? paymentDetailModel!.paymentEventType as ZellePayment
                : ZellePayment(zelleId: ''));
        break;
      case PaymentMode.ACH:
        achPayment = isEdit
            ? ACHPayment()
            : (paymentDetailModel?.paymentEventType is ACHPayment
                ? paymentDetailModel?.paymentEventType as ACHPayment
                : ACHPayment());
        break;
      case PaymentMode.PAYPAL:
        payPalPayment = isEdit
            ? PayPalPayment()
            : (paymentDetailModel?.paymentEventType is PayPalPayment
                ? paymentDetailModel?.paymentEventType as PayPalPayment
                : PayPalPayment());
        break;
      case PaymentMode.VENMO:
        venmoPayment = isEdit
            ? VenmoPayment()
            : (paymentDetailModel?.paymentEventType is VenmoPayment
                ? paymentDetailModel?.paymentEventType as VenmoPayment
                : VenmoPayment());
        break;
      case PaymentMode.SWIFT:
        swiftPayment = isEdit
            ? SwiftPayment()
            : (paymentDetailModel?.paymentEventType is SwiftPayment
                ? paymentDetailModel?.paymentEventType as SwiftPayment
                : SwiftPayment());
        break;
      case PaymentMode.OTHER:
        otherPayment = isEdit
            ? OtherPayment()
            : (paymentDetailModel?.paymentEventType is OtherPayment
                ? paymentDetailModel?.paymentEventType as OtherPayment
                : OtherPayment());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).request_payment_description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        Text(
          S.of(context).request_payment_description_hint_new,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Container(
          height: 40,
          margin: EdgeInsets.only(top: 12.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                onTap: widget.onTap as VoidCallback?,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down),
                iconEnabledColor: Theme.of(context).primaryColor,
                value: selectedMode,
                onChanged: (val) {
                  setState(() {
                    selectedMode = val! as PaymentMode;
                    if (widget.onDropDownChanged != null) {
                      widget.onDropDownChanged!(selectedMode!);
                    }
                    if (selectedMode ==
                        widget.paymentDetailModel!.paymentMode) {
                      isEdit = false;
                    } else {
                      isEdit = true;
                    }
                    _initialize();
                  });
                },
                items: [
                  DropdownMenuItem(
                    child: Text(S.of(context).request_paymenttype_ach),
                    value: PaymentMode.ACH,
                  ),
                  DropdownMenuItem(
                    child: Text(S.of(context).request_paymenttype_paypal),
                    value: PaymentMode.PAYPAL,
                  ),
                  DropdownMenuItem(
                    child: Text(S.of(context).request_paymenttype_swift),
                    value: PaymentMode.SWIFT,
                  ),
                  DropdownMenuItem(
                    child: Text(S.of(context).request_paymenttype_venmo),
                    value: PaymentMode.VENMO,
                  ),
                  DropdownMenuItem(
                    child: Text(S.of(context).request_paymenttype_zellepay),
                    value: PaymentMode.ZELLEPAY,
                  ),
                  DropdownMenuItem(
                    child: Text(S.of(context).other_text),
                    value: PaymentMode.OTHER,
                  ),
                ]),
          ),
        ),
        selectedMode == PaymentMode.ACH
            ? RequestPaymentACH()
            : selectedMode == PaymentMode.PAYPAL
                ? RequestPaymentPaypal()
                : selectedMode == PaymentMode.VENMO
                    ? RequestPaymentVenmo()
                    : selectedMode == PaymentMode.SWIFT
                        ? RequestPaymentSwift()
                        : selectedMode == PaymentMode.OTHER
                            ? OtherDetailsWidget()
                            : RequestPaymentZellePay(),
      ],
    );
  }

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    if (ExitWithConfirmation.of(context) != null)
      ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  Widget RequestPaymentACH() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          DoseTextField(
            // key: UniqueKey(),
            isRequired: selectedMode == PaymentMode.ACH,
            controller: bankNameController,
            focusNode: focusNodeList[0],
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\S.*$'))],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 1, value);
            },
            // initialValue: ,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: selectedMode == PaymentMode.ACH
                ? (value) {
                    if (value!.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else if (!value.isEmpty) {
                      achPayment!.bank_name = value;
                      if (widget.onPaymentEventChanged != null) {
                        widget.onPaymentEventChanged!(achPayment!);
                      }
                    } else {
                      return S.of(context).enter_valid_bank_name;
                    }
                    return null;
                  }
                : null,
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          DoseTextField(
            isRequired: selectedMode == PaymentMode.ACH,
            controller: bankAddressController,
            // key: UniqueKey(),
            focusNode: focusNodeList[1],
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\S.*$'))],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 2, value);
            },
            // initialValue: achPayment?.bank_address,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: selectedMode == PaymentMode.ACH
                ? (value) {
                    if (value!.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else if (!value.isEmpty) {
                      achPayment!.bank_address = value;
                      if (widget.onPaymentEventChanged != null) {
                        widget.onPaymentEventChanged!(achPayment!);
                      }
                    } else {
                      return S.of(context).enter_valid_bank_address;
                    }
                    return null;
                  }
                : null,
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_routing_number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          DoseTextField(
            isRequired: selectedMode == PaymentMode.ACH,
            controller: routingController,
            // key: UniqueKey(),
            focusNode: focusNodeList[2],
            maxLength: 30,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 3, value);
            },
            // initialValue: achPayment?.routing_number ?? '',
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            maxLines: 1,
            validator: selectedMode == PaymentMode.ACH
                ? (value) {
                    if (value!.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else if (!value.isEmpty) {
                      achPayment!.routing_number = value;
                      if (widget.onPaymentEventChanged != null) {
                        widget.onPaymentEventChanged!(achPayment!);
                      }
                    } else {
                      return S.of(context).enter_valid_routing_number;
                    }
                    return null;
                  }
                : null,
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_account_no,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          DoseTextField(
            isRequired: selectedMode == PaymentMode.ACH,
            controller: accountController,
            focusNode: focusNodeList[3],
            // key: UniqueKey(),
            maxLength: 30,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 4, value);
            },
            textInputAction: TextInputAction.next,
            // initialValue: achPayment?.account_number ?? '',
            keyboardType: TextInputType.number,
            maxLines: 1,
            validator: selectedMode == PaymentMode.ACH
                ? (value) {
                    if (value!.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else if (!value.isEmpty) {
                      achPayment!.account_number = value;
                      if (widget.onPaymentEventChanged != null) {
                        widget.onPaymentEventChanged!(achPayment!);
                      }
                    } else {
                      return S.of(context).enter_valid_account_number;
                    }
                    return null;
                  }
                : null,
          )
        ]);
  }

  Widget RequestPaymentZellePay() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoseTextField(
            isRequired: selectedMode == PaymentMode.ZELLEPAY,
            controller: zelleController,
            focusNode: focusNodeList[4],
            // key: UniqueKey(),
            formatters: _formatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 5, value);
            },
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText:
                  S.of(context).request_payment_descriptionZelle_inputhint,
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              zellePayment!.zelleId = value!;
              if (widget.onPaymentEventChanged != null) {
                if (widget.onPaymentEventChanged != null) {
                  if (widget.onPaymentEventChanged != null) {
                    widget.onPaymentEventChanged!(zellePayment!);
                  }
                }
              }
            },
            validator: selectedMode == PaymentMode.ZELLEPAY
                ? (value) {
                    zellePayment!.zelleId = value!;
                    widget.onPaymentEventChanged!(zellePayment!);
                    return selectedMode == PaymentMode.ZELLEPAY
                        ? widget.requestUtils
                            .validateEmailAndPhone(value, context)
                        : null;
                  }
                : null,
          )
        ]);
  }

  Widget RequestPaymentPaypal() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoseTextField(
            isRequired: selectedMode == PaymentMode.PAYPAL,
            controller: paypalController,
            focusNode: focusNodeList[5],
            // key: UniqueKey(),
            formatters: _formatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 6, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: 'Ex: Paypal ID (phone or email)',
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              payPalPayment!.paypalId = value!;
              widget.onPaymentEventChanged!(payPalPayment!);
            },
            validator: selectedMode == PaymentMode.PAYPAL
                ? (value) {
                    RegExp regExp = RegExp(widget.requestUtils.mobilePattern);
                    if (value!.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else if (widget.requestUtils.emailPattern
                            .hasMatch(value!) ||
                        regExp.hasMatch(value)) {
                      payPalPayment!.paypalId = value;
                      widget.onPaymentEventChanged!(payPalPayment!);
                      return null;
                    } else {
                      return S.of(context).enter_valid_link;
                    }
                  }
                : null,
          )
        ]);
  }

  Widget RequestPaymentVenmo() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoseTextField(
            isRequired: selectedMode == PaymentMode.VENMO,
            controller: venmoController,
            focusNode: focusNodeList[6],
            // key: UniqueKey(),
            formatters: _formatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 7, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).venmo_hint,
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              venmoPayment!.venmoId = value!;
              widget.onPaymentEventChanged!(venmoPayment!);
            },
            validator: selectedMode == PaymentMode.VENMO
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    } else {
                      venmoPayment!.venmoId = value;
                      widget.onPaymentEventChanged!(venmoPayment!);
                      return null;
                    }
                  }
                : null,
          )
        ]);
  }

  Widget RequestPaymentSwift() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoseTextField(
            isRequired: selectedMode == PaymentMode.SWIFT,
            controller: swiftController,
            focusNode: focusNodeList[7],
            // key: UniqueKey(),
            formatters: _formatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 8, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: 'Ex: Swift ID',
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            // initialValue: ,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            maxLength: 11,
            onSaved: (value) {
              swiftPayment!.swiftId = value!;
              widget.onPaymentEventChanged!(swiftPayment!);
            },
            validator: selectedMode == PaymentMode.SWIFT
                ? (value) {
                    if (value!.isEmpty) {
                      return 'ID cannot be empty';
                    } else if (value.length < 8) {
                      return 'Enter valid Swift ID';
                    } else {
                      swiftPayment!.swiftId = value;
                      widget.onPaymentEventChanged!(swiftPayment!);
                      return null;
                    }
                  }
                : null,
          )
        ]);
  }

  Widget OtherDetailsWidget() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            S.of(context).other_payment_name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          DoseTextField(
            isRequired: selectedMode == PaymentMode.OTHER,
            controller: othersController,
            focusNode: focusNodeList[8],
            // key: UniqueKey(),
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\S.*$'))],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 9, value);
            },
            // initialValue: otherPayment?.others ?? '',
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).other_payment_title_hint,
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              otherPayment!.others = value!;
              widget.onPaymentEventChanged!(otherPayment!);
            },
            validator: selectedMode == PaymentMode.OTHER
                ? (value) {
                    if (value!.isEmpty || value == null) {
                      return S.of(context).validation_error_general_text;
                    }
                    if (!value.isEmpty &&
                        profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else {
                      otherPayment!.others = value;
                      widget.onPaymentEventChanged!(otherPayment!);
                      return null;
                    }
                  }
                : null,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            S.of(context).other_payment_details,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          DoseTextField(
            isRequired: selectedMode == PaymentMode.OTHER,
            controller: otherDetailController,
            focusNode: focusNodeList[9],
            // key: UniqueKey(),
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\S.*$'))],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 10, value);
            },
            // initialValue: otherPayment?.other_details ?? '',
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: null,
            onSaved: (value) {
              otherPayment!.other_details = value!;
            },
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).other_payment_details_hint,
              hintStyle: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Europa',
              ),
            ),
            validator: selectedMode == PaymentMode.OTHER
                ? (value) {
                    if (value!.isEmpty || value == null) {
                      return S.of(context).validation_error_general_text;
                    }
                    if (!value.isEmpty &&
                        profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else {
                      otherPayment!.other_details = value;
                      widget.onPaymentEventChanged!(otherPayment!);
                      return null;
                    }
                  }
                : null,
          ),
        ]);
  }
}
