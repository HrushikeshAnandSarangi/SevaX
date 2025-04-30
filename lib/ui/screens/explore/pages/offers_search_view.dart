import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/communities/widgets/communities_categories.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/utils/tag_builder.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import '../../../../l10n/l10n.dart';

class OffersSearchView extends StatelessWidget {
  final bool? isUserSignedIn;

  const OffersSearchView({Key? key, this.isUserSignedIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<OfferModel>>(
          stream: _bloc.offers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Text(S.of(context).no_result_found);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var offer = snapshot.data![index];
                // var date = DateTime.fromMillisecondsSinceEpoch(offer.timestamp);
                return ExploreEventCard(
                  onTap: () {
                    if (isUserSignedIn != null && isUserSignedIn!) {
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
                          message: S.of(context).sign_in_alert);
                    }
                  },
                  photoUrl: /*offer.photoUrl ??*/ defaultProjectImageURL,
                  title: getOfferTitle(offerDataModel: offer),
                  description: getOfferDescription(offerDataModel: offer),
                  location: offer.selectedAdrress,
                  communityName: offer.communityName ?? '',
                  date: DateFormat('d MMMM, y')
                      .format(context.getDateTime(offer.timestamp!)),
                  time: DateFormat.jm()
                      .format(context.getDateTime(offer.timestamp!)),
                  tagsToShow: TagBuilder(
                    isPublic: offer.public!,
                    isVirtual: offer.virtual!,
                    isMoneyOffer: offer.type == RequestType.CASH &&
                        offer.offerType == OfferType.INDIVIDUAL_OFFER,
                    isGoodsOffer: offer.type == RequestType.GOODS &&
                        offer.offerType == OfferType.INDIVIDUAL_OFFER,
                    isTimeOffer: offer.type == RequestType.TIME &&
                        offer.offerType == OfferType.INDIVIDUAL_OFFER,
                    isOneToManyOffer: offer.offerType == OfferType.GROUP_OFFER,
                  ).getTags(context),
                );
              },
            );
          },
        ),
        SizedBox(height: 22),
        Text(
          S.of(context).browse_by_category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        CommunitiesCategory(
          stream: _bloc.communityCategory,
          onTap: (value) {
            _bloc.onCommunityCategoryChanged(value.id);
            Provider.of<ScrollController>(context, listen: false)?.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }
}
