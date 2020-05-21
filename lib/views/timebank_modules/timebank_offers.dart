import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/offer_list_items.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

import '../../flavor_config.dart';
import '../../ui/screens/offers/pages/create_offer.dart' as prefix0;

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
  _setORValue() {
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
                            AppLocalizations.of(context).translate('offers','my_offers'),
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => prefix0.CreateOffer(
                              timebankId: timebankId,
                              // communityId: widget.communityId,
                            ),
                          ),
                        );
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
            IconButton(
              icon: Image.asset(
                'lib/assets/images/help.png',
              ),
              color: FlavorConfig.values.theme.primaryColor,
              iconSize: 24,
              onPressed: showOffersWebPage,
            ),
            Container(
              width: 120,
              child: CupertinoSegmentedControl<int>(
                selectedColor: Theme.of(context).primaryColor,
                children: logoWidgets,
                borderColor: Colors.grey,
                padding: EdgeInsets.only(left: 0, right: 5.0),
                groupValue: sharedValue,
                onValueChanged: (int val) {
                  print(val);
                  if (val != sharedValue) {
                    setState(() {
                      if (isNearme == true)
                        isNearme = false;
                      else
                        isNearme = true;
                    });
                    setState(() {
                      sharedValue = val;
                    });
                  }
                },
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
              )
      ],
    );
  }

  void showOffersWebPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    navigateToWebView(
      aboutMode: AboutMode(
          title: AppLocalizations.of(context).translate('offers','my_offers_help'), urlToHit: dynamicLinks['offersInfoLink']),
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

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'Near Me',
      style: TextStyle(fontSize: 10.0),
    ),
  };
}
