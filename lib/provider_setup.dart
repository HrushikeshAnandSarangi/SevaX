import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/services/authentication/authentication_service.dart';
import 'package:sevaexchange/services/authentication/email_authentication_service.dart';
import 'package:sevaexchange/services/authentication/google_authentication_service.dart';
import 'package:sevaexchange/services/local_storage/local_storage_service.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];

List<SingleChildCloneableWidget> independentServices = [
  Provider.value(value: LocalStorageService.getInstance()),
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
];

List<SingleChildCloneableWidget> dependentServices = [
  ProxyProvider2<GoogleAuthenticationService, EmailAuthenticationService,
      AuthenticationService>(
    builder: (context, googleService, emailService, service) {
      return AuthenticationService(
        emailAuthService: emailService,
        googleAuthService: googleService,
      );
    },
  ),
];

List<SingleChildCloneableWidget> uiConsumableProviders = [];
