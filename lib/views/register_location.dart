import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:sevaexchange/models/availability.dart';
import 'package:sevaexchange/views/popup.dart';
import 'package:sevaexchange/views/timebanks/time_bank_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_pinView.dart';

import '../flavor_config.dart';

const kGoogleApiKey = "AIzaSyAsFTtNd5UvFnzDk9sTD0EyesFkWVKQoZY";
// to get places detail (lat/lng)
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

typedef StringListCallback = void Function(Object calendar);

class LocationView extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringListCallback onSelectedCalendar;

  LocationView({
    @required this.onSelectedCalendar,
    @required this.onSkipped,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _locationScreenState();
  }
}

final searchScaffoldKey = GlobalKey<ScaffoldState>();

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold()
      : super(
          apiKey: kGoogleApiKey,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [],
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  String locationText;
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p, searchScaffoldKey.currentState);
      },
      logo: Row(
        children: [FlutterLogo()],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
    return Scaffold(key: searchScaffoldKey, appBar: appBar, body: body);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      print(p.description);
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      AvailabilityModel data = AvailabilityModel.empty();
      data.lat_lng = "$lat,$lng";
      data.location = p.description;
      Navigator.pop(context, data);
      scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      );
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    print(response);
    if (response != null && response.predictions.isNotEmpty) {
      // searchScaffoldKey.currentState.showSnackBar(
      //   SnackBar(content: Text("Got answer")),
      // );
    }
  }
}

enum SingingCharacter { Never, On, After }

class _locationScreenState extends State<LocationView> {
  final _minimumSpacing = 5.0;
  TextEditingController locationController = TextEditingController();
  TextEditingController onController = TextEditingController();
  TextEditingController afterController = TextEditingController();
  TextEditingController myCommentsController = TextEditingController();
  double _value = 0.0;
  double _secondValue = 0.0;

  Timer _progressTimer;
  Timer _secondProgressTimer;

  bool _done = false;
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
  bool _canSave = false;
  var _numbers = ["1", "2", "3", "4", "5"];
  String _selectedNumber = "1";
  String distanceValue;
  List<MaterialColor> colorList;
  Set<String> selectedInterests = <String>[].toSet();
  SingingCharacter _character = SingingCharacter.Never;
  AvailabilityModel totalData = AvailabilityModel.empty();

  @override
  void initState() {
    colorList = Colors.primaries.map((color) {
      return color;
    }).toList();
    colorList.shuffle();

    _resumeProgressTimer();
    _secondProgressTimer =
        Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        _secondValue += 0.001;
        if (_secondValue >= 1) {
          _secondProgressTimer.cancel();
        }
      });
    });
    super.initState();
  }

  _resumeProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        _value += 0.0005;
        if (_value >= 1) {
          _progressTimer.cancel();
          _done = true;
        }
      });
    });
  }

//  Widget showSnackBar(String message,BuildContext context) => AlertDialog(
//      title: Text('Field Empty'),
//      content: Text(message),
//      actions: <Widget>[
//        FlatButton(
//          child: Text('Ok'),
//          onPressed: () {
//            Navigator.of(context).pop();
//          },
//        ),
//      ],
//    );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle textStyle = Theme.of(context).textTheme.title;
    final ThemeData theme = Theme.of(context);
    String locationStr = "";
    bool _locationValidate = false;
    // bool _distnaceValidate = false;
    bool _weekValidate = false;
    //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Location & Schedule',
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 20.0, color: Colors.white)),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Save',
                style: theme.textTheme.body1.copyWith(
                    color: _canSave
                        ? Colors.white
                        : new Color.fromRGBO(255, 255, 255, 0.5))),
            onPressed: _canSave
                ? () {
                    bool checkFields = true;
                    String message;
                    if (locationController.text == null ||
                        locationController.text.isEmpty) {
//                   _scaffoldKey.currentState.showSnackBar(
//                       SnackBar(
//                         content: Text('Purchase Successful'),
//                         duration: Duration(seconds: 3),
//                       ));
                    }
//                 setState(() {
//                   locationController.text.isEmpty ? _locationValidate = true : _locationValidate = false;
//                 });
                    if (myCommentsController.text == null ||
                        myCommentsController.text.isEmpty) {
                      checkFields = false;
                      message = 'Please selecte your availability';
                    }
                    widget.onSelectedCalendar(totalData);
                  }
                : null,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: _minimumSpacing * 3,
                  bottom: _minimumSpacing,
                  left: 10.0,
                  right: 5.0),
              child: TextField(
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 15.0, fontStyle: FontStyle.normal),
                controller: locationController,
                decoration: InputDecoration(
                    labelText: "Location",
                    hintText: "Enter location",
                    errorText:
                        _locationValidate ? 'Please enter your location' : null,
                    labelStyle:
                        TextStyle(fontSize: 15.0, fontStyle: FontStyle.normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                onChanged: (value) {},
                onTap: () async {
                  AvailabilityModel dataModel = AvailabilityModel.empty();
                  dataModel = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new CustomSearchScaffold(),
                        fullscreenDialog: true),
                  );
                  setState(() {
                    locationController.text = dataModel.location;
                    totalData.location = dataModel.location;
                    totalData.lat_lng = dataModel.lat_lng;
                  });
                },
              ),
            ),
            paddingColumn(),
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
                Padding(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text('$finalValue Miles',
                      style: TextStyle(
                        fontSize: 12.0,
                        // fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w500,
                      )),
                )
              ],
            ),
            paddingColumn(),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey,
                trackHeight: 3.0,
                thumbColor: Colors.blue,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayColor: Colors.blue.withAlpha(60),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 15.0),
              ),
              child: Slider(
                  min: 0.0,
                  max: 50.0,
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                      finalValue = _value.toStringAsFixed(0);
                      distanceValue = _value.toStringAsFixed(0);
                      totalData.distnace = '$finalValue Miles';
                    });
                  }),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 13.0),
                  child: Text(
                    'Days Available',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                FlatButton(
                  child: Text(
                    'Select Availability',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    _openAddEntryDialog();
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextFormField(
                enableInteractiveSelection: true,
                controller: myCommentsController,
                style: TextStyle(fontSize: 15.0, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: '',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red, //this has no effect
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                enabled: false,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
            ),
            paddingColumn(),
            paddingColumn(),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Have a timebank code?',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  Container(
                    height: 40,
                    width: 80,
                    child: RaisedButton(
                      focusColor: Colors.blue,
                      highlightColor: Colors.white,
                      child: Text(
                        'Enter',
                        textDirection: TextDirection.ltr,
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
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return OnBoardWithTimebank("");
                        //     },
                        //   ),
                        // );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // RaisedButton(
            //   padding: EdgeInsets.all(16),
            //   onPressed: () {},
            //   color: Theme.of(context).accentColor,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       SizedBox(width: 16),
            //       Text(
            //         'Explore Time Banks',
            //         style: TextStyle(color: Colors.white, fontSize: 16.0),
            //       ),
            //     ],
            //   ),
            //   shape: StadiumBorder(),
            // ),
            paddingColumn(),
          ],
        ),
      ),
    );
  }

  Future _openAddEntryDialog() async {
    AvailabilityModel data = await Navigator.of(context)
        .push(new MaterialPageRoute<AvailabilityModel>(
            builder: (BuildContext context) {
              return new Availability();
            },
            fullscreenDialog: true));
    setState(() {
      totalData.weekArray = data.weekArray;
      totalData.endsData = data.endsData;
      totalData.endsStatus = data.endsStatus;
      totalData.accurance_number = data.accurance_number;
      totalData.repeatAfterStr = data.repeatAfterStr;
      totalData.repeatNumber = data.repeatNumber;
      String weekStr;
//      for(var week in totalData.weekArray) {
//        weekStr = weekStr + week;
//      }
      final string =
          totalData.weekArray.reduce((value, element) => value + ',' + element);
      print(string);
      myCommentsController.text = "User is available $string in week";
      setState(() {
        _canSave = true;
      });
      print(totalData.toMap());
      //_items.add(data);
    });
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
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 13.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
              ),
              controller: afterController,
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
            ),
          ),
        ],
      );
    }
  }

  Widget paddingColumn() {
    return Padding(
      padding: EdgeInsets.all(8.0),
    );
  }

  Widget _ends(String radioBtnName, SingingCharacter value) {
    return Container(
      width: 50,
      child: RadioListTile<SingingCharacter>(
        title: Text(
          radioBtnName,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
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

  Widget _daysAvailable() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              'Days Available',
              style: TextStyle(
                fontSize: 15.0,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
//  Widget _repeatAfter(TextStyle textStyle) {
//    bool pressAttention = false;
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
//                      child: Text(value,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400),textAlign: TextAlign.center,),
//                    );
//                  }).toList(),
//                  value: _selectedNumber,
//                  onChanged: (String newValueSelected) {
//                    setState(() {
//                      _selectedNumber = newValueSelected;
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
//                      child: Text(value,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w400),textAlign: TextAlign.center,),
//                    );
//                  }).toList(),
//                  value: _selectedScheduleItem,
//                  onChanged: (String newValueSelected) {
//                    setState(() {
//                      _selectedScheduleItem = newValueSelected;
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
//              fontSize: 15,
//              fontWeight: FontWeight.w400,
//            ),
//              textAlign: TextAlign.start,
//            ),
//            textColor: Colors.blue,
//            color: Colors.transparent,
//            elevation: 0.0,
//            onPressed: (){
//              pressAttention = !pressAttention;
//              print('pressed skip');
//            },
//          )
//        ],
//      ),
//    );
//  }

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
      margin: EdgeInsets.all(4),
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
            });
          },
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                    fontSize: 12.0,
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

  void _navigateToPinView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PinView(),
      ),
    );
  }

  void _navigateToTimebanks() {
    FlavorConfig.values.timebankId = '73d0de2c-198b-4788-be64-a804700a88a4';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => TimeBankList(
          timebankid: FlavorConfig.values.timebankId,
          title: 'Timebanks List',
        ),
      ),
    );
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

    if (lights.contains(materialColor)) {
      return Colors.black;
    } else if (darks.contains(materialColor)) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }
}
