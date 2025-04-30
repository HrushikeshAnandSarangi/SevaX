import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.color,
    this.shape,
    this.textColor,
    this.padding,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final OutlinedBorder? shape;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        // onSurface: Colors.black,
        // textStyle: TextStyle(color: textColor),
        shape: shape ?? StadiumBorder(),
        padding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 0),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color,
    this.shape,
    this.padding,
    this.elevation,
    this.textColor,
  }) : super(key: key);
  final Widget? child;
  final VoidCallback? onPressed;
  final Color? color;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.all(12),
        shape: shape ?? StadiumBorder(),
        textStyle: TextStyle(color: textColor ?? Colors.black),
        backgroundColor: color ?? Theme.of(context).primaryColor,
        elevation: elevation,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
