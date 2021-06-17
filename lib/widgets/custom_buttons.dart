import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    Key key,
    this.onPressed,
    this.child,
    this.color,
    this.shape,
    this.textColor,
    this.padding,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final ShapeBorder shape;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: color,
        textStyle: TextStyle(color: textColor),
        shape: shape,
        padding: padding,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.color,
    this.shape,
    this.padding,
    this.elevation,
    this.textColor,
  }) : super(key: key);
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final ShapeBorder shape;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: padding,
        shape: shape,
        textStyle: TextStyle(color: textColor ?? Colors.black),
        primary: color ?? Theme.of(context).primaryColor,
        elevation: elevation,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
