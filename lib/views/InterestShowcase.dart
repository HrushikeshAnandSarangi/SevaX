// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'interestsedit.dart';
// import '../globals.dart' as globals;

// class InterestShowcase extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new Column(
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text(
//                 'My Interests',
//                 style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
//               ),
//               FlatButton(
//                 // color: Colors.deepPurple,
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => InterestsEdit()));
//                 },
//                 child: Icon(Icons.edit),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.only(left: 25.0, right: 25.0),
//           child: getChipWidgets(globals.interests),
//         ),
//       ],
//     );
//     // Center(
//     //   child: new Text(
//     //     'interests: TODO',
//     //     style: textTheme.title.copyWith(color: Colors.white),
//     //   ),
//     // );
//   }
// }

// Color _getChipColor() {
//   List colors = [
//     Colors.red,
//     Colors.pink,
//     Colors.purple,
//     Colors.deepPurple,
//     Colors.indigo,
//     Colors.blue,
//     Colors.lightBlue,
//     Colors.cyan,
//     Colors.teal,
//     Colors.green,
//     Colors.lightGreen,
//     Colors.lime,
//     Colors.amber,
//     Colors.orange,
//     Colors.deepOrange,
//     Colors.brown,
//     Colors.blueGrey,
//     Colors.redAccent,
//   ];

//   Random random = Random();
//   int selected = random.nextInt(18);

//   return colors[selected];
// }

// Widget getChipWidgets(List<dynamic> strings) {
//   return Wrap(
//     spacing: 5.0,
//     alignment: WrapAlignment.start,
//     children: strings
//         .map(
//           (item) => ActionChip(
//             padding: EdgeInsets.all(3.0),
//             onPressed: () {},
//             backgroundColor: _getChipColor(),
//             label: Text(
//               item,
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         )
//         .toList(),
//   );
// }
