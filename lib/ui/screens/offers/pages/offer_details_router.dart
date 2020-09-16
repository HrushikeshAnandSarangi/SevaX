import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/donation_accepted_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

import 'offer_accepted_admin_router.dart';
import 'offer_details.dart';

class OfferDetailsRouter extends StatefulWidget {
  final OfferModel offerModel;

  const OfferDetailsRouter({Key key, this.offerModel}) : super(key: key);

  @override
  _OfferDetailsRouterState createState() => _OfferDetailsRouterState();
}

class _OfferDetailsRouterState extends State<OfferDetailsRouter> {
  final OfferBloc _bloc = OfferBloc();

  @override
  void initState() {
    log("-----offerid---------------> ${widget.offerModel.id} - ${widget.offerModel.occurenceCount}");
    print(widget.offerModel.toString());
    _bloc.offerModel = widget.offerModel;
    _bloc.init();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isCreator = widget.offerModel.sevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID;
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        body: SafeArea(
          child: DefaultTabController(
            length: _isCreator ? 2 : 1,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.grey,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: TabBar(
                        indicator: BoxDecoration(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: _isCreator
                            ? <Widget>[
                                Tab(
                                  child: Text(S.of(context).details),
                                ),
                                Tab(
                                  child: Text(S.of(context).accepted),
                                ),
                              ]
                            : <Widget>[
                                Tab(
                                  child: Text(S.of(context).details),
                                ),
                              ],
                      ),
                    ),
                    SizedBox(
                      width: 38,
                    )
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: _isCreator
                        ? <Widget>[
                            OfferDetails(
                              offerModel: widget.offerModel,
                            ),
                            widget.offerModel.type == RequestType.TIME
                                ? OfferAcceptedAdminRouter(
                                    offerModel: widget.offerModel,
                                  )
                                : DonationAcceptedPage(
                                    offermodel: widget.offerModel,
                                  ),
                          ]
                        : <Widget>[
                            OfferDetails(
                              offerModel: widget.offerModel,
                            ),
                          ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
