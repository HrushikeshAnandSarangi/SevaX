import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/bookmarked_offers.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_offers.dart';

class OfferRouter extends StatelessWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  const OfferRouter({Key key, this.timebankId, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black,
                tabs: <Widget>[
                  Tab(
                    child: Text(S.of(context).offers),
                  ),
                  Tab(
                    child: Text(S.of(context).bookmarked_offers),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    OffersModule.of(
                      timebankId: timebankId,
                      timebankModel: timebankModel,
                    ),
                    BookmarkedOffers(
                      sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
                      timebankModel: timebankModel,
                    ),
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
