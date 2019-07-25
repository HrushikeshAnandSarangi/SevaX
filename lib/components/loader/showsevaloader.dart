// Dart Official Packages
import 'package:flutter/material.dart';
import './seva_loader.dart';

// Seva Developer Designed Packages

class ShowSevaLoader extends StatefulWidget {
  _ShowSevaLoaderState createState() => _ShowSevaLoaderState();
}

class _ShowSevaLoaderState extends State<ShowSevaLoader> {
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pinkAccent,
    Colors.blue
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SevaLoader(colors: colors, duration: Duration(milliseconds: 1200)),
    );
  }
}
