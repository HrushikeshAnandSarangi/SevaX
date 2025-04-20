import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/auth/auth_provider.dart' as SevaAuthProvider;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/empty_text_span.dart';

class VerifyEmail extends StatefulWidget {
  final User? firebaseUser;
  final String? email;
  final bool? emailSent;

  const VerifyEmail(
      {Key? key, this.firebaseUser, this.email, this.emailSent = false})
      : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgressDialog? progressDialog;

  @override
  void initState() {
    if (!widget.emailSent!) {
      CollectionRef.users
          .doc(widget.email)
          .set({'emailSent': true}, SetOptions(merge: true)).then(
        (_) => widget.firebaseUser!
            .sendEmailVerification()
            .then((onValue) => {
                  logger.i(
                      "Email successfully sent ${widget.firebaseUser!.email}")
                })
            .catchError((err) => {logger.e("Email not sent due to $err")}),
      );
    }
    super.initState();
  }

  void sendVerificationEmail(User user, {VoidCallback? onSuccess}) {
    user?.sendEmailVerification()?.then((onValue) {
      onSuccess?.call();
    })?.catchError((onError) {
      logger.e(onError);
      final snackBar = SnackBar(content: Text(onError.message));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
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
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: S.of(context).thanks,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        emptyTextSpan(placeHolder: '\n'),
                        TextSpan(
                          text: S.of(context).check_email,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        emptyTextSpan(placeHolder: '\n'),
                        TextSpan(
                          text: S.of(context).email_sent_to,
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        emptyTextSpan(placeHolder: '\n'),
                        TextSpan(
                          text: "${widget.email}",
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        emptyTextSpan(),
                        TextSpan(
                          text: S.of(context).verify_account,
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
                  child: CustomTextButton(
                    child: Text(S.of(context).resend_email),
                    onPressed: () {
                      progressDialog = ProgressDialog(
                        context,
                        customBody: Container(
                          height: 100,
                          width: 100,
                          child: LoadingIndicator(),
                        ),
                        isDismissible: false,
                      );
                      progressDialog!.show();
                      widget.firebaseUser!
                          .sendEmailVerification()
                          .then((onValue) {
                        progressDialog!.hide();
                        showVerificationEmailDialog();
                      }).catchError((onError) {
                        progressDialog!.hide();
                        final snackBar =
                            SnackBar(content: Text(onError.message));
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        logger.e(onError);
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
                S.of(context).login_after_verification,
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
            child: CustomElevatedButton(
              color: Colors.blue, // Replace with your desired color
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8)), // Replace with your desired shape
              padding: EdgeInsets.all(16), // Replace with your desired padding
              elevation: 5, // Replace with your desired elevation
              textColor: Colors.white, // Replace with your desired text color
              child: Text(S.of(context).sign_in),
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
    var auth = SevaAuthProvider.AuthProvider.of(context).auth;

    auth.signOut().then(
          (_) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false,
          ),
        );
  }

  void showVerificationEmailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).verification_sent),
          content: Text(
            S.of(context).verification_sent_desc,
          ),
          actions: <Widget>[
            CustomTextButton(
              child: Text(
                S.of(context).ok,
                //
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
