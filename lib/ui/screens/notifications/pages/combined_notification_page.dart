import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/personal_notifications.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class CombinedNotificationsPage extends StatefulWidget {
  @override
  _CombinedNotificationsPageState createState() =>
      _CombinedNotificationsPageState();
}

class _CombinedNotificationsPageState extends State<CombinedNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    print(_bloc.personalNotifications);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context).translate('notifications', 'title'),
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: PersonalNotifications(),
    );
  }
}
