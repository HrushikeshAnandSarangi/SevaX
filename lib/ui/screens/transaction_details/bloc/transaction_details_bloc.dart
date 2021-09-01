import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class TransactionDetailsBloc {
  final _transactionDetailsController =
      BehaviorSubject<List<TransactionModel>>();

  Stream<List<TransactionModel>> get transactionDetailsStream =>
      _transactionDetailsController.stream;

  void init(String id, String userId) {
    if (id.contains('-')) {
      FirestoreManager.getUsersCreditsDebitsStream(
        userId: id,
      ).listen((result) => _transactionDetailsController.add(result));
    } else {
      FirestoreManager.getTimebankCreditsDebitsStream(
        timebankid: id,
        userId: userId,
      ).listen(
        (result) => _transactionDetailsController.add(result),
      );
    }
  }
}
