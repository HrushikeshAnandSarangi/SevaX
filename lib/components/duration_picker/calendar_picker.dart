// import 'package:business/main.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import 'calendar_widget.dart';
import 'date_time_selector_widget.dart';
import 'time_picker_widget.dart';

class CalendarPicker extends StatefulWidget {
  final bool hideEndDate;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String selectedstartorend;
  //final void Function(DateTime dateTime) onDateSelected;

  CalendarPicker({
    this.title,
    Key key,
    this.startDate,
    this.endDate,
    this.selectedstartorend,
    this.hideEndDate = false,
  }) : super(key: key);

  @override
  CalendarPickerState createState() => CalendarPickerState();
}

class CalendarPickerState extends State<CalendarPicker> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
//  int timehour = DateTime.now().hour, timeminute = DateTime.now().minute;

  SelectionType selectionType;

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
    selectionType =
        widget.selectedstartorend == 'start' ? SelectionType.START_DATE : SelectionType.END_DATE;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context, [startDate, endDate]);
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Europa'),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DateTimeSelector(
                  title: S.of(context).start,
                  onPressed: () {
                    setState(() => {selectionType = SelectionType.START_DATE});
                    log("start date : $startDate");
                  },
                  dateTime: startDate,
                  isSelected: selectionType == SelectionType.START_DATE,
                ),
              ),
              HideWidget(
                hide: widget.hideEndDate,
                child: Expanded(
                  child: DateTimeSelector(
                    title: S.of(context).end,
                    onPressed: () {
                      setState(() => {selectionType = SelectionType.END_DATE});
                      log("end date : $endDate");
                    },
                    dateTime: endDate,
                    isSelected: selectionType == SelectionType.END_DATE,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                CalendarWidget(DateTime.now(), startDate, endDate, selectionType,
                    (callbackDate, callbackSelectionType) {
                  setState(() {
                    // selectionType = callbackSelectionType;
                    if (selectionType == SelectionType.START_DATE) {
                      startDate = DateTime(callbackDate.year, callbackDate.month, callbackDate.day,
                          startDate.hour, startDate.minute);
                      if (endDate.millisecondsSinceEpoch < startDate.millisecondsSinceEpoch) {
                        endDate = DateTime(startDate.year, startDate.month, startDate.day,
                            endDate.hour + 1, endDate.minute);
                      }
                    } else
                      endDate = callbackDate;
                  });
                }),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                  color: Color(0xfff2f2f2),
                  child: Text(
                    S.of(context).time,
                    style:
                        TextStyle(fontFamily: 'Europa', fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Container()),
                      Expanded(
                        child: TimePicker(
                          hour: selectionType == SelectionType.START_DATE
                              ? startDate.hour == 12
                                  ? startDate.hour
                                  : startDate.hour % 12
                              : startDate.millisecondsSinceEpoch < endDate.millisecondsSinceEpoch
                                  ? endDate.hour % 12
                                  : startDate.hour % 12,
                          minute: selectionType == SelectionType.START_DATE
                              ? (((startDate.minute / 15).round() * 15) % 60)
                              : startDate.millisecondsSinceEpoch < endDate.millisecondsSinceEpoch
                                  ? ((endDate.minute / 15).round() * 15) % 60
                                  : ((startDate.minute / 15).round() * 15) % 60,
                          ispm: selectionType == SelectionType.START_DATE
                              ? startDate.hour >= 12
                                  ? "PM"
                                  : "AM"
                              : startDate.millisecondsSinceEpoch < endDate.millisecondsSinceEpoch
                                  ? endDate.hour >= 12
                                      ? "PM"
                                      : "AM"
                                  : startDate.hour >= 12
                                      ? "PM"
                                      : "AM",
                          onTimeSelected: (hour, minute, ispm) {
                            setState(() {
                              if (selectionType == SelectionType.START_DATE) {
                                DateTime d1 = startDate;
                                startDate = DateTime(d1.year, d1.month, d1.day, hour, minute);
                              } else {
                                DateTime d1 = endDate;
                                endDate = DateTime(d1.year, d1.month, d1.day, hour, minute);
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
          getBottomButton(
            context,
            () {
              if (endDate.millisecondsSinceEpoch < startDate.millisecondsSinceEpoch) {
                _dateInvalidAlert(context);
              } else {
                Navigator.pop(context, [startDate, endDate]);
              }
            },
            S.of(context).done,
          ),
        ],
      ),
    );
  }

  void _dateInvalidAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).date_selection_issue),
          content: Container(
            child: Text(S.of(context).validation_error_end_date_greater),
          ),
          actions: <Widget>[
            CustomTextButton(
              shape: StadiumBorder(),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
