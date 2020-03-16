import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';

import '../../flavor_config.dart';

class AboutApp extends StatelessWidget {
  AboutMode aboutMode;
  var dynamicLinks;
  final formkey = GlobalKey<FormState>();

  String feedbackValue;

  @override
  Future<void> initState() async {
    // super.initState();
    await AppConfig.remoteConfig.fetch(expiration: Duration(hours: 3));
    await AppConfig.remoteConfig.activateFetched();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          aboutSevaX(context),
          aboutUs(context),
          trainingVideo(context),
          contactUs(context),
        ],
      ),
    );
  }

  Widget aboutSevaX(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () async {
            dynamicLinks =
                json.decode(AppConfig.remoteConfig.getString('links'));

            navigateToWebView(
              aboutMode: AboutMode(
                  title: "About SevaX", urlToHit: dynamicLinks['aboutSeva']),
              context: context,
            );
          },
          child: Container(
            child: Text(
              "About SevaX",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToWebView({
    BuildContext context,
    AboutMode aboutMode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevaWebView(aboutMode),
      ),
    );
  }

  Widget aboutUs(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            dynamicLinks =
                json.decode(AppConfig.remoteConfig.getString('links'));

            navigateToWebView(
              aboutMode: AboutMode(
                  title: "About Us", urlToHit: dynamicLinks['aboutUsLink']),
              context: context,
            );
          },
          child: Container(
            child: Text(
              "About Us",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget trainingVideo(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            dynamicLinks =
                json.decode(AppConfig.remoteConfig.getString('links'));

            navigateToWebView(
              aboutMode: AboutMode(
                title: "Training Video",
                urlToHit: dynamicLinks['trainingVideo'],
              ),
              context: context,
            );
          },
          child: Container(
            child: Text(
              "Training Video",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget contactUs(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text(
                      "Please let us know about your valuable feedback"),
                  content: Form(
                    key: formkey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Feedback',
                        labelText: 'Feedback',
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                          borderSide: new BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your feedback';
                        }
                        feedbackValue = value;
                      },
                    ),
                  ),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      color: Theme.of(context).accentColor,
                      textColor: FlavorConfig.values.buttonTextColor,
                      child: new Text(
                        "Send feedback",
                        style: TextStyle(
                            fontSize: dialogButtonSize, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //For test
                        if (formkey.currentState.validate()) {
                          String url =
                              "https://us-central1-sevaxproject4sevax.cloudfunctions.net/sendFeedbackToTimebank";

                          await http.post(
                            url,
                            body: json.encode({
                              // "memberEmail":SevaCore.of(context).loggedInUser.email,
                              "memberEmail": "sample@example.com",
                              "feedbackBody": feedbackValue,
                            }),
                          );

                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    new FlatButton(
                      child: new Text(
                        "Close",
                        style: TextStyle(
                            fontSize: dialogButtonSize,
                            color: Colors.red,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            child: Text(
              "Contact Us",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
