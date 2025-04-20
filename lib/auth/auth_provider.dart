import 'package:flutter/material.dart';

import '../auth/auth.dart';

class AuthProvider extends InheritedWidget {
  final Auth auth;

  AuthProvider({
    Key? key,
    required Widget child,
    required this.auth,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AuthProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>()!;
  }
}
