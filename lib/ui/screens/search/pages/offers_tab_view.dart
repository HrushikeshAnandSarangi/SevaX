import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_offers.dart';

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
              timebankId: _bloc.timebank.id,
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
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final offer = snapshot.data[index];
                  return OffersCard(
                    title: offer.title,
                    description: offer.description,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferCardView(offerModel: OfferModel()),
      ),
    );
  }
}

class OffersCard extends StatelessWidget {
  final String title;
  final String description;
  final String photoUrl;

  const OffersCard({Key key, this.title, this.description, this.photoUrl})
      : assert(title != null),
        assert(description != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
    );
  }
}
