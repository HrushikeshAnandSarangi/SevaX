import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/interestsview.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/data.dart';

const List<String> _defaultTools = <String>[
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

typedef StringListCallback = void Function(List<String> skills);

class InterestViewNew extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringListCallback onSelectedInterests;

  InterestViewNew({
    @required this.onSelectedInterests,
    @required this.onSkipped,
  });

  @override
  _InterestViewNewState createState() => _InterestViewNewState();
}

class ProductPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductPage({this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Text(
              this.product['name'],
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
              this.product['price'].toString() + ' USD',
              style: Theme.of(context).textTheme.subhead,
            )
          ],
        ),
      ),
    );
  }
}

class _InterestViewNewState extends State<InterestViewNew> {
  List<String> interests = const [
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Interests'),
        ),
        body: Column(
          children: <Widget>[
            ScrollExample(context),
            list()
          ],
        ),
        bottomNavigationBar: ButtonBar(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                widget.onSkipped();
              },
              child: Text('Skip'),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                widget.onSelectedInterests(selectedInterests.toList());
              },
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget list() {
    if (selectedInterests.length > 0) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children:
          selectedInterests.map((interest) {
            int index = interests.indexOf(interest);
            //if (selectedSkills.contains(skill)) {
            return chip(interest, false, colorList[index]);
            // }
            //return chip(skill, false, colorList[index]);
          }).toList(),
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
        child:TypeAheadField<String>(
          getImmediateSuggestions: true,
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search for interests'),
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
              interests.remove(suggestion);
            }
            print("Suggestion selected $suggestion");
          },
        ),
      ),
      //child: SizedBox(height: 500),
      //]),
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

class SkillViewNew extends StatefulWidget {
  final VoidCallback onSkipped;
  final StringListCallback onSelectedSkills;

  SkillViewNew({
    @required this.onSelectedSkills,
    @required this.onSkipped,
  });

  @override
  _SkillViewNewState createState() => _SkillViewNewState();
}
class Skill {
  String skillName;
  bool isSelected;
  Skill(this.skillName,this.isSelected);
}
class _SkillViewNewState extends State<SkillViewNew> {
  List<String> skills = const [
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

  List<Skill> skillsList = [Skill('Curators',false),
                            Skill('Developers',false),
                            Skill('Writer',false),
                            Skill('Advertisers',false),
                            Skill('Customer',false),
                            Skill('Sports',false),
                            Skill('Adventure',false),
                            Skill('Culture',false),
                            Skill('Baseball',false)];
  List<MaterialColor> colorList;
  Set<String> selectedSkills = <String>[].toSet();
  @override
  void initState() {
    super.initState();
    colorList = Colors.primaries.map((color) {
      return color;
    }).toList();
    colorList.shuffle();
    //skillsList.add();
//    skillsList.add(Skill('Curators',false));
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
        child:TypeAheadField<String>(
          getImmediateSuggestions: true,
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search for skills'),
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
              skills.remove(suggestion);
            }
            print("Suggestion selected $suggestion");
          },
        ),
      ),
      //child: SizedBox(height: 500),
      //]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Skills'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            ScrollExample(context),
            list(),
          ],
        )),
        bottomNavigationBar: ButtonBar(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                widget.onSkipped();
              },
              child: Text('Skip'),
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                widget.onSelectedSkills(selectedSkills.toList());
              },
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget list() {
    if (selectedSkills.length > 0) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children:
          selectedSkills.map((skill) {
            int index = skills.indexOf(skill);
            //if (selectedSkills.contains(skill)) {
              return chip(skill, false, colorList[index]);
           // }
            //return chip(skill, false, colorList[index]);
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
            setState(() {
              if (selectedSkills.contains(value)) {
                selectedSkills.remove(value);
                //skills.remove(value);
                //skills.add(value);
              } else {
                //selectedSkills.add(value);
                //skills.remove(value);
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

class _ChipsTile extends StatelessWidget {
  _ChipsTile({
    Key key,
    this.label,
    this.children,
  }) : super(key: key);

  final String label;
  final List<Widget> children;

  final _formKey = GlobalKey<FormState>();

  // Wraps a list of chips into a ListTile for display as a section in the demo.
  @override
  Widget build(BuildContext context) {
    final List<Widget> cardChildren = <Widget>[
      Container(
        // padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        alignment: Alignment.center,
        child: Text(label,
            textAlign: TextAlign.start, style: TextStyle(color: Colors.white)),
      ),

      // bio goes here
      Container(
          // padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 4.0),
          child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      // color: Colors.deepPurple,
                      onPressed: () {
                        createOnSkip(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => CoreView(
                              sevaUserID: null,
                            ),
                          ),
                        );
                      },
                      child: Text('Skip',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0)),
                    ),
                    FlatButton(
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(20.0)),
                      // color: Colors.deepPurple,
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, we want to show a Snackbar
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                          _updateSkillsToDB(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      InterestsView()));
                        }
                      },
                      child: Text('Next',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
      Text('Choose Skills',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ))
      // TextFormField(
      //   style: TextStyle(fontSize: 18.0, color: Colors.black),
      //   decoration: InputDecoration(
      //       contentPadding: EdgeInsets.fromLTRB(10.0, 20, 0, 0),
      //       hintText: 'Your Bio and any #hashtages',
      //       border: InputBorder.none),
      //   keyboardType: TextInputType.multiline,
      //   maxLines: 3,
      //   validator: (value) {
      //     if (value.isEmpty) {
      //       return 'Please enter a Bio and any #hashtages';
      //     }
      //     globals.bio = value;
      //   },
      // ),
    ];
    if (children.isNotEmpty) {
      cardChildren.add(Wrap(
          children: children.map<Widget>((Widget chip) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 2, 2),
          child: chip,
        );
      }).toList()));
    } else {
      final TextStyle textStyle = Theme.of(context)
          .textTheme
          .caption
          .copyWith(fontStyle: FontStyle.italic);
      cardChildren.add(Semantics(
        container: true,
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          padding: const EdgeInsets.all(8.0),
          child: Text('None', style: textStyle),
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: cardChildren,
    );
  }
}

class SkillView extends StatefulWidget {
  @override
  _SkillViewState createState() => _SkillViewState();
}

class _SkillViewState extends State<SkillView> {
  _SkillViewState() {
    _reset();
  }

  final Set<String> _materials = Set<String>();

  final Set<String> _tools = Set<String>();
  final Set<String> _selectedTools = Set<String>();
  final Set<String> _actions = Set<String>();
  bool _showShapeBorder = false;

  // Initialize members with the default data.
  void _reset() {
    _materials.clear();

    _actions.clear();

    _tools.clear();
    _tools.addAll(_defaultTools);

    _selectedTools.clear();
  }

  String _capitalize(String name) {
    assert(name != null && name.isNotEmpty);
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }

  Color _nameToColor(String name) {
    assert(name.length > 1);
    final int hash = name.hashCode & 0xffff;
    final double hue = (360.0 * hash / (1 << 15)) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> filterChips = _defaultTools.map<Widget>((String name) {
      return FilterChip(
        key: ValueKey<String>(name),
        backgroundColor: _nameToColor(name),
        label: Text(_capitalize(name)),
        selected: _tools.contains(name) ? _selectedTools.contains(name) : false,
        onSelected: !_tools.contains(name)
            ? null
            : (bool value) {
                setState(() {
                  if (!value) {
                    _selectedTools.remove(name);
                  } else {
                    _selectedTools.add(name);
                  }
                  globals.skills = _selectedTools.toList();
                  print(_selectedTools.toList());
                });
              },
      );
    }).toList();

    final ThemeData theme = Theme.of(context);
    final List<Widget> tiles = <Widget>[
      const SizedBox(height: 8.0, width: 0.0),
      _ChipsTile(label: 'Choose skills/interests', children: filterChips),
      // const Divider(),
    ];

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Skills/Intersts'),
      // ),
      body: ChipTheme(
        data: _showShapeBorder
            ? theme.chipTheme.copyWith(
                shape: BeveledRectangleBorder(
                side: BorderSide(width: 0.90, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10.0),
              ))
            : theme.chipTheme,
        child: ListView(children: tiles),
      ),
    );
  }
}

_setPreferencesNext(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('skills', globals.skills);
  await prefs.setStringList('interests', []);
  await prefs.setString('bio', '');
  await prefs.setString('email', SevaCore.of(context).loggedInUser.email);
  await prefs.setString(
      'sevauserid', SevaCore.of(context).loggedInUser.sevaUserID);
  await prefs.setString('fullname', SevaCore.of(context).loggedInUser.fullname);
}

_setPreferencesSkip(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('skills', []);
  await prefs.setStringList('interests', []);
  await prefs.setString('bio', '');
  await prefs.setString('email', SevaCore.of(context).loggedInUser.email);
  await prefs.setString(
      'sevauserid', SevaCore.of(context).loggedInUser.sevaUserID);
  await prefs.setString('fullname', SevaCore.of(context).loggedInUser.fullname);
}

_updateSkillsToDB(BuildContext context) {
  print('writeToDB');
  Firestore.instance
      .collection('users')
      .document(SevaCore.of(context).loggedInUser.email)
      .setData({
    'skills': globals.skills,
    'interests': [],
    'membership': [],
    'bio': '',
    'sevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
    'email': SevaCore.of(context).loggedInUser.email,
    'fullname': SevaCore.of(context).loggedInUser.fullname,
    'photourl': SevaCore.of(context).loggedInUser.photoURL
  });
  _setPreferencesNext(context);
  // Navigator.pushReplacement(
  //     context, MaterialPageRoute(builder: (BuildContext context) => BioView()));
}

createOnSkip(BuildContext context) {
  print('writeToDB');
  Firestore.instance
      .collection('users')
      .document(SevaCore.of(context).loggedInUser.email)
      .setData({
    'skills': [],
    'interests': [],
    'membership': [],
    'bio': '',
    'sevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
    'email': SevaCore.of(context).loggedInUser.email,
    'fullname': SevaCore.of(context).loggedInUser.fullname,
    'photourl': SevaCore.of(context).loggedInUser.photoURL
  });
  _setPreferencesSkip(context);
}
