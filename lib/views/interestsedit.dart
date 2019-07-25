import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart' as globals;
import 'core.dart';

class InterestsEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Edit Interests",style: TextStyle(color: Colors.white),),
      ),
      body: Interests(),
    );
  }
}

const List<String> _defaultTools = <String>[
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

class ChipsTile extends StatelessWidget {
  ChipsTile({
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, we want to show a Snackbar
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                          _updateInterestsToDB(context);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Update Interests',
                          style: TextStyle(
                              color: Colors.blue,
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
      Text('Choose Interests',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ))
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

class Interests extends StatefulWidget {
  @override
  _InterestsEditState createState() => _InterestsEditState();
}

class _InterestsEditState extends State<Interests> {
  _InterestsEditState() {
    _reset();
  }

  final Set<String> _materials = Set<String>();

  final Set<String> _tools = Set<String>();
  Set<String> _selectedTools = Set<String>();
  final Set<String> _actions = Set<String>();
  bool _showShapeBorder = false;

  // Initialize members with the default data.
  void _reset() {
    _materials.clear();

    _actions.clear();

    _tools.clear();
    _tools.addAll(_defaultTools);

    _selectedTools = Set<String>.from(globals.interests);
    // _selectedTools.clear();
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
                  globals.tempList = _selectedTools.toList();
                });
              },
      );
    }).toList();

    final ThemeData theme = Theme.of(context);
    final List<Widget> tiles = <Widget>[
      const SizedBox(height: 8.0, width: 0.0),
      ChipsTile(label: '', children: filterChips),
    ];

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('interests/Intersts'),
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

_setPreferencesNext() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('interests', globals.interests);
}

_updateInterestsToDB(BuildContext context) {
  globals.interests = globals.tempList;

  Firestore.instance
      .collection('users')
      .document(SevaCore.of(context).loggedInUser.email)
      .updateData({
    'interests': globals.interests,
  });
  _setPreferencesNext();
}
