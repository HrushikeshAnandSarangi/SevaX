import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

enum Actions { Approve, Reject, Remove, Promote, Demote, Exit, Loan, MakeOwner }

String actionToStringMapper(BuildContext context, Actions action) {
  S s = S.of(context);
  switch (action) {
    case Actions.Approve:
      return s.approve;
      break;

    case Actions.MakeOwner:
      return S.of(context).make_owner;
      break;
    case Actions.Reject:
      return s.reject;
      break;
    case Actions.Remove:
      return s.remove;
      break;
    case Actions.Promote:
      return s.promote;
      break;
    case Actions.Demote:
      return s.demote;
      break;
    case Actions.Exit:
      return s.exit;
      break;
    case Actions.Loan:
      return s.donate;
      break;
    default:
      return '';
  }
}

class CustomRaisedButton extends StatelessWidget {
  final Actions? action;
  final Function? onTap;
  final Debouncer? debouncer;

  const CustomRaisedButton({
    Key? key,
    this.onTap,
    this.action,
    this.debouncer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var btn = CustomElevatedButton(
      padding: EdgeInsets.all(0),
      color: (action == Actions.Approve ||
              action == Actions.Promote ||
              action == Actions.MakeOwner ||
              action == Actions.Loan)
          ? null!
          : Colors.red!,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 2.0,
      textColor: Colors.white,
      child: Text(
        actionToStringMapper(context, action!),
        style: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        debouncer!.run(() => onTap!());
      },
    );
    return Container(
      width: 70,
      height: 30,
      child: btn,
    );
  }
}

// move the dialog into it's own stateful widget.
// It's completely independent from your page
// this is good practice
class InputDonateDialog extends StatefulWidget {
  /// initial selection for the slider
  final double? donateAmount;
  final double? maxAmount;
  final double? creditsNeeded;

  const InputDonateDialog({
    Key? key,
    this.donateAmount,
    this.maxAmount,
    this.creditsNeeded = 0,
  }) : super(key: key);

  @override
  _InputDonateDialogState createState() => _InputDonateDialogState();
}

class _InputDonateDialogState extends State<InputDonateDialog> {
  /// current selection of the slider
  double? _donateAmount;
  bool donatezeroerror = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _donateAmount = widget.donateAmount;
  }

  @override
  Widget build(BuildContext context) {
    String creditsNeededFinal = widget.creditsNeeded!.round().toString();

    return AlertDialog(
      title: Text(S.of(context).loan_seva_credit_to_user),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${S.of(context).timebank_seva_credit} ' +
                widget.maxAmount!.toStringAsFixed(2).toString()),
            TextFormField(
              initialValue: creditsNeededFinal,
              decoration: InputDecoration(
                hintText: S.of(context).number_of_seva_credit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return S.of(context).empty_credit_loan_error;
                } else if (int.parse(value) > widget!.maxAmount!) {
                  return S.of(context).insufficient_credits_to_donate;
                } else if (int.parse(value) == 0) {
                  return S.of(context).loan_zero_credit_error;
                } else if (int.parse(value) <= 0) {
                  return S.of(context).negative_credit_loan_error;
                } else {
                  _donateAmount = double.parse(value);
                  return null;
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(S.of(context).timebank_loan_message),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 20),
      actions: <Widget>[
        CustomTextButton(
          color: HexColor("#d2d2d2"),
          textColor: Colors.white,
          child: Text(
            S.of(context).cancel,
            style: TextStyle(fontSize: dialogButtonSize),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CustomTextButton(
          color: Theme.of(context).colorScheme.secondary,
          textColor: Colors.white,
          child: Text(
            S.of(context).donate,
            style: TextStyle(
              fontSize: dialogButtonSize,
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
//              if (_donateAmount == 0) {
//                setState(() {
//                  donatezeroerror = true;
//                });
//                return;
//              }
              setState(() {
                donatezeroerror = false;
              });
              Navigator.pop(context, _donateAmount);
            }
          },
        ),
      ],
    );
  }
}

class InputDonateSuccessDialog extends StatefulWidget {
  /// initial selection for the slider
  final VoidCallback onComplete;

  const InputDonateSuccessDialog({Key? key, required this.onComplete})
      : super(key: key);

  @override
  _InputDonateSuccessDialogState createState() =>
      _InputDonateSuccessDialogState();
}

class _InputDonateSuccessDialogState extends State<InputDonateSuccessDialog> {
  VoidCallback? onComplete;

  /// current selection of the slider
  @override
  void initState() {
    super.initState();
    onComplete = widget.onComplete;
    var _duration = Duration(milliseconds: 2000);
    Timer(_duration, () => {Navigator.pop(context)});
  }

//  Text('Coins successfully donated to timebank')
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).loan_seva_credit_to_user),
      content: Container(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / 12,
        child: Text(S.of(context).loan_success),
      ),
    );
  }
}
