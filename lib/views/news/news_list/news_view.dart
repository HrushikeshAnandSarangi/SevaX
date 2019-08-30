import 'package:flutter/material.dart';
import 'package:sevaexchange/base/base_view.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/app_bar/common_app_bar_view.dart';
import 'package:sevaexchange/views/news/news_list/news_view_model.dart';

class NewsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewsViewModel viewModel = NewsViewModel();
    return BaseView<NewsViewModel>(
      viewModel: viewModel,
      builder: (context, viewModel, _) {
        return _getView(context, viewModel);
      },
    );
  }

  Widget _getView(BuildContext context, NewsViewModel viewModel) {
    return Scaffold(
      appBar: CommonAppBarView(
        titleString: 'Feed',
        userEmail: '',
      ),
      body: StreamBuilder<List<NewsModel>>(
        stream: FirestoreManager.getNewsStream(timebankID: FlavorConfig.timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
              break;
            default:
              List<NewsModel> newsList = snapshot.data;
              if (newsList.length == 0) {
                return Center(child: Text('Your feed is empty'));
              }
              return ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  //return NewsCard(newsList.elementAt(index), false);
                },
              );
          }
        },
      ),
    );
  }
}
