import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/request/pages/donation_accepted_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';

import 'offer_accepted_admin_router.dart';
import 'offer_details.dart';

class OfferDetailsRouter extends StatefulWidget {
  final OfferModel? offerModel;
  final ComingFrom comingFrom;
  const OfferDetailsRouter({
    Key? key,
    this.offerModel,
    required this.comingFrom,
  }) : super(key: key);

  @override
  _OfferDetailsRouterState createState() => _OfferDetailsRouterState();
}

class _OfferDetailsRouterState extends State<OfferDetailsRouter> {
  final OfferBloc _bloc = OfferBloc();
  TimebankModel timebankModel = TimebankModel({});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTimebank();
    });
    _bloc.offerModel = widget.offerModel;
    _bloc.init();
    super.initState();
  }

  Future<void> getTimebank() async {
    if (widget.offerModel != null && widget.offerModel!.timebankId != null) {
      timebankModel = (await FirestoreManager.getTimeBankForId(
        timebankId: widget.offerModel!.timebankId!,
      ))!;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

//  void _onEdit(BuildContext context, ComingFrom comingFrom) {
//    //TODO by eswer - navigate to respective edit offer page using either offers router
//
//    switch (widget.offerModeferType) {
//      case OfferType.INDIVIDUAL_OFFER:
//        if(comingFrom == ComingFrom.Offers){
//
//        ExtendedNavigator.ofRouter<OffersNavigationRouter>().pushEditIndividualOfferContainer(
//          type: OfferType.INDIVIDUAL_OFFER,
//          offerModel: widget.offerModel,
//          timebankId: widget.offerModel.timebankId,
//        );
//        } else {
//          ExtendedNavigator.ofRouter<ElasticsearchRouter>()
//              .pushIndividualOfferElastic(offerModel: widget.offerModel, timebankId: widget.offerModel.timebankId);
//        }
//
//        break;
//      case OfferType.GROUP_OFFER:
//        if(comingFrom == ComingFrom.Offers){
//          ExtendedNavigator.ofRouter<OffersNavigationRouter>().pushEditIndividualOfferContainer(
//          type: OfferType.GROUP_OFFER,
//          offerModel: widget.offerModel,
//          timebankId: widget.offerModel.timebankId,
//        );
//        }else{
//          ExtendedNavigator.ofRouter<ElasticsearchRouter>()
//              .pushOneToManyOfferElastic(offerModel: widget.offerModel, timebankId: widget.offerModel.timebankId);
//        }
//        break;
//    }
//  }
//
//  void _onCancel(BuildContext context) {
//    switch (widget.offerModeferType) {
//      case OfferType.INDIVIDUAL_OFFER:
//        ExtendedNavigator.ofRouter<OffersNavigationRouter>().pushIndividualOffer(
//          offerModel: widget.offerModel,
//          timebankId: BlocProvider.of<AuthBloc>(context).user.currentTimebank,
//        );
//        break;
//      case OfferType.GROUP_OFFER:
//        showDialog(
//          context: context,
//          builder: (BuildContext _context) {
//            return AlertDialog(
//              title: Text(S.of(context).cancel_offer),
//              content: Text(S.of(context).cancel_offer_confirmation),
//              actions: [
//                CustomTextButton(
//                  child: Text(S.of(context).close),
//                  onPressed: () {
//                    ExtendedNavigator.of(context).pop();
//                  },
//                ),
//                CustomTextButton(
//                  child: Text(S.of(context).cancel_offer),
//                  onPressed: () async {
//                    await CollectionRef
//                        .offers
//                        .doc(widget.offerModel.id)
//                        .update({'groupOfferDataModel.isCanceled': true});
//                    ExtendedNavigator.of(context).pop();
//                  },
//                ),
//              ],
//            );
//          },
//        );
//        break;
//    }
//  }

  @override
  Widget build(BuildContext context) {
    if (widget.offerModel == null) {
      return const Center(child: CircularProgressIndicator());
    }
    bool _isCreator = widget.offerModel?.sevaUserId ==
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
                                offerModel: widget.offerModel!,
                                comingFrom: widget.comingFrom,
                                timebankModel: timebankModel,
                              ),
                              widget.offerModel!.type == RequestType.TIME
                                  ? OfferAcceptedAdminRouter(
                                      offerModel: widget.offerModel,
                                      timebankModel: timebankModel,
                                    )
                                  : widget.offerModel!.type ==
                                          RequestType.LENDING_OFFER
                                      ? LendingOfferParticipants(
                                          timebankModel: timebankModel,
                                          offerModel: widget.offerModel!,
                                        )
                                      : DonationAcceptedPage(
                                          offermodel: widget.offerModel,
                                        ),
                            ]
                          : <Widget>[
                              OfferDetails(
                                offerModel: widget.offerModel!,
                                comingFrom: widget.comingFrom,
                                timebankModel: timebankModel,
                              ),
                            ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
