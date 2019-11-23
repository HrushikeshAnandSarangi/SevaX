import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart'
    as prefix0;
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:share/share.dart';

import '../core.dart';
import 'TimebankCodeModel.dart';

class InviteMembers extends StatefulWidget {
  final String timebankId;

  InviteMembers(this.timebankId);

  @override
  State<StatefulWidget> createState() => InviteMembersState(timebankId);
}

class InviteMembersState extends State<InviteMembers> {
  String timebankId;
  InviteMembersState(this.timebankId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "Yang Gang Codes"
              : "Timebank codes",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Divider(
            color: Colors.grey,
            height: 0,
          ),
          StreamBuilder<List<TimebankCodeModel>>(
              stream: getTimebankCodes(timebankId: timebankId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                print("timebank Code --> ${timebankId}");
                List<TimebankCodeModel> codeList =
                    snapshot.data.reversed.toList();

                if (codeList.length == 0) {
                  return Center(
                    child: Text('No codes genrated yet.'),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: codeList.length,
                      itemBuilder: (context, index) {
                        TimebankCodeModel timebankCode =
                            codeList.elementAt(index);
                        return GestureDetector(
                          child: Card(
                            margin: EdgeInsets.all(5),
                            child: Container(
                              margin: EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(FlavorConfig.values.timebankName ==
                                          "Yang 2020"
                                      ? "Yang Gang Code : " +
                                          timebankCode.timebankCode
                                      : "Timebank code : " +
                                          timebankCode.timebankCode),
                                  Text(
                                      "Redeemed by ${timebankCode.usersOnBoarded == null ? 0 : timebankCode.usersOnBoarded.length} users"),
                                  Text(
                                    DateTime.now().millisecondsSinceEpoch >
                                            timebankCode.validUpto
                                        ? "Expired"
                                        : "Active",
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Share.share(
                                          "Hello Fellow Yang Gang \nPlease join me on the Humanity First App by using the code \"${timebankCode.timebankCode}\" In case you don't have the app installed already, you can install it from the Google Play Store at  https://play.google.com/store/apps/details?id=com.sevaexchange.humanityfirst&hl=en  or in the App Store at https://apps.apple.com/us/app/humanity-first-app-official/id1466915003 Looking forward to growing the Yang Gang movement with you!");
                                    },
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      child: Text(
                                        'Share code',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                );

                // return SizedBox(
                //     height: MediaQuery.of(context).size.height - 120,
                //     child: );
              })
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Generate Code"),
        onPressed: () {
          _asyncInputDialog(context);
        },
      ),
    );
  }

  Stream<List<TimebankCodeModel>> getTimebankCodes({
    String timebankId,
  }) async* {
    var data = Firestore.instance
        .collection('timebankCodes')
        .where('timebankId', isEqualTo: timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<TimebankCodeModel>>.fromHandlers(
        handleData: (querySnapshot, timebankCodeSink) {
          List<TimebankCodeModel> timebankCodes = [];
          querySnapshot.documents.forEach((documentSnapshot) {
            timebankCodes.add(TimebankCodeModel.fromMap(
              documentSnapshot.data,
            ));
          });
          timebankCodeSink.add(timebankCodes);
        },
      ),
    );
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String timebankCode = createCryptoRandomString();

    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Code generated"),
          content: new Row(
            children: <Widget>[
              Text(timebankCode + " is your code."),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Publish code',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                var today = new DateTime.now();
                var oneDayFromToday =
                    today.add(new Duration(days: 30)).millisecondsSinceEpoch;
                registerTimebankCode(
                  timebankCode: timebankCode,
                  timebankId: timebankId,
                  validUpto: oneDayFromToday,
                );
                Navigator.of(context).pop("completed");
              },
            ),
          ],
        );
      },
    );
  }

  static String createCryptoRandomString([int length = 10]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(100));
    return base64Url.encode(values).substring(0, 5).toLowerCase();
  }

  void registerTimebankCode(
      {String timebankId, String timebankCode, int validUpto}) {
    Firestore.instance.collection("timebankCodes").add({
      "timebankId": timebankId,
      "timebankCode": timebankCode,
      "validUpto": validUpto,
      "createdOn": DateTime.now().millisecondsSinceEpoch
    }).then((doc) {
      // task completed
    });
  }
}

// class InvitationListView extends StatelessWidget {
//   final String timebankId;
//   InvitationListView.forTimebank({this.timebankId});
//   List<prefix0.TimebankModel> timebankList = [];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             Padding(
//               padding: EdgeInsets.only(left: 10),
//             ),
//             Text(
//               FlavorConfig.values.timebankTitle,
//               style: (TextStyle(fontWeight: FontWeight.w500)),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 10),
//             ),
//             Expanded(
//               child: StreamBuilder<Object>(
//                 stream: FirestoreManager.getTimebanksForUserStream(
//                   userId: SevaCore.of(context).loggedInUser.sevaUserID,
//                 ),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError)
//                     return new Text('Error: ${snapshot.error}');
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   timebankList = snapshot.data;
//                   List<String> dropdownList = [];
//                   timebankList.forEach((t) {
//                     dropdownList.add(t.id);
//                   });
//                   SevaCore.of(context).loggedInUser.associatedWithTimebanks =
//                       dropdownList.length;
//                   return DropdownButton<String>(
//                     value: timebankId,
//                     onChanged: (String newValue) {},
//                     items: dropdownList
//                         .map<DropdownMenuItem<String>>((String value) {
//                       if (value == 'All') {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       } else
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: FutureBuilder<Object>(
//                               future: FirestoreManager.getTimeBankForId(
//                                   timebankId: value),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasError)
//                                   return new Text('Error: ${snapshot.error}');
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return Offstage();
//                                 }
//                                 prefix0.TimebankModel timebankModel =
//                                     snapshot.data;
//                                 return Text(timebankModel.name);
//                               }),
//                         );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         Divider(
//           color: Colors.grey,
//           height: 0,
//         ),
//         StreamBuilder<List<TimebankCodeModel>>(
//             stream: getTimebankCodes(timebankId: timebankId),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Text(snapshot.error.toString());
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               List<TimebankCodeModel> codeList =
//                   snapshot.data.reversed.toList();

//               if (codeList.length == 0) {
//                 return Center(
//                   child: Text('No codes genrated yet.'),
//                 );
//               }

//               return ListView.builder(
//                   itemCount: codeList.length,
//                   itemBuilder: (context, index) {
//                     TimebankCodeModel timebankCode = codeList.elementAt(index);
//                     return GestureDetector(
//                       child: Card(
//                         margin: EdgeInsets.all(5),
//                         child: Container(
//                           margin: EdgeInsets.all(15),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(FlavorConfig.values.timebankName ==
//                                       "Yang 2020"
//                                   ? "Yang Gang Code : " +
//                                       timebankCode.timebankCode
//                                   : "Timebank code : " +
//                                       timebankCode.timebankCode),
//                               Text(
//                                   "Redeemed by ${timebankCode.usersOnBoarded == null ? 0 : timebankCode.usersOnBoarded.length} users"),
//                               Text(
//                                 DateTime.now().millisecondsSinceEpoch >
//                                         timebankCode.validUpto
//                                     ? "Expired"
//                                     : "Active",
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   Share.share(
//                                       "Hello Fellow Yang Gang \nPlease join me on the Humanity First App by using the code \"${timebankCode.timebankCode}\" In case you don't have the app installed already, you can install it from the Google Play Store at  https://play.google.com/store/apps/details?id=com.sevaexchange.humanityfirst&hl=en  or in the App Store at https://apps.apple.com/us/app/humanity-first-app-official/id1466915003 Looking forward to growing the Yang Gang movement with you!");
//                                 },
//                                 child: Container(
//                                   margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
//                                   child: Text(
//                                     'Share code',
//                                     style: TextStyle(color: Colors.blue),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   });
//             })
//       ],
//     );
//   }

//   prefix0.TimebankModel timebBank;
//   Future setTimebankDetails() async {
//     timebBank = await FirestoreManager.getTimeBankForId(timebankId: timebankId);
//     print("Timebank name --> ${timebBank.name}");
//   }
// }
