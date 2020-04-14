import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/offers_ui.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
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
                  return OffersCard(
                    title: getOfferTitle(
                      offerDataModel: offer,
                    ),
                    description: getOfferDescription(offerDataModel: offer),
                    onTap: () => onTap(offer),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void onTap(OfferModel offerModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferCardView(offerModel: offerModel),
      ),
    );
  }
}

class OffersCard extends StatelessWidget {
  final String title;
  final String description;
  final String photoUrl;
  final Function onTap;

  const OffersCard(
      {Key key, this.title, this.description, this.photoUrl, this.onTap})
      : assert(title != null),
        assert(description != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: SizedBox(
                height: 40,
                width: 40,
                child: FadeInImage.assetNetwork(
                  placeholder: 'lib/assets/images/profile.png',
                  image: photoUrl ?? "",
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
