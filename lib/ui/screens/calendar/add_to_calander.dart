import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
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
  @required
  final List<String> eventsIdsArr;


  AddToCalendar({
    this.requestModel,
    this.userModel,
    this.offer,
    this.isOfferRequest,
    this.eventsIdsArr
  });

  @override
  State<StatefulWidget> createState() {
    return AddToCalendarState();
  }
}

enum CalanderType { iCAL, GOOGLE_CALANDER, OUTLOOK }

class AddToCalendarState extends State<AddToCalendar> {
    Future<void> googleCalanderIntegration() async {
        Map<String, dynamic> stateOfcalendarCallback = {
            "email": SevaCore.of(context).loggedInUser.email,
            // "mobile": globals.isMobile,
            //TODO
            "mobile": true,
            "envName": FlavorConfig.values.envMode,
            "eventsArr": widget.eventsIdsArr,
            "createType": widget.requestModel != null ? "REQUEST" : "OFFER"
        };
        var stateVar = jsonEncode(stateOfcalendarCallback);
        String redirectUrl =
            "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
        String authorizationUrl =
            "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

        //listOfEmails for which event is created
        if(widget.requestModel != null){
            List<String> acceptorList =
            widget.isOfferRequest != null
                ? widget.offer.creatorAllowedCalender==null || widget.offer.creatorAllowedCalender==false ? [widget.requestModel.email] : [widget.offer.email, widget.requestModel.email]
                : [widget.requestModel.email];
            widget.requestModel.allowedCalenderUsers = acceptorList.toList();
            await FirestoreManager.updateRequest(requestModel: widget.requestModel);
        }
        if (await canLaunch(authorizationUrl.toString())) {
            await launch(authorizationUrl.toString());
        }

        if (widget.isOfferRequest == true && widget.userModel != null) {
            Navigator.pop(context, {'response': 'ACCEPTED'});
        } else {
            Navigator.pop(context);
        }
    }

    Future<void> outlookCalanderIntegration() async {
        Map<String, dynamic> stateOfcalendarCallback = {
            "email": SevaCore.of(context).loggedInUser.email,
            // "mobile": globals.isMobile,
            //TODO
            "mobile": true,
            "envName": FlavorConfig.values.envMode,
            "eventsArr": widget.eventsIdsArr,
            "createType": widget.requestModel!=null ? "REQUEST" : "OFFER"
        };
        var stateVar = jsonEncode(stateOfcalendarCallback);
        String redirectUrl =
            "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
        String authorizationUrl =
            "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

        if(widget.requestModel!=null){
            List<String> acceptorList =
            widget.isOfferRequest != null
                ? widget.offer.creatorAllowedCalender==null || widget.offer.creatorAllowedCalender==false ? [widget.requestModel.email] : [widget.offer.email, widget.requestModel.email]
                : [widget.requestModel.email];
            widget.requestModel.allowedCalenderUsers = acceptorList.toList();
            await FirestoreManager.updateRequest(requestModel: widget.requestModel);
        }
        if (await canLaunch(authorizationUrl.toString())) {
            await launch(authorizationUrl.toString());
        }

        if (widget.isOfferRequest == true && widget.userModel != null) {
            Navigator.pop(context, {'response': 'ACCEPTED'});
        } else {
            Navigator.pop(context);
        }
    }

    Future<void> iCalIntegration() async {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      // "mobile": globals.isMobile,
      //TODO
      "mobile": true,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": widget.eventsIdsArr,
      "createType": widget.requestModel!=null ? "REQUEST":"OFFER"
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);

    String redirectUrl =
        "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
    String authorizationUrl =
        "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

    if(widget.requestModel!=null){
        List<String> acceptorList =
        widget.isOfferRequest != null
            ? widget.offer.creatorAllowedCalender==null || widget.offer.creatorAllowedCalender==false ? [widget.requestModel.email] : [widget.offer.email, widget.requestModel.email]
            : [widget.requestModel.email];
        widget.requestModel.allowedCalenderUsers = acceptorList.toList();
        await FirestoreManager.updateRequest(requestModel: widget.requestModel);
    }
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }

    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Add event to calander',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 120,
            color: Colors.green,
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text('Add to calendar'),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text('Do you want to add this event to your calendar?'),
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  getCalander(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 35,
                      child: Image.asset("lib/assets/images/googlecal.png"),
                    ),
                    onPressed: googleCalanderIntegration,
                    title: 'Add to Google Calendar',
                  ),
                  getCalander(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 35,
                      child: Image.asset("lib/assets/images/outlookcal.png"),
                    ),
                    onPressed: outlookCalanderIntegration,
                    title: 'Add to Outlook',
                  ),
                    getCalander(
                        icon: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 35,
                            child: Image.asset("lib/assets/images/ical.png"),
                        ),
                        onPressed: iCalIntegration,
                        title: 'Add to iCal',
                    ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        S.of(context).skip_for_now,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getCalander({
    Function onPressed,
    String title,
    CircleAvatar icon,
  }) {
    return TransactionsMatrixCheck(
        upgradeDetails: AppConfig.upgradePlanBannerModel.calendar_sync,
        transaction_matrix_type: "calendar_sync",
        child: Container(
        margin: EdgeInsets.only(left: 10),
        child: Row(
          children: [
            icon,
            FlatButton(
              onPressed: onPressed,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
