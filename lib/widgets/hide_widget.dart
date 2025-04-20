import 'package:flutter/material.dart';

class HideWidget extends StatelessWidget {
  final bool hide;
  final Widget child;
  final Widget secondChild;

  const HideWidget(
      {Key? key,
      required this.hide,
      required this.child,
      required this.secondChild})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return hide ? secondChild ?? Container() : child;
  }
}
