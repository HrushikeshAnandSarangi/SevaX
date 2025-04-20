import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/utils/icons.dart';

class CameraIcon extends StatelessWidget {
  final double radius;

  const CameraIcon({Key? key, required this.radius})
      : assert(radius != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(radius / 3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(),
      ),
      child: Image.asset(cameraIcon),
    );
  }
}
