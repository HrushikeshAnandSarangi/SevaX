import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';

import '../../flavor_config.dart';
import '../core.dart';

class AboutApp extends StatelessWidget {
  AboutMode aboutMode;
  var dynamicLinks;
  final formkey = GlobalKey<FormState>();

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
          AppLocalizations.of(context).translate('profile', 'help'),
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getHelpButton(
              context,
              getOnTap(
                  context,
                  AppLocalizations.of(context).translate('help', 'about_sevax'),
                  'aboutSeva'),
              AppLocalizations.of(context).translate('help', 'about_sevax')),
          getHelpButton(
              context,
              getOnTap(
                  context,
                  AppLocalizations.of(context).translate('help', 'about_us'),
                  'aboutUsLink'),
              AppLocalizations.of(context).translate('help', 'about_us')),
          getHelpButton(
              context,
              getOnTap(
                  context,
                  AppLocalizations.of(context)
                      .translate('help', 'training_video'),
                  'trainingVideo'),
              AppLocalizations.of(context).translate('help', 'training_video')),
          getHelpButton(context, contactUsOnTap(context),
              AppLocalizations.of(context).translate('help', 'contact_us')),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlavorConfig.appFlavor == Flavor.SEVA_DEV
                ? Text(
                    "${AppConfig.appName}",
                    style: TextStyle(
                      fontFamily: 'Europa',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
            Text(
              '${AppLocalizations.of(context).translate('help', 'version')} ${AppConfig.appVersion}',
              style: TextStyle(
                fontFamily: 'Europa',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Function getOnTap(BuildContext context, String title, String dynamicKey) {
    return () {
      dynamicLinks = json.decode(
        AppConfig.remoteConfig.getString(
          AppLocalizations.of(context).translate('links', 'linkToWeb'),
        ),
      );

      navigateToWebView(
        aboutMode: AboutMode(title: title, urlToHit: dynamicLinks[dynamicKey]),
        context: context,
      );
    };
  }

  Widget aboutSevaX(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () async {
            dynamicLinks = json.decode(
              AppConfig.remoteConfig.getString(
                AppLocalizations.of(context).translate('links', 'linkToWeb'),
              ),
            );

            navigateToWebView(
              aboutMode: AboutMode(
                  title: AppLocalizations.of(context)
                      .translate('help', 'about_sevax'),
                  urlToHit: dynamicLinks['aboutSeva']),
              context: context,
            );
          },
          child: Container(
            child: Text(
              AppLocalizations.of(context).translate('help', 'about_sevax'),
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

  Widget getHelpButton(BuildContext context, Function onTap, String title) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.navigate_next),
              SizedBox(
                width: 10,
              ),
            ],
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
            dynamicLinks = json.decode(
              AppConfig.remoteConfig.getString(
                AppLocalizations.of(context).translate('links', 'linkToWeb'),
              ),
            );

            navigateToWebView(
              aboutMode: AboutMode(
                  title: AppLocalizations.of(context)
                      .translate('help', 'about_us'),
                  urlToHit: dynamicLinks['aboutUsLink']),
              context: context,
            );
          },
          child: Container(
            child: Text(
              AppLocalizations.of(context).translate('help', 'about_us'),
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
            dynamicLinks = json.decode(
              AppConfig.remoteConfig.getString(
                AppLocalizations.of(context).translate('links', 'linkToWeb'),
              ),
            );
            navigateToWebView(
              aboutMode: AboutMode(
                title: AppLocalizations.of(context)
                    .translate('help', 'training_video'),
                urlToHit: dynamicLinks['trainingVideo'],
              ),
              context: context,
            );
          },
          child: Container(
            child: Text(
              AppLocalizations.of(context).translate('help', 'training_video'),
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

  String feedbackText;

  Function contactUsOnTap(BuildContext context) {
    return () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
                AppLocalizations.of(context).translate('help', 'alert_text')),
            content: Form(
              key: formkey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate('help', 'feedback'),
                  labelText: AppLocalizations.of(context)
                      .translate('help', 'feedback'),
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
                    return AppLocalizations.of(context)
                        .translate('help', 'enter_feedback');
                  }
                  feedbackText = value;
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
                  AppLocalizations.of(context)
                      .translate('help', 'send_feedback'),
                  style: TextStyle(
                      fontSize: dialogButtonSize, fontFamily: 'Europa'),
                ),
                onPressed: () async {
                  //For test
                  if (formkey.currentState.validate()) {
                    print("------------------------------------");
                    Navigator.of(dialogContext).pop();

                    showProgressDialog(
                        context,
                        AppLocalizations.of(context)
                            .translate('help', 'send_feedback'));

                    await http.post(
                        "${FlavorConfig.values.cloudFunctionBaseURL}/sendFeedbackToTimebank",
                        body: {
                          "memberEmail":
                              SevaCore.of(context).loggedInUser.email,
                          "feedbackBody": feedbackText
                        });
                    Navigator.pop(progressContext);
                  }
                },
              ),
              new FlatButton(
                child: new Text(
                  AppLocalizations.of(context).translate('help', 'close'),
                  style: TextStyle(
                      fontSize: dialogButtonSize,
                      color: Colors.red,
                      fontFamily: 'Europa'),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    };
  }

  BuildContext progressContext;

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

//   Future<UserCardsModel> getUserCard(String communityId) async {
//     var result = await http.post(
//         "https://us-central1-sevaxproject4sevax.cloudfunctions.net/getCardsOfCustomer",
//         body: {"communityId": communityId});
//     print(result.body);
//     if (result.statusCode == 200) {
//       return userCardsModelFromJson(result.body);
//     } else {
//       throw Exception('No cards available');
//     }
//   }
// }

}
