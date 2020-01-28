import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/utils/data_managers/skills_interest_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as fireStoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';

@deprecated

///use interests view new ////
class EditSkills extends StatefulWidget {
  @override
  _EditSkillsState createState() => _EditSkillsState();
}

class _EditSkillsState extends State<EditSkills> {
//  List<String> skills = const [
//    'Curators',
//    'Developers',
//    'Writer',
//    'Advertisers',
//    'Customer',
//    'Sports',
//    'Adventure',
//    'Culture',
//    'Baseball',
//  ];

  List<String> skills = FlavorConfig.values.timebankName == "Yang 2020"
      ? const [
          "Data entry",
          "Research",
          "Graphic design",
          "Coding/development",
          "Photography",
          "Videography",
          "Multilingual/translations",
        ]
      : [
          'Curators',
          'Developers',
          'Writer',
          'Advertisers',
          'Customer',
          'Sports',
          'Adventure',
          'Culture',
          'Baseball',
        ];
  List<MaterialColor> colorList;
  Set<String> selectedSkills = <String>[].toSet();
  @override
  void initState() {
    super.initState();
    colorList = Colors.primaries.map((color) {
      return color;
    }).toList();
    colorList.shuffle();
    getSkillsForTimebank(timebankId: FlavorConfig.values.timebankId)
        .then((onValue) {
      setState(() {
        if (onValue != null && onValue.isNotEmpty) skills = onValue;
      });
      this.selectedSkills = <String>[].toSet();
      this.selectedSkills = SevaCore.of(context).loggedInUser.skills.toSet();
    });
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
                border: OutlineInputBorder(), hintText: 'Search for skills'),
          ),
          suggestionsCallback: (String pattern) async {
            return skills
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
            if (skills.contains(suggestion)) {
              selectedSkills.add(suggestion);
              //skills.remove(suggestion);
            }
          },
        ),
      ),
      //child: SizedBox(height: 500),
      //]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Skills',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ScrollExample(context),
          list(),
        ],
      ),
      floatingActionButton: Container(
        width: 134,
        height: 39,
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          shape: StadiumBorder(),
          onPressed: () {
            SevaCore.of(context).loggedInUser.skills =
                this.selectedSkills.toList();
            this.updateUserData();
          },
          child: Text(
            'Update Skills',
            style: Theme.of(context).primaryTextTheme.button,
          ),
        ),
      ),
      // bottomNavigationBar: ButtonBar(
      //   children: <Widget>[
      //     RaisedButton(
      //       onPressed: () {
      //         SevaCore.of(context).loggedInUser.skills =
      //             this.selectedSkills.toList();
      //         this.updateUserData();
      //       },
      //       child: Text(
      //         'Update Skills',
      //         style: Theme.of(context).primaryTextTheme.button,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Future updateUserData() async {
    await fireStoreManager.updateUser(user: SevaCore.of(context).loggedInUser);
    Navigator.of(context).pop();
  }

  Widget list() {
    if (selectedSkills.length > 0) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: selectedSkills.map((skill) {
            final _random = new Random();
            var element = colorList[_random.nextInt(colorList.length)];
            return chip(skill, false, element);
          }).toList(),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(5.0),
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
            if (skills.contains(value)) {
              setState(() {
                selectedSkills.remove(value);
                print(selectedSkills);
              });
            }
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
