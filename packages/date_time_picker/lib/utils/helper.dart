bool isLeapYear(int year) {
  return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
}

bool isSameDay(DateTime d1, DateTime d2) {
  return (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
}

bool isSameTime(DateTime d1, DateTime d2) {
  return (d1.hour == d2.hour && d1.minute == d2.minute);
}

DateTime mergeDateAndTime(DateTime date, DateTime time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
