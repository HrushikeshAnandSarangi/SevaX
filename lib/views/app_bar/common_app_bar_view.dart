import 'package:flutter/material.dart';
import 'package:sevaexchange/base/base_view.dart';
import 'package:sevaexchange/views/app_bar/common_app_bar_view_model.dart';

class CommonAppBarView extends StatelessWidget with PreferredSizeWidget {
  final String titleString;
  final String userEmail;

  CommonAppBarView({
    @required this.titleString,
    @required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    CommonAppBarViewModel viewModel = CommonAppBarViewModel();
    return BaseView<CommonAppBarViewModel>(
      viewModel: viewModel,
      builder: (context, viewModel, _) {
        return _getView(context, viewModel);
      },
    );
  }

  Widget _getView(BuildContext context, CommonAppBarViewModel viewModel) {
    return AppBar(
      title: Text(titleString),
      leading: IconButton(
        icon: Hero(
          tag: 'profilehero',
          child: Container(
            height: 36,
            width: 36,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              image: viewModel.busy
                  ? CircularProgressIndicator()
                  : DecorationImage(
                      image: NetworkImage(viewModel.photoUrl),
                    ),
            ),
          ),
        ),
        onPressed: () => viewModel.goToProfilePage(context),
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
            stream: viewModel.getNotifications(userEmail: userEmail),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return IconButton(
                  icon: Icon(Icons.notifications),
                  color: Colors.white,
                  onPressed: () => viewModel.gotoNotificationsPage(context),
                );
              }
              return IconButton(
                icon: snapshot.data
                    ? Icon(Icons.notifications_active)
                    : Icon(Icons.notifications),
                color: snapshot.data ? Colors.red : Colors.white,
                onPressed: () => viewModel.gotoNotificationsPage(context),
              );
            }),
        IconButton(
          icon: Icon(
            Icons.chat,
            color: Colors.white,
          ),
          onPressed: () => viewModel.gotoChatListView(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
