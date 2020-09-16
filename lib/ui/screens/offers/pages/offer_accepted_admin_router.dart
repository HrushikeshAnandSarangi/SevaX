import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';

import 'offer_earnings.dart';
import 'offer_participants.dart';

class OfferAcceptedAdminRouter extends StatelessWidget {
  final OfferModel offerModel;

  const OfferAcceptedAdminRouter({Key key, this.offerModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> tabslist;
    offerModel.type == RequestType.TIME
        ? tabslist = [ OfferParticipants(offerModel: offerModel),
      OfferEarnings(offerModel: offerModel),
    ] : tabslist = [ OfferParticipants(offerModel: offerModel),
      OfferDonationRequest(offerModel: offerModel),
    ];
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
                    child: Text(S.of(context).participants),
                  ),
                  Tab(
                    child: Text(S.of(context).completed),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: tabslist,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
