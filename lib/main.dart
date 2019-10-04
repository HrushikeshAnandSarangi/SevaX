// library business;

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/themes/sevatheme.dart';
// import 'package:sevaexchange/views/splash_view.dart';
// import './auth/auth.dart';
// import './auth/auth_provider.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// const String FlavorConfig.timebankId = 'ajilo297@gmail.com*1563778489754';

// void main() {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

//   _firebaseMessaging.requestNotificationPermissions(
//     IosNotificationSettings(
//       alert: true,
//       badge: true,
//       sound: true,
//     ),
//   );

//   _firebaseMessaging.configure(
//     onMessage: (Map<String, dynamic> message) {
//       print('onMessage: $message');
//       return null;
//     },
//     onLaunch: (Map<String, dynamic> message) {
//       print('onLaunch: $message');
//       return null;
//     },
//     onResume: (Map<String, dynamic> message) {
//       print('onResume: $message');
//       return null;
//     },
//   );

//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
//     (_) {
//       runApp(new SevaXApp());
//     },
//   );
// }

// class SevaXApp extends StatefulWidget {
//   @override
//   _SevaXAppState createState() => _SevaXAppState();
// }

// class _SevaXAppState extends State<SevaXApp> {
//   @override
//   Widget build(BuildContext context) {
//     return AuthProvider(
//       auth: Auth(),
//       child: MaterialApp(
//         theme: sevaTheme,
//         home: SplashView(),
//       ),
//     );
//   }
// }


void main(){}