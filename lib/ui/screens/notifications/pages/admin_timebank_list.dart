import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/timebank_notifications.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class NotificationTimebankList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder<TimebankNotificationData>(
      stream: _bloc!.timebankNotifications,
      builder: (context, AsyncSnapshot<TimebankNotificationData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }

        if (!(snapshot.data?.isNotificationAvailable() ?? false)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                S.of(context).no_notifications,
              ),
            ),
          );
        }

        final List<TimebankModel> timebanks =
            List.from(snapshot.data!.timebanks.values);

        return ListView.separated(
          shrinkWrap: true,
          itemCount: timebanks.length,
          itemBuilder: (_, index) {
            var _timebank = timebanks[index];
            return snapshot.data!.notifications.containsKey(_timebank.id)
                ? ExpansionTile(
                    leading: CustomNetworkImage(_timebank.photoUrl),
                    title: Text(_timebank.name),
                    trailing:
                        snapshot.data!.notifications.containsKey(_timebank.id)
                            ? CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  (snapshot.data!.notifications[_timebank.id]
                                              ?.length ??
                                          0)
                                      .toString(),
                                ),
                                foregroundColor: Colors.white,
                              )
                            : SizedBox.fromSize(size: Size.zero),
                    children: [
                      TimebankNotifications(
                        timebankModel: _timebank,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                    ],
                  )
                : Container();
          },
          separatorBuilder: (_, index) {
            return snapshot.data!.notifications.containsKey(timebanks[index].id)
                ? Divider(
                    indent: 40,
                    endIndent: 20,
                    thickness: 1,
                  )
                : Container();
          },
        );
      },
    );
  }
}
