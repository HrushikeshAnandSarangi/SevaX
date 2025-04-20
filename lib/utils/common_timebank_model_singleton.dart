import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class TimeBankModelSingleton {
  late TimebankModel model;
  static final TimeBankModelSingleton _singleton =
      TimeBankModelSingleton._internal();

  factory TimeBankModelSingleton() {
    return _singleton;
  }
  TimeBankModelSingleton._internal();
}
