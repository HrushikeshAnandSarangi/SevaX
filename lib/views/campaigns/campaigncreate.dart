import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/components/sevaavatar/campaignavatar.dart';
import 'package:sevaexchange/views/membersadd.dart';

import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class CampaignCreate extends StatelessWidget {
  final TimebankModel timebankModel;

  CampaignCreate({@required this.timebankModel}) {
    assert(timebankModel != null && timebankModel.id != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a campaign"),
        centerTitle: false,
      ),
      body: CampaignCreateForm(
        timebankModel: timebankModel,
      ),
    );
  }
}

// Create a Form Widget
class CampaignCreateForm extends StatefulWidget {
  final TimebankModel timebankModel;

  CampaignCreateForm({@required this.timebankModel}) {
    assert(timebankModel != null && timebankModel.id != null);
  }

  @override
  CampaignCreateFormState createState() {
    return CampaignCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class CampaignCreateFormState extends State<CampaignCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();

    globals.campaignAvatarURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
  }

  String _campaignName;
  String _missionStatement;
  String _address;
  String _primaryEmail;
  String _primaryNumber;

  void _writeToDB() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    Firestore.instance
        .collection('campaigns')
        .document(
            SevaCore.of(context).loggedInUser.email + '*' + timestampString)
        .setData({
      'campaignname': _campaignName,
      'parent_timebank': widget.timebankModel.id,
      'missionstatement': _missionStatement,
      'primaryemail': _primaryEmail,
      'primarynumber': _primaryNumber,
      'ownerfullname': SevaCore.of(context).loggedInUser.fullname,
      'ownerphotourl': SevaCore.of(context).loggedInUser.photoURL,
      'ownersevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
      'sevauserid': SevaCore.of(context).loggedInUser.sevaUserID,
      'owneremail': SevaCore.of(context).loggedInUser.email,
      'creatoremail': SevaCore.of(context).loggedInUser.email,
      'address': _address,
      'campaignavatarurl': globals.campaignAvatarURL,
      'membersemail': globals.addedMembersId,
      'membersfullname': globals.addedMembersFullname,
      'membersphotourl': globals.addedMembersPhotoURL,
      'posttimestamp': timestamp
    });
    globals.campaignAvatarURL = null;
    globals.addedMembersId = [];
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
                    child: CampaignAvatar(),
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
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Create Campaign',
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
                  hintText: 'Campaign Name',
                  labelText: 'Campaign Name',
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
                  _campaignName = value;
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
    if (globals.addedMembersId == []) {
      Text('');
    } else {
      Text(globals.addedMembersId.toString());
    }
  }
}
