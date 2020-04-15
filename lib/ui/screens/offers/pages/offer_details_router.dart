import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/views/core.dart';

import '../offers_ui.dart';
import 'offer_accepted_admin_router.dart';

class OfferDetailsRouter extends StatelessWidget {
  final OfferModel offerModel;

  const OfferDetailsRouter({Key key, this.offerModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool _isCreator =
        offerModel.sevaUserId == SevaCore.of(context).loggedInUser.sevaUserID;
    return Scaffold(
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
                                child: Text("Details"),
                              ),
                              Tab(
                                child: Text("Accepted"),
                              )
                            ]
                          : <Widget>[
                              Tab(
                                child: Text("Details"),
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
                          OfferCardView(offerModel: offerModel),
                          OfferAcceptedAdminRouter(),
                        ]
                      : <Widget>[
                          Container(
                            color: Colors.red,
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
