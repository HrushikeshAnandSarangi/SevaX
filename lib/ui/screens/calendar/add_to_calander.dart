import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:url_launcher/url_launcher.dart';

import '../../../flavor_config.dart';

class AddToCalendar extends StatefulWidget {
  @required
  final RequestModel requestModel;
  @required
  final UserModel userModel;
  @required
  final OfferModel offer;
  @required
  final bool isOfferRequest;

  AddToCalendar({
    this.requestModel,
    this.userModel,
    this.offer,
    this.isOfferRequest,
  });

  @override
  State<StatefulWidget> createState() {
    return AddToCalendarState();
  }
}

enum CalanderType { iCAL, GOOGLE_CALANDER, OUTLOOK }

class AddToCalendarState extends State<AddToCalendar> {
  List<String> eventsIdsArr = [];

  Future<void> iCalIntegration() async {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      // "mobile": globals.isMobile,
      //TODO
      "mobile": true,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": eventsIdsArr,
      "createType": "REQUEST"
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);

    String redirectUrl =
        "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
    String authorizationUrl =
        "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

    List<String> acceptorList =
        widget.isOfferRequest != null && widget.offer.creatorAllowedCalender
            ? [widget.offer.email, widget.requestModel.email]
            : [widget.requestModel.email];
    widget.requestModel.allowedCalenderUsers = acceptorList.toList();
    await FirestoreManager.updateRequest(requestModel: widget.requestModel);
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
    // setState(() {
    //   comingFromDynamicLink = true;
    // });
    // Navigator.of(bc).pop();
    // Navigator.of(bc).pop();

    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> googleCalanderIntegration() async {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      // "mobile": globals.isMobile,
      //TODO
      "mobile": true,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": eventsIdsArr,
      "createType": "REQUEST"
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    String redirectUrl =
        "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
    String authorizationUrl =
        "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

    //listOfEmails for which event is created
    List<String> acceptorList =
        widget.isOfferRequest != null && widget.offer.creatorAllowedCalender
            ? [widget.offer.email, widget.requestModel.email]
            : [widget.requestModel.email];
    widget.requestModel.allowedCalenderUsers = acceptorList.toList();
    await FirestoreManager.updateRequest(requestModel: widget.requestModel);
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
    // setState(() {
    //   comingFromDynamicLink = true;
    // });

    // log("after showing modal bottom");
    // if (eventsIdsArr.length == 0) {
    //   showInsufficientBalance();
    // }

    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
    // Navigator.of(bc).pop();
  }

  Future<void> outlookCalanderIntegration() async {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      // "mobile": globals.isMobile,
      //TODO
      "mobile": true,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": eventsIdsArr,
      "createType": "REQUEST"
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    String redirectUrl =
        "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
    String authorizationUrl =
        "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

    List<String> acceptorList =
        widget.isOfferRequest != null && widget.offer.creatorAllowedCalender
            ? [widget.offer.email, widget.requestModel.email]
            : [widget.requestModel.email];
    widget.requestModel.allowedCalenderUsers = acceptorList.toList();
    await FirestoreManager.updateRequest(requestModel: widget.requestModel);
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
    // setState(() {
    //   comingFromDynamicLink = true;
    // });
    // Navigator.of(bc).pop();

    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Thank you for confirming your appointment'),
          Text('Tuesday september'),
          FlatButton(
            onPressed: () {
              // _settingModalBottomSheet(context);
            },
            child: Text('Add to Calander'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getCalander(
                icon: Icon(Icons.calendar_today_outlined),
                onPressed: iCalIntegration,
                title: 'Add to iCal',
              ),
              getCalander(
                icon: Icon(Icons.calendar_today_outlined),
                onPressed: googleCalanderIntegration,
                title: 'Add to Google',
              ),
              getCalander(
                icon: Icon(Icons.calendar_today_outlined),
                onPressed: outlookCalanderIntegration,
                title: 'Add to Outlook',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getCalander({
    Function onPressed,
    String title,
    Icon icon,
  }) {
    return Row(
      children: [
        IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
        Text(title)
      ],
    );
  }

  // void _settingModalBottomSheet(BuildContext context) {

  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return Container(
  //           child: new Wrap(
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
  //                 child: Text(
  //                   S.of(context).calendars_popup_desc,
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: <Widget>[
  //                     GestureDetector(
  //                       child: CircleAvatar(
  //                         backgroundColor: Colors.white,
  //                         radius: 40,
  //                         child: Image.asset("lib/assets/images/googlecal.png"),
  //                       ),
  //                       onTap: () async {},
  //                     ),
  //                     GestureDetector(
  //                         child: CircleAvatar(
  //                           backgroundColor: Colors.white,
  //                           radius: 40,
  //                           child: Image.asset(
  //                             "lib/assets/images/outlookcal.png",
  //                           ),
  //                         ),
  //                         onTap: () async {
  //                           String redirectUrl =
  //                               "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
  //                           String authorizationUrl =
  //                               "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

  //                           List<String> acceptorList =
  //                               widget.isOfferRequest != null &&
  //                                       widget.offer.creatorAllowedCalender
  //                                   ? [
  //                                       widget.offer.email,
  //                                       widget.requestModel.email
  //                                     ]
  //                                   : [widget.requestModel.email];
  //                           widget.requestModel.allowedCalenderUsers =
  //                               acceptorList.toList();
  //                           await FirestoreManager.updateRequest(
  //                               requestModel: widget.requestModel);
  //                           if (await canLaunch(authorizationUrl.toString())) {
  //                             await launch(authorizationUrl.toString());
  //                           }
  //                           // setState(() {
  //                           //   comingFromDynamicLink = true;
  //                           // });
  //                           Navigator.of(bc).pop();
  //                         }),
  //                     GestureDetector(
  //                         child: CircleAvatar(
  //                           backgroundColor: Colors.white,
  //                           radius: 40,
  //                           child: Image.asset("lib/assets/images/ical.png"),
  //                         ),
  //                         onTap: () async {
  //                           String redirectUrl =
  //                               "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
  //                           String authorizationUrl =
  //                               "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

  //                           List<String> acceptorList =
  //                               widget.isOfferRequest != null &&
  //                                       widget.offer.creatorAllowedCalender
  //                                   ? [
  //                                       widget.offer.email,
  //                                       widget.requestModel.email
  //                                     ]
  //                                   : [widget.requestModel.email];
  //                           widget.requestModel.allowedCalenderUsers =
  //                               acceptorList.toList();
  //                           await FirestoreManager.updateRequest(
  //                               requestModel: widget.requestModel);
  //                           if (await canLaunch(authorizationUrl.toString())) {
  //                             await launch(authorizationUrl.toString());
  //                           }
  //                           // setState(() {
  //                           //   comingFromDynamicLink = true;
  //                           // });
  //                           Navigator.of(bc).pop();
  //                         })
  //                   ],
  //                 ),
  //               ),
  //               Row(
  //                 children: <Widget>[
  //                   Spacer(),
  //                   FlatButton(
  //                       child: Text(
  //                         S.of(context).skip_for_now,
  //                         style: TextStyle(
  //                             color: FlavorConfig.values.theme.primaryColor),
  //                       ),
  //                       onPressed: () async {
  //                         List<String> acceptorList =
  //                             widget.isOfferRequest != null &&
  //                                     widget.offer.creatorAllowedCalender
  //                                 ? [widget.offer.email]
  //                                 : [];
  //                         widget.requestModel.allowedCalenderUsers =
  //                             acceptorList.toList();
  //                         await FirestoreManager.updateRequest(
  //                             requestModel: widget.requestModel);
  //                         Navigator.of(bc).pop();
  //                       }),
  //                 ],
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

}
