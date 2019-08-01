import 'package:logger/logger.dart';
import 'package:sevaexchange/logger/logger.dart';

class BaseService {
  Logger log;

  BaseService({String title}) {
    this.log = getLogger(title ?? this.runtimeType.toString());
  }
}
