import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:sevaexchange/components/sevaavatar/campaignavatar.dart';
import 'package:sevaexchange/views/membersaddedit.dart';
import 'package:sevaexchange/views/membersmanagecampaign.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/models/campaign_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class CampaignEdit extends StatelessWidget {
  final String timebankId;
  final CampaignModel campaignModel;

  CampaignEdit({
    @required this.timebankId,
    @required this.campaignModel,
  }) {
    assert(timebankId != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start a Campaign"),
        centerTitle: false,
      ),
      body: StreamBuilder<TimebankModel>(
          stream:
              FirestoreManager.getTimebankModelStream(timebankId: timebankId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return CampaignEditForm(
              timebankModel: snapshot.data,
              campaignModel: campaignModel,
            );
          }),
    );
  }
}

// Edit a Form Widget
class CampaignEditForm extends StatefulWidget {
  final TimebankModel timebankModel;
  final CampaignModel campaignModel;

  CampaignEditForm({
    @required this.timebankModel,
    @required this.campaignModel,
  }) {
    assert(timebankModel != null && timebankModel.id != null);
    assert(campaignModel != null);
  }

  @override
  CampaignEditFormState createState() {
    return CampaignEditFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class CampaignEditFormState extends State<CampaignEditForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    globals.campaignAvatarURL = widget.campaignModel.avatarUrl;
  }

  String _campaignName;
  String _missionStatement;
  String _address;
  String _primaryEmail;
  String _primaryNumber;

  void _updateToDB() {
    Firestore.instance
        .collection('campaigns')
        .document(widget.campaignModel.id)
        .updateData({
      'campaignname': _campaignName,
      'missionstatement': _missionStatement,
      'primaryemail': _primaryEmail,
      'primarynumber': _primaryNumber,
      'address': _address,
      'campaignavatarurl': globals.campaignAvatarURL,
    });

    setState(() {
//      globals.currentCampaignName = _campaignName;
//      globals.currentCampaignMission = _missionStatement;
//      globals.currentCampaignEmail = _primaryEmail;
//      globals.currentCampaignNumber = _primaryNumber;
//      globals.currentCampaignAddress = _address;
      globals.currentCampaignAvatar = globals.campaignAvatarURL;
    });

    Navigator.pop(context);
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
                          _updateToDB();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Update Campaign',
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
                initialValue: widget.campaignModel.name,
                decoration: InputDecoration(
                  hintText: 'Project Name',
                  labelText: 'Project Name',
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
                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))],
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  _campaignName = value;
                },
              ),
              Text(' '),
              TextFormField(
                initialValue: widget.campaignModel.missionStatement,
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
                initialValue: widget.campaignModel.primaryEmail,
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
                initialValue: widget.campaignModel.primaryNumber,
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
                initialValue: widget.campaignModel.address,
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
                        MaterialPageRoute(
                          builder: (context) => MembersManageCampaign(
                            campaignID: widget.campaignModel.id,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.supervisor_account,
                          color: Colors.blue,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                        ),
                        Text(
                          'Manage Members',
                          style: TextStyle(fontSize: 16.0, color: Colors.blue),
                        ),
                      ],
                    ),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMembersEdit(
                            timebankModel: widget.timebankModel,
                          ),
                        ),
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
      Text(widget.campaignModel.members
          .map((member) => member.email)
          .toList()
          .toString());
    }
  }
}
