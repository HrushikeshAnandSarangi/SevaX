// import 'package:business/main.dart';

import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/utils.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime dateTime;
  final DateTime startDate;
  final DateTime endDate;
  final SelectionType selectionType;
  final void Function(DateTime callbackDate, SelectionType selectionType)
      onDateSelected;

  CalendarWidget(
    this.dateTime,
    this.startDate,
    this.endDate,
    this.selectionType,
    this.onDateSelected, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CalendarWidgetState();
  }
}

class CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _currentDate;
  num _beginMonthPadding = 0;

  DateTime? startDate;
  DateTime? endDate;
  SelectionType? selectionType;

  @override
  void initState() {
    super.initState();
    selectionType = widget.selectionType;
    _currentDate = widget.dateTime ?? DateTime.now();
    setMonthPadding();
//    assert(widget.startDate.isBefore(widget.endDate) ||
//        isSameDay(widget.startDate, widget.endDate));
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Column(
                children: <Widget>[
                  monthSpinner,
                  Row(
                      children: weekdayList.map(
                    (weekday) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            weekday.substring(0, 2),
                            // style: sectionLabelTextStyle,
                          ),
                        ),
                      );
                    },
                  ).toList()),
                  GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                        getNumberOfDaysInMonth(_currentDate!.month), (index) {
                      int dayNumber = index + 1;
                      return GestureDetector(
                        onTap: () {
                          switch (widget.selectionType) {
                            case SelectionType.START_DATE:
                              if (isPastDay(dayNumber)) ;
//                              if (getSelectedDate(dayNumber).isAfter(endDate))
//                                return false;
                              setState(() {
                                startDate = getSelectedDate(dayNumber);
                                endDate = startDate;

                                //   selectionType = SelectionType.END_DATE;
                                widget.onDateSelected(
                                    getSelectedDate(dayNumber), selectionType!);
                              });
                              break;
                            case SelectionType.END_DATE:
                              if (isPastDay(dayNumber)) return;
//                              if (getSelectedDate(dayNumber)
//                                  .isBefore(startDate)) return false;
                              setState(() {
                                endDate = getSelectedDate(dayNumber);

                                //   selectionType = SelectionType.START_DATE;
                                widget.onDateSelected(
                                    getSelectedDate(dayNumber), selectionType!);
                              });
                              break;
                          }
                        },
                        child: Center(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            margin: EdgeInsets.symmetric(
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: dateBorder(dayNumber),
                              color: <Color>() {
                                if (dayNumber <= (_beginMonthPadding ?? 0)) {
                                  return Colors.transparent;
                                }
                                if (isInSelectedRange(dayNumber))
                                  return Theme.of(context).primaryColor;
                                return Colors.transparent;
                              }(),
                            ),
                            child: Container(
                              margin: EdgeInsets.all(1.0),
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: buildDayNumberWidget(dayNumber),
                                  ),
                                  // Container(
                                  //  child: buildDayNumberWidget1(dayNumber),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget buildDayNumberWidget(int dayNumber) {
    return Container(
      margin: EdgeInsets.all(1.5),
      decoration: ShapeDecoration(
        color: <Color>() {
          if (dayNumber <= _beginMonthPadding) return Colors.transparent;
          return Colors.transparent;
        }(),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: () {
            if (isCurrentDay(dayNumber)) return Theme.of(context).primaryColor;
            return Colors.transparent;
          }()),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Center(
        child: Text(
          dayNumber <= _beginMonthPadding
              ? ''
              : '${dayNumber - _beginMonthPadding}',
          style: TextStyle(
              color: <Color>() {
                if (isInSelectedRange(dayNumber)) return Colors.white;
                if (isCurrentDay(dayNumber)) return Colors.black;
                if (isPastDay(dayNumber)) return Colors.grey;
                return Colors.black;
              }(),
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  BorderRadius dateBorder(int dayNumber) {
    if (isSameDay(getSelectedDate(dayNumber), startDate!) &&
        isSameDay(getSelectedDate(dayNumber), endDate!)) {
      return BorderRadius.all(Radius.circular(15.0));
    }
    if (isSameDay(getSelectedDate(dayNumber), startDate!)) {
      return BorderRadius.only(
          topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0));
    }
    if (isSameDay(getSelectedDate(dayNumber), endDate!)) {
      return BorderRadius.only(
          topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0));
    }
    return BorderRadius.all(Radius.circular(0.0));
  }

  Widget get monthSpinner {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: IconButton(
            alignment: Alignment.centerRight,
            icon: Icon(
              Icons.expand_less,
              color: Colors.black,
            ),
            onPressed: goToPreviousMonth,
          ),
        ),
        Expanded(
          child: Text(
            '${monthName.elementAt(_currentDate!.month - 1)}',
            textAlign: TextAlign.center,
            // style: sectionLabelTextStyle,
          ),
        ),
        Expanded(
          child: Text(
            '${_currentDate!.year}',
            textAlign: TextAlign.center,
            // style: sectionLabelTextStyle,
          ),
        ),
        Expanded(
          child: IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.expand_more,
              color: Colors.black,
            ),
            onPressed: goToNextMonth,
          ),
        ),
      ],
    );
  }

  void setMonthPadding() {
    _beginMonthPadding =
        DateTime(_currentDate!.year, _currentDate!.month, 1).weekday;
    _beginMonthPadding = _beginMonthPadding == 7 ? 0 : _beginMonthPadding;
  }

  void goToPreviousMonth() {
    setState(() {
      if (_currentDate!.month == DateTime.january)
        _currentDate = DateTime(_currentDate!.year - 1, DateTime.december);
      else
        _currentDate = DateTime(_currentDate!.year, _currentDate!.month - 1);

      setMonthPadding();
    });
  }

  void goToNextMonth() {
    setState(() {
      if (_currentDate!.month == DateTime.december)
        _currentDate = DateTime(_currentDate!.year + 1, DateTime.january);
      else
        _currentDate = DateTime(_currentDate!.year, _currentDate!.month + 1);

      setMonthPadding();
    });
  }

  DateTime getSelectedDate(int dayNumber) {
    int day = dayNumber - _beginMonthPadding.toInt();
    var date = DateTime(
      _currentDate!.year,
      _currentDate!.month,
      day,
    );
    return date;
  }

  bool isInSelectedRange(int dayNumber) {
    int day = dayNumber - _beginMonthPadding.toInt();
    DateTime testDate = DateTime(_currentDate!.year, _currentDate!.month, day);

    if (startDate == null) return false;
    if (endDate == null) return false;
    if ((testDate.isAfter(startDate!) || isSameDay(testDate, startDate!)) &&
        (testDate.isBefore(endDate!) || isSameDay(testDate, endDate!))) {
      return true;
    }
    return false;
  }

  bool isPastDay(int dayNumber) =>
      (dayNumber - _beginMonthPadding) < DateTime.now().day &&
      _currentDate!.month == DateTime.now().month &&
      _currentDate!.year == DateTime.now().year;

  bool isCurrentDay(int dayNumber) =>
      (dayNumber - _beginMonthPadding) == DateTime.now().day &&
      _currentDate!.month == DateTime.now().month &&
      _currentDate!.year == DateTime.now().year;

  int getNumberOfDaysInMonth(int month) {
    int numDays = 28;
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        if (isLeapYear(_currentDate!.year)) {
          numDays = 29;
        } else {
          numDays = 28;
        }
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding.toInt();
  }

  List<String> get monthName => [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];

  List<String> get weekdayList => [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednessday',
        'Thursday',
        'Friday',
        'Saturday',
      ];
}

enum SelectionType { START_DATE, END_DATE }
