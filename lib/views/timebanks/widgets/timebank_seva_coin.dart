import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:sevaexchange/views/profile/widgets/seva_coin_widget.dart';

class TimeBankSevaCoin extends StatefulWidget {
  final UserModel loggedInUser;
  final bool isAdmin;
  final TimebankModel timebankData;

  const TimeBankSevaCoin(
      {Key key, this.loggedInUser, this.isAdmin, this.timebankData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new TimeBankSevaCoinState();
  }
}

class TimeBankSevaCoinState extends State<TimeBankSevaCoin> {
  double donateAmount = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("timebanknew")
          .document(widget.timebankData.id)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        print(widget.timebankData.id);
        double balance = 0;
        if (snapshot.hasData && snapshot != null) {
          balance = snapshot.data['balance'].toDouble();
          return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                    offstage: widget.isAdmin,
                    child: SevaCoinWidget(
                        amount: balance ?? 0,
                        onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ReviewEarningsPage(
                                      type: "timebank",
                                      timebankid: this.widget.timebankData.id);
                                },
                              ),
                            ))),
                Container(
                  width: 148,
                  height: 40,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: RaisedButton(
                        onPressed: _showFontSizePickerDialog,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('coins', 'donate'),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )),
                )
              ]);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showFontSizePickerDialog() async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('shared', 'check_internet')),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    print("${this.widget.loggedInUser.currentBalance}");

    if (this.widget.loggedInUser.currentBalance <= 0) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('coins', 'not_enough')),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('shared', 'dismiss'),
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
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
          maxAmount: this.widget.loggedInUser.currentBalance),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      setState(() {
        donateAmount = donateAmount_Received;
        SevaCore.of(context).loggedInUser.currentBalance =
            widget.loggedInUser.currentBalance - donateAmount_Received;
      });
      await TransactionBloc().createNewTransaction(
          this.widget.loggedInUser.sevaUserID,
          this.widget.timebankData.id,
          DateTime.now().millisecondsSinceEpoch,
          donateAmount,
          true,
          "USER_DONATE_TOTIMEBANK",
          null,
          this.widget.timebankData.id);
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
      title:
          Text(AppLocalizations.of(context).translate('coins', 'donate_coins')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                '${AppLocalizations.of(context).translate('coins', 'current_coins')} ' +
                    widget.maxAmount.toStringAsFixed(2).toString()),
            TextFormField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)
                    .translate('coins', 'coins_hint'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)
                      .translate('coins', 'empty_error');
                } else if (int.parse(value) > widget.maxAmount) {
                  return AppLocalizations.of(context)
                      .translate('coins', 'not_enough');
                } else if (int.parse(value) == 0) {
                  return AppLocalizations.of(context)
                      .translate('coins', 'zero_err');
                } else if (int.parse(value) <= 0) {
                  return AppLocalizations.of(context)
                      .translate('coins', 'less_zero_err');
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
            Text(AppLocalizations.of(context).translate('coins', 'hint')),
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          child: Text(
            AppLocalizations.of(context).translate('coins', 'donate'),
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
        FlatButton(
          child: Text(
            AppLocalizations.of(context).translate('shared', 'cancel'),
            style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
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
    var _duration = new Duration(milliseconds: 2000);
    new Timer(_duration, () => {Navigator.pop(context)});
  }

//  Text('Coins successfully donated to timebank')
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          AppLocalizations.of(context).translate('coins', 'donate_totimebank')),
      content: Container(
          height: MediaQuery.of(context).size.height / 10,
          width: MediaQuery.of(context).size.width / 12,
          child: Text(AppLocalizations.of(context)
              .translate('coins', 'donate_success'))),
    );
  }
}
