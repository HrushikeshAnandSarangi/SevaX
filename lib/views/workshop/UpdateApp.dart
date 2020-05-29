import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';
// import 'package:open_appstore/open_appstore.dart';

class UpdateView extends StatefulWidget {
  final VoidCallback onSkipped;
  bool isForced;

  UpdateView({
    @required this.onSkipped,
    @required this.isForced,
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
            'Update Available',
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar: ButtonBar(
          children: <Widget>[
            !widget.isForced
                ? FlatButton(
                    onPressed: () {
                      widget.onSkipped();
                    },
                    child: Text('Skip'),
                  )
                : Offstage(),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                StoreRedirect.redirect(
                    androidAppId: "com.sevaexchange.sevax",
                    iOSAppId: "456DU6XRWC.com.sevaexchange.app");
              },
              child: Text(
                "Update App",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(25),
          alignment: Alignment.center,
          child: Text(
            "There is an update available with the app, Please tap on update to use the latest version of the app",
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
