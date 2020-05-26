import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/nav_bar_model.dart';
import 'package:sevaexchange/views/core.dart';

import 'custom_navigation_item.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onChanged;
  final int startIndex;
  final int selected;

  const CustomBottomNavigationBar(
      {Key key, this.onChanged, this.startIndex = 2, this.selected})
      : super(key: key);

  @override
  build(BuildContext context) {
    return StreamBuilder<NavBarBadgeModel>(
      // stream: CombineLatestStream.combine2(
      //   Firestore.instance
      //       .collection('users')
      //       .document(SevaCore.of(context).loggedInUser.email)
      //       .collection('notifications')
      //       .where("communityId",
      //           isEqualTo: SevaCore.of(context).loggedInUser.currentCommunity)
      //       .where("isRead", isEqualTo: false)
      //       .snapshots()
      //       .transform(
      //     StreamTransformer.fromHandlers(
      //       handleData: (QuerySnapshot snapshot, sink) {
      //         sink.add(snapshot.documents.length);
      //       },
      //     ),
      //   ),
      //   getChatsforUser(
      //     email: SevaCore.of(context).loggedInUser.email,
      //     blockedBy: SevaCore.of(context).loggedInUser.blockedBy,
      //     blockedMembers: SevaCore.of(context).loggedInUser.blockedMembers,
      //     communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      //   ),
      //   (n, m) => NavBarBadgeModel(notificationCount: n, chats: m),
      // ),
      builder: (context, AsyncSnapshot<NavBarBadgeModel> snapshot) {
        int notificationCount = 0;
        int chatCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          notificationCount = snapshot.data.notificationCount;
          chatCount =
              snapshot.data.chatCount(SevaCore.of(context).loggedInUser.email);
        }

        return CurvedNavigationBar(
          // key: UniqueKey(),
          key: Key((notificationCount + chatCount).toString()),
          animationDuration: Duration(milliseconds: 300),
          index: selected,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.orange,
          height: 55,
          items: <CustomNavigationItem>[
            CustomNavigationItem(
              primaryIcon: Icons.explore,
              title: 'Explore',
              isSelected: selected == 0,
            ),
            CustomNavigationItem(
              key: UniqueKey(),
              primaryIcon: Icons.notifications,
              secondaryIcon: Icons.notifications_none,
              title: 'Notifications',
              isSelected: selected == 1,
              showBadge: notificationCount > 0,
              count: notificationCount.toString(),
            ),
            CustomNavigationItem(
              primaryIcon: Icons.home,
              title: 'Home',
              isSelected: selected == 2,
            ),
            CustomNavigationItem(
              key: UniqueKey(),
              primaryIcon: Icons.chat_bubble,
              secondaryIcon: Icons.chat_bubble_outline,
              title: 'Messages',
              isSelected: selected == 3,
              showBadge: chatCount > 0,
              count: chatCount.toString(),
            ),
            CustomNavigationItem(
              primaryIcon: Icons.settings,
              title: 'Profile',
              isSelected: selected == 4,
            ),
          ],
          onTap: (index) {
            onChanged(index);
            // selected = index;
            // setState(() {});
          },
        );
      },
    );
  }
}
