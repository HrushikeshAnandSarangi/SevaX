import 'package:flutter/material.dart';

import 'initial_generator.dart';

class CustomAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double radius;
  const CustomAvatar({
    Key key,
    this.name,
    this.color,
    this.radius,
  })  : assert(name != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color ?? Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Center(
        child: Text(
          getInitials(name.trim()).trim().toUpperCase(),
        ),
      ),
    );
  }
}
