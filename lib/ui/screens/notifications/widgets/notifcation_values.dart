import 'package:flutter/material.dart';

EdgeInsets notificationPadding = EdgeInsets.fromLTRB(5, 5, 5, 0);

Decoration notificationDecoration = ShapeDecoration(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  color: Colors.white,
  shadows: [_shadow],
);

BoxShadow _shadow = BoxShadow(
  color: Colors.black.withAlpha(10),
  spreadRadius: 2,
  blurRadius: 3,
);

Widget dismissibleBackground = Container(
  margin: EdgeInsets.all(8),
  decoration: ShapeDecoration(
    color: Colors.red.withAlpha(80),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    shadows: [_shadow],
  ),
  child: ListTile(),
);
