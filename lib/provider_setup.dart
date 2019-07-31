import 'package:provider/provider.dart';
import 'package:sevaexchange/services/authentication/google_authentication_service.dart';
import 'package:sevaexchange/services/local_storage/local_storage_service.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];

List<SingleChildCloneableWidget> independentServices = [
  Provider.value(value: LocalStorageService.getInstance()),
  Provider.value(value: GoogleAuthenticationService())
];

List<SingleChildCloneableWidget> dependentServices = [

];

List<SingleChildCloneableWidget> uiConsumableProviders = [];
