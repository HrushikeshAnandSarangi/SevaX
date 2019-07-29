import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sevaexchange/logger/logger.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy;
  Logger log;

  BaseViewModel({
    bool busy = false,
    String title,
  }) : _busy = busy {
    log = getLogger(title ?? this.runtimeType.toString());
  }

  bool get busy {
    // log.i('getBusy: $_busy');
    return this._busy;
  }

  set busy(bool busy) {
    // log.i('setBusy: $busy');
    this._busy = busy;
    notifyListeners();
  }

  @override
  void dispose() {
    log.i('dispose');
    super.dispose();
  }
}
