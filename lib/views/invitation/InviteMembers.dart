import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

import 'TimebankCodeModel.dart';

class InviteMembers extends StatefulWidget {
  final String timebankId;

  InviteMembers({this.timebankId});

  @override
  State<StatefulWidget> createState() => InviteMembersState(timebankId);
}

class InviteMembersState extends State<InviteMembers> {
  final String timebankId;
  InviteMembersState(this.timebankId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang Codes" : "Timebank codes",
          style: TextStyle(color: Colors.white),
        ),
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
      body: InvitationListView.forTimebank(timebankId: timebankId),
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
                    validUpto: oneDayFromToday);
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

    print("Code registered");
  }
}

class InvitationListView extends StatelessWidget {
  final String timebankId;
  InvitationListView.forTimebank({this.timebankId});

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

          List<TimebankCodeModel> codeList = snapshot.data.reversed.toList();

          if (codeList.length == 0) {
            return Center(
              child: Text('No codes genrated yet.'),
            );
          }

          return ListView.builder(
              itemCount: codeList.length,
              itemBuilder: (context, index) {
                TimebankCodeModel timebankCode = codeList.elementAt(index);
                return Card(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang Code : " + timebankCode.timebankCode : "Timebank code : " + timebankCode.timebankCode),
                        Text(
                            "Redeemed by ${timebankCode.usersOnBoarded == null ? 0 : timebankCode.usersOnBoarded.length} users"),
                        Text(DateTime.now().millisecondsSinceEpoch >
                                timebankCode.validUpto
                            ? "Expired"
                            : "Active"),
                      ],
                    ),
                  ),
                );
              });
        });
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
}
