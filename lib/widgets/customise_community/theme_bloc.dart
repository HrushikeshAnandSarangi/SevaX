// lib/widgets/customise_community/theme_bloc.dart
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

/// Manages dynamic theme color
class ThemeBloc {
  /// Default primary color
  static const Color defaultColor = Color(0xFF766FE0);

  /// Internal subject for color changes
  final BehaviorSubject<Color> _color =
      BehaviorSubject<Color>.seeded(defaultColor);

  /// Emits color stream
  Stream<Color> get color => _color.stream;

  /// Change theme color
  void changeColor(Color color) {
    _color.add(color);
  }

  void dispose() {
    _color.close();
  }
}
