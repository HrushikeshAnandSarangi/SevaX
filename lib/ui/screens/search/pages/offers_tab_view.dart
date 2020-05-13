import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';

class OffersTabView extends StatefulWidget {
  @override
  _OffersTabViewState createState() => _OffersTabViewState();
}

class _OffersTabViewState extends State<OffersTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    print("==>${_bloc.user.email}");
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<OfferModel>>(
            stream: Searches.searchOffers(
              queryString: search.data,
              loggedInUser: _bloc.user,
              currentCommunityOfUser: _bloc.community,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == null || snapshot.data.isEmpty) {
                print("===>> ${snapshot.data}");
                return Center(
                  child: Text("No data found !"),
                );
              }

              //Todo UPDATE_REQUIRED
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final offer = snapshot.data[index];
                  return OfferCard(
                    isCardVisible: isOfferVisible(
                      offer,
                      SevaCore.of(context).loggedInUser.sevaUserID,
                    ),
                    isCreator:
                        offer.email == SevaCore.of(context).loggedInUser.email,
                    title: getOfferTitle(offerDataModel: offer),
                    subtitle: getOfferDescription(offerDataModel: offer),
                    offerType: offer.offerType,
                    startDate: offer?.groupOfferDataModel?.startDate,
                    selectedAddress: offer.selectedAdrress,
                    actionButtonLabel: getButtonLabel(
                        offer, SevaCore.of(context).loggedInUser.sevaUserID),
                    onCardPressed: () => _navigateToOfferDetails(offer),
                    onActionPressed: () => offerActions(context, offer),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  _navigateToOfferDetails(OfferModel model) {
    print(model);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  }
}