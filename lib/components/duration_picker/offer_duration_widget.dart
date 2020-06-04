// import 'package:business/main.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/utils/app_config.dart';

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
//        ),
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
      // endtimestamp = endTime.add(new Duration(days: 1)).millisecondsSinceEpoch;
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
              Navigator.of(context)
                  .push(MaterialPageRoute<List<DateTime>>(
                builder: (context) =>
                    CalendarPicker(
                        widget.title.replaceAll('*', ''),
                        _calendarState,
                        startTime ?? DateTime.now(),
                        endTime ?? DateTime.now(),
                        type == DurationType.START ? 'start': 'end'),
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
      return '${type == DurationType.START ? AppLocalizations.of(context).translate('create_request','start') : AppLocalizations.of(context).translate('create_request','end')}\n${AppLocalizations.of(context).translate('create_request','start_end')}';
    }
    String dateTimeString = '';
    DateFormat format = DateFormat('dd MMM,\nhh:mm a', Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
    dateTimeString = format.format(dateTime);
    return dateTimeString;
  }
}

enum DurationType { START, END }