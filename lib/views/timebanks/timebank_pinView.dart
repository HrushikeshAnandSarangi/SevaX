import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/views/onboarding/bioview.dart';
import '../../splash_view.dart';
import '../splash_view.dart';
import 'timebank_congratsView.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

import 'timebank_join_request.dart';
//import 'package:sevaexchange/views/core.dart';

typedef StringListCallback = void Function(String otp);

class PinView extends StatefulWidget {
  // final Widget child;
  // TimebankModel timebankModel;
  // UserModel owner;
  // final VoidCallback onSkipped;
  // final StringListCallback onSelectedOtp;

  // PinView({
  //   Key key,
  //   this.child,
  //   @required this.timebankModel,
  //   @required this.owner,
  //   @required this.onSelectedOtp,
  //   @required this.onSkipped,
  // }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginSignupScreenState();
  }
}

class _LoginSignupScreenState extends State<PinView> {
  // TRUE: register page, FALSE: login page
  bool _register = true;
  TextEditingController controller = TextEditingController();
  String thisText = "";
  int pinLength = 5;

  bool hasError = false;
  String errorMessage1 = '';

  void _changeScreen() {
    setState(() {
      // sets it to the opposite of the current screen
      _register = !_register;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "OTP",
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
                    'Enter the code you recieved from your timebank Coordinator to see the exchange opportunities for your group',
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
                    'Enter 5 Digit Code',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                ),
                PinCodeTextField(
                  autofocus: false,
                  controller: controller,
                  hideCharacter: false,
                  highlight: true,
                  highlightColor: Colors.blue,
                  defaultBorderColor: Colors.black,
                  hasTextBorderColor: Colors.green,
                  maxLength: pinLength,
                  hasError: hasError,
                  maskCharacter: "•",
                  onTextChanged: (text) {
                    setState(() {
                      hasError = false;
                    });
                  },
                  onDone: (text) {},
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
                    Expanded(
                      child: RaisedButton(
                        //splashColor: Colors.white,
                        focusColor: Colors.blue,
                        highlightColor: Colors.white,
                        child: Text('Skip this step'),
                        textColor: Colors.blue,
                        color: Colors.transparent,
                        elevation: 0.0,
                        onPressed: () {
                          _navigateCongrats();
                        },
                      ),
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
                          color: Colors.blue,
                          onPressed: () {
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
      this._navigateCongrats();
    } else {
      if (controller.text.length == 0) {
        setState(() {
          this.hasError = true;
          this.errorMessage1 = 'Please enter PIN to verify';
        });
      } else {
        setState(() {
          this.hasError = true;
          this.errorMessage1 = "Wrong PIN!";
        });
      }
    }
  }

  void _navigateCongrats() {
    UserData.shared.user.calendar = "done";
    UserData.shared.user.requestStatus = "Accepted";
    UserData.shared.updateUserData();

    Navigator.popUntil(context, (r) => r.isFirst);
    //widget.onSelectedOtp(controller.text);
//    Navigator.pop(
//      context,
//      MaterialPageRoute(
//        builder: (BuildContext context) => SplashView(),
//      ),
//    );
  }
}
