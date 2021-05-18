import 'package:date_time_picker/utils/custom_shapes.dart';
import 'package:date_time_picker/utils/helper.dart';
import 'package:date_time_picker/utils/strings.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;

  const DatePicker({Key key, this.currentDate, this.onDateChanged})
      : super(key: key);
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime _currentDate;
  DateTime _selectedDate;
  int _beginMonthPadding = 0;

  @override
  void initState() {
    _currentDate = widget.currentDate ?? DateTime.now();
    _selectedDate = _currentDate;
    setMonthPadding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        monthSpinner,
        Row(
          children: weekdayList.map(
            (weekday) {
              return Expanded(
                child: Center(
                  child: Text(
                    weekday.substring(0, 2),
                  ),
                ),
              );
            },
          ).toList(),
        ),
        Container(
          child: GridView.count(
            padding: EdgeInsets.symmetric(vertical: 8),
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: List.generate(
              getNumberOfDaysInMonth(_currentDate.month),
              (index) {
                int dayNumber = index + 1;
                return GestureDetector(
                  onTap: () {
                    if (isPastDay(dayNumber)) return false;
                    setState(() {
                      _selectedDate = getSelectedDate(dayNumber);
                      widget.onDateChanged.call(_selectedDate);
                    });
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.symmetric(
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        color: <Color>() {
                          if (isSameDay(
                              getSelectedDate(dayNumber), _selectedDate))
                            return Theme.of(context).primaryColor;
                          return Colors.transparent;
                        }(),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(1.0),
                        padding: EdgeInsets.all(1.0),
                        child: Stack(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buildDayNumberWidget(dayNumber),
                            isSameDay(getSelectedDate(dayNumber), _selectedDate)
                                ? Align(
                                    alignment: Alignment.bottomRight,
                                    child: TriangleShapeWidget(),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDayNumberWidget(int dayNumber) {
    return Container(
      margin: EdgeInsets.all(1.5),
      decoration: ShapeDecoration(
        color: Colors.transparent,
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
              if (isSameDay(getSelectedDate(dayNumber), _selectedDate))
                return Colors.white;
              if (isCurrentDay(dayNumber)) return Colors.black;
              if (isPastDay(dayNumber)) return Colors.grey;
              return Colors.black;
            }(),
          ),
        ),
      ),
    );
  }

  DateTime getSelectedDate(int dayNumber) {
    int day = dayNumber - _beginMonthPadding;
    var date = DateTime(
      _currentDate.year,
      _currentDate.month,
      day,
    );
    return date;
  }

  Widget get monthSpinner => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          IconButton(
            alignment: Alignment.centerRight,
            icon: Icon(
              Icons.navigate_before,
              color: Colors.black,
            ),
            onPressed: goToPreviousMonth,
          ),
          Spacer(),
          Text(
            '${monthName.elementAt(_currentDate.month - 1)}',
            textAlign: TextAlign.center,
            maxLines: 1,
            // style: sectionLabelTextStyle,
          ),
          SizedBox(width: 8),
          Text(
            '${_currentDate.year}',
            textAlign: TextAlign.center,
            // style: sectionLabelTextStyle,
          ),
          Spacer(),
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.navigate_next,
              color: Colors.black,
            ),
            onPressed: goToNextMonth,
          ),
          Spacer(),
        ],
      );

  void goToPreviousMonth() {
    setState(() {
      if (_currentDate.month == DateTime.january)
        _currentDate = DateTime(_currentDate.year - 1, DateTime.december);
      else
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);

      setMonthPadding();
    });
  }

  void goToNextMonth() {
    setState(() {
      if (_currentDate.month == DateTime.december)
        _currentDate = DateTime(_currentDate.year + 1, DateTime.january);
      else
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);

      setMonthPadding();
    });
  }

  void setMonthPadding() {
    _beginMonthPadding =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday;
    _beginMonthPadding = _beginMonthPadding == 7 ? 0 : _beginMonthPadding;
  }

  bool isPastDay(int dayNumber) =>
      (dayNumber - _beginMonthPadding) < DateTime.now().day &&
      _currentDate.month == DateTime.now().month &&
      _currentDate.year == DateTime.now().year;

  bool isCurrentDay(int dayNumber) =>
      (dayNumber - _beginMonthPadding) == DateTime.now().day &&
      _currentDate.month == DateTime.now().month &&
      _currentDate.year == DateTime.now().year;

  int getNumberOfDaysInMonth(int month) {
    int numDays = 28;
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        if (isLeapYear(_currentDate.year)) {
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
    return numDays + _beginMonthPadding;
  }
}
