import 'package:flutter/material.dart';

import 'initial_generator.dart';

class CustomAvatar extends StatelessWidget {
  final String? name;
  final Color? color;
  final Color? foregroundColor;
  final double? radius;
  final VoidCallback? onTap;

  const CustomAvatar({
    Key? key,
    this.name,
    this.color,
    this.radius,
    this.foregroundColor,
    this.onTap,
  })  : assert(name != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: foregroundColor ?? Colors.white,
        child: Center(
          child: Text(
            getInitials(name!.trim()).trim().toUpperCase(),
            style: TextStyle(
                color: color == Colors.white ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }
}
