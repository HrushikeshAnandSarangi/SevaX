import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class ThemeBloc {
  final _color = BehaviorSubject<Color>();

  Stream<Color> get color => _color.stream;

  void changeColor(Color color) {
    _color.sink.add(color);
  }

  void dispose() {
    _color.close();
  }
}
