import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_invitation.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_earnings.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

import 'offer_earnings.dart';
import 'offer_participants.dart';

class OfferAcceptedAdminRouter extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const OfferAcceptedAdminRouter(
      {Key? key, this.offerModel, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> tabslist;
    offerModel!.type == RequestType.TIME
        ? tabslist = offerModel!.offerType == OfferType.INDIVIDUAL_OFFER
            ? [
                TimeOfferParticipants(
                  //LendingOfferParticipants
                  //above lending offer widget to be integrated
                  offerModel: offerModel!,
                  timebankModel: timebankModel!,
                ),
                FindVolunteersViewForOffer(
                  sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!,
                  timebankId: timebankModel!.id,
                  offerModel: offerModel!,
                ),
                TimeOfferEarnings(
                    offerModel: offerModel!, timebankModel: timebankModel!),
              ]
            : [
                OfferParticipants(
                  offerModel: offerModel!,
                  timebankModel: timebankModel!,
                ),
                OfferEarnings(
                    offerModel: offerModel!, timebankModel: timebankModel!),
              ]
        : tabslist = [
            OfferParticipants(
              offerModel: offerModel!,
              timebankModel: timebankModel!,
            ),
            OfferDonationRequest(
              offerModel: offerModel!,
              timebankModel: timebankModel!,
            ),
          ];
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: tabslist.length,
          child: Column(
            children: <Widget>[
              TabBar(
                  indicatorColor: Colors.black,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: offerModel!.type == RequestType.TIME
                      ? offerModel!.offerType == OfferType.INDIVIDUAL_OFFER
                          ? <Widget>[
                              Tab(
                                child: Text(S.of(context).participants),
                              ),
                              Tab(
                                child: Text(S.of(context).invitations),
                              ),
                              Tab(
                                child: Text(S.of(context).completed),
                              ),
                            ]
                          : <Widget>[
                              Tab(
                                child: Text(S.of(context).participants),
                              ),
                              Tab(
                                child: Text(S.of(context).completed),
                              ),
                            ]
                      : <Widget>[
                          Tab(
                            child: Text(S.of(context).participants),
                          ),
                          Tab(
                            child: Text(S.of(context).completed),
                          ),
                        ]),
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
