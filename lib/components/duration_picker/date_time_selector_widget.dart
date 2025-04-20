import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
// import 'package:business/main.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime? dateTime;
  final String? title;
  final bool? isSelected;
  final VoidCallback? onPressed;

  DateTimeSelector({
    required this.title,
    this.dateTime,
    this.onPressed,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContainer('$title', dateTime, context);
  }

  Widget _buildContainer(String _title, DateTime? _date, BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 9.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _title,
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Europa'
                          //color: title == 'End' ? Colors.red : Colors.green,
                          ),
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    _buildTime(_date),
                    SizedBox(
                      height: 7.0,
                    ),
                  ],
                ),
              ),
              Container(
                height: 2.0,
                color: (isSelected ?? false)
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTime(DateTime? _date) {
    if (_date == null) {
      return Text(
        'date & time',
        style: TextStyle(
          color: Color(0xff999999),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      String _forDate = DateFormat(
              'dd MMM yyyy, hh:mm a',
              Locale(
                getLangTag(),
              ).toString())
          .format(_date);
      return Text(
        _forDate,
        style: TextStyle(
          // color: title == 'End' ? Colors.red : Colors.green,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
        ),
      );
    }
  }
}
