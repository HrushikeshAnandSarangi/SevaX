import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/models.dart';
import '../resources/repository.dart';

class PaymentCards {

}
class PaymentsModel {
}

class PaymentsController {
  PaymentsModel payment;
  List<PaymentCards> cards = [];

  paymentsController() {}
  setIsAdmin(isAdminStatus) {}
}

class PaymentsBloc {
  final _repository = Repository();
  final _paymentsController = BehaviorSubject<PaymentsController>();
  Observable<PaymentsController> get paymentsController =>
      _paymentsController.stream;

  paymentsBloc() {
    _paymentsController.add(PaymentsController());
  }

  storeNewCard(token, timebankid, UserModel user) {
    // storing a new card
    print("hey" + token);
    _repository.storeCard(token, timebankid, user);
    //
  }

  setIsAdmin(isAdminStatus) {
    _paymentsController.value.setIsAdmin(isAdminStatus);
    _paymentsController.add(_paymentsController.value);
  }

  dispose() {
    _paymentsController.close();
  }
}
final paymentsBloc = PaymentsBloc();