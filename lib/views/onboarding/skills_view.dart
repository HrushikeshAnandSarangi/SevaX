import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';

typedef StringListCallback = void Function(List<String> skills);

class SkillViewNew extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final UserModel userModel;
  final VoidCallback onSkipped;
  final StringListCallback onSelectedSkills;

  SkillViewNew({
    @required this.onSelectedSkills,
    @required this.onSkipped,
    this.userModel,
    this.automaticallyImplyLeading = true,
  });
  @override
  _SkillViewNewState createState() => _SkillViewNewState();
}

class _SkillViewNewState extends State<SkillViewNew> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  bool autovalidate = false;
  // List<String> suggestionText = [];
  // List<String> suggestionID = [];
  // List<String> selectedSkills = [];
  // List<String> selectedID = [];
  Map<String, dynamic> skills = {};
  // Map<String, dynamic> ids = {};
  Map<String, dynamic> _selectedSkills = {};
  // List<Widget> selectedChips = [];
  @override
  void initState() {
    print(widget.userModel.skills);
    Firestore.instance
        .collection('skills')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.documentID);
        skills[data.documentID] = data['name'];
        // ids[data['name']] = data.documentID;
      });
      if (widget.userModel.skills.length > 0) {
        widget.userModel.skills.forEach((id) {
          _selectedSkills[id] = skills[id];
          // selectedChips.add(buildChip(id: id, value: skills[id]));
        });
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        title: Text(
          'Skills',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'What skills are you good at that you\'d like to share with your community?',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            TypeAheadField<String>(
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                // color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                // shape: RoundedRectangleBorder(),
              ),
              hideOnError: true,
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.grey[300],
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.white),
                    borderRadius: new BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(25.7)),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
              ),
              suggestionsBoxController: controller,
              suggestionsCallback: (pattern) async {
                List<String> dataCopy = [];
                skills.forEach((id, skill) => dataCopy.add(skill));
                dataCopy.retainWhere(
                    (s) => s.toLowerCase().contains(pattern.toLowerCase()));
                return await Future.value(dataCopy);
              },
              itemBuilder: (context, suggestion) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              },
              noItemsFoundBuilder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No matching skills found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                if (!_selectedSkills.containsValue(suggestion)) {
                  controller.close();
                  String id =
                      skills.keys.firstWhere((k) => skills[k] == suggestion);
                  _selectedSkills[id] = suggestion;
                  // selectedChips.add(buildChip(id: id, value: suggestion));
                  setState(() {});
                }
              },
            ),
            SizedBox(height: 20),
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                Wrap(
                  runSpacing: 5.0,
                  spacing: 5.0,
                  children: _selectedSkills.values
                      .toList()
                      .map(
                        (value) => CustomChip(
                          title: value,
                          onDelete: () {
                            String id = skills.keys
                                .firstWhere((k) => skills[k] == value);
                            _selectedSkills.remove(id);
                            setState(() {});
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: 134,
              child: RaisedButton(
                onPressed: () {
                  List<String> selectedID = [];
                  _selectedSkills.forEach((id, _) => selectedID.add(id));
                  print(selectedID);
                  widget.onSelectedSkills(selectedID);
                },
                child: Text(
                  widget.userModel.skills == null ? 'Next' : 'Update',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ),
            ),
            widget.userModel.skills == null
                ? FlatButton(
                    onPressed: () {
                      widget.onSkipped();
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Padding buildChip(value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
  //     child: CustomChip(
  //       title: value,
  //       onDelete: () {
  //         String id = skills.keys.firstWhere((k) => skills[k] == value);
  //         _selectedSkills.remove(id);
  //       },
  //     ),
  //     // child: Chip(
  //   label: Text(value),
  //   onDeleted: () {
  //     String id = skills.keys.firstWhere((k) => skills[k] == value);
  //     _selectedSkills.remove(id);
  //     setState(() {});
  //   },
  // ),
  // );
}
// }

// const List<String> _defaultTools = <String>[
//   'Curators',
//   'Developers',
//   'Writer',
//   'Advertisers',
//   'Customer',
//   'Sports',
//   'Adventure',
//   'Culture',
//   'Baseball',
// ];

// typedef StringListCallback = void Function(List<String> skills);

// class InterestViewNew extends StatefulWidget {
//   final VoidCallback onSkipped;
//   final StringListCallback onSelectedInterests;

//   InterestViewNew({
//     @required this.onSelectedInterests,
//     @required this.onSkipped,
//   });

//   @override
//   _InterestViewNewState createState() => _InterestViewNewState();
// }

// class _InterestViewNewState extends State<InterestViewNew> {
//   List<String> interests = FlavorConfig.values.timebankName == "Yang 2020"
//       ? const [
//           'Block Walk',
//           'Crowd control',
//           'Cleaning campaign office',
//           'Make calls to voters',
//           'Send texts to voters',
//           "Host a meet and greet",
//           "Canvassing Neighborhoods",
//           "Phone Bank"
//         ]
//       : [
//           'Branding',
//           'Campaigning',
//           'Kids',
//           'Animals',
//           'Music',
//           'Movies',
//           'Adventure',
//           'Culture',
//           'Food',
//         ];

//   List<MaterialColor> colorList;
//   Set<String> selectedInterests = <String>[].toSet();

//   @override
//   void initState() {
//     super.initState();
//     colorList = Colors.primaries.map((color) {
//       return color;
//     }).toList();
//     colorList.shuffle();
//     getInterestsForTimebank(timebankId: FlavorConfig.values.timebankId)
//         .then((onValue) {
//       setState(() {
//         if (onValue != null && onValue.isNotEmpty) {
//           interests = onValue;
//         } else {
//           print(interests);
//         }
//       });
//       this.selectedInterests = <String>[].toSet();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0.5,
//           title: Text(
//             'Interests',
//             style: TextStyle(
//               fontSize: 18,

//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Column(
//           children: <Widget>[
//             ListView(
//               shrinkWrap: true,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0, top: 20.0, bottom: 20.0),
//                   child: Text(
//                     'We would like to personalize the experiance based on your interests',
//                     style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Container(
//                       child: list(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             SizedBox(
//               width: 134,
//               child: RaisedButton(
//                 onPressed: () {
//                   widget.onSelectedInterests(interests.toList());
//                 },
//                 child: Text(
//                   'Next',
//                   style: Theme.of(context).primaryTextTheme.button,
//                 ),
//               ),
//             ),
//             FlatButton(
//               onPressed: () {
//                 widget.onSkipped();
//               },
//               child: Text(
//                 'Skip',
//                 style: TextStyle(
//                   color: Theme.of(context).accentColor,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget list() {
//     if (interests.length > 0) {
//       return Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Wrap(
//           spacing: 3.0,
//           runSpacing: 0.0,
//           alignment: WrapAlignment.center,
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: interests.map((interest) {
//             return chip(interest, selectedInterests.contains(interest));
//           }).toList(),
//         ),
//       );
//     }
//     return Padding(
//       padding: EdgeInsets.all(5.0),
//     );
//   }

//   Widget chip(String value, bool selected) {
//     return FilterChip(
//       label: Text(value),
//       labelStyle: TextStyle(
//           color: selected ? Colors.white : Colors.black,
//           fontSize: 12.0,
//           fontWeight: FontWeight.bold),
//       selected: selected,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30.0),
//       ),
//       backgroundColor: Colors.grey[300],
//       onSelected: (isSelected) {
//         setState(() {
//           if (selectedInterests.contains(value)) {
//             selectedInterests.remove(value);
//           } else {
//             selectedInterests.add(value);
//           }
//         });
//       },
//       showCheckmark: false,
//       // checkmarkColor: Color(0xFFF70C493),
//       avatar: selected
//           ? Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFFFFFFFF),
//               ),
//               child: Center(
//                 child: Icon(
//                   Icons.check,
//                   color: Color(0xFFF70C493),
//                   size: 18,
//                 ),
//               ),
//             )
//           : null,
//       selectedColor: Color(0xFFF70C493),
//     );
//   }

//   Color getTextColor(Color materialColor) {
//     List<MaterialColor> lights = [
//       Colors.blue,
//       Colors.lightBlue,
//       Colors.cyan,
//       Colors.lightGreen,
//       Colors.lime,
//       Colors.yellow,
//       Colors.amber,
//       Colors.orange,
//     ];

//     List<MaterialColor> darks = [
//       Colors.red,
//       Colors.pink,
//       Colors.purple,
//       Colors.deepPurple,
//       Colors.indigo,
//       Colors.teal,
//       Colors.green,
//       Colors.deepOrange,
//       Colors.brown,
//       Colors.blueGrey,
//     ];

//     if (lights.contains(materialColor)) {
//       return Colors.black;
//     } else if (darks.contains(materialColor)) {
//       return Colors.white;
//     } else {
//       return Colors.white;
//     }
//   }
// }

// class SkillViewNew extends StatefulWidget {
//   final VoidCallback onSkipped;
//   final StringListCallback onSelectedSkills;

//   SkillViewNew({
//     @required this.onSelectedSkills,
//     @required this.onSkipped,
//   });

//   @override
//   _SkillViewNewState createState() => _SkillViewNewState();
// }

// class Skill {
//   String skillName;
//   bool isSelected;

//   Skill(this.skillName, this.isSelected);
// }

// class _SkillViewNewState extends State<SkillViewNew> {
//   List<String> skills = FlavorConfig.values.timebankName == "Yang 2020"
//       ? const [
//           "Data entry",
//           "Research",
//           "Graphic design",
//           "Coding/development",
//           "Photography",
//           "Videography",
//           "Multilingual/translations",
//         ]
//       : [
//           'Curators',
//           'Developers',
//           'Writer',
//           'Advertisers',
//           'Customer',
//           'Sports',
//           'Adventure',
//           'Culture',
//           'Baseball',
//         ];
//   List<MaterialColor> colorList;
//   Set<String> selectedSkills = <String>[].toSet();

//   @override
//   void initState() {
//     super.initState();
//     colorList = Colors.primaries.map((color) {
//       return color;
//     }).toList();
//     colorList.shuffle();
//     getSkillsForTimebank(timebankId: FlavorConfig.values.timebankId)
//         .then((onValue) {
//       setState(() {
//         if (onValue != null && onValue.isNotEmpty) skills = onValue;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0.5,
//           title: Text(
//             'Skills',
//             style: TextStyle(fontSize: 18),
//           ),
//           centerTitle: true,
//         ),
//         body: Column(
//           children: <Widget>[
//             Container(
//               // height: MediaQuery.of(context).size.height - 100,
//               child: ListView(
//                 shrinkWrap: true,
//                 children: <Widget>[
//                   Padding(
//                       padding: const EdgeInsets.only(
//                           left: 16.0, top: 20.0, bottom: 20.0),
//                       child: Text(
//                         'Lets get to know more, Which skills do you know more',
//                         style: TextStyle(
//                             color: Colors.black54,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500),
//                       )),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         child: list(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Spacer(),
//             SizedBox(
//               width: 134,
//               child: RaisedButton(
//                 onPressed: () {
//                   widget.onSelectedSkills(selectedSkills.toList());
//                 },
//                 child: Text(
//                   'Next',
//                   style: Theme.of(context).primaryTextTheme.button,
//                 ),
//               ),
//             ),
//             FlatButton(
//               onPressed: () {
//                 widget.onSkipped();
//               },
//               child: Text(
//                 'Skip',
//                 style: TextStyle(
//                   color: Theme.of(context).accentColor,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//         // bottomNavigationBar: ButtonBar(
//         //   children: <Widget>[
//         //     FlatButton(
//         //       onPressed: () {
//         //         widget.onSkipped();
//         //       },
//         //       child: Text('Skip'),
//         //     ),
//         //     SizedBox(
//         //       width: 134,
//         //       child: RaisedButton(
//         //         onPressed: () {
//         //           widget.onSelectedSkills(selectedSkills.toList());
//         //         },
//         //         child: Text(
//         //           'Next',
//         //           style: Theme.of(context).primaryTextTheme.button,
//         //         ),
//         //       ),
//         //     )
//         //   ],
//         // ),
//       ),
//     );
//   }

//   Widget list() {
//     if (skills.length > 0) {
//       return Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Wrap(
//           spacing: 3.0,
//           runSpacing: 0.0,
//           alignment: WrapAlignment.center,
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: skills.map((skill) {
//             return chip(skill, selectedSkills.contains(skill));
//           }).toList(),
//         ),
//       );
//     }
//     return Padding(
//       padding: EdgeInsets.all(5.0),
//     );
//   }

//   Widget chip(String value, bool selected) {
//     return FilterChip(
//       label: Text(value),
//       labelStyle: TextStyle(
//         // color: FlavorConfig.values.buttonTextColor,
//         color: selected ? Colors.white : Colors.black,
//         fontSize: 12.0,
//         fontWeight: FontWeight.bold,
//       ),
//       selected: selected,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30.0),
//       ),
//       // backgroundColor: FlavorConfig.values.theme.splashColor,
//       // backgroundColor: selected ? Color(0x0FF70C493) : Colors.grey[300],
//       backgroundColor: Colors.grey[300],
//       onSelected: (isSelected) {
//         setState(() {
//           print(value);
//           print(selectedSkills);
//           if (selectedSkills.contains(value)) {
//             selectedSkills.remove(value);
//           } else {
//             selectedSkills.add(value);
//           }
//         });
//       },
//       showCheckmark: false,
//       avatar: selected
//           ? Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFFFFFFFF),
//               ),
//               child: Center(
//                 child: Icon(
//                   Icons.check,
//                   color: Color(0xFFF70C493),
//                   size: 18,
//                 ),
//               ),
//             )
//           : null,
//       selectedColor: Color(0x0FF70C493),
//     );
//   }

//   Color getTextColor(Color materialColor) {
//     List<MaterialColor> lights = [
//       Colors.blue,
//       Colors.lightBlue,
//       Colors.cyan,
//       Colors.lightGreen,
//       Colors.lime,
//       Colors.yellow,
//       Colors.amber,
//       Colors.orange,
//     ];

//     List<MaterialColor> darks = [
//       Colors.red,
//       Colors.pink,
//       Colors.purple,
//       Colors.deepPurple,
//       Colors.indigo,
//       Colors.teal,
//       Colors.green,
//       Colors.deepOrange,
//       Colors.brown,
//       Colors.blueGrey,
//     ];

//     if (lights.contains(materialColor)) {
//       return Colors.black;
//     } else if (darks.contains(materialColor)) {
//       return Colors.white;
//     } else {
//       return Colors.white;
//     }
//   }
// }

// class _ChipsTile extends StatelessWidget {
//   _ChipsTile({
//     Key key,
//     this.label,
//     this.children,
//   }) : super(key: key);

//   final String label;
//   final List<Widget> children;

//   final _formKey = GlobalKey<FormState>();

//   // Wraps a list of chips into a ListTile for display as a section in the demo.
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> cardChildren = <Widget>[
//       Container(
//         // padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
//         alignment: Alignment.center,
//         child: Text(label,
//             textAlign: TextAlign.start, style: TextStyle(color: Colors.white)),
//       ),

//       // bio goes here
//       Container(
//           // padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 4.0),
//           child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.only(bottom: 0.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     FlatButton(
//                       // shape: RoundedRectangleBorder(
//                       //     borderRadius: BorderRadius.circular(20.0)),
//                       // color: Colors.deepPurple,
//                       onPressed: () {
//                         createOnSkip(context);
// //                        Navigator.pushReplacement(
// //                          context,
// //                          MaterialPageRoute(
// //                            builder: (BuildContext context) => CoreView(
// //                              sevaUserID: null,
// //                            ),
// //                          ),
// //                        );
//                       },
//                       child: Text('Skip',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 18.0)),
//                     ),
//                     FlatButton(
//                       // shape: RoundedRectangleBorder(
//                       //     borderRadius: BorderRadius.circular(20.0)),
//                       // color: Colors.deepPurple,
//                       onPressed: () {
//                         // Validate will return true if the form is valid, or false if
//                         // the form is invalid.
//                         if (_formKey.currentState.validate()) {
//                           // If the form is valid, we want to show a Snackbar
//                           Scaffold.of(context).showSnackBar(
//                               SnackBar(content: Text('Processing Data')));
//                           _updateSkillsToDB(context);
//                           Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (BuildContext context) =>
//                                       LocationView()));
//                         }
//                       },
//                       child: Text('Next',
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 18.0)),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )),
//       Text('Choose Skills',
//           style: TextStyle(
//             fontSize: 18.0,
//             color: Colors.black,
//             fontWeight: FontWeight.w500,
//           ))
//       // TextFormField(
//       //   style: TextStyle(fontSize: 18.0, color: Colors.black),
//       //   decoration: InputDecoration(
//       //       contentPadding: EdgeInsets.fromLTRB(10.0, 20, 0, 0),
//       //       hintText: 'Your Bio and any #hashtages',
//       //       border: InputBorder.none),
//       //   keyboardType: TextInputType.multiline,
//       //   maxLines: 3,
//       //   validator: (value) {
//       //     if (value.isEmpty) {
//       //       return 'Please enter a Bio and any #hashtages';
//       //     }
//       //     globals.bio = value;
//       //   },
//       // ),
//     ];
//     if (children.isNotEmpty) {
//       cardChildren.add(Wrap(
//           children: children.map<Widget>((Widget chip) {
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(0, 10.0, 2, 2),
//           child: chip,
//         );
//       }).toList()));
//     } else {
//       final TextStyle textStyle = Theme.of(context)
//           .textTheme
//           .caption
//           .copyWith(fontStyle: FontStyle.italic);
//       cardChildren.add(Semantics(
//         container: true,
//         child: Container(
//           alignment: Alignment.center,
//           constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
//           padding: const EdgeInsets.all(8.0),
//           child: Text('None', style: textStyle),
//         ),
//       ));
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: cardChildren,
//     );
//   }
// }

// class SkillView extends StatefulWidget {
//   @override
//   _SkillViewState createState() => _SkillViewState();
// }

// class _SkillViewState extends State<SkillView> {
//   _SkillViewState() {
//     _reset();
//   }

//   final Set<String> _materials = Set<String>();

//   final Set<String> _tools = Set<String>();
//   final Set<String> _selectedTools = Set<String>();
//   final Set<String> _actions = Set<String>();
//   bool _showShapeBorder = false;

//   // Initialize members with the default data.
//   void _reset() {
//     _materials.clear();

//     _actions.clear();

//     _tools.clear();
//     _tools.addAll(_defaultTools);

//     _selectedTools.clear();
//   }

//   String _capitalize(String name) {
//     assert(name != null && name.isNotEmpty);
//     return name.substring(0, 1).toUpperCase() + name.substring(1);
//   }

//   Color _nameToColor(String name) {
//     assert(name.length > 1);
//     final int hash = name.hashCode & 0xffff;
//     final double hue = (360.0 * hash / (1 << 15)) % 360.0;
//     return HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> filterChips = _defaultTools.map<Widget>((String name) {
//       return FilterChip(
//         key: ValueKey<String>(name),
//         backgroundColor: _nameToColor(name),
//         label: Text(_capitalize(name)),
//         selected: _tools.contains(name) ? _selectedTools.contains(name) : false,
//         onSelected: !_tools.contains(name)
//             ? null
//             : (bool value) {
//                 setState(() {
//                   if (!value) {
//                     _selectedTools.remove(name);
//                   } else {
//                     _selectedTools.add(name);
//                   }
//                   globals.skills = _selectedTools.toList();
//                 });
//               },
//       );
//     }).toList();

//     final ThemeData theme = Theme.of(context);
//     final List<Widget> tiles = <Widget>[
//       const SizedBox(height: 8.0, width: 0.0),
//       _ChipsTile(label: 'Choose skills/interests', children: filterChips),
//       // const Divider(),
//     ];

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Skills/Intersts'),
//       // ),
//       body: ChipTheme(
//         data: _showShapeBorder
//             ? theme.chipTheme.copyWith(
//                 shape: BeveledRectangleBorder(
//                 side: BorderSide(width: 0.90, style: BorderStyle.solid),
//                 borderRadius: BorderRadius.circular(10.0),
//               ))
//             : theme.chipTheme,
//         child: ListView(children: tiles),
//       ),
//     );
//   }
// }

// _setPreferencesNext(BuildContext context) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setStringList('skills', globals.skills);
//   await prefs.setStringList('interests', []);
//   await prefs.setString('bio', '');
//   await prefs.setString('email', SevaCore.of(context).loggedInUser.email);
//   await prefs.setString(
//       'sevauserid', SevaCore.of(context).loggedInUser.sevaUserID);
//   await prefs.setString('fullname', SevaCore.of(context).loggedInUser.fullname);
// }

// _setPreferencesSkip(BuildContext context) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setStringList('skills', []);
//   await prefs.setStringList('interests', []);
//   await prefs.setString('bio', '');
//   await prefs.setString('email', SevaCore.of(context).loggedInUser.email);
//   await prefs.setString(
//       'sevauserid', SevaCore.of(context).loggedInUser.sevaUserID);
//   await prefs.setString('fullname', SevaCore.of(context).loggedInUser.fullname);
// }

// _updateSkillsToDB(BuildContext context) {
//   Firestore.instance
//       .collection('users')
//       .document(SevaCore.of(context).loggedInUser.email)
//       .setData({
//     'skills': globals.skills,
//     'interests': [],
//     'membership': [],
//     'bio': '',
//     'sevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
//     'email': SevaCore.of(context).loggedInUser.email,
//     'fullname': SevaCore.of(context).loggedInUser.fullname,
//     'photourl': SevaCore.of(context).loggedInUser.photoURL
//   });
//   _setPreferencesNext(context);
// }

// createOnSkip(BuildContext context) {
//   Firestore.instance
//       .collection('users')
//       .document(SevaCore.of(context).loggedInUser.email)
//       .setData({
//     'skills': [],
//     'interests': [],
//     'membership': [],
//     'bio': '',
//     'sevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
//     'email': SevaCore.of(context).loggedInUser.email,
//     'fullname': SevaCore.of(context).loggedInUser.fullname,
//     'photourl': SevaCore.of(context).loggedInUser.photoURL
//   });
//   _setPreferencesSkip(context);
// }

// class CustomFilterChip extends StatelessWidget {
//   final String title;
//   final Function delete;
//   final bool selected;

//   const CustomFilterChip({Key key, this.title, this.delete, this.selected})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FilterChip(
//       label: Text(title),
//       labelStyle: TextStyle(
//         color: Colors.white,
//         fontSize: 12.0,
//         fontWeight: FontWeight.bold,
//       ),
//       selected: selected,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30.0),
//       ),
//       backgroundColor: Colors.grey[300],
//       showCheckmark: false,
//       avatar: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Color(0xFFFFFFFF),
//         ),
//         child: Center(
//           child: Icon(
//             Icons.check,
//             color: Color(0xFFF70C493),
//             size: 18,
//           ),
//         ),
//       ),
//       selectedColor: Color(0x0FF70C493),
//       onSelected: (bool value) {
//         delete();
//       },
//     );
//   }
// }

