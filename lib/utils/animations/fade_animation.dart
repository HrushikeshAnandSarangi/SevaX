import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    // final tween = MultiTrackTween([
    //   Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
    //   Track("translateY").add(
    //       Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0),
    //       curve: Curves.easeOut)
    // ]);

    return CustomAnimationBuilder<double>(
      control: Control.play,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: (500 * delay).round(),
      ),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );

    //   delay: ,
    //   duration: tween.duration,
    //   tween: tween,
    //   child: child,
    //   builderWithChild: (context, child, animation) => Opacity(
    //     opacity: animation["opacity"],
    //     child: Transform.translate(
    //         offset: Offset(0, animation["translateY"]),
    //         child: child
    //     ),
    //   ),
    // );
  }
}
