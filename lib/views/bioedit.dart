import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/globals.dart' as globals;
import 'core.dart';

class BioEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Edit Bio",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BioForm(),
    );
  }
}

class BioForm extends StatefulWidget {
  @override
  BioFormState createState() {
    return BioFormState();
  }
}

class BioFormState extends State<BioForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();

  // Future<dynamic> _getPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String sevaUID = prefs.getString('userid') ?? 'nothing';

  //   globals.sevaUserID = sevaUID;
  // }

  _setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bio', SevaCore.of(context).loggedInUser.bio);
  }

  Future _loadFromFirestore() async {
    globals.onLoadResult = await Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .get();

    var userDocument = globals.onLoadResult.data;
    SevaCore.of(context).loggedInUser.bio = userDocument['bio'];
  }

  void _updateBioToDB() {
    Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .updateData({
      'bio': SevaCore.of(context).loggedInUser.bio,
    });
    _setPreferences();
  }

  @override
  Widget build(BuildContext context) {
    _loadFromFirestore();
    // Build a Form widget using the _formKey we created above
    return Container(
        padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  // padding: EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            // If the form is valid, we want to show a Snackbar
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Processing Data')));
                            _updateBioToDB();
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Update Bio',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                                color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  initialValue: SevaCore.of(context).loggedInUser.bio,
                  style: TextStyle(fontSize: 18.0, color: Colors.black87),
                  decoration: InputDecoration(
                      hintText: 'Your Bio. ', border: InputBorder.none),
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a Bio.';
                    }
                    SevaCore.of(context).loggedInUser.bio = value;
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
