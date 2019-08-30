import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views//membersadd.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class TimebankCreate extends StatelessWidget {
  final String timebankId;
  TimebankCreate({@required this.timebankId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Start a Timebank",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: TimebankCreateForm(
        timebankId: timebankId,
      ),
    );
  }
}

// Create a Form Widget
class TimebankCreateForm extends StatefulWidget {
  final String timebankId;
  TimebankCreateForm({@required this.timebankId});
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

  TimebankModel timebankModel = TimebankModel();
  bool protectedVal = false;

  void initState() {
    super.initState();

    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
  }

  void _writeToDB() {
    // _checkTimebankName();
    // if (!_exists) {
    print('writeToDB');
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    List<String> members = [SevaCore.of(context).loggedInUser.sevaUserID];
    globals.addedMembersId.forEach((m) {
      members.add(m);
    });

    timebankModel.id = Utils.getUuid();
    timebankModel.creatorId = SevaCore.of(context).loggedInUser.sevaUserID;
    timebankModel.photoUrl = globals.timebankAvatarURL;
    timebankModel.createdAt = timestamp;
    timebankModel.admins = [SevaCore.of(context).loggedInUser.sevaUserID];
    timebankModel.coordinators = [];
    timebankModel.members = members;
    timebankModel.children = [];
    timebankModel.balance = 0;
    timebankModel.protected = protectedVal;
    timebankModel.parentTimebankId = widget.timebankId;

    createTimebank(timebankModel: timebankModel);

    globals.timebankAvatarURL = null;
    globals.addedMembersId = [];

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
                        child: FutureBuilder<Object>(
                            future:
                                getTimeBankForId(timebankId: widget.timebankId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) return Offstage();
                              TimebankModel parentTimebank = snapshot.data;
                              return FlatButton(
                                // color: Colors.blue,
                                onPressed: () {
                                  // Validate will return true if the form is valid, or false if
                                  // the form is invalid.

                                  if (_formKey.currentState.validate()) {
                                    // If the form is valid, we want to show a Snackbar
                                    _writeToDB();
                                    if(parentTimebank.children == null) parentTimebank.children=[];
                                    parentTimebank.children
                                        .add(timebankModel.id);
                                    updateTimebank(timebankModel: parentTimebank);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  'Create Timebank',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                textColor: Colors.blue,
                              );
                            })),
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
                maxLines: 1,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  timebankModel.name = value;
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
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  timebankModel.missionStatement = value;
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
                  timebankModel.emailId = value;
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
                  timebankModel.phoneNumber = value;
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
                maxLines: null,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  timebankModel.address = value;
                },
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Text(
                    'Protected :',
                    style: TextStyle(fontSize: 18),
                  ),
                  Checkbox(
                    value: protectedVal,
                    onChanged: (bool value) {
                      setState(() {
                        protectedVal = value;
                      });
                    },
                  ),
                ],
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
    if (globals.addedMembersId == []) {
      Text('');
    } else {
      print('dkcjzdlcj - ' + globals.addedMembersId.toString());
      Text(globals.addedMembersId.toString());
    }
  }
}
