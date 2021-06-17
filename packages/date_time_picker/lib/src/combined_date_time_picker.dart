import 'dart:developer';

import 'package:date_time_picker/src/date_picker.dart';
import 'package:date_time_picker/src/time_picker.dart';
import 'package:date_time_picker/utils/helper.dart';
import 'package:flutter/material.dart';

class CombinedDateTimePicker extends StatefulWidget {
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onDateTimeSelected;

  const CombinedDateTimePicker(
      {Key key, this.selectedDateTime, this.onDateTimeSelected})
      : super(key: key);
  @override
  _CombinedDateTimePickerState createState() => _CombinedDateTimePickerState();
}

class _CombinedDateTimePickerState extends State<CombinedDateTimePicker> {
  bool showTimePicker = false;
  DateTime selectedDateTime;
  DateTime time;
  DateTime date;

  @override
  void initState() {
    selectedDateTime = widget.selectedDateTime ?? DateTime.now();
    date = DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      selectedDateTime.day,
    );
    time = DateTime(
      selectedDateTime.year,
      0,
      0,
      selectedDateTime.hour,
      selectedDateTime.minute,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            child: showTimePicker
                ? pickerButton(
                    Icons.calendar_today,
                    onTap: () {
                      if (showTimePicker) {
                        showTimePicker = false;
                        setState(() {});
                      }
                    },
                  )
                : DatePicker(
                    currentDate: date,
                    onDateChanged: (newDate) {
                      date = newDate;
                      selectedDateTime =
                          mergeDateAndTime(newDate, selectedDateTime);
                      setState(() {});
                    },
                  ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            child: !showTimePicker
                ? pickerButton(
                    Icons.access_time,
                    onTap: () {
                      if (!showTimePicker) {
                        showTimePicker = true;
                        setState(() {});
                      }
                    },
                  )
                : TimePicker(
                    currentTime: time,
                    onTimeChanged: (newTime) {
                      time = newTime;
                      selectedDateTime =
                          mergeDateAndTime(selectedDateTime, newTime);
                      log(time.toString());
                      setState(() {});
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop(selectedDateTime);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget pickerButton(IconData icon, {VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 34,
          width: double.infinity,
          alignment: Alignment.center,
          color: Color(0xFFFE9E9E9),
          child: Icon(icon),
        ),
      ),
    );
  }
}
