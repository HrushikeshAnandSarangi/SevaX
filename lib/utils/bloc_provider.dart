import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
}

// Generic BLOC Provider
class BlocProvider<T extends BlocBase> extends StatefulWidget {
  const BlocProvider({this.bloc, this.child});

  final T? bloc;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _BlocProviderState<dynamic>();

  static T? of<T extends BlocBase>(BuildContext context) {
    final provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    return provider?.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  Widget build(context) => widget.child!;

  @override
  void dispose() {
    widget.bloc!.dispose();
    super.dispose();
  }
}
