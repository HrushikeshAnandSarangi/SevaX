import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/ui/screens/transaction_details/manager/transactions_details_handler.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class TransactionDetailsBloc {
  final _transactionDetailsController =
      BehaviorSubject<List<TransactionModel>>();
  final _searchQuery = BehaviorSubject<String>.seeded('');

  Stream<List<TransactionModel>> get _transactionDetailsStream =>
      _transactionDetailsController.stream;
  Stream<String> get searchQueryStream => _searchQuery.stream;
  Sink<String> get onSearchQueryChanged => _searchQuery.sink;

  Stream<List<TransactionModel>> data(BuildContext context) =>
      CombineLatestStream.combine2<List<TransactionModel>, String,
          List<TransactionModel>>(
        _transactionDetailsStream,
        _searchQuery.stream,
        (transactions, searchText) {
          if (searchText.isEmpty) {
            return transactions;
          }

          final _transactions = List<TransactionModel>.from(transactions);
          final searchTextLower = searchText.toLowerCase();
          _transactions.retainWhere(
            (element) =>
                getTransactionTypeLabel(element.type!, context)
                    .toLowerCase()
                    .contains(
                      searchTextLower,
                    ) ||
                element.credits.toString().contains(searchTextLower) ||
                element.createdDate.toLowerCase().contains(searchTextLower),
          );
          return _transactions;
        },
      );

  void init(String id, String userId) {
    logger.i("id==>: $id");
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

  void dispose() {
    _transactionDetailsController.close();
    _searchQuery.close();
  }
}
