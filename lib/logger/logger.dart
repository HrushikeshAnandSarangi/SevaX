import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  final String className;

  SimpleLogPrinter(this.className);

  @override
  void log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    debugPrint(
      color('${() {
        if (event.level != Level.info) return emoji;
        return '';
      }()}$className: ${event.message}'),
    );
  }
}

Logger getLogger(String className) {
  return Logger(printer: SimpleLogPrinter(className));
}