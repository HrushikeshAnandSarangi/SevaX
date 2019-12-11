import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sevaexchange/logger/logger.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy;
  Logger log;
  bool _isDisposed = false;

  BaseViewModel({
    bool busy = false,
    String title,
  }) : _busy = busy {
    log = getLogger(title ?? this.runtimeType.toString());
  }

  bool get busy {
    return this._busy;
  }

  set busy(bool busy) {
    this._busy = busy;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    } else {
      log.w('notifyListeners: View has been disposed');
    }
  }

  @override
  void dispose() {
    log.i('dispose');
    _isDisposed = true;
    super.dispose();
  }
}
