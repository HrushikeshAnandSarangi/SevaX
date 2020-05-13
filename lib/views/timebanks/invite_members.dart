import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:share/share.dart';

class InviteAddMembers extends StatefulWidget {
  final String communityId;
  final String timebankId;
  final TimebankModel timebankModel;

  InviteAddMembers(this.timebankId, this.communityId, this.timebankModel);

  @override
  State<StatefulWidget> createState() => InviteAddMembersState();
}

class InviteAddMembersState extends State<InviteAddMembers> {
  TimebankCodeModel codeModel = TimebankCodeModel();
  final TextEditingController searchTextController =
      new TextEditingController();
  Future<TimebankModel> getTimebankDetails;
  TimebankModel timebankModel;
  var validItems = List<String>();

  @override
  void initState() {
    super.initState();
    _setTimebankModel();
    getMembersList();
    searchTextController.addListener(() {
      setState(() {});
    });
    // setState(() {});
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        validItems = onValue;
      });
    });
  }

  void _setTimebankModel() async {
    timebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "Yang Gang Codes"
              : "Invite Members",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: FutureBuilder(
          future: getTimebankDetails,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            return inviteCodeWidget;
          },
        ),
      ),
    );
  }

  Widget get inviteCodeWidget {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            style: TextStyle(color: Colors.black),
            controller: searchTextController,
            decoration: InputDecoration(
                suffixIcon: Offstage(
                  offstage: searchTextController.text.length == 0,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    icon: Icon(
                      Icons.clear,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      //searchTextController.clear();
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => searchTextController.clear());
                    },
                  ),
                ),
                hasFloatingPlaceholder: false,
                alignLabelWithHint: true,
                isDense: true,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                contentPadding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 3.0),
                filled: true,
                fillColor: Colors.grey[300],
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white),
                  borderRadius: new BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: new BorderRadius.circular(25.7)),
                hintText: 'Invite members via email',
                hintStyle: TextStyle(color: Colors.black45, fontSize: 13)),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
          child: Container(
            height: 25,
            child: Text(
              "Members",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: buildList(),
        ),
        !widget.timebankModel.private == true
            ? Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  child: Container(
                    height: 25,
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Invite via code",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Image.asset("lib/assets/images/add.png"),
                      ],
                    ),
                  ),
                  onTap: () async {
                    _asyncInputDialog(context);
                  },
                ),
              )
            : Offstage(),
        !widget.timebankModel.private == true
            ? getTimebankCodesWidget
            : Offstage(),
      ],
    );
  }

  Widget buildList() {
    print("search ${searchTextController.text}");

//    if (searchTextController.text.trim().length < 1) {
//      //  print('Search requires minimum 1 character');
//      return Offstage();
//    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchUserInSevaX(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Please try again later');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            );
          }
          List<UserModel> userlist = snapshot.data;
          print("user list ${snapshot.data}");
          print("user  ${userlist}");
          if (userlist.length == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('No member found')),
            );
          }
          return Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
              child: ListView.builder(
                  shrinkWrap: true,
//                  padding: EdgeInsets.only(
//                      bottom:
//                          180), //to avoid keyboard overlap //temp fix neeeds to be changed
                  itemCount: userlist.length,
                  itemBuilder: (context, index) {
//                          CompareUserStatus status;
//
//                          status = _compareUserStatus(communityList[index],
//                              widget.loggedInUser.sevaUserID);

                    return userWidget(
                      user: userlist[index],
                    );
                  }));

          return Text("");
        });
  }

  Widget userWidget({
    UserModel user,
  }) {
    bool isJoined = false;
    if (validItems.contains(user.sevaUserID)) {
      isJoined = true;
    }

    return ListTile(
      leading: user.photoURL != null
          ? ClipOval(
              child: FadeInImage.assetNetwork(
                fadeInCurve: Curves.easeIn,
                fadeInDuration: Duration(milliseconds: 400),
                fadeOutDuration: Duration(milliseconds: 200),
                width: 50,
                height: 50,
                placeholder: 'lib/assets/images/noimagefound.png',
                image: user.photoURL,
              ),
            )
          : CircleAvatar(),
      // onTap: goToNext(snapshot.data),
      title: Text(user.fullname,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),

      ///  subtitle: Text(user.email),
      trailing: RaisedButton(
        onPressed: !isJoined
            ? () async {
                await addMemberToTimebank(
                        sevaUserId: user.sevaUserID,
                        timebankId: timebankModel.id,
                        communityId: timebankModel.communityId,
                        userEmail: user.email)
                    .commit();
                setState(() {
                  getMembersList();
                });
              }
            : null,
        child: Text(isJoined ? "Joined" : "Add"),
        color: FlavorConfig.values.theme.accentColor,
        textColor: FlavorConfig.values.buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  Widget get getTimebankCodesWidget {
    return StreamBuilder<List<TimebankCodeModel>>(
        stream: getTimebankCodes(timebankId: widget.timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          print("timebank Code --> ${widget.timebankId}");
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

  String shareText(TimebankCodeModel timebankCode) {
    // var text =  "Please download the SevaX volunteer app and join my Timebank ${timebankModel.name} by using the code \"${timebankCode.timebankCode}\"";
    var text =
        "${SevaCore.of(context).loggedInUser.fullname} has invited you to join \"${timebankModel.name}\" Timebank. Timebanks are communities that allow you to volunteer and also receive time credits towards getting things done for you. Use the code \"${timebankCode.timebankCode}\" when prompted to join this Timebank. Please download the app from the links provided at https://sevaxapp.com";

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
                  timebankId: widget.timebankId,
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

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  WriteBatch addMemberToTimebank(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) {
    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var addToCommunityRef =
        Firestore.instance.collection('communities').document(communityId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(userEmail);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    batch.updateData(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
    });

    batch.updateData(addToCommunityRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    return batch;
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
