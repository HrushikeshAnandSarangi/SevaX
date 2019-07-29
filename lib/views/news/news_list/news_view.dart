import 'package:flutter/material.dart';
import 'package:sevaexchange/base/base_view.dart';
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
    );
  }
}
