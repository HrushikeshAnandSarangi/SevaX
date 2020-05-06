// import 'package:flutter/material.dart';
// import 'package:sevaexchange/base/base_view_model.dart';
// import 'package:sevaexchange/new_baseline/services/local_storage/local_storage_service.dart';

// class SplashViewModel extends BaseViewModel {
//   String _loadingMessage = '';
//   LocalStorageService _localStorageService;

//   SplashViewModel({
//     @required LocalStorageService localStorageService,
//   }) : this._localStorageService = localStorageService;

//   String get loadingMessage => _loadingMessage;
//   set loadingMessage(String value) {
//     _loadingMessage = value;
//     notifyListeners();
//   }

//   /// Precache images and check if user is logged in
//   Future initialize(BuildContext context) async {
//     await pauseLoading();
//     await preCacheImage(context);

//     bool userLoggedIn = await isUserLoggedIn();
//     if (userLoggedIn) {
//       navigateToCoreView(context);
//     } else {
//       navigateToLoginPage(context);
//     }
//   }

//   /// Pause loading for [duration]
//   Future pauseLoading({
//     Duration duration = const Duration(seconds: 1),
//   }) async {
//     log.i('pauseLoading: duration: ${duration.inSeconds} seconds');
//     busy = true;
//     await Future.delayed(duration);
//     loadingMessage = 'Loading';
//     busy = false;
//     return;
//   }

//   /// Pre-cache images
//   Future preCacheImage(BuildContext context) async {
//     log.i('preCacheImage: ');
//     busy = true;
//     loadingMessage = 'Pre caching images';
//     await precacheImage(
//       AssetImage('lib/assets/Y_from_Andrew_Yang_2020_logo.png'),
//       context,
//     );
//     busy = false;
//   }

//   /// Check if user is logged in and return a [bool]
//   Future<bool> isUserLoggedIn() async {
//     log.i('isUserLoggedIn: ');
//     loadingMessage = 'Checking if user is logged in';
//     busy = true;
//     String userEmail = await _localStorageService.loggedInEmailId;
//     String userId = await _localStorageService.loggedInUserId;
//     busy = false;

//     if (userEmail == null ||
//         userId == null ||
//         userId.isEmpty ||
//         userEmail.isEmpty) {
//       log.i('isUserLoggedIn: loginStatus: false');
//       return false;
//     }
//     log.i('isUserLoggedIn: loginStatus: true');
//     return false;
//   }

//   /// Navigate to login page using [Navigator.pushReplacement]
//   void navigateToLoginPage(BuildContext context) {
//     log.i('navigateToLoginPage: ');
//     // TODO: Complete this implementation
//   }

//   /// Navigate to core view using [Navigator.pushReplacement]
//   void navigateToCoreView(BuildContext context) {
//     log.i('navigateToCoreView: ');
//     // TODO: Complete this implementation
//   }
// }
