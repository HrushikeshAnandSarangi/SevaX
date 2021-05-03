import 'package:flutter/material.dart';

class HideWidget extends StatelessWidget {
  final bool hide;
  final Widget child;
  final Widget secondChild;

  const HideWidget({Key key, this.hide = true, this.child, this.secondChild})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return hide ? secondChild ?? Container() : child;
  }
}
