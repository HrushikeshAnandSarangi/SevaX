import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimePicker extends StatefulWidget {
  final DateTime currentTime;
  final ValueChanged<DateTime> onTimeChanged;
  const TimePicker({Key key, this.currentTime, this.onTimeChanged})
      : super(key: key);
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  DateTime selectedTime;
  bool isAm;

  @override
  void initState() {
    selectedTime =
        widget.currentTime ?? DateTime(DateTime.now().year, 0, 0, 12);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 268.5,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CounterWithIncrementDecrement(
                  isHours: true,
                  currentValue: selectedTime.hour > 12
                      ? selectedTime.hour - 12
                      : selectedTime.hour,
                  increment: () {
                    setState(() {
                      selectedTime = selectedTime.add(Duration(hours: 1));
                      widget.onTimeChanged(selectedTime);
                    });
                  },
                  decrement: () {
                    setState(() {
                      selectedTime = selectedTime.subtract(Duration(hours: 1));
                      widget.onTimeChanged(selectedTime);
                    });
                  },
                  onChanged: (v) {
                    if (v != null && v.isNotEmpty) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          int.tryParse(v),
                          selectedTime.minute,
                          selectedTime.second,
                          selectedTime.millisecond,
                          selectedTime.microsecond,
                        );
                        widget.onTimeChanged(selectedTime);
                      });
                    }
                  },
                ),
                Text(
                  ':',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                CounterWithIncrementDecrement(
                  isHours: false,
                  currentValue: selectedTime.minute,
                  increment: () {
                    setState(() {
                      selectedTime = selectedTime.add(Duration(minutes: 1));
                      widget.onTimeChanged(selectedTime);
                    });
                  },
                  decrement: () {
                    setState(() {
                      selectedTime =
                          selectedTime.subtract(Duration(minutes: 1));
                      widget.onTimeChanged(selectedTime);
                    });
                  },
                  onChanged: (v) {
                    if (v != null && v.isNotEmpty) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          selectedTime.hour,
                          int.tryParse(v),
                          selectedTime.second,
                          selectedTime.millisecond,
                          selectedTime.microsecond,
                        );
                        widget.onTimeChanged(selectedTime);
                      });
                    }
                  },
                ),
                InkWell(
                  onTap: () {
                    debugPrint(selectedTime.toString());
                    setState(() {
                      if (selectedTime.hour > 12) {
                        selectedTime = selectedTime.subtract(
                          Duration(hours: 12),
                        );
                      } else {
                        selectedTime = selectedTime.add(
                          Duration(hours: 12),
                        );
                      }
                    });
                    debugPrint(selectedTime.toString());
                    widget.onTimeChanged(selectedTime);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      selectedTime.hour >= 12 ? 'PM' : 'AM',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CounterWithIncrementDecrement extends StatelessWidget {
  final bool isHours;
  final int currentValue;
  final VoidCallback increment;
  final VoidCallback decrement;
  final ValueChanged<String> onChanged;
  final _textController = TextEditingController();

  CounterWithIncrementDecrement({
    Key key,
    this.currentValue,
    this.increment,
    this.decrement,
    this.onChanged,
    @required this.isHours,
  }) {
    _textController.text = currentValue.toString();
    final val = TextSelection.collapsed(offset: _textController.text.length);
    _textController.selection = val;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.expand_less),
          onPressed: increment,
        ),
        Container(
          width: 30,
          child: TextField(
            controller: _textController,
            // '${currentValue ?? 0}',
            onChanged: onChanged,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.allow(
                isHours
                    ? RegExp(r'^([1-9]|[0-1][0-2])$')
                    : RegExp(r'^[0-5]?[0-9]$'),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.expand_more),
          onPressed: decrement,
        ),
      ],
    );
  }
}
