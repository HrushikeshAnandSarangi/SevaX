import 'package:flutter/material.dart';

class MessageDecoration {
  static BoxDecoration sendDecoration() {
    return BoxDecoration(
      color: Colors.indigo[200],
      border: Border.all(width: 0.1),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(15),
        topLeft: Radius.circular(8),
      ),
    );
  }

  static BoxDecoration receiveDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 0.1),
      borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(8)),
    );
  }
}
