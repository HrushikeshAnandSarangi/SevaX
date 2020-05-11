import 'package:intl/intl.dart';

String getTimeFormattedString(int timeInMilliseconds) {
  DateFormat dateFormat = DateFormat('d MMM h:m a ');
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}
