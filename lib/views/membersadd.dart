import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/globals.dart' as globals;

class AddMembers extends StatefulWidget {
  final Widget child;

  AddMembers({Key key, this.child}) : super(key: key);

  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  String _searchValue = '';
  Color _color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              hintText: 'Search People by Email',
              hintStyle: TextStyle(fontSize: 18.0, color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
          onChanged: (value) {
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
                          setState(() {
                            globals.addedMembersId.add(document['sevauserid']);
                            globals.addedMembersFullname
                                .add(document['fullname']);
                            globals.addedMembersPhotoURL
                                .add(document['photourl']);
                            _color = Colors.orange;
                          });
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
