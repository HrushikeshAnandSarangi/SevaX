import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

import 'package:sevaexchange/views/core.dart';

import 'timebank_congratsView.dart';

class TimebankJoinRequest extends StatefulWidget {
  final Widget child;
  final TimebankModel timebankModel;
  final UserModel owner;

  TimebankJoinRequest({
    Key key,
    this.child,
    @required this.timebankModel,
    @required this.owner,
  }) : super(key: key);

  _TimebankJoinRequestState createState() => _TimebankJoinRequestState();
}

class _TimebankJoinRequestState extends State<TimebankJoinRequest> {
  final _formKey = GlobalKey<FormState>();

  String _reason;

  void _writeToDB() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    Firestore.instance
        .collection('join_requests_timebanks')
        .document(
            '${widget.owner.email}*${widget.timebankModel.createdAt}*${SevaCore.of(context).loggedInUser.email}')
        .setData({
      'timebankid': widget.timebankModel.creatorId +
          '*' +
          widget.timebankModel.createdAt.toString(),
      'reason': _reason,
      'requestor_email': SevaCore.of(context).loggedInUser.email,
      'requestor_fullname': SevaCore.of(context).loggedInUser.fullname,
      'requestor_photourl': SevaCore.of(context).loggedInUser.photoURL,
      'timebank_name': widget.timebankModel.name,
      'joinrequesttimestamp': timestamp
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request to Join Timebank'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      alignment: Alignment(1.0, 0.0),
                      child: FlatButton(
                        // color: Colors.blue,
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          //_navigateCongrats();
                          if (_formKey.currentState.validate()) {
                            //_writeToDB();
                            _navigateCongrats();
                          }
                        },
                        child: Text(
                          'Submit Request to Join',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        textColor: Colors.blue,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Why you want to join us.',
                      labelText: 'Reason to Join',
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
                      _reason = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _navigateCongrats() {
    Navigator.pop(context);

   // Navigator.of(context).pushReplacement(
//      MaterialPageRoute(
//          builder: (context) => Congrats()
//      ),
//    );
  }
}
