import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/widgets/admin_message_card.dart';

class AdminMessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      physics: BouncingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (_, index) {
        return AdminMessageCard(
          name: "Treva Group",
          timestamp: 12334,
        );
      },
    );
  }
}
