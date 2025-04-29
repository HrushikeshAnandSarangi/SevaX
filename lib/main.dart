import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sevaexchange/app.dart';
import 'package:sevaexchange/flavor_config.dart';
import './firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize app configurations based on flavor
  await initApp(Flavor.APP);

  // Run the app
  runApp(MainApplication(skipToHomePage: false));
}
