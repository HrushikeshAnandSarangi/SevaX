// import 'package:business/main.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final void Function(int hour, int minute) onTimeSelected;

  TimePicker({this.onTimeSelected});

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  int hour = 0, minute = 0;
  PageController _pageController;
  bool ispm = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      child: Row(
        children: <Widget>[
          Expanded(
            child: DataScrollPicker(hourList, (value) {
              setState(() {
                hour = int.parse(value);
                if (ispm) hour = hour + 12;
              });
              widget.onTimeSelected(hour, minute);
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
            child: DataScrollPicker(minuteList, (value) {
              setState(() {
                minute = int.parse(value);
              });
              widget.onTimeSelected(hour, minute);
            }),
          ),
          Expanded(
            child: DataScrollPicker(amPmList, (value) {
              setState(() {
                switch (value) {
                  case 'PM':
                    if (ispm == false) {
                      ispm = true;
                      hour = hour + 12;
                      if (hour == 24) {
                        hour = 0;
                        break;
                      }
                      if (hour > 24) break;
                    }
                    break;

                  case 'AM':
                    if (ispm == true) {
                      hour = hour - 12;
                      ispm = false;
                    }
                    break;
                }
              });
              widget.onTimeSelected(hour, minute);
            }),
          ),
        ],
      ),
    );
  }

  List<String> get hourList {
    return [
      //'0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      // '13',
      // '14',
      // '15',
      // '16',
      // '17',
      // '18',
      // '19',
      // '20',
      // '21',
      // '22',
      // '23',
    ];
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

  DataScrollPicker(
    this.dataList,
    this.onValueSelected,
  );

  @override
  _DataScrollPickerState createState() => _DataScrollPickerState();
}

class _DataScrollPickerState extends State<DataScrollPicker> {
  PageController _pageController;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        ? Theme.of(context).primaryColor
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
