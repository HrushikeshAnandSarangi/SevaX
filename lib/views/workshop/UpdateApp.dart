import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
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
    return Scaffold(
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
              //Store
              const APP_STORE_URL =
                  'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=YOUR-APP-ID&mt=8';
              const PLAY_STORE_URL =
                  'https://play.google.com/store/apps/details?id=com.sevaexchange.app';
              PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                String appName = packageInfo.appName;
                String packageName = packageInfo.packageName;
                String version = packageInfo.version;

                String buildNumber = packageInfo.buildNumber;
                print("Package info --> $packageName");
                StoreRedirect.redirect(
                    androidAppId: packageName, iOSAppId: "1466915003");
              });

              // OpenAppstore.launch(
              //     androidAppId: "${packageName}", iOSAppId: "284882215");
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
//      Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Container(
//            margin: EdgeInsets.all(20),
//            alignment: Alignment.center,
//            child: Center(
//              child: Text(
//                "There is an update available with the app, Please tap on update to use the latest version of the app",
//                style: TextStyle(),
//              ),
//            ),
//          ),
//        ],
//      ),
    );
  }
}
