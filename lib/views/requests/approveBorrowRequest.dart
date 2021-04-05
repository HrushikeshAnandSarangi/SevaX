import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class AcceptBorrowRequest extends StatefulWidget {
  final String timeBankId;
  final String userId;
  final RequestModel requestModel;
  final BuildContext parentContext;
  final VoidCallback onTap;

  AcceptBorrowRequest({
    this.timeBankId,
    this.userId,
    this.requestModel,
    this.parentContext,
    this.onTap,
  });

  @override
  _AcceptBorrowRequestState createState() => _AcceptBorrowRequestState();
}

class _AcceptBorrowRequestState extends State<AcceptBorrowRequest> {
  GeoFirePoint location;
  String selectedAddress = '';
  String doAndDonts = '';

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Approve Borrow request', //Labels to be created
          style: TextStyle(
              fontFamily: "Europa", fontSize: 20, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20),
              Text("Guests can do and don't*",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.start),
              SizedBox(height: 10),
              TextFormField(
                onFieldSubmitted: (v) {
                  FocusScope.of(context).unfocus();
                },
                onChanged: (enteredValue) {
                  doAndDonts = enteredValue;
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText:
                      "Tell your borrower do and dont's", //Label to be created
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  // labelText: 'No. of volunteers',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter the do's and dont's"; //Label to be created
                  } else {
                    doAndDonts = value;
                    setState(() {});
                    return null;
                  }
                },
              ),
              SizedBox(height: 20),
              LocationPickerWidget(
                selectedAddress: selectedAddress,
                location: location,
                onChanged: (LocationDataModel dataModel) {
                  setState(() {
                    location = dataModel.geoPoint;
                    selectedAddress = dataModel.location;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                  "I acknowledge that you can use the room on the mentioned dates.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.start),
              SizedBox(height: 15),
              Text(
                  "Note: Please instruct on how to reach the location and do and don't accordingly",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.start),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.all(5.0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 32,
                    child: RaisedButton(
                      padding: EdgeInsets.only(left: 11, right: 11),
                      color: Colors.grey[300],
                      child: Text(
                        S.of(context).acknowledge,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //donation approved
                        if (_formKey.currentState.validate()) {
                          if (location == null) {
                            _key.currentState.showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).location_not_added),
                              ),
                            );
                          } else {

                            if (widget.requestModel.roomOrTool == 'ROOM') {
                              await storeAcceptorDataBorrowRequest(
                                model: widget.requestModel,
                                acceptorEmail:
                                    SevaCore.of(context).loggedInUser.email,
                                doAndDonts: doAndDonts,
                                selectedAddress: selectedAddress,
                                location: location,
                                acceptorName:
                                    SevaCore.of(context).loggedInUser.fullname,
                              );
                            }

                            widget.onTap?.call();
                          }
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  SizedBox(width: 5),
                  Container(
                    height: 32,
                    child: RaisedButton(
                      padding: EdgeInsets.only(left: 11, right: 11),
                      color: Colors.grey[300],
                      child: Text(
                        S.of(context).message,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        UserModel loggedInUser =
                            SevaCore.of(context).loggedInUser;

                        ParticipantInfo sender = ParticipantInfo(
                          id: loggedInUser.sevaUserID,
                          name: loggedInUser.fullname,
                          photoUrl: loggedInUser.photoURL,
                          type: ChatType.TYPE_PERSONAL,
                        );

                        ParticipantInfo reciever = ParticipantInfo(
                          id: widget.requestModel.sevaUserId,
                          name: widget.requestModel.creatorName,
                          photoUrl: widget.requestModel.photoUrl,
                          type: ChatType.TYPE_PERSONAL,
                        );

                        createAndOpenChat(
                          context: context,
                          communityId: loggedInUser.currentCommunity,
                          sender: sender,
                          reciever: reciever,
                          onChatCreate: () {
                            //Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
