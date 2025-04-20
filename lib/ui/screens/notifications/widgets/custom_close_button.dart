import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomCloseButton({Key? key, this.onTap})
      : assert(onTap != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: FractionalOffset.topRight,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/assets/images/close.png',
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
