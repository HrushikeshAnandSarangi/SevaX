import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:share/share.dart';

import 'TimebankCodeModel.dart';

class InviteMembers extends StatefulWidget {
  final String communityId;
  final String timebankId;

  InviteMembers(this.timebankId, this.communityId);

  @override
  State<StatefulWidget> createState() => InviteMembersState(timebankId);
}

class InviteMembersState extends State<InviteMembers> {
  String timebankId;
  InviteMembersState(this.timebankId);
  TimebankCodeModel codeModel = TimebankCodeModel();
  Future<TimebankModel> timebankModel;

  @override
  void initState() {
    // TODO: implement initState

    timebankModel = getTimebankDetailsbyFuture(
      timebankId: timebankId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "Yang Gang Codes"
              : "Timebank Codes",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Divider(
            color: Colors.grey,
            height: 0,
          ),
          FutureBuilder(
            future: timebankModel,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                
              }

              return;
            },
          ),
          TimebankCodes(timebankId: timebankId)
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

  String shareText(TimebankCodeModel timebankCode) {
    var text =
        "Please join me on the SevaX by using the code \"${timebankCode.timebankCode}\"";

    return text;
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
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                'Publish code',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                var today = new DateTime.now();
                var oneDayFromToday =
                    today.add(new Duration(days: 30)).millisecondsSinceEpoch;
                registerTimebankCode(
                  timebankCode: timebankCode,
                  timebankId: timebankId,
                  validUpto: oneDayFromToday,
                  communityId: widget.communityId,
                );
                Navigator.of(context).pop("completed");
              },
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
              ),
              onPressed: () {
                Navigator.of(context).pop();
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
    return base64Url.encode(values).substring(0, 6).toLowerCase();
  }

  Future<void> registerTimebankCode({
    String timebankId,
    String timebankCode,
    int validUpto,
    String communityId,
  }) async {
    codeModel.createdOn = DateTime.now().millisecondsSinceEpoch;
    codeModel.timebankId = timebankId;
    codeModel.validUpto = validUpto;
    codeModel.timebankCodeId = utils.Utils.getUuid();
    codeModel.timebankCode = timebankCode;
    codeModel.communityId = communityId;

    print('codemodel ${codeModel.toString()}');
    await Firestore.instance
        .collection('timebankCodes')
        .document(codeModel.timebankCodeId)
        .setData(codeModel.toMap());

//    Firestore.instance.collection("timebankCodes").add({
//      "timebankId": timebankId,
//      "timebankCode": timebankCode,
//      "timebankCodeId": utils.Utils.getUuid(),
//      "validUpto": validUpto,
//      "createdOn": DateTime.now().millisecondsSinceEpoch,
//      "communityId": communityId,
//    }).then((doc) {
//      // task completed
//    });
  }

  void deleteShareCode(String timebankCodeId) {
    Firestore.instance
        .collection("timebankCodes")
        .document(timebankCodeId)
        .delete();

    print('deleted');
  }
}

class TimebankCodes extends StatelessWidget {
  const TimebankCodes({
    Key key,
    @required this.timebankId,
  }) : super(key: key);

  final String timebankId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TimebankCodeModel>>(
        stream: getTimebankCodes(timebankId: timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          print("timebank Code --> ${timebankId}");
          List<TimebankCodeModel> codeList = snapshot.data.reversed.toList();

          if (codeList.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No codes generated yet.'),
              ),
            );
          }
          return Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: codeList.length,
                itemBuilder: (context, index) {
                  String length = "0";

                  TimebankCodeModel timebankCode = codeList.elementAt(index);
                  if (timebankCode.usersOnBoarded == null) {
                    length = "Not yet redeemed";
                  } else {
                    if (timebankCode.usersOnBoarded.length == 1) {
                      length = "Redeemed by 1 user";
                    } else if (timebankCode.usersOnBoarded.length > 1) {
                      length =
                          "Redeemed by ${timebankCode.usersOnBoarded.length} users";
                    } else {
                      length = "Not yet redeemed";
                    }
                  }
                  return GestureDetector(
                    child: Card(
                      margin: EdgeInsets.all(5),
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(FlavorConfig.values.timebankName == "Yang 2020"
                                ? "Yang Gang Code : " +
                                    timebankCode.timebankCode
                                : "Timebank code : " +
                                    timebankCode.timebankCode),
                            Text(length),
                            Text(
                              DateTime.now().millisecondsSinceEpoch >
                                      timebankCode.validUpto
                                  ? "Expired"
                                  : "Active",
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Share.share(shareText(timebankCode));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(
                                      'Share code',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: IconButton(
                                    icon: Image.asset(
                                      'lib/assets/images/recycle-bin.png',
                                    ),
                                    iconSize: 30,
                                    onPressed: () {
                                      deleteShareCode(
                                          timebankCode.timebankCodeId);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
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
