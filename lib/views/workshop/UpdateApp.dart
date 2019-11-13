import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
// import 'package:open_appstore/open_appstore.dart';

class UpdateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Available',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                "There an update available with the app, Please tap on update to use the latest version of the app",
                style: TextStyle(),
              ),
            ),
          ),
          RaisedButton(
            onPressed: () {
              PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                String appName = packageInfo.appName;
                String packageName = packageInfo.packageName;
                String version = packageInfo.version;

                String buildNumber = packageInfo.buildNumber;
                print("Package info --> $packageName");
              });

              // OpenAppstore.launch(
              //     androidAppId: "${packageName}", iOSAppId: "284882215");
            },
            child: Text("Update App"),
          )
        ],
      ),
    );
  }
}
