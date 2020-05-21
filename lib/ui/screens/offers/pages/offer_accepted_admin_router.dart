import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/offer_model.dart';

import 'offer_earnings.dart';
import 'offer_participants.dart';

class OfferAcceptedAdminRouter extends StatelessWidget {
  final OfferModel offerModel;

  const OfferAcceptedAdminRouter({Key key, this.offerModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                indicatorColor: Colors.black,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: <Widget>[
                  Tab(
                    child: Text(AppLocalizations.of(context).translate('offers','participants')),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).translate('offers','completed')),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    OfferParticipants(offerModel: offerModel),
                    OfferEarnings(offerModel: offerModel),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
