import 'package:flutter/material.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/news_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class FeedsTabView extends StatefulWidget {
  @override
  _FeedsTabViewState createState() => _FeedsTabViewState();
}

class _FeedsTabViewState extends State<FeedsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<NewsModel>>(
            stream: Searches.searchFeeds(queryString: search.data),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final news = snapshot.data[index];
                  return NewsCard(
                    imageUrl: news.newsImageUrl ?? news.imageScraped,
                    title: news.title != null && news.title != "NoData"
                        ? news.title.trim()
                        : news.subheading.trim(),
                    userImageUrl: news.userPhotoURL,
                    userName: news.fullName,
                    timestamp: news.postTimestamp,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
