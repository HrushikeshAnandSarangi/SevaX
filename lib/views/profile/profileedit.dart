import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
      ),
      body: ProfileForm(),
    );
  }
}

class ProfileForm extends StatefulWidget {
  @override
  ProfileFormState createState() {
    return ProfileFormState();
  }
}

class ProfileFormState extends State<ProfileForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> _getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sevaUID = prefs.getString('userid') ?? 'nothing';

    SevaCore.of(context).loggedInUser.sevaUserID = sevaUID;
  }

  Future<void> _setPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('fullname', globals.fullname);
    await prefs.setString('bio', SevaCore.of(context).loggedInUser.bio);
    await prefs.setStringList('interests', globals.interests);
    await prefs.setStringList('skills', globals.skills);
  }

  Future _loadFromFirestore() async {
    globals.onLoadResult = await Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .get();

    var userDocument = globals.onLoadResult.data;
    // fullname = userDocument['fullname'];
    SevaCore.of(context).loggedInUser.bio = userDocument['bio'];
    globals.interests = userDocument['interests'];
    globals.skills = userDocument['skills'];
  }

  void _updateDB() {
    Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .updateData({
      'bio': SevaCore.of(context).loggedInUser.bio,
    });
    _setPreferences();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    _getPreferences();
    _loadFromFirestore();

    return Container(
        child: SingleChildScrollView(
            child: Form(
      key: _formKey,
      child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(''),
              // Text(globals.fullname),
              // TextFormField(
              //   initialValue: fullname,
              //   decoration: InputDecoration(labelText: 'Full Name', hintText: 'Enter Your Full Name',
              //   border: OutlineInputBorder(
              //       borderRadius: const BorderRadius.all(
              //         const Radius.circular(20.0),
              //       ),
              //       borderSide: new BorderSide(
              //         color: Colors.black,
              //         width: 1.0,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.multiline,
              //   maxLines: 1,
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Please enter you full name';
              //     }
              //   fullname = value;
              //   },
              // ),
              Text(''),
              // TextFormField(
              //   initialValue: globals.bio,
              //   decoration: InputDecoration(labelText: 'Bio and Resumé', hintText: 'Your Bio and any #hashtages',
              //   border: OutlineInputBorder(
              //       borderRadius: const BorderRadius.all(
              //         const Radius.circular(20.0),
              //       ),
              //       borderSide: new BorderSide(
              //         color: Colors.black,
              //         width: 1.0,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.multiline,
              //   maxLines: 10,
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Please enter a Bio and any #hashtages';
              //     }
              //   globals.bio = value;
              //   },
              // ),
              Text(''),
              // TextFormField(
              //   initialValue: interests,
              //   decoration: InputDecoration(labelText: 'Interests',  hintText: 'Enter your Interests',
              //   border: OutlineInputBorder(
              //       borderRadius: const BorderRadius.all(
              //         const Radius.circular(20.0),
              //       ),
              //       borderSide: new BorderSide(
              //         color: Colors.black,
              //         width: 1.0,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.multiline,
              //   maxLines: 4,
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Please enter your Interests';
              //     }
              //   interests = value;
              //   },
              // ),
              Text(''),
              // TextFormField(
              //   initialValue: skills,
              //   decoration: InputDecoration(labelText: 'Skills', hintText: 'Enter your Skills',
              //   border: OutlineInputBorder(
              //       borderRadius: const BorderRadius.all(
              //         const Radius.circular(20.0),
              //       ),
              //       borderSide: new BorderSide(
              //         color: Colors.black,
              //         width: 1.0,
              //       ),
              //     ),
              //   ),
              //   keyboardType: TextInputType.multiline,
              //   maxLines: 4,
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Please enter your Skills';
              //     }
              //   skills = value;
              //   },
              // ),
              // Text(sevaUserID),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  color: Colors.deepPurple,
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Registering Profile Details')));
                    }
                    _updateDB();
                    _setPreferences();
                  },
                  child: Text('Update Profile'),
                  textColor: Colors.white,
                ),
              ),
            ],
          )),
    )));
  }
}
