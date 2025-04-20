import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/admin_timebank_list.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/personal_notifications.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CombinedNotificationsPage extends StatefulWidget {
  @override
  _CombinedNotificationsPageState createState() =>
      _CombinedNotificationsPageState();
}

class _CombinedNotificationsPageState extends State<CombinedNotificationsPage>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          S.of(context).bottom_nav_notifications,
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<TimebankNotificationData>(
        stream: _bloc!.timebankNotifications,
        builder: (context, snapshot) {
          if (snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          return snapshot.data?.isAdmin == true
              ? Column(
                  children: [
                    TabBar(
                      controller: _controller,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: [
                        Tab(
                          child: Text(S.of(context).personal),
                        ),
                        Tab(
                          child: Text(S.of(context).timebank),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        children: [
                          PersonalNotifications(),
                          NotificationTimebankList(),
                        ],
                      ),
                    )
                  ],
                )
              : PersonalNotifications();
        },
      ),
    );
  }
}
