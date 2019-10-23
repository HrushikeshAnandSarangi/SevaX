import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/views/core.dart';
import '../../flavor_config.dart';
import '../splash_view.dart';

class OnBoardWithTimebank extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OnBoardWithTimebankState();
}

class OnBoardWithTimebankState extends State<OnBoardWithTimebank> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();

  bool hasError = false;
  String errorMessage1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Enter ${FlavorConfig.values.timebankTitle} code",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  //child: Text(thisText, style: Theme.of(context).textTheme.title),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 10.0, bottom: 25.0),
                  child: Text(
                    'Enter the code you received from your ${FlavorConfig.values.timebankTitle} Coordinator to see the exchange opportunities for your group.',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Text(
                    'Enter ${FlavorConfig.values.timebankTitle} code',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                ),
                PinCodeTextField(
                  autofocus: false,
                  controller: controller,
                  hideCharacter: false,
                  highlight: true,
                  keyboardType: TextInputType.text,
                  highlightColor: Colors.blue,
                  defaultBorderColor: Colors.black,
                  hasTextBorderColor: Colors.green,
                  maxLength: 5,
                  hasError: hasError,
                  maskCharacter: "•",
                  onTextChanged: (text) {
                    setState(() {
                      hasError = false;
                    });
                  },
                  onDone: (text) {
                    // print("############################ DONE $text");
                    //widget.onSelectedOtp(controller.text);
                  },
                  pinCodeTextFieldLayoutType:
                      PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
                  wrapAlignment: WrapAlignment.start,
                  pinBoxDecoration:
                      ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                  pinTextStyle: TextStyle(fontSize: 30.0),
                  pinTextAnimatedSwitcherTransition:
                      ProvidedPinBoxTextAnimation.scalingTransition,
                  pinTextAnimatedSwitcherDuration: Duration(milliseconds: 100),
                ),
                Visibility(
                  child: Text(
                    this.errorMessage1,
                    style: TextStyle(color: Colors.red),
                  ),
                  visible: hasError,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Expanded(
                      child: RaisedButton(
                          child: Text(
                            'NEXT',
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            print('pressed Next');

                            this._checkFields();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _checkFields() {
    if (controller.text.length == 5) {
      verifyTimebankCode(timebankCode: controller.text);
    } else {
      if (controller.text.length == 0) {
        setError(errorMessage: "Please enter PIN to verify");
      }
    }
  }

  void setError({String errorMessage}) {
    setState(() {
      this.hasError = true;
      this.errorMessage1 = errorMessage;
    });
  }

  void verifyTimebankCode({String timebankCode}) {
    Firestore.instance
        .collection("timebankCodes")
        .where("timebankCode", isEqualTo: timebankCode)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      if (snapshot.documents.length > 0) {
        // timabnk code exists , check its validity
        snapshot.documents.forEach((f) {
          print('${f.data}}');
          if (DateTime.now().millisecondsSinceEpoch > f.data['validUpto']) {
            _showDialog(
                activityContext: context,
                mode: TimeBankResponseModes.CODE_EXPIRED,
                dialogTitle: "Code Expired!",
                dialogSubTitle:
                    "This timebank code has been expired, please request the admin for a noew one!");
          } else {
            //code matche and is alive

            // add to usersOnBoarded
            Firestore.instance
                .collection("timebankCodes")
                .document(f.documentID)
                .updateData({
              'usersOnboarded': FieldValue.arrayUnion(
                  [SevaCore.of(context).loggedInUser.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .updateData({
              'members': FieldValue.arrayUnion(
                  [SevaCore.of(context).loggedInUser.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .get()
                .then((DocumentSnapshot timeBank) {
              var response = _showDialog(
                  mode: TimeBankResponseModes.ONBOARDED,
                  dialogTitle: "Awesome!",
                  dialogSubTitle:
                      "You have been onboaded to ${timeBank.data['name'].toString()} successfully.\nYou can switch to this timebank.");
              response.then((onValue) {
                print("onboadrd");
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
                // Navigator.of(context).pop();
              });
            });
          }
        });
      } else {
        var selected = _showDialog(
          mode: TimeBankResponseModes.NO_CODE,
          dialogTitle: "Not found!",
          dialogSubTitle:
              "We were unable to find the timebank code, please check and try again.",
        );

        selected.then((TimeBankResponseModes data) {
          print("----------------------------------------");
        });
      }
    });
  }

// user defined function
  Future<TimeBankResponseModes> _showDialog(
      {TimeBankResponseModes mode,
      String dialogTitle,
      String dialogSubTitle,
      BuildContext activityContext}) async {
    // flutter defined function
    return await showDialog<TimeBankResponseModes>(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog

        print("init dialog");
        return AlertDialog(
          title: new Text(dialogTitle),
          content: new Text(dialogSubTitle),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                switch (mode) {
                  case TimeBankResponseModes.CODE_EXPIRED:
                    Navigator.pop(context, TimeBankResponseModes.CODE_EXPIRED);
                    break;

                  case TimeBankResponseModes.NO_CODE:
                    Navigator.pop(context, TimeBankResponseModes.NO_CODE);
                    break;

                  case TimeBankResponseModes.ONBOARDED:
                    Navigator.pop(context, TimeBankResponseModes.ONBOARDED);
                    break;
                }
              },
            ),
          ],
        );
      },
    );
  }
}

enum TimeBankResponseModes { ONBOARDED, CODE_EXPIRED, NO_CODE }
