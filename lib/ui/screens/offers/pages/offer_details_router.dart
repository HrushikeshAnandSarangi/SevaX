import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
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
            SevaCore.of(context).loggedInUser.sevaUserID &&
        widget.offerModel.offerType == OfferType.GROUP_OFFER;
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
                                Tab(child: Text("Details")),
                                Tab(child: Text("Accepted")),
                              ]
                            : <Widget>[
                                Tab(child: Text("Details")),
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
                            OfferAcceptedAdminRouter(
                              offerModel: widget.offerModel,
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
