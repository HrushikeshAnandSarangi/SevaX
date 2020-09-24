import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/offers/offer_list_items.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
import '../../ui/screens/offers/pages/create_offer.dart' as prefix0;
import '../core.dart';

class OffersModule extends StatefulWidget {
  final String communityId;
  final String timebankId;
  final TimebankModel timebankModel;
  OffersModule.of({this.timebankId, this.timebankModel, this.communityId});
  @override
  OffersState createState() => OffersState();
}

class OffersState extends State<OffersModule> {
  String timebankId;
  void _setORValue() {
    globals.orCreateSelector = 1;
  }

  bool isNearme = false;
  int sharedValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _setORValue();
    timebankId = widget.timebankModel.id;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              // margin: EdgeInsets.only(top: 12, bottom: 12),
              child: Row(
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 110.0,
                    height: 50.0,
                    buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                    child: Stack(
                      children: [
                        FlatButton(
                          onPressed: () {},
                          child: Text(
                            S.of(context).my_offers,
                            style: (TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        Positioned(
                          // will be positioned in the top right of the container
                          top: -10,
                          right: -10,
                          child: infoButton(
                            context: context,
                            key: GlobalKey(),
                            type: InfoType.OFFERS,
                            // text: infoDetails['offersInfo'] ?? description,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TransactionLimitCheck(
                    isSoftDeleteRequested:
                        widget.timebankModel.requestedSoftDelete,
                    child: GestureDetector(
                      onTap: () {
                        //TODO REMOVE
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddToCalendar(),
                          ),
                        );

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => prefix0.CreateOffer(
                        //       timebankId: timebankId,
                        //       // communityId: widget.communityId,
                        //     ),
                        //   ),
                        // );
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: 0),
                          child: Icon(
                            Icons.add_circle,
                            color: FlavorConfig.values.theme.primaryColor,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              height: 40,
              width: 40,
              child: IconButton(
                icon: Image.asset(
                  'lib/assets/images/help.png',
                ),
                color: FlavorConfig.values.theme.primaryColor,
                //iconSize: 16,
                onPressed: showOffersWebPage,
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
        Divider(
          color: Colors.white,
          height: 0,
        ),
        isNearme == true
            ? NearOfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
            : OfferListItems(
                parentContext: context,
                timebankId: timebankId,
                timebankModel: widget.timebankModel,
              )
      ],
    );
  }

  void _settingModalBottomSheet(context) {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    S.of(context).calendars_popup_desc,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/googlecal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => prefix0.CreateOffer(
                                    timebankId: timebankId,
                                    // communityId: widget.communityId,
                                  ),
                                ),
                              );
                            }),
                      ),
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/outlookcal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => prefix0.CreateOffer(
                                    timebankId: timebankId,
                                    // communityId: widget.communityId,
                                  ),
                                ),
                              );
                            }),
                      ),
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset("lib/assets/images/ical.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => prefix0.CreateOffer(
                                    timebankId: timebankId,
                                    // communityId: widget.communityId,
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text(
                          S.of(context).skip_for_now,
                          style: TextStyle(
                              color: FlavorConfig.values.theme.primaryColor),
                        ),
                        onPressed: () {
                          Navigator.of(bc).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => prefix0.CreateOffer(
                                timebankId: timebankId,
                                // communityId: widget.communityId,
                              ),
                            ),
                          );
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  void showOffersWebPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        'links_${S.of(context).localeName}',
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).offer_help,
          urlToHit: dynamicLinks['offersInfoLink']),
      context: context,
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
}
