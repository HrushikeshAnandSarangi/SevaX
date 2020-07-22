import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/availability.dart';

enum SingingCharacter { Never, On, After }

//class MyApp extends StatefulWidget {
//
//
//  @override
//  _MyAppState createState() => _MyAppState();
//}
class Availability extends StatefulWidget {
  @override
  AvailabilityState createState() => AvailabilityState();
}

class AvailabilityState extends State<Availability> {
  bool _canSave = false;
  AvailabilityModel _data = new AvailabilityModel.empty();
  TextEditingController locationController = TextEditingController();
  TextEditingController myCommentsController = TextEditingController();
  void _setCanSave(bool save) {
    if (save != _canSave) setState(() => _canSave = save);
  }

  String finalValue = '';

  List<String> interests = const [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];

  var _schedule = ["Day", "Month", "Year"];
  String _selectedScheduleItem = "Day";

  var _numbers = ["1", "2", "3", "4", "5"];
  String _selectedNumber = "1";

  List<MaterialColor> colorList;
  Set<String> selectedInterests = <String>[].toSet();
  SingingCharacter _character = SingingCharacter.Never;

  @override
  void initState() {
    colorList = Colors.primaries.map((color) {
      return color;
    }).toList();
    colorList.shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final ThemeData theme = Theme.of(context);
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        title: Text("Availability"),
        actions: <Widget>[
          new FlatButton(
              child: new Text('SAVE',
                  style: theme.textTheme.body1.copyWith(
                      color: _canSave
                          ? Colors.white
                          : new Color.fromRGBO(255, 255, 255, 0.5))),
              onPressed: _canSave
                  ? () {
                      //_data.weekArray = this.selectedInterests;
                      this.checkWeekDayAndStore();
                      //this.updateUserWeekDay()
                      Navigator.of(context).pop(_data);
                    }
                  : null)
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            //paddingColumn(),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Days Available',
                style: TextStyle(
                  fontSize: 17.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            //paddingColumn(),
            paddingColumn(),
            list(),
            paddingColumn(),
            _titleRow('Repeat After'),
            paddingColumn(),
            _repeatAfter(textStyle),
            paddingColumn(),
            _ends('Never', SingingCharacter.Never),
            _ends('On', SingingCharacter.On),
            _character == SingingCharacter.On
                ? Container(
                    height: 50,
                    width: 100,
                    padding: EdgeInsets.only(left: 30.0, right: 100.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                      ),
                      controller: locationController,
                      decoration: InputDecoration(
                          labelText: "Date",
                          hintText: "Selecte Date",
                          labelStyle: TextStyle(
                            fontSize: 13.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                      onChanged: (value) {
                        setState(() {
                          _data.endsData = value;
                        });
                      },
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
            _ends('After', SingingCharacter.After),
            _character == SingingCharacter.After
                ? Container(
                    height: 50,
                    width: 150,
                    padding: EdgeInsets.only(left: 30.0, right: 100.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                      ),
                      controller: myCommentsController,
                      decoration: InputDecoration(
                          labelText: "Occurances",
                          hintText: "Enter occurances",
                          labelStyle: TextStyle(
                            fontSize: 13.0,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                      onChanged: (value) {
                        setState(() {
                          _data.accurance_number = value;
                          _setCanSave(value.isNotEmpty);
                        });
                      },
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _ends(String radioBtnName, SingingCharacter value) {
    return Container(
      width: 50,
      child: RadioListTile<SingingCharacter>(
        title: Text(radioBtnName),
        value: value,
        groupValue: _character,
        onChanged: (SingingCharacter value) {
          setState(() {
            _character = value;
          });
        },
      ),
    );
  }

  Widget _endsOnTF(SingingCharacter character) {
    if (character == SingingCharacter.Never ||
        character == SingingCharacter.On) {
      return _ends('After', SingingCharacter.After);
    } else {
      return Row(
        children: <Widget>[
          Expanded(
            child: _ends('After', SingingCharacter.After),
          ),
          Container(
            height: 40,
            width: 150,
            child: TextField(
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
              ),
              controller: myCommentsController,
              decoration: InputDecoration(
                  labelText: "Occurances",
                  hintText: "Enter occurances",
                  labelStyle: TextStyle(
                    fontSize: 13.0,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
              onChanged: (value) {
                setState(() {
                  _data.accurance_number = value;
                  _setCanSave(value.isNotEmpty);
                });
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _titleRow(String name) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 17.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget paddingColumn() {
    return Padding(
      padding: EdgeInsets.all(8.0),
    );
  }

//  Widget _repeatAfter1(TextStyle textStyle) {
//    return Padding(padding: EdgeInsets.only(left: 10.0),
//      child:Row(
//        children: <Widget>[
//          Row(
//            children: <Widget>[
//              Container(
//                padding: EdgeInsets.symmetric(horizontal: 20.0),
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(15.0),
//                  border: Border.all(
//                      color: Colors.grey, style: BorderStyle.solid, width: 1.5),
//                ),
//                child: DropdownButton<String>(
//                  items: _numbers.map((String value) {
//                    return DropdownMenuItem<String>(
//                      value: value,
//                      child: Text(value,style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.w400),textAlign: TextAlign.center,),
//                    );
//                  }).toList(),
//                  value: _selectedNumber,
//                  onChanged: (String newValueSelected) {
//                    setState(() {
//                      //_selectedNumber = newValueSelected;
//                      setState(() {
//                        _data.repeatNumber = newValueSelected;
//                      });
//                    });
//                  },
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.all(10.0),
//              ),
//              Container(
//                padding: EdgeInsets.symmetric(horizontal: 15.0),
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(15.0),
//                  border: Border.all(
//                      color: Colors.grey, style: BorderStyle.solid, width: 1.5),
//                ),
//                child: DropdownButton<String>(
//                  items: _schedule.map((String value) {
//                    return DropdownMenuItem<String>(
//                      value: value,
//                      child: Text(value,style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.w400),textAlign: TextAlign.center,),
//                    );
//                  }).toList(),
//                  value: _selectedScheduleItem,
//                  onChanged: (String newValueSelected) {
//                    setState(() {
//                      _data.repeatAfterStr = newValueSelected;
//                    });
//                  },
//                ),
//              ),
//            ],
//          ),
//          RaisedButton(
//            focusColor: Colors.blue,
//            highlightColor: Colors.white,
//            child: Text('Never',style: TextStyle(
//              fontSize: 12,
//              fontWeight: FontWeight.w400,
//            ),
//              textAlign: TextAlign.start,
//            ),
//            textColor: Colors.blue,
//            color: Colors.transparent,
//            elevation: 0.0,
//            onPressed: (){
//              //updateData();
//              print('pressed skip');
//            },
//          )
//        ],
//      ),
//    );
//  }
  Widget _repeatAfter(TextStyle textStyle) {
    bool pressAttention = false;
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Row(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                      color: Colors.grey, style: BorderStyle.solid, width: 1.5),
                ),
                child: DropdownButton<String>(
                  items: _numbers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  value: _selectedNumber,
                  onChanged: (String newValueSelected) {
                    setState(() {
                      _selectedNumber = newValueSelected;
                      _data.repeatNumber = newValueSelected;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                      color: Colors.grey, style: BorderStyle.solid, width: 1.5),
                ),
                child: DropdownButton<String>(
                  items: _schedule.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  value: _selectedScheduleItem,
                  onChanged: (String newValueSelected) {
                    setState(() {
                      _selectedScheduleItem = newValueSelected;
                      _data.repeatAfterStr = newValueSelected;
                    });
                  },
                ),
              ),
            ],
          ),
          RaisedButton(
            focusColor: Colors.blue,
            highlightColor: Colors.white,
            child: Text(
              'Never',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
            textColor: Colors.blue,
            color: Colors.transparent,
            elevation: 0.0,
            onPressed: () {
              pressAttention = !pressAttention;
              print('pressed skip');
            },
          )
        ],
      ),
    );
  } //

  Widget list() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: interests.map((skill) {
            int index = interests.indexOf(skill);
            if (selectedInterests.contains(skill)) {
              return chip(skill, true, colorList[index]);
            }
            return chip(skill, false, colorList[index]);
          }).toList(),
        ),
      ),
    );
  }

  Widget chip(String value, bool selected, Color color) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: color,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.white.withAlpha(0),
        child: InkWell(
          customBorder: StadiumBorder(),
          onTap: () {
            setState(() {
              if (selectedInterests.contains(value)) {
                selectedInterests.remove(value);
              } else {
                selectedInterests.add(value);
              }
              if (selectedInterests.length != 0) {
                _canSave = true;
              } else {
                _canSave = false;
              }
            });
          },
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
              duration: Duration(milliseconds: 250),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: selected ? color : null,
              ),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 250),
                crossFadeState: selected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                secondChild: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void checkWeekDayAndStore() {
    _data.weekArray = Set<String>();
    for (var day in this.selectedInterests) {
      switch (day) {
        case "Su":
          _data.weekArray.add('Sunday');
          break;
        case "Mo":
          _data.weekArray.add('Monday');
          break;
        case "Tu":
          _data.weekArray.add('Tuesday');
          break;
        case "We":
          _data.weekArray.add('Wednesday');
          break;
        case "Th":
          _data.weekArray.add('Thursday');
          break;
        case "Fr":
          _data.weekArray.add('Friday');
          break;
        case "Sa":
          _data.weekArray.add('Saturday');
          break;
        default:
          print("no data");
          break;
      }
    }
  }

  Color getTextColor(Color materialColor) {
    List<MaterialColor> lights = [
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
    ];

    List<MaterialColor> darks = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.green,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];
  }
}

//class _MyAppState extends State<MyApp> {
//  final _formKey = GlobalKey<FormState>();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Flutter"),
//      ),
//      body: Center(
//        child: RaisedButton(
//          onPressed: () {
//            showDialog(
//                context: context,
//                builder: (BuildContext context) {
//                  return AlertDialog(
//                    content: Form(
//                      key: _formKey,
//                      child: Column(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          Padding(
//                            padding: EdgeInsets.all(8.0),
//                            child: TextFormField(),
//                          ),
//                          Padding(
//                            padding: EdgeInsets.all(8.0),
//                            child: TextFormField(),
//                          ),
//                          Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: RaisedButton(
//                              child: Text("Submitß"),
//                              onPressed: () {
//                                if (_formKey.currentState.validate()) {
//                                  _formKey.currentState.save();
//                                }
//                              },
//                            ),
//                          )
//                        ],
//                      ),
//                    ),
//                  );
//                });
//          },
//          child: Text("Open Popup"),
//        ),
//      ),
//    );
//  }
//}
