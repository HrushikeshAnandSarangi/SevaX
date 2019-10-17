// import 'package:business/main.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'calendar_picker.dart';

class OfferDurationWidget extends StatefulWidget {
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  OfferDurationWidget(
      {Key key, @required this.title, this.endTime, this.startTime})
      : super(key: key);

  @override
  OfferDurationWidgetState createState() => OfferDurationWidgetState();
}

class OfferDurationWidgetState extends State<OfferDurationWidget> {
  DateTime startTime;
  DateTime endTime;
  static int starttimestamp = DateTime.now().millisecondsSinceEpoch;
  static int endtimestamp = DateTime.now().millisecondsSinceEpoch;
  final GlobalKey<CalendarPickerState> _calendarState = GlobalKey();

  @override
  void initState() {
    startTime = widget.startTime;
    endTime = widget.endTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        splashColor: Color(0xffe5e5e5),
        onTap: () async {
          Navigator.of(context)
              .push(MaterialPageRoute<List<DateTime>>(
            builder: (context) => CalendarPicker(
                widget.title.replaceAll('*', ''), _calendarState),
            // Open calendar
          ))
              .then((List<DateTime> dateList) {
            setState(() {
              startTime = dateList?.elementAt(0);
              endTime = dateList?.elementAt(1);
            });
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              title,
              SizedBox(height: 8),
              Row(
                children: <Widget>[
                  startWidget,
                  SizedBox(width: 16),
                  endWidget,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get title {
    return Text(
      widget.title,
      // style: sectionLabelTextStyle,
    );
  }

  Widget get startWidget {
    if (startTime == null)
      starttimestamp = DateTime.now().millisecondsSinceEpoch;
    else
      starttimestamp = startTime.millisecondsSinceEpoch;

    return getDateTimeWidget(startTime, DurationType.START);
  }

  Widget get endWidget {
    if (endTime == null)
      endtimestamp = DateTime.now().millisecondsSinceEpoch;
    else
      endtimestamp = endTime.millisecondsSinceEpoch;
    return getDateTimeWidget(endTime, DurationType.END);
  }

  Widget getDateTimeWidget(DateTime dateTime, DurationType type) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: Color(0xfff2f2f2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              // child: SvgPicture.asset('assets/icons/icon-calendar.svg'),
              child: Icon(Icons.calendar_today, color: Colors.black),
            ),
            Text(
              getTimeString(dateTime, type),
              style: dateTime == null
                  ? TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    )
                  : TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeString(DateTime dateTime, DurationType type) {
    if (dateTime == null) {
      return '${type == DurationType.START ? 'Start' : 'End'}\ndate & time';
    }
    String dateTimeString = '';
    DateFormat format = DateFormat('dd MMM,\nhh:mm a');
    dateTimeString = format.format(dateTime);
    return dateTimeString;
  }
}

enum DurationType { START, END }
