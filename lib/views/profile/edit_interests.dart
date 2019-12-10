import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/utils/data_managers/skills_interest_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import '../../flavor_config.dart';
import '../core.dart';

class EditInterests extends StatefulWidget {
  @override
  _EditInterestsState createState() => _EditInterestsState();
}

class _EditInterestsState extends State<EditInterests> {

  List<String> interests = FlavorConfig.values.timebankName == "Yang 2020" ? const [
    'Block Walk',
    'Crowd control',
    'Cleaning campaign office',
    'Make calls to voters',
    'Send texts to voters',
    "Host a meet and greet",
    "Canvassing Neighborhoods",
    "Phone Bank",
  ] : [
    'Branding',
    'Campaigning',
    'Kids',
    'Animals',
    'Music',
    'Movies',
    'Adventure',
    'Culture',
    'Food',
  ];

  List<MaterialColor> colorList;
  Set<String> selectedInterests = <String>[].toSet();

  @override
  void initState() {
    super.initState();
    colorList = Colors.primaries.map((color) {
      return color;
    }).toList();
    colorList.shuffle();
    getInterestsForTimebank(timebankId: FlavorConfig.values.timebankId)
        .then((onValue) {
          print(onValue);
      setState(() {
        if (onValue != null && onValue.isNotEmpty) {
          interests = onValue;
        } else {
          print(interests);
        }

      });
      this.selectedInterests = <String>[].toSet();
      this.selectedInterests = SevaCore.of(context).loggedInUser.interests.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Interests',style: TextStyle(color: Colors.white),),
        ),
        body: ListView(
          children: <Widget>[ScrollExample(context), list()],
        ),
        bottomNavigationBar: ButtonBar(
          children: <Widget>[
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                SevaCore.of(context).loggedInUser.interests = this.selectedInterests.toList();
                this.updateUserData();
              },
              child: Text(
                'Update Interests',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
    );
  }

  Widget list() {
    if (selectedInterests.length > 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: selectedInterests.map((interest) {
              final _random = new Random();
              var element = colorList[_random.nextInt(colorList.length)];
              return chip(interest, false, element);
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
    );
  }

  Widget ScrollExample(BuildContext context) {
    //final List<String> items = List.generate(5, (index) => "Item $index");
//
//  List<String> some = items.where((item) {
//    item.isSelected = false;
//  }).cast<String>().toList();

    return Container(
      child:
      //Column(children: [
      Padding(
        padding: EdgeInsets.all(10.0),
        child: TypeAheadField<String>(
          getImmediateSuggestions: true,
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Search for interests'),
          ),
          suggestionsCallback: (String pattern) async {
            return interests
                .where((item) =>
                item.toLowerCase().startsWith(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, String suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          onSuggestionSelected: (String suggestion) {
            if (interests.contains(suggestion)) {
              selectedInterests.add(suggestion);
              //interests.remove(suggestion);
            }
          },
        ),
      ),
      //child: SizedBox(height: 500),
      //]),
    );
  }

  Future updateUserData() async {
    await fireStoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    Navigator.of(context).pop();
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
                //selectedInterests.add(value);
              }
            });
          },
          child: Material(
            elevation: selected ? 3 : 0,
            shape: StadiumBorder(),
            child: AnimatedContainer(
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    color: getTextColor(color),
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