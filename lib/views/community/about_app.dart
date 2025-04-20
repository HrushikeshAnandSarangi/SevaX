import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/intro_slider.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../flavor_config.dart';
import '../core.dart';

class AboutApp extends StatelessWidget {
  late AboutMode aboutMode;
  var dynamicLinks;
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).help,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getHelpButton(
              context,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Intro(
                      onSkip: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              'Intro',
            ),
            getHelpButton(
              context,
              () => getOnTap(
                context,
                S.of(context).about + ' ' + AppConfig.appName,
                'aboutSeva',
              )(),
              S.of(context).about + ' ' + AppConfig.appName,
            ),
            getHelpButton(
              context,
              getOnTap(
                context,
                S.of(context).help_about_us,
                'aboutUsLink',
              )(),
              S.of(context).help_about_us,
            ),
            getHelpButton(
              context,
              () {
                navigateToWebView(
                  aboutMode: AboutMode(
                      title: S.of(context).help,
                      urlToHit: AppConfig.remoteConfig!
                          .getString('help_videos_admin')),
                  context: context,
                );
              },
              S.of(context).help_training_video,
            ),
            getHelpButton(
              context,
              () => contactUsOnTap(context)(),
              S.of(context).help_contact_us,
            ),
            getHelpButton(
              context,
              getOnTap(
                context,
                'Glossaries',
                'glossariesLink',
              )(),
              'Glossaries',
            ),
            getHelpButton(
              context,
              () => getOnTap(
                context,
                'FAQ',
                'faqLink',
              )(),
              'FAQ',
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
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
              '${S.of(context).help_version} ${AppConfig.appVersion}',
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
        AppConfig.remoteConfig!.getString(
          'links_${S.of(context).localeName}',
        ),
      );

      navigateToWebView(
        aboutMode: AboutMode(title: title, urlToHit: dynamicLinks[dynamicKey]),
        context: context,
      );
    };
  }

  Widget getHelpButton(BuildContext context, VoidCallback onTap, String title) {
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

  late String feedbackText;

  Function contactUsOnTap(BuildContext context) {
    return () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(
              S.of(context).feedback_messagae,
            ),
            content: Form(
              key: formkey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: S.of(context).feedback,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                validator: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).enter_feedback;
                  }
                  feedbackText = value;
                },
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              CustomTextButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(context).colorScheme.secondary,
                textColor: FlavorConfig.values.buttonTextColor,
                child: Text(
                  S.of(context).send_feedback,
                  style: TextStyle(
                      fontSize: dialogButtonSize, fontFamily: 'Europa'),
                ),
                onPressed: () async {
                  //For test
                  if (formkey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop();

                    showProgressDialog(
                      context,
                      S.of(context).sending_feedback,
                    );

                    await http.post(
                        Uri.parse(
                            "${FlavorConfig.values.cloudFunctionBaseURL}/sendFeedbackToTimebank"),
                        body: {
                          "memberEmail":
                              SevaCore.of(context).loggedInUser.email,
                          "feedbackBody": feedbackText
                        });
                    Navigator.pop(progressContext);
                  }
                },
              ),
              CustomTextButton(
                child: Text(
                  S.of(context).close,
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

  late BuildContext progressContext;

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        progressContext = createDialogContext;
        return AlertDialog(
          title: Text(message),
          content: LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
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
