import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/nav_bar_model.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

import 'custom_navigation_item.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final int startIndex;
  final int selected;

  const CustomBottomNavigationBar(
      {Key? key,
      required this.onChanged,
      this.startIndex = 2,
      required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _messageBloc = BlocProvider.of<MessageBloc>(context);
    final _notificationBloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder<NavBarBadgeModel>(
      stream: CombineLatestStream.combine3(
        _notificationBloc!.personalNotificationCount,
        _notificationBloc.timebankNotificationCount,
        _messageBloc!.messageCount,
        (p, t, m) => NavBarBadgeModel(
          notificationCount: (p as int) + (t as int),
          chatCount: m as int,
        ),
      ),
      builder: (context, AsyncSnapshot<NavBarBadgeModel> snapshot) {
        int notificationCount = 0;
        int chatCount = 0;

        if (snapshot.hasData && snapshot.data != null) {
          notificationCount = snapshot.data!.notificationCount;
          chatCount = snapshot.data!.chatCount;
        }
        // log('notification count -> ${snapshot.data.notificationCount}');
        return CurvedNavigationBar(
          key: Key((notificationCount + chatCount).toString()),
          animationDuration: Duration(milliseconds: 300),
          index: selected,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.orange,
          height: 55,
          items: <CustomNavigationItem>[
            CustomNavigationItem(
              primaryIcon: Icons.explore,
              title: S.of(context).bottom_nav_explore,
              isSelected: selected == 0,
            ),
            CustomNavigationItem(
              key: UniqueKey(),
              primaryIcon: Icons.notifications,
              secondaryIcon: Icons.notifications_none,
              title: S.of(context).bottom_nav_notifications,
              isSelected: selected == 1,
              showBadge: notificationCount > 0,
              count: notificationCount.toString(),
            ),
            CustomNavigationItem(
              primaryIcon: Icons.home,
              title: S.of(context).bottom_nav_home,
              isSelected: selected == 2,
            ),
            CustomNavigationItem(
              key: UniqueKey(),
              primaryIcon: Icons.chat_bubble,
              secondaryIcon: Icons.chat_bubble_outline,
              title: S.of(context).bottom_nav_messages,
              isSelected: selected == 3,
              showBadge: chatCount > 0,
              count: chatCount.toString(),
            ),
            CustomNavigationItem(
              primaryIcon: Icons.account_circle_sharp,
              title: S.of(context).bottom_nav_profile,
              isSelected: selected == 4,
            ),
          ],
          onTap: (index) {
            onChanged(index);
          },
        );
      },
    );
  }
}
