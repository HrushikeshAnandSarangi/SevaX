import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/offer_list_items.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

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

  @override
  void initState() {
    timebankId = widget.timebankModel.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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
                    comingFrom: ComingFrom.Offers,
                    timebankId: widget.timebankId,
                   isSoftDeleteRequested:
                       widget.timebankModel.requestedSoftDelete,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.timebankModel.id ==
                                FlavorConfig.values.timebankId &&
                            !isAccessAvailable(widget.timebankModel,
                                SevaCore.of(context).loggedInUser.sevaUserID)) {
                          showAdminAccessMessage(context: context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => prefix0.CreateOffer(
                                timebankId: timebankId,
                                // communityId: widget.communityId,
                              ),
                            ),
                          );
                        }
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
            // Container(
            //   height: 40,
            //   width: 40,
            //   child: IconButton(
            //     icon: Image.asset(
            //       'lib/assets/images/help.png',
            //     ),
            //     color: FlavorConfig.values.theme.primaryColor,
            //     //iconSize: 16,
            //     onPressed: showOffersWebPage,
            //   ),
            // ),
            SizedBox(width: 5),
          ],
        ),
        OfferListItems(
          parentContext: context,
          timebankId: timebankId,
          timebankModel: widget.timebankModel,
        )
      ],
    );
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
}
