import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String title;
  final Function onDelete;

  const CustomChip({Key key, this.title, this.onDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0x0FF70C493),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFFFFFFF),
                foregroundColor: Color(0xFFF70C493),
                child: Icon(
                  Icons.clear,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}