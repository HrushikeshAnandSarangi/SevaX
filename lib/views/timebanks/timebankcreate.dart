import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/views//membersadd.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';

class TimebankCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start a Timebank"),
        centerTitle: false,
      ),
      body: TimebankCreateForm(),
    );
  }
}

// Create a Form Widget
class TimebankCreateForm extends StatefulWidget {
  @override
  TimebankCreateFormState createState() {
    return TimebankCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class TimebankCreateFormState extends State<TimebankCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String subHeading = '';
  String description = '';
  String _timeBankName;
  String _missionStatement;
  String _address;
  String _primaryEmail;
  String _primaryNumber;

  void initState() {
    super.initState();

    globals.timebankAvatarURL = null;
    globals.addedMembersEmail = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
  }

  void _writeToDB() {
    // _checkTimebankName();
    // if (!_exists) {
    print('writeToDB');
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    Firestore.instance
        .collection('timebanks')
        .document(
            SevaCore.of(context).loggedInUser.email + '*' + timestampString)
        .setData({
      'timebankname': _timeBankName,
      'missionstatement': _missionStatement,
      'primaryemail': _primaryEmail,
      'primarynumber': _primaryNumber,
      'ownerfullname': SevaCore.of(context).loggedInUser.fullname,
      'ownerphotourl': SevaCore.of(context).loggedInUser.photoURL,
      'ownersevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
      'owneremail': SevaCore.of(context).loggedInUser.email,
      'creatoremail': SevaCore.of(context).loggedInUser.email,
      'address': _address,
      'timebankavatarurl': globals.timebankAvatarURL,
      'membersemail': globals.addedMembersEmail,
      'membersfullname': globals.addedMembersFullname,
      'membersphotourl': globals.addedMembersPhotoURL,
      'posttimestamp': timestamp
    });
    globals.timebankAvatarURL = null;
    globals.addedMembersEmail = [];
    Navigator.pop(context);
    // } else {
    //   print('timebank name exists');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: TimebankAvatar(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                        child: FlatButton(
                      // color: Colors.blue,
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.

                        if (_formKey.currentState.validate()) {
                          // If the form is valid, we want to show a Snackbar
                          _writeToDB();
                        }
                      },
                      child: Text(
                        'Create Timebank',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      textColor: Colors.blue,
                    )),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(15.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Timebank Name',
                  labelText: 'Timebank Name',
                  // labelStyle: textStyle,
                  // labelStyle: textStyle,
                  // labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _timeBankName = value;
                },
              ),
              Text(' '),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'What you are about',
                  labelText: 'Mission Statement',
                  // labelStyle: textStyle,
                  // labelStyle: textStyle,
                  // labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _missionStatement = value;
                },
              ),
              Text(''),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'The Timebank\'s primary email',
                  labelText: 'Email',
                  // labelStyle: textStyle,
                  // labelStyle: textStyle,
                  // labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _primaryEmail = value;
                },
              ),
              Text(''),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'The Timebanks primary phone number',
                  labelText: 'Phone Number',
                  // labelStyle: textStyle,
                  // labelStyle: textStyle,
                  // labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _primaryNumber = value;
                },
              ),
              Text(''),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Your main address',
                  labelText: 'Address',
                  // labelStyle: textStyle,
                  // labelStyle: textStyle,
                  // labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                    borderSide: new BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _address = value;
                },
              ),
              // Text(sevaUserID),
              Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddMembers()),
                      );
                    },
                    child: Text(
                      '+ Add Members',
                      style: TextStyle(fontSize: 16.0, color: Colors.blue),
                    ),
                  )),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: _showMembers(),
              ),
              Text(''),
              // Padding(
              //   padding: EdgeInsets.only(top: 8.0),
              //   child:
              //   Text('Add Admins'),
              // ),
            ],
          )),
        ));
  }

  _showMembers() {
    if (globals.addedMembersEmail == []) {
      Text('');
    } else {
      print('dkcjzdlcj - ' + globals.addedMembersEmail.toString());
      Text(globals.addedMembersEmail.toString());
    }
  }
}
