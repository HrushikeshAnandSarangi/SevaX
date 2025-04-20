import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class HomePageBloc {
  final _currentTimebank = BehaviorSubject<TimebankModel>();
  final _isAdmin = BehaviorSubject<bool>();
  TimebankModel? _oldValue;

  void changeTimebank(TimebankModel timebank) {
    logger.wtf(timebank.name);
    _oldValue = _currentTimebank.value ?? timebank;
    _currentTimebank.sink.add(timebank);
  }

  void switchToPreviousTimebank() {
    if (_oldValue != null) {
      AppConfig.timebankConfigurations = _oldValue!.timebankConfigurations;
      _currentTimebank.sink.add(_oldValue!);
    }
  }

  Stream<TimebankModel> get currentTimebank => _currentTimebank.stream;

  bool isAdmin(String userId) {
    try {
      logger.i(_currentTimebank.value);
      return isMemberAnAdmin(_currentTimebank.value, userId);
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  void dispose() {
    _isAdmin.close();
    _currentTimebank.close();
  }
}
