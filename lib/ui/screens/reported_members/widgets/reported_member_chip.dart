import 'package:flutter/material.dart';

class ReportedMemberChip extends StatelessWidget {
  final int? count;
  final String? title;

  const ReportedMemberChip({Key? key, this.count, this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 14,
              child: Text(count.toString()),
              backgroundColor: Color(0xFF0FAFAFA),
              foregroundColor: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 4),
            Text(
              title!,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
