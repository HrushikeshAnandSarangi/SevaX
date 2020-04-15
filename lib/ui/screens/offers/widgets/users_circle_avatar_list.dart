import 'package:flutter/material.dart';

class UserCircleAvatarList extends StatelessWidget {
  final List<String> userIds;

  const UserCircleAvatarList({Key key, this.userIds}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: userIds.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Text(userIds[index]),
        );
      },
    );
  }
}
