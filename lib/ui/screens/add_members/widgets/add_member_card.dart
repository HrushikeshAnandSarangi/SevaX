import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';

class AddMemberCard extends StatefulWidget {
  final String userId;
  final String photoUrl;
  final String fullName;
  final HashSet selectedMembers;
  const AddMemberCard({
    Key? key,
    required this.userId,
    required this.photoUrl,
    required this.fullName,
    required this.selectedMembers,
  }) : super(key: key);
  @override
  _AddMemberCardState createState() => _AddMemberCardState();
}

class _AddMemberCardState extends State<AddMemberCard> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedMembers.contains(widget.userId);
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        if (isSelected) {
          widget.selectedMembers.remove(widget.userId);
        } else {
          widget.selectedMembers.add(widget.userId);
        }
        setState(() {});
      },
      child: Card(
        color: isSelected ? Colors.green : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(widget.photoUrl ?? defaultUserImageURL),
          ),
          title: Text(
            widget.fullName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
