import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class RepeatWidget extends StatefulWidget {
  RepeatWidget();

  @override
  RepeatWidgetState createState() => RepeatWidgetState();
}

class RepeatWidgetState extends State<RepeatWidget> {
  List<String> dayNameList = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  List<String> daysName = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  List<String> occurenccesList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  static List<bool> _selected = [];
  static List<int> recurringDays = [];
  static bool isRecurring = false;

  @override
  void initState() {
    super.initState();
    _selected = List.generate(dayNameList.length, (i) => false);
//    _selected[1] = true;
//    recurringDays =  List(7);
    isRecurring = false;
  }

  bool viewVisible = false;
  bool titleCheck = true;
  static int endType = 0;
  static String after = '1';
  static String selectedDays = '';

  double _result = 0.0;

  void _handleRadioValueChange(int? value) {
    setState(() {
      endType = value ?? 0;
    });
  }

  static List<int> getRecurringdays() {
    var x = 0;
    recurringDays.clear();
    for (var i = 0; i < _selected.length; i++) {
      if (_selected[i]) {
        recurringDays.add(i);
        x++;
      }
    }

    return recurringDays;
  }

  void _selectOnAfter() {
    setState(() {
      if (viewVisible) {
        viewVisible = false;
      } else {
        viewVisible = true;
      }
      titleCheck = !viewVisible;
      String days = "";
      for (int i = 0; i < 7; i++) {
        if (_selected[i]) {
          days = days + " " + daysName[i];
        }
      }
      selectedDays = days.trim();
    });
  }

  void _cancelOnAfter() {
    setState(() {
      if (viewVisible) {
        viewVisible = false;
      } else {
        viewVisible = true;
      }
      titleCheck = !viewVisible;
    });
  }

  static DateTime selectedDate = DateTime.now();
  DateFormat dateFormat = DateFormat.yMMMd();

//  var now =  DateTime.now();
//  var formatter =  DateFormat('yyyy-MM-dd');
//  String formatted = formatter.format(now);

//  Future<Null> _selectDate(BuildContext context) async {
//    final DateTime picked = await showDatePicker(
//        context: context,
//        initialDate: selectedDate,
//        firstDate: DateTime(2015, 1),
//        lastDate: DateTime(2101));
//    if (picked != null && picked != selectedDate)
//      setState(() {
//        selectedDate = picked;
//      });
//  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 1),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.purple, //Head background
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                secondary: Colors.purple, //selection color
              ),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
              //dialogBackgroundColor: Colors.white,//Background color
            ),
            child: child!,
          );
        });
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 8.0, 0, 8.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRecurring,
                    onChanged: (Value) {
                      setState(() {
                        isRecurring = Value!;
                        if (viewVisible) {
                          viewVisible = Value;
                        }
                        titleCheck = Value;
                      });
                    },
                  ),
                  Text("${S.of(context).repeat}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      )),
                  Visibility(
                    visible: isRecurring,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 8.0),
                      child: Container(
                        width: 160.0,
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.black12,
                        ),
                        child: InkWell(
                            onTap: _selectOnAfter,
                            child: Text(
                                "${S.of(context).recuring_weekly_on} ${selectedDays == "" || selectedDays == " " ? "..." : selectedDays}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Europa',
                                  color: Colors.black,
                                ))),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: viewVisible,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 8.0),
                        child: Text(
                          "${S.of(context).repeat_on}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Europa',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        height: 45.0,
                        margin: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 7,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) =>
                              Container(
                            alignment: Alignment.center,
                            height: 40.0,
                            width: 40.0,
                            margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40.0),
                              color: _selected[index]
                                  ? Theme.of(context).primaryColor
                                  : Colors.black12,
                            ),
                            child: InkWell(
                              child: Center(
                                child: Text(dayNameList[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Europa',
                                      color: _selected[index]
                                          ? Colors.white
                                          : Colors.black,
                                    )),
                              ),
                              onTap: () => setState(
                                () {
                                  _selected[index] = !_selected[index];
                                },
                              ), // reverse bool value
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 8.0),
                        child: Text("${S.of(context).ends}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                              color: Colors.black,
                            )),
                      ),
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: endType,
                            onChanged: _handleRadioValueChange,
                          ),
                          Text("${S.of(context).on}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: endType == 0
                                    ? Colors.black
                                    : Colors.black12,
                              )),
                          Container(
                            width: 160.0,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(34.0, 8.0, 8.0, 8.0),
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 15.0, 12.0, 15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              color: Colors.black12,
                            ),
                            child: InkWell(
                                onTap: endType == 0
                                    ? () async => await _selectDate(context)
                                    : null,
                                child:
                                    Text("${dateFormat.format(selectedDate)}",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Europa',
                                          color: endType == 0
                                              ? Colors.black54
                                              : Colors.black12,
                                        ))),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio(
                            value: 1,
                            groupValue: endType,
                            onChanged: _handleRadioValueChange,
                          ),
                          Text("${S.of(context).after}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: endType == 1
                                    ? Colors.black
                                    : Colors.black12,
                              )),
                          Container(
                            width: 160.0,
                            height: 44,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(20.0, 8.0, 8.0, 8.0),
                            padding:
                                const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              color: Colors.black12,
                            ),
                            child: InkWell(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: DropdownButton(
                                    value: after,
                                    onChanged: endType == 1
                                        ? (Value) {
                                            setState(() {
                                              after = Value as String;
                                            });
                                          }
                                        : null,
                                    items: occurenccesList
                                        .map<DropdownMenuItem<String>>(
                                            (String number) {
                                      return DropdownMenuItem(
                                        value: number,
                                        child: Text(
                                          number,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Europa',
                                            color: endType == 1
                                                ? Colors.black54
                                                : Colors.black12,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Text("${S.of(context).occurrences}",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Europa',
                                      color: endType == 1
                                          ? Colors.black54
                                          : Colors.black12,
                                    ))
                              ],
                            )),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: _selectOnAfter,
                                child: Text("${S.of(context).done}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Europa',
                                      color: Theme.of(context).primaryColor,
                                    )),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: _cancelOnAfter,
                                child: Text(
                                  "${S.of(context).cancel}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Europa',
                                    color: Colors.black12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
