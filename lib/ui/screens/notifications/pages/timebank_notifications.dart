import 'package:flutter/material.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class TimebankNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder(
      stream: _bloc.timebankNotifications,
      builder:
          (_, AsyncSnapshot<Map<String, List<NotificationsModel>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }
        List<String> keys = List<String>.from(snapshot.data.keys);
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (_, index) {
            return Text(snapshot.data[keys[index]].toString());
          },
        );
      },
    );
  }
}
