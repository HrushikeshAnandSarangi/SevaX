//TODO needs update
import 'chat_model.dart';

class NavBarBadgeModel {
  final int notificationCount;
  final List<ChatModel> chats;

  NavBarBadgeModel({this.notificationCount, this.chats});

  // int chatCount(String email) {
  //   int count = 0;
  //   chats.forEach((element) {
  //     if (element.unreadStatus.containsKey(email) && !element.isBlocked) {
  //       count += element.unreadStatus[email];
  //     }
  //   });
  //   return count;
  // }
}
