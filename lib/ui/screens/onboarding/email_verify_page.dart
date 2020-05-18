import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

class VerifyEmail extends StatefulWidget {
  final FirebaseUser firebaseUser;
  final String email;
  final bool emailSent;

  const VerifyEmail(
      {Key key, this.firebaseUser, this.email, this.emailSent = false})
      : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    if (!widget.emailSent) {
      print('sending email');
      Firestore.instance
          .collection('users')
          .document(widget.email)
          .setData({'emailSent': true}, merge: true).then(
        (_) => widget.firebaseUser
            .sendEmailVerification()
            .then((onValue) =>
                {print("Email successfully sent ${widget.firebaseUser.email}")})
            .catchError((err) => {print("Email not sent due to $err")}),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'images/verify_email.png',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: AppLocalizations.of(context).translate('verify_email','check_email'),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context).translate('verify_email','email_sent'),
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "${widget.email}",
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context).translate('verify_email','verify_account'),
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: FlatButton(
                    child: Text(AppLocalizations.of(context).translate('verify_email','resend_email')),
                    onPressed: () {
                      print("Sending email for verification");
                      widget.firebaseUser
                          .sendEmailVerification()
                          .then((onValue) {
                        showVerificationEmailDialog();
                      }).catchError((onError) {
                        print("Exception $onError");
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 40,
            right: 40,
            bottom: 80,
            child: Center(
              child: Text(
                AppLocalizations.of(context).translate('verify_email','please_login'),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            left: 40,
            right: 40,
            bottom: 20,
            child: RaisedButton(
              child: Text(AppLocalizations.of(context).translate('verify_email','login')),
              onPressed: () {
                _signOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    var auth = AuthProvider.of(context).auth;
    auth.signOut().then(
          (_) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AuthRouter(),
            ),
          ),
        );
  }

  void showVerificationEmailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('verify_email','verification_sent')),
          content: Text(AppLocalizations.of(context).translate('verify_email','verification_sent_desc'),),
          actions: <Widget>[
            FlatButton(
              child: Text(
            AppLocalizations.of(context).translate('shared','cancel'),
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ].reversed.toList(),
        );
      },
      barrierDismissible: false,
    );
  }
}
