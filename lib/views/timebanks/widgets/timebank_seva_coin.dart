import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
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
                Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: RaisedButton(
                      onPressed: _showFontSizePickerDialog,
                      child: Text(
                        'Donate',
                        style: Theme.of(context).primaryTextTheme.button,
                      ),
                    ))
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
          content: Text("Please check your internet connection."),
          action: SnackBarAction(
            label: 'Dismiss',
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
          content: Text("You do not have sufficient credits to donate!"),
          action: SnackBarAction(
            label: 'Dismiss',
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

  @override
  void initState() {
    super.initState();
    _donateAmount = widget.donateAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Donate seva coins to timebank'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Your current seva coins is ' +
              widget.maxAmount.toStringAsFixed(2).toString()),
          Slider(
            label: "Donate " + _donateAmount.toStringAsFixed(2) + " Coins",
            value: _donateAmount,
            min: 0,
            max: widget.maxAmount,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                if (value > 0) {
                  donatezeroerror = false;
                }
                _donateAmount = value;
              });
            },
          ),
          Text('On click of donate your balance will be adjusted'),
          SizedBox(
            height: 15,
          ),
          donatezeroerror ? Text(
            "You cannot donate 0 credits",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ): Text("")
        ],
      ),
      actions: <Widget>[
        RaisedButton(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          child: Text(
            'Donate',
            style: TextStyle(
              fontSize: dialogButtonSize,
            ),
          ),
          onPressed: () {
            if (_donateAmount == 0) {
              setState(() {
                donatezeroerror = true;
              });
              return;
            }
            setState(() {
              donatezeroerror = false;
            });
            Navigator.pop(context, _donateAmount);
          },
        ),
        FlatButton(
          child: Text(
            'Cancel',
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
      title: Text('Donate seva coins to timebank'),
      content: Container(
          height: MediaQuery.of(context).size.height / 10,
          width: MediaQuery.of(context).size.width / 12,
          child: Text('You have donated credits successfully')),
    );
  }
}
