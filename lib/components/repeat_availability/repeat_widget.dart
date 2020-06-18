import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class RepeatWidget extends StatefulWidget {
  RepeatWidget();

  @override
  RepeatWidgetState createState() => RepeatWidgetState();
}

class RepeatWidgetState extends State<RepeatWidget> {
  List<String> dayNameList = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
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

  static List<bool> _selected;
  static List<int> recurringDays = new List<int>();

  @override
  void initState() {
    super.initState();
    _selected = List.generate(dayNameList.length, (i) => false);

  }

  static bool isRecurring = true;
  bool viewVisible = false;
  bool titleCheck = true;
  static int endType = 0;
  static String after = '1';
  static String selectedDays = 'Monday';

  double _result = 0.0;

  void _handleRadioValueChange(int value) {
    setState(() {
      endType = value;
    });
  }

  static getRecurringdays() {
//    var x = 0;
    for (var i = 0; i < _selected.length; i++) {
      if(_selected[i]==false && _selected.contains(i)){
        recurringDays.remove(i);
      }else if(_selected[i]==true && !_selected.contains(i)){
        recurringDays.add(i);
      }else{
        assert(true);
      }
    }
    print("list of data $recurringDays");
  }

  void _selectOnAfter() {
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
  DateFormat dateFormat = new DateFormat.yMMMd();

//  var now = new DateTime.now();
//  var formatter = new DateFormat('yyyy-MM-dd');
//  String formatted = formatter.format(now);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRecurring,
                    onChanged: (newValue) {
                      setState(() {
                        isRecurring = newValue;
                        if (viewVisible) {
                          viewVisible = newValue;
                        }
                        titleCheck = newValue;
                      });
                    },
                  ),
                  Text("Repeat",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      )),
                  Visibility(
                    visible: titleCheck,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26.0, 8.0, 6.0, 8.0),
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 10.0, 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.black12,
                        ),
                        child: InkWell(
                            onTap: _selectOnAfter,
                            child: Text("Weekly",
//                            child: Text("Weekly on $selectedDays",
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
                        child: Text("Repeat on",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                              color: Colors.black,
                            )),
                      ),
                      Container(
                          height: 45.0,
                          margin: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                          alignment: Alignment.center,
                          child: new ListView.builder(
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
                                        borderRadius:
                                            BorderRadius.circular(40.0),
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
                                        onTap: () => setState(() {
                                          _selected[index] = !_selected[index];
                                        }), // reverse bool value
                                      ))
//                            children: getDayList(),
                              )),
                      Container(
                        alignment: Alignment.topLeft,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 8.0),
                        child: Text("Ends",
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
                          Text("On",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: endType == 0
                                    ? Colors.black
                                    : Colors.black12,
                              )),
                          Container(
                            width: 180.0,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(32.0, 8.0, 8.0, 8.0),
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 15.0, 12.0, 15.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              color: Colors.black12,
                            ),
                            child: new InkWell(
                                onTap: () async => await _selectDate(context),
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
                          Text("After",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: endType == 1
                                    ? Colors.black
                                    : Colors.black12,
                              )),
                          Container(
                            width: 180.0,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 8.0),
                            padding:
                                const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.0),
                              color: Colors.black12,
                            ),
                            child: InkWell(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  child: DropdownButton(
                                    value: after,
                                    onChanged: (newValue) {
                                      setState(() {
                                        after = newValue;
                                      });
                                    },
                                    items: occurenccesList
                                        .map<DropdownMenuItem<String>>(
                                            (String number) {
                                      return DropdownMenuItem(
                                        value: number,
                                        child: new Text(number),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Text("OCCURENCES",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14,
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
                                  child: Text("CANCEL",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                        color: Colors.black12,
                                      )),
                                )),
                            Container(
                              margin: EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: _selectOnAfter,
                                child: Text("DONE",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Europa',
                                      color: Theme.of(context).primaryColor,
                                    )),
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

  openCalender() {}
}
