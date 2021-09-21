import 'package:flutter/material.dart';
import 'package:sevaexchange/components/repeat_availability/recurring_listing.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_list_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/create_offer.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/ui/screens/request/widgets/cutom_chip.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/utils/extensions.dart';


class OfferList extends StatefulWidget {
  final TimebankModel timebankModel;

  const OfferList({Key key, this.timebankModel}) : super(key: key);

  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList> {
  final bloc = OfferListBloc();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bloc.init(
        widget.timebankModel.id,
        SevaCore.of(context).loggedInUser,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = SevaCore.of(context).loggedInUser;
    return Column(
      children: [
        Row(
          children: <Widget>[
            SizedBox(width: 8),
            Text(
              S.of(context).offers,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            infoButton(
              context: context,
              key: GlobalKey(),
              type: InfoType.OFFERS,
            ),
            TransactionLimitCheck(
              comingFrom: ComingFrom.Offers,
              timebankId: widget.timebankModel.id,
              isSoftDeleteRequested: widget.timebankModel.requestedSoftDelete,
              child: GestureDetector(
                onTap: () {
                  if (widget.timebankModel.id ==
                          FlavorConfig.values.timebankId &&
                      !isAccessAvailable(
                          widget.timebankModel, user.sevaUserID)) {
                    showAdminAccessMessage(context: context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOffer(
                          timebankId: widget.timebankModel.id,
                          timebankModel: widget.timebankModel,
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
                  ),
                ),
              ),
            ),
          ],
        ),
        buildFilterView(),
        SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<OfferLists>(
            stream: bloc.offers,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('${S.of(context).general_stream_error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingIndicator(),
                );
              }

              if (snapshot.data == null || snapshot.data.isEmpty) {
                return Center(
                  child: EmptyWidget(
                    sub_title: S.of(context).no_content_common_description,
                    title: S.of(context).no_offers_title,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HideWidget(
                      hide: snapshot.data.myOffers.isEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              S.of(context).my_offers,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ...snapshot.data.myOffers
                              .map(
                                (model) => getOfferCard(
                                  model,
                                  widget.timebankModel,
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                    HideWidget(
                      hide: snapshot.data.communityoffers.isEmpty,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8),
                            child: Text(
                              S.of(context).timebank_offers,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ...snapshot.data.communityoffers
                              .map(
                                (model) => getOfferCard(
                                  model,
                                  widget.timebankModel,
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  StreamBuilder<OfferFilter> buildFilterView() {
    return StreamBuilder<OfferFilter>(
      initialData: OfferFilter(),
      stream: bloc.filter,
      builder: (context, snapshot) {
        var filter = snapshot.data;
        return Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).time,
                isSelected: filter.timeOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      timeOffer: !snapshot.data.timeOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).cash,
                isSelected: filter.cashOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      cashOffer: !snapshot.data.cashOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: 'Goods',
                isSelected: filter.goodsOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      goodsOffer: !snapshot.data.goodsOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).one_to_many.sentenceCase(),
                isSelected: filter.oneToManyOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      oneToManyOffer: !snapshot.data.oneToManyOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).lending_text,
                isSelected: filter.lendingOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      lendingOffer: !snapshot.data.lendingOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: 'Public',
                isSelected: filter.publicOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      publicOffer: !snapshot.data.publicOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              CustomChip(
                label: S.of(context).virtual,
                isSelected: filter.virtualOffer,
                onTap: () {
                  bloc.onFilterChange(
                    snapshot.data.copyWith(
                      virtualOffer: !snapshot.data.virtualOffer,
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget getOfferCard(OfferModel model, TimebankModel timebankModel) {
    var user = SevaCore.of(context).loggedInUser;
    return OfferCard(
      isCardVisible: isOfferVisible(
        model,
        user.sevaUserID,
      ),
      requestType: model.type,
      public: model.public,
      virtual: model.virtual,
      userCoordinates: model.currentUserLocation,
      offerCoordinates: model.location?.coords,
      isAutoGenerated: model.autoGenerated,
      isRecurring: model.isRecurring,
      type: model.type,
      isCreator: model.email == user.email,
      title: getOfferTitle(offerDataModel: model),
      subtitle: getOfferDescription(offerDataModel: model),
      offerType: model.offerType,
      startDate: model?.groupOfferDataModel?.startDate,
      timestamp: model?.timestamp,
      selectedAddress: model.selectedAdrress,
      actionButtonLabel: getButtonLabel(context, model, user.sevaUserID),
      buttonColor:
          (model.type == RequestType.CASH || model.type == RequestType.GOODS)
              ? Theme.of(context).primaryColor
              : isParticipant(context, model)
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
      onCardPressed: () async {
        if (model.isRecurring) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecurringListing(
                comingFrom: ComingFrom.Offers,
                offerModel: model,
                timebankModel: null,
                requestModel: null,
              ),
            ),
          );
        } else {
          _navigateToOfferRouter(model, ComingFrom.Offers, timebankModel);
        }
      },
      onActionPressed: () async {
        bool isAccepted = getOfferParticipants(offerDataModel: model)
            .contains(model.sevaUserId);

        if (model.type != RequestType.TIME &&
            !isAccessAvailable(
              timebankModel,
              user.sevaUserID,
            )) {
          CustomDialogs.generalDialogWithCloseButton(
            context,
            S.of(context).only_community_admins_can_accept,
          );
          return;
        }

        if (model.type == RequestType.CASH ||
            model.type == RequestType.GOODS && !isAccepted) {
          navigateToDonations(context, model);
        } else {
          offerActions(context, model, ComingFrom.Offers);
        }
      },
    );
  }

  void _navigateToOfferRouter(
      OfferModel model, ComingFrom comingFrom, TimebankModel timebankModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_context) => BlocProvider(
          bloc: BlocProvider.of<HomeDashBoardBloc>(context),
          child: OfferDetailsRouter(
            offerModel: model,
            comingFrom: ComingFrom.Offers,
          ),
        ),
      ),
    );
  }

  void navigateToDonations(context, OfferModel offerModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationView(
          offerModel: offerModel,
          timabankName: '',
          requestModel: null,
          notificationId: null,
        ),
      ),
    );
  }
}
