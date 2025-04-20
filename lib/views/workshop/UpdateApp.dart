import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:open_appstore/open_appstore.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:store_redirect/store_redirect.dart';

class UpdateView extends StatefulWidget {
  final VoidCallback onSkipped;
  bool isForced;

  UpdateView({
    required this.onSkipped,
    required this.isForced,
  });

  @override
  UpdateAppState createState() => UpdateAppState();
}

class UpdateAppState extends State<UpdateView> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            S.of(context).update_available,
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar: ButtonBar(
          children: <Widget>[
            !widget.isForced
                ? CustomTextButton(
                    onPressed: () {
                      widget.onSkipped();
                    },
                    child: Text(S.of(context).skip),
                  )
                : Offstage(),
            CustomElevatedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2.0,
              textColor: Colors.white,
              onPressed: () {
                StoreRedirect.redirect(
                    androidAppId: "com.sevaexchange.sevax",
                    iOSAppId: "456DU6XRWC.com.sevaexchange.app");
              },
              child: Text(
                S.of(context).update_app,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(25),
          alignment: Alignment.center,
          child: Text(
            S.of(context).update_msg,
            style: TextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
