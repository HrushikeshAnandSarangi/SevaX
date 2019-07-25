// import 'package:business/main.dart';
import 'package:flutter/material.dart';
import 'time_picker_widget.dart';
import 'calendar_widget.dart';
import 'date_time_selector_widget.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';

class CalendarPicker extends StatefulWidget {
  final String title;
  //final void Function(DateTime dateTime) onDateSelected;

  CalendarPicker(this.title, Key key) : super(key: key);

  @override
  CalendarPickerState createState() => CalendarPickerState();
}

class CalendarPickerState extends State<CalendarPicker> {
  final GlobalKey<CalendarWidgetState> _calendarState = GlobalKey();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int timehour = 0, timeminute = 0;

  SelectionType selectionType = SelectionType.START_DATE;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DateTimeSelector(
                  title: 'Start',
                  onPressed: () {
                    setState(() => selectionType = SelectionType.START_DATE);
                    print("start date : $startDate");
                  },
                  dateTime: startDate,
                  isSelected: selectionType == SelectionType.START_DATE,
                ),
              ),
              Expanded(
                child: DateTimeSelector(
                  title: 'End',
                  onPressed: () {
                    setState(() => selectionType = SelectionType.END_DATE);
                    print("end date : $endDate");
                  },
                  dateTime: endDate,
                  isSelected: selectionType == SelectionType.END_DATE,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                CalendarWidget(
                    DateTime.now(), startDate, endDate, selectionType,
                    (callbackDate) {
                  setState(() {
                    if (selectionType == SelectionType.START_DATE)
                      startDate = callbackDate;
                    else
                      endDate = callbackDate;
                  });
                }),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                  color: Color(0xfff2f2f2),
                  child: Text(
                    'Time',
                    // style: sectionLabelTextStyle,
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Container()),
                      Expanded(
                        child: TimePicker(
                          onTimeSelected: (hour, minute) {
                            setState(() {
                              timehour = hour;
                              timeminute = minute;
                              if (selectionType == SelectionType.START_DATE) {
                                DateTime d1 = startDate;
                                startDate = DateTime(d1.year, d1.month, d1.day,
                                    timehour, timeminute);
                              } else {
                                DateTime d1 = endDate;
                                endDate = DateTime(d1.year, d1.month, d1.day,
                                    timehour, timeminute);
                              }
                            });
                          },
                        ),
                        flex: 2,
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          getBottomButton(context, () {
// DateTime startDate = _calendarState.currentState.startDate;
// DateTime endDate = _calendarState.currentState.endDate;

            Navigator.pop(context, [startDate, endDate]);
            //TimePickerState.hour = 0;
            //TimePickerState.minute = 0;
          }, 'Done'),
        ],
      ),
    );
  }
}

Widget getBottomButton(BuildContext context, VoidCallback onTap, String title) {
  return Material(
    color: Theme.of(context).primaryColor,
    child: InkWell(
      onTap: onTap,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '$title'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
