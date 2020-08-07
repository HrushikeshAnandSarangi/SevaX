// import 'dart:convert';
// import 'package:flutter/material.dart';

// class MyThreeOptions extends StatefulWidget {
//   @override
//   _MyThreeOptionsState createState() => _MyThreeOptionsState();
// }

// class _MyThreeOptionsState extends State<MyThreeOptions> {
//   int _value = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//         elevation: 4.0,
//         child: Container(
//           height: 120,
//         alignment: Alignment.center,
//         margin: const EdgeInsets.symmetric(
//             horizontal: 0.0, vertical: 15),
//         padding: const EdgeInsets.symmetric(
//             horizontal: 20.0, vertical: 20.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(0.0),
//           gradient: LinearGradient(
//             colors: [Colors.white12, Colors.white12],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey[200],
//             ),
//           ],
//         ),
//         child: Column(
//           children: <Widget>[
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Text(
//                     "Are you the one who is already contracted and recovered from Virus?",
//                     maxLines: 2,
//                     overflow: TextOverflow.clip,
//                     style: Theme
//                         .of(context)
//                         .textTheme
//                         .title
//                         .apply(
//                         fontWeightDelta: 2,
//                         color: Colors.black54),
//                   ),
//                 ),
//                 SizedBox(width: 15.0),
//               ],
//             ),
//             SizedBox(height: 5.0),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Text(
//                     "Volunteers who are recovered from Covid 19 very much needed right now.",
//                     textAlign: TextAlign.left,
//                     maxLines: 2,
//                     style: Theme
//                         .of(context)
//                         .textTheme
//                         .subtitle
//                         .apply(color: Colors.black54),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: <Widget>[
//                     Wrap(
//                         alignment: WrapAlignment.center,
//                         spacing: 12.0,
//                         children: <Widget>[
//                           ChoiceChip(
//                             pressElevation: 0.0,
//                             selectedColor: Colors.blue,
//                             backgroundColor: Colors.grey[100],
//                             label: Text("Yes", style: TextStyle(
//                                 color: _value == 0 ? Colors.white : Colors
//                                     .black)),
//                             selected: _value == 0,
//                             onSelected: (bool selected) {
//                               setState(() {
//                                 _value = selected ? 0 : null;
//                               });
//                             },
//                           ),
//                           ChoiceChip(
//                             pressElevation: 0.0,
//                             selectedColor: Colors.blue,
//                             backgroundColor: Colors.grey[100],
//                             label: Text("No", style: TextStyle(
//                                 color: _value == 1 ? Colors.white : Colors
//                                     .black)),
//                             selected: _value == 1,
//                             onSelected: (bool selected) {
//                               setState(() {
//                                 _value = selected ? 1 : null;
//                               });
//                             },
//                           ),
//                           ChoiceChip(
//                             pressElevation: 0.0,
//                             selectedColor: Colors.blue,
//                             backgroundColor: Colors.grey[100],
//                             label: Text("Skip to answer", style: TextStyle(
//                                 color: _value == 2 ? Colors.white : Colors
//                                     .black)),
//                             selected: _value == 2,
//                             onSelected: (bool selected) {
//                               setState(() {
//                                 _value = selected ? 2 : null;
//                               });
//                             },
//                           ),
//                         ])
//                   ],
//                 ),
// //            InfoScreen()
//           ],
//         )));
//   }
// }
