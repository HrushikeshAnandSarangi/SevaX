import 'package:flutter/material.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';

class PaymentDescription extends StatefulWidget {
  final RequestModel requestModel;

  const PaymentDescription({this.requestModel});

  @override
  _PaymentDescriptionState createState() => _PaymentDescriptionState();
}

class _PaymentDescriptionState extends State<PaymentDescription> {
  final profanityDetector = ProfanityDetector();
  RequestUtils requestUtils = RequestUtils();

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
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_paypal,
          value: RequestPaymentType.PAYPAL,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: 'Swift',
          value: RequestPaymentType.SWIFT,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: 'Venmo',
          value: RequestPaymentType.VENMO,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_zellepay,
          value: RequestPaymentType.ZELLEPAY,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).other_text,
          value: RequestPaymentType.OTHER,
          groupvalue: widget.requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        widget.requestModel.cashModel.paymentType == RequestPaymentType.ACH
            ? RequestPaymentACH()
            : widget.requestModel.cashModel.paymentType ==
                    RequestPaymentType.PAYPAL
                ? RequestPaymentPaypal()
                : widget.requestModel.cashModel.paymentType ==
                        RequestPaymentType.VENMO
                    ? RequestPaymentVenmo()
                    : widget.requestModel.cashModel.paymentType ==
                            RequestPaymentType.SWIFT
                        ? RequestPaymentSwift()
                        : widget.requestModel.cashModel.paymentType ==
                                RequestPaymentType.OTHER
                            ? OtherDetailsWidget()
                            : RequestPaymentZellePay(),
      ],
    );
  }

  Widget RequestPaymentDescriptionData(RequestModel requestModel) {}

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
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue:
                widget.requestModel.cashModel?.achdetails?.bank_name ?? '',
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 3, value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.bank_name = value;
              } else {
                return S.of(context).enter_valid_bank_name;
              }
              return null;
            },
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
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue:
                widget.requestModel.cashModel?.achdetails?.bank_address ?? '',
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 4, value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.bank_address = value;
              } else {
                return S.of(context).enter_valid_bank_address;
              }
              return null;
            },
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
          TextFormField(
            maxLength: 30,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue:
                widget.requestModel.cashModel?.achdetails?.routing_number ?? '',
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 5, value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.routing_number = value;
              } else {
                return S.of(context).enter_valid_routing_number;
              }
              return null;
            },
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
          TextFormField(
            maxLength: 30,
            initialValue:
                widget.requestModel.cashModel?.achdetails?.account_number ?? '',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 6, value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.account_number = value;
              } else {
                return S.of(context).enter_valid_account_number;
              }
              return null;
            },
          )
        ]);
  }

  Widget RequestPaymentZellePay() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.requestModel.cashModel?.zelleId ?? '',
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 7, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText:
                  S.of(context).request_payment_descriptionZelle_inputhint,
              hintStyle: requestUtils.hintTextStyle,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.zelleId = value;
            },
            validator: (value) {
              widget.requestModel.cashModel.zelleId = value;
              return _validateEmailAndPhone(value);
            },
          )
        ]);
  }

  String mobilePattern = r'^[0-9]+$';
  RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  String _validateEmailAndPhone(String value) {
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
  }

  Widget RequestPaymentPaypal() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 8, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: 'Ex: Paypal ID (phone or email)',
              hintStyle: requestUtils.hintTextStyle,
            ),
            initialValue: widget.requestModel.cashModel?.paypalId ?? '',
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.paypalId = value;
            },
            validator: (value) {
              RegExp regExp = RegExp(mobilePattern);
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (emailPattern.hasMatch(value) ||
                  regExp.hasMatch(value)) {
                widget.requestModel.cashModel.paypalId = value;
                return null;
              } else {
                return S.of(context).enter_valid_link;
              }
            },
          )
        ]);
  }

  Widget RequestPaymentVenmo() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.requestModel.cashModel?.venmoId ?? '',
            onChanged: (value) {},
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).venmo_hint,
              hintStyle: requestUtils.hintTextStyle,
            ),
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                widget.requestModel.cashModel.venmoId = value;
                return null;
              }
            },
          )
        ]);
  }

  Widget RequestPaymentSwift() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.requestModel.cashModel?.swiftId ?? '',
            onChanged: (value) {
              requestUtils.updateExitWithConfirmationValue(context, 7, value);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: 'Ex: Swift ID',
              hintStyle: requestUtils.hintTextStyle,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            maxLength: 11,
            onSaved: (value) {
              widget.requestModel.cashModel.swiftId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'ID cannot be empty';
              } else if (value.length < 8) {
                return 'Enter valid Swift ID';
              } else {
                widget.requestModel.cashModel.swiftId = value;
                return null;
              }
            },
          )
        ]);
  }

  Widget OtherDetailsWidget() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).other_payment_name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.requestModel.cashModel?.others ?? '',
            onChanged: (value) {},
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).other_payment_title_hint,
              hintStyle: requestUtils.hintTextStyle,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.others = value;
            },
            validator: (value) {
              if (value.isEmpty || value == null) {
                return S.of(context).validation_error_general_text;
              }
              if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              } else {
                widget.requestModel.cashModel.others = value;
                return null;
              }
            },
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
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: widget.requestModel.cashModel?.other_details ?? '',
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: null,
            onSaved: (value) {
              widget.requestModel.cashModel.other_details = value;
            },
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).other_payment_details_hint,
              hintStyle: requestUtils.hintTextStyle,
            ),
            validator: (value) {
              if (value.isEmpty || value == null) {
                return S.of(context).validation_error_general_text;
              }
              if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              } else {
                widget.requestModel.cashModel.other_details = value;
                return null;
              }
            },
          ),
        ]);
  }

  Widget _optionRadioButton<T>({
    String title,
    T value,
    T groupvalue,
    Function onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      key: UniqueKey(),
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: (isEnabled ?? true) ? onChanged : null,
      ),
    );
  }
}
