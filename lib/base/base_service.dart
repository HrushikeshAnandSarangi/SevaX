import 'package:logger/logger.dart';
import 'package:sevaexchange/logger/logger.dart';
import 'package:meta/meta.dart';

class BaseService {
  @protected
  Logger log;

  BaseService({String title}) {
    this.log = getLogger(title ?? this.runtimeType.toString());
  }
}
