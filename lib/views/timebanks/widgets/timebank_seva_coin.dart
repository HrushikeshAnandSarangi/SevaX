import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/add_manual_time/widgets/add_manual_time_button.dart';
import 'package:sevaexchange/ui/screens/transaction_details/view/transaction_details_view.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/widgets/seva_coin_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class TimeBankSevaCoin extends StatefulWidget {
  final UserModel loggedInUser;
  final bool isAdmin;
  final TimebankModel timebankData;

  const TimeBankSevaCoin(
      {Key key, this.loggedInUser, this.isAdmin, this.timebankData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimeBankSevaCoinState();
  }
}

class TimeBankSevaCoinState extends State<TimeBankSevaCoin> {
  double donateAmount = 0;

  TimebankModel timebankModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CollectionRef.timebank.doc(widget.timebankData.id).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        double balance = 0;
        if (snapshot.hasData && snapshot != null) {
          balance = AppConfig.isTestCommunity
              ? snapshot.data['sandboxBalance'].toDouble()
              : snapshot.data['balance'].toDouble();
          timebankModel = TimebankModel.fromMap(snapshot.data.data());
          return widget.isAdmin
              ? Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SevaCoinWidget(
                          amount: balance ?? 0,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return TransactionDetailsView(
                                  id: SevaCore.of(context)
                                      .loggedInUser
                                      .currentTimebank,
                                  userId: SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID,
                                  totalBalance: '${balance ?? 0}',
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            donateButton(),
                            isAccessAvailable(
                              timebankModel,
                              SevaCore.of(context).loggedInUser.sevaUserID,
                            )
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TransactionsMatrixCheck(
                                      upgradeDetails: AppConfig
                                          .upgradePlanBannerModel
                                          .add_manual_time,
                                      transaction_matrix_type:
                                          "add_manual_time",
                                      child: AddManualTimeButton(
                                        typeId: timebankModel.id,
                                        timebankId: timebankModel
                                                    .parentTimebankId ==
                                                FlavorConfig.values.timebankId
                                            ? timebankModel.id
                                            : timebankModel.parentTimebankId,
                                        timeFor: ManualTimeType.Timebank,
                                        userType: getLoggedInUserRole(
                                          timebankModel,
                                          SevaCore.of(context)
                                              .loggedInUser
                                              .sevaUserID,
                                        ),
                                        communityName: timebankModel.name,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ]),
                )
              : donateButton();
        }
        return LoadingIndicator();
      },
    );
  }

  Widget donateButton() {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 8.0),
      child: CustomElevatedButton(
        onPressed: _showFontSizePickerDialog,
        child: Text(
          S.of(context).donate,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  void _showFontSizePickerDialog() async {
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

    if (AppConfig.isTestCommunity
        ? this.widget.loggedInUser.sandboxCurrentBalance <= 0
        : this.widget.loggedInUser.currentBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).insufficient_credits_to_donate),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    // <-- note the async keyword here

    // this will contain the result from Navigator.pop(context, result)
    final donateAmount_Received = await showDialog<double>(
      context: context,
      builder: (context) => InputDonateDialog(
          donateAmount: donateAmount,
          maxAmount: AppConfig.isTestCommunity
              ? this.widget.loggedInUser.sandboxCurrentBalance
              : this.widget.loggedInUser.currentBalance),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      setState(() {
        donateAmount = donateAmount_Received;
        if (AppConfig.isTestCommunity) {
          SevaCore.of(context).loggedInUser.sandboxCurrentBalance =
              widget.loggedInUser.sandboxCurrentBalance - donateAmount_Received;
        } else {
          SevaCore.of(context).loggedInUser.currentBalance =
              widget.loggedInUser.currentBalance - donateAmount_Received;
        }
      });
      await TransactionBloc().createNewTransaction(
        this.widget.loggedInUser.sevaUserID,
        this.widget.timebankData.id,
        DateTime.now().millisecondsSinceEpoch,
        donateAmount,
        true,
        "USER_DONATE_TOTIMEBANK",
        null,
        this.widget.timebankData.id,
        communityId: widget.loggedInUser.currentCommunity,
        fromEmailORId: this.widget.loggedInUser.email,
        toEmailORId: this.widget.timebankData.id,
      );
      await showDialog<double>(
        context: context,
        builder: (context) => InputDonateSuccessDialog(
            onComplete: () => {Navigator.pop(context)}),
      );
    }
  }
}

// move the dialog into it's own stateful widget.
// It's completely independent from your page
// this is good practice
class InputDonateDialog extends StatefulWidget {
  /// initial selection for the slider
  final double donateAmount;
  final double maxAmount;

  const InputDonateDialog({Key key, this.donateAmount, this.maxAmount})
      : super(key: key);

  @override
  _InputDonateDialogState createState() => _InputDonateDialogState();
}

class _InputDonateDialogState extends State<InputDonateDialog> {
  /// current selection of the slider
  double _donateAmount;
  bool donatezeroerror = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _donateAmount = widget.donateAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).donate_to_timebank),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${S.of(context).current_seva_credit} ' +
                widget.maxAmount.toStringAsFixed(2).toString()),
            TextFormField(
              decoration: InputDecoration(
                hintText: S.of(context).number_of_seva_credit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return S.of(context).empty_credit_donation_error;
                } else if (int.parse(value) > widget.maxAmount) {
                  return S.of(context).insufficient_credits_to_donate;
                } else if (int.parse(value) == 0) {
                  return S.of(context).zero_credit_donation_error;
                } else if (int.parse(value) <= 0) {
                  return S.of(context).negative_credit_donation_error;
                } else {
                  _donateAmount = double.parse(value);
                  return null;
                }
              },
            ),
//          Slider(
//            label: "${AppLocalizations.of(context).translate('coins', 'donate')} " +
//                _donateAmount.toStringAsFixed(2) +
//                " ${AppLocalizations.of(context).translate('coins', 'coins')}",
//            value: _donateAmount,
//            min: 0,
//            max: widget.maxAmount,
//            divisions: 100,
//            onChanged: (value) {
//              setState(() {
//                if (value > 0) {
//                  donatezeroerror = false;
//                }
//                _donateAmount = value;
//              });
//            },
//          ),
            SizedBox(
              height: 10,
            ),
            Text(S.of(context).donate_message),
          ],
        ),
      ),
      actions: <Widget>[
        CustomTextButton(
          shape: StadiumBorder(),
          color: HexColor("#D2D2D2"),
          child: Text(
            S.of(context).cancel,
            style: TextStyle(color: Colors.white, fontSize: dialogButtonSize),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CustomElevatedButton(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          child: Text(
            S.of(context).donate,
            style: TextStyle(
              fontSize: dialogButtonSize,
            ),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
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

  const InputDonateSuccessDialog({Key key, this.onComplete}) : super(key: key);

  @override
  _InputDonateSuccessDialogState createState() =>
      _InputDonateSuccessDialogState();
}

class _InputDonateSuccessDialogState extends State<InputDonateSuccessDialog> {
  VoidCallback onComplete;

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
      title: Text(S.of(context).donate_to_timebank),
      content: Container(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / 12,
        child: Text(S.of(context).donation_success),
      ),
    );
  }
}
