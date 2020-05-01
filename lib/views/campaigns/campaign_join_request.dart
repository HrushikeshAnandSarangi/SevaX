import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class CampaignJoinRequest extends StatefulWidget {
  final CampaignModel campaignModel;

  CampaignJoinRequest({
    Key key,
    @required this.campaignModel,
  }) : super(key: key);

  _CampaignJoinRequestState createState() => _CampaignJoinRequestState();
}

class _CampaignJoinRequestState extends State<CampaignJoinRequest> {
  final _formKey = GlobalKey<FormState>();

  String _reason;

  Future<void> _writeToDB() async {
    UserModel campaignOwner = await FirestoreManager.getUserForId(
      sevaUserId: widget.campaignModel.ownerSevaUserId,
    );

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Firestore.instance
        .collection('join_requests_campaign')
        .document(campaignOwner.email +
            '*' +
            widget.campaignModel.postTimestamp.toString() +
            '*' +
            SevaCore.of(context).loggedInUser.email)
        .setData({
      'campaignid': widget.campaignModel.id,
      'reason': _reason,
      'requestor_email': SevaCore.of(context).loggedInUser.email,
      'requestor_fullname': SevaCore.of(context).loggedInUser.fullname,
      'requestor_photourl': SevaCore.of(context).loggedInUser.photoURL,
      'campaign_name': widget.campaignModel.name,
      'joinrequesttimestamp': timestamp
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Request'),
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
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _writeToDB();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Submit Request',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          textColor: Colors.blue,
                        )),
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Why you want to join us.',
                      labelText: 'Reason to Join Campaign',
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
}
