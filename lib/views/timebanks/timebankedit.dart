//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
//import 'package:sevaexchange/globals.dart' as globals;
//import 'package:sevaexchange/models/user_model.dart';
//import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
//import 'package:sevaexchange/views/membersaddedit.dart';
//import 'package:sevaexchange/views/membersmanage.dart';
//
//class TimebankEdit extends StatelessWidget {
//  final TimebankModel timebankModel;
//  final UserModel ownerModel;
//
//  TimebankEdit({
//    @required this.timebankModel,
//    @required this.ownerModel,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Start a Timebank"),
//        centerTitle: false,
//      ),
//      body: TimebankEditForm(
//        timebankModel: timebankModel,
//        ownerModel: ownerModel,
//      ),
//    );
//  }
//}
//
//// Edit a Form Widget
//class TimebankEditForm extends StatefulWidget {
//  final TimebankModel timebankModel;
//  final UserModel ownerModel;
//
//  TimebankEditForm({
//    @required this.timebankModel,
//    @required this.ownerModel,
//  });
//
//  @override
//  TimebankEditFormState createState() {
//    return TimebankEditFormState();
//  }
//}
//
//// Create a corresponding State class. This class will hold the data related to
//// the form.
//class TimebankEditFormState extends State<TimebankEditForm> {
//  // Create a global key that will uniquely identify the Form widget and allow
//  // us to validate the form
//  //
//  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
//  final _formKey = GlobalKey<FormState>();
//
//  String title = '';
//  String subHeading = '';
//  String description = '';
//  String _timeBankName;
//  String _missionStatement;
//  String _address;
//  String _primaryEmail;
//  String _primaryNumber;
//
//  void initState() {
//    super.initState();
//  }
//
//  void _updateToDB() {
//    Firestore.instance
//        .collection('timebanks')
//        .document(widget.timebankModel.creatorId +
//            '*' +
//            widget.timebankModel.createdAt.toString())
//        .updateData({
//      'timebankname': _timeBankName,
//      'missionstatement': _missionStatement,
//      'primaryemail': _primaryEmail,
//      'primarynumber': _primaryNumber,
//      'address': _address,
//      'timebankavatarurl': globals.timebankAvatarURL,
//    });
//
//    setState(() {
//      globals.currentTimebankName = _timeBankName;
//      globals.currentTimebankMission = _missionStatement;
//      globals.currentTimebankEmail = _primaryEmail;
//      globals.currentTimebankNumber = _primaryNumber;
//      globals.currentTimebankAddress = _address;
//      globals.currentTimebankAvatar = globals.timebankAvatarURL;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Form(
//        key: _formKey,
//        child: Container(
//          padding: EdgeInsets.all(20.0),
//          child: SingleChildScrollView(
//              child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.all(0.0),
//                    child: TimebankAvatar(),
//                  ),
//                  Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 5.0),
//                    child: Container(
//                        child: FlatButton(
//                      // color: Colors.blue,
//                      onPressed: () {
//                        // Validate will return true if the form is valid, or false if
//                        // the form is invalid.
//
//                        if (_formKey.currentState.validate()) {
//                          // If the form is valid, we want to show a Snackbar
//                          _updateToDB();
//                          Navigator.pop(context);
//                        }
//                      },
//                      child: Text(
//                        'Update Timebank',
//                        style: TextStyle(fontSize: 16.0),
//                      ),
//                      textColor: Colors.blue,
//                    )),
//                  ),
//                ],
//              ),
//
//              Padding(
//                padding: EdgeInsets.all(15.0),
//              ),
//              TextFormField(
//                textCapitalization: TextCapitalization.sentences,
//                initialValue: widget.timebankModel.name,
//                decoration: InputDecoration(
//                  hintText: 'Timebank Name',
//                  labelText: 'Timebank Name',
//                  // labelStyle: textStyle,
//                  // labelStyle: textStyle,
//                  // labelText: 'Description',
//                  border: OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(20.0),
//                    ),
//                    borderSide: BorderSide(
//                      color: Colors.black,
//                      width: 1.0,
//                    ),
//                  ),
//                ),
//                keyboardType: TextInputType.multiline,
//                maxLines: 3,
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Please enter some text';
//                  }
//                  _timeBankName = value;
//                },
//              ),
//              Text(' '),
//              TextFormField(
//                textCapitalization: TextCapitalization.sentences,
//                initialValue: widget.timebankModel.missionStatement,
//                decoration: InputDecoration(
//                  hintText: 'What you are about',
//                  labelText: 'Mission Statement',
//                  // labelStyle: textStyle,
//                  // labelStyle: textStyle,
//                  // labelText: 'Description',
//                  border: OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(20.0),
//                    ),
//                    borderSide: BorderSide(
//                      color: Colors.black,
//                      width: 1.0,
//                    ),
//                  ),
//                ),
//                keyboardType: TextInputType.multiline,
//                maxLines: 10,
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Please enter some text';
//                  }
//                  _missionStatement = value;
//                },
//              ),
//              Text(''),
//              TextFormField(
//                initialValue: widget.timebankModel.emailId,
//                decoration: InputDecoration(
//                  hintText: 'The Timebank\'s primary email',
//                  labelText: 'Email',
//                  // labelStyle: textStyle,
//                  // labelStyle: textStyle,
//                  // labelText: 'Description',
//                  border: OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(20.0),
//                    ),
//                    borderSide: BorderSide(
//                      color: Colors.black,
//                      width: 1.0,
//                    ),
//                  ),
//                ),
//                keyboardType: TextInputType.multiline,
//                maxLines: 1,
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Please enter some text';
//                  }
//                  _primaryEmail = value;
//                },
//              ),
//              Text(''),
//              TextFormField(
//                initialValue: widget.timebankModel.phoneNumber,
//                decoration: InputDecoration(
//                  hintText: 'The Timebanks primary phone number',
//                  labelText: 'Phone Number',
//                  // labelStyle: textStyle,
//                  // labelStyle: textStyle,
//                  // labelText: 'Description',
//                  border: OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(20.0),
//                    ),
//                    borderSide: BorderSide(
//                      color: Colors.black,
//                      width: 1.0,
//                    ),
//                  ),
//                ),
//                keyboardType: TextInputType.multiline,
//                maxLines: 1,
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Please enter some text';
//                  }
//                  _primaryNumber = value;
//                },
//              ),
//              Text(''),
//              TextFormField(
//                textCapitalization: TextCapitalization.sentences,
//                initialValue: widget.timebankModel.address,
//                decoration: InputDecoration(
//                  hintText: 'Your main address',
//                  labelText: 'Address',
//                  // labelStyle: textStyle,
//                  // labelStyle: textStyle,
//                  // labelText: 'Description',
//                  border: OutlineInputBorder(
//                    borderRadius: const BorderRadius.all(
//                      const Radius.circular(20.0),
//                    ),
//                    borderSide: BorderSide(
//                      color: Colors.black,
//                      width: 1.0,
//                    ),
//                  ),
//                ),
//                keyboardType: TextInputType.multiline,
//                maxLines: 6,
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Please enter some text';
//                  }
//                  _address = value;
//                },
//              ),
//              // Text(sevaUserID),
//              Padding(
//                  padding: EdgeInsets.only(top: 8.0),
//                  child: FlatButton(
//                    onPressed: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => MembersManage(
//                            timebankModel: widget.timebankModel,
//                          ),
//                        ),
//                      );
//                    },
//                    child: Row(
//                      children: <Widget>[
//                        Icon(
//                          Icons.supervisor_account,
//                          color: Colors.blue,
//                        ),
//                        Padding(
//                          padding: EdgeInsets.only(right: 5.0),
//                        ),
//                        Text(
//                          'Manage Members',
//                          style: TextStyle(fontSize: 16.0, color: Colors.blue),
//                        ),
//                      ],
//                    ),
//                  )),
//              Padding(
//                padding: EdgeInsets.only(top: 8.0),
//                child: FlatButton(
//                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => AddMembersEdit(
//                                timebankModel: widget.timebankModel,
//                              )),
//                    );
//                  },
//                  child: Text(
//                    '+ Add Members',
//                    style: TextStyle(fontSize: 16.0, color: Colors.blue),
//                  ),
//                ),
//              ),
//              Divider(),
//              Text(''),
//            ],
//          )),
//        ));
//  }
//}
