import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/base/base_view.dart';
import 'package:sevaexchange/services/local_storage/local_storage_service.dart';
import 'package:sevaexchange/views/splash/splash_view_model.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SplashViewModel viewModel = SplashViewModel(
      localStorageService: Provider.of<LocalStorageService>(context),
    );

    return BaseView<SplashViewModel>(
      viewModel: viewModel,
      onModelReady: (viewModel) {
        return viewModel.initialize(context);
      },
      builder: (context, viewModel, _) {
        return _getView(context, viewModel);
      },
    );
  }

  Widget _getView(BuildContext context, SplashViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SplashView'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            getLoader(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget getLoader(BuildContext context, SplashViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(viewModel.loadingMessage ?? ''),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 2,
            width: 150,
            child: LinearProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
