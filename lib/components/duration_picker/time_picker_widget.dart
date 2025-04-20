// import 'package:business/main.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final int? hour;
  final int? minute;
  final String? ispm;
  final void Function(int hour, int minute, String ispm) onTimeSelected;

  TimePicker({required this.onTimeSelected, this.hour, this.minute, this.ispm});

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  int hour = 0, minute = 0;
  String ispm = 'AM';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    hour = (widget.hour ?? 0) > 0 ? widget.hour ?? 0 : 0;
    minute = (widget.minute ?? 0) > 0 ? widget.minute ?? 0 : 0;
    ispm = widget.ispm ?? 'AM';
    return Container(
      height: 130,
      child: Row(
        children: <Widget>[
          Expanded(
            child: DataScrollPicker(hourList, hour.toString(), (value) {
              if (ispm == 'PM')
                (int.parse(value) + 12) >= 24
                    ? int.parse(value) == 12
                        ? hour = int.parse(value)
                        : hour = int.parse(value)
                    : hour = int.parse(value) + 12;
              if (ispm == 'AM')
                (int.parse(value) - 12) <= 0
                    ? int.parse(value) == 12
                        ? hour = 0
                        : hour = int.parse(value)
                    : hour = int.parse(value) - 12;
              setState(() {
                hour = hour;
                ispm;
              });
              widget.onTimeSelected(hour, minute, ispm);
            }),
          ),
          Container(
            height: 44,
            color: Color(0xfff2f2f2),
            child: Center(
              child: Text(
                ':',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: DataScrollPicker(minuteList, minute.toString(), (value) {
              if (ispm == 'PM')
                (hour + 12) >= 24
                    ? hour == 12
                        ? hour = hour
                        : hour = hour
                    : hour = hour + 12;
              if (ispm == 'AM')
                (hour - 12) <= 0
                    ? hour == 12
                        ? hour = 0
                        : hour = hour
                    : hour = hour - 12;
              setState(() {
                minute = int.parse(value);
              });
              widget.onTimeSelected(hour, int.parse(value), ispm);
            }),
          ),
          Expanded(
            child: DataScrollPicker(amPmList, ispm, (value) {
              if (value == 'PM') (hour + 12) > 23 ? hour : hour = hour + 12;
              if (value == 'AM') (hour - 12) < 0 ? hour : hour = hour - 12;
              setState(() {
                hour = hour;
                ispm = value;
              });
              widget.onTimeSelected(hour, minute, value);
            }),
          ),
        ],
      ),
    );
  }

  List<String> get hourList {
    return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  }

  List<String> get minuteList {
    return ['00', '15', '30', '45'];
  }

  List<String> get amPmList {
    return ['AM', 'PM'];
  }
}

class DataScrollPicker extends StatefulWidget {
  final List<String> dataList;
  final void Function(String value) onValueSelected;
  final String presetvalue;

  DataScrollPicker(
    this.dataList,
    this.presetvalue,
    this.onValueSelected,
  );

  @override
  _DataScrollPickerState createState() => _DataScrollPickerState();
}

class _DataScrollPickerState extends State<DataScrollPicker> {
  late PageController _pageController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  int findSelectedIndex(datalist, presetvalue) {
    var temp = widget.dataList.indexOf(presetvalue);
    if (temp != null && temp != -1) {
      return temp;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = findSelectedIndex(widget.dataList, widget.presetvalue);
    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.4,
    );
    Future.delayed(Duration.zero, () {
      _pageController.jumpToPage(_selectedIndex > -1 ? _selectedIndex : 0);
    });
    return Container(
      height: 110,
      child: PageView(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        children: widget.dataList.map((data) {
          int index = widget.dataList.indexOf(data);

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
              widget.onValueSelected(widget.dataList.elementAt(index));
            },
            child: Container(
              color: _selectedIndex == index
                  ? Color(0xfff2f2f2)
                  : Colors.transparent,
              child: Center(
                child: Text(
                  data,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedIndex == index
                        ? Colors.black
                        : Color(0xffcccccc),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            widget.onValueSelected(widget.dataList.elementAt(index));
          });
        },
      ),
    );
  }
}
