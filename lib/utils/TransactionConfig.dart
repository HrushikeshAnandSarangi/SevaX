import 'package:flutter/cupertino.dart';

class TransactionConfig extends ChangeNotifier {
  late int _currentTransactionCount;

  int get currentTransactionCount => _currentTransactionCount;

//  bool get isTransactionAllowed =>
//      _currentTransactionCount <= AppConfig.maxTransactionLimit;

  set currentTransactionCount(int value) {
    _currentTransactionCount = value;
    notifyListeners();
  }
}
