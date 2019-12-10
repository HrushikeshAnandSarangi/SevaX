// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import '../components/member.dart';

class AddMembersEdit extends StatefulWidget {
  final TimebankModel timebankModel;

  AddMembersEdit({
    Key key,
    @required this.timebankModel,
  }) : super(key: key) {
    assert(timebankModel != null && timebankModel.id != null);
  }

  _AddMembersEditState createState() => _AddMembersEditState();
}

class _AddMembersEditState extends State<AddMembersEdit> {
  String _searchValue = '';
  Color _color = Colors.white;

  TimebankModel timebankModel;

  @override
  void initState() {
    super.initState();
    this.timebankModel = widget.timebankModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              hintText: 'Search People by Email!',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white54)),
          onSubmitted: (value) {
            setState(() {
              _searchValue = value;
              _color = Colors.white;
            });
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .where('email', isEqualTo: _searchValue)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return GestureDetector(
                        child: Card(
                          margin: EdgeInsets.all(10.0),
                          color: _color,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                // Padding(
                                //   padding: EdgeInsets.all(5.0),
                                // ),
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(document['photourl'] ?? ''),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.68,
                                  child: Text(
                                    document['fullname'],
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Member newMember = Member(
                            fullName: document['fullname'],
                            email: document['email'],
                            photoUrl: document['photourl'],
                          );

                          timebankModel.members.add(newMember.email);
                          Firestore.instance
                              .collection('timebanks')
                              .document(timebankModel.id)
                              .updateData(timebankModel.toMap());
                          setState(() {
                            _color = Colors.orange;
                          });
                          // Duration(milliseconds: 10);
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return NewsCardView(newsItem: document);
                        });
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }
}

class Member extends DataModel {
  String email;
  String fullName;
  String photoUrl;

  Member({this.fullName, this.email, this.photoUrl});

  Member.fromMap(Map<String, dynamic> dataMap) {
    if (dataMap.containsKey('membersemail')) {
      this.email = dataMap['membersemail'];
    }

    if (dataMap.containsKey('membersfullname')) {
      this.fullName = dataMap['membersfullname'];
    }

    if (dataMap.containsKey('membersphotourl')) {
      this.photoUrl = dataMap['membersphotourl'];
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.email != null && this.email.isNotEmpty) {
      object['membersemail'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      object['membersfullname'] = this.fullName;
    }
    if (this.photoUrl != null && this.photoUrl.isNotEmpty) {
      object['membersphotourl'] = this.photoUrl;
    }

    return object;
  }
}
