import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/new_baseline/services/authentication/authentication_service.dart';
import 'package:sevaexchange/new_baseline/services/authentication/email_authentication_service.dart';
import 'package:sevaexchange/new_baseline/services/authentication/google_authentication_service.dart';
import 'package:sevaexchange/new_baseline/services/local_storage/local_storage_service.dart';
List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];

List<SingleChildCloneableWidget> independentServices = [
  Provider.value(
    value: GoogleAuthenticationService(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    ),
  ),
  Provider.value(
    value: EmailAuthenticationService(
      firebaseAuth: FirebaseAuth.instance,
    ),
  ),
  Provider<LocalStorageService>.value(
    value: LocalStorageService(),
  ),
];

List<SingleChildCloneableWidget> dependentServices = [
  ProxyProvider3<GoogleAuthenticationService, EmailAuthenticationService,
      LocalStorageService, AuthenticationService>(
    builder: (context, googleService, emailService, storageService, service) {
      return AuthenticationService(
        emailAuthService: emailService,
        googleAuthService: googleService,
        localStorageService: storageService,
      );
    },
  ),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [];
