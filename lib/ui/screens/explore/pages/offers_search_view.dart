import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class OffersSearchView extends StatelessWidget {
  final bool isUserSignedIn;

  const OffersSearchView({Key key, this.isUserSignedIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return StreamBuilder<List<OfferModel>>(
      stream: _bloc.offers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Text('No result found');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            var offer = snapshot.data[index];
            var date = DateTime.fromMillisecondsSinceEpoch(offer.timestamp);
            return ExploreEventCard(
              onTap: () {
                if (isUserSignedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OfferDetailsRouter(
                          offerModel: offer,
                          comingFrom: ComingFrom.Home,
                        );
                      },
                    ),
                  );
                } else {
                  showSignInAlertMessage(
                      context: context,
                      message:
                          'Please Sign In/Sign up to access ${offer.individualOfferDataModel != null ? offer.individualOfferDataModel.title : offer.groupOfferDataModel.classTitle}');
                }
              },
              photoUrl: /*offer.photoUrl ??*/ defaultProjectImageURL,
              title: getOfferTitle(offerDataModel: offer),
              description: getOfferDescription(offerDataModel: offer),
              location: offer.selectedAdrress,
              communityName: offer.communityName ?? '',
              date: DateFormat('d MMMM, y').format(date),
              time: DateFormat.jm().format(date),
            );
          },
        );
      },
    );
  }
}
