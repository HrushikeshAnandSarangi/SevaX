// import 'package:business/main.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import 'calendar_picker.dart';

class OfferDurationWidget extends StatefulWidget {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool hideEndDate;

  OfferDurationWidget({
    Key key,
    @required this.title,
    this.endTime,
    this.startTime,
    this.hideEndDate = false,
  }) : super(key: key);

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            title,
            SizedBox(height: 8),
            Row(
              children: <Widget>[
                startWidget,
                SizedBox(width: 16),
                HideWidget(
                  hide: widget.hideEndDate,
                  child: endWidget,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get title {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 0, 0),
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
          // style: sectionLabelTextStyle,
        ));
  }

  Widget get startWidget {
    if (startTime == null)
      starttimestamp = 0;
    // throw ("START_DATE_NOT_DEFINED");
    else
      starttimestamp = startTime.millisecondsSinceEpoch;

    return getDateTimeWidget(startTime, DurationType.START);
  }

  Widget get endWidget {
    if (endTime == null) {
      endtimestamp = 0;
      // var endTime = DateTime.now();
      // endtimestamp = endTime.add(  Duration(days: 1)).millisecondsSinceEpoch;
      // throw ("END_DATE_NOT_DEFINED");
    } else
      endtimestamp = endTime.millisecondsSinceEpoch;
    return getDateTimeWidget(endTime, DurationType.END);
  }

  Widget getDateTimeWidget(DateTime dateTime, DurationType type) {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(8),
      decoration: ShapeDecoration(
        // color: Color(0xfff2f2f2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: InkWell(
        splashColor: Color(0xffe5e5e5),
        onTap: () async {
          logger.d(widget.hideEndDate.toString() + "<<<___");
          Navigator.of(context)
              .push(MaterialPageRoute<List<DateTime>>(
            builder: (context) => CalendarPicker(
                hideEndDate: widget.hideEndDate,
                title: widget.title.replaceAll('*', ''),
                key: _calendarState,
                startDate: startTime ?? DateTime.now(),
                endDate: endTime ?? DateTime.now(),
                selectedstartorend: type == DurationType.START ? 'start' : 'end'),
            // Open calendar
          ))
              .then((List<DateTime> dateList) {
            setState(() {
              startTime = dateList?.elementAt(0);
              endTime = dateList?.elementAt(1);
            });
          });
        },
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
                      color: Colors.black,
                    ),
            ),
          ],
        ),
      ),
    ));
  }

  String getTimeString(DateTime dateTime, DurationType type) {
    if (dateTime == null) {
      return '${type == DurationType.START ? S.of(context).start : S.of(context).end}\n${S.of(context).date_time}';
    }
    String dateTimeString = '';
    DateFormat format = DateFormat('dd MMM,\nhh:mm a', Locale(getLangTag()).toLanguageTag());
    dateTimeString = format.format(dateTime);
    return dateTimeString;
  }
}

enum DurationType { START, END }
