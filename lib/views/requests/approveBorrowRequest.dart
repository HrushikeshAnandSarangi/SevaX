import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/requestOfferAgreementForm.dart';
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

  String borrowAgreementLinkFinal = '';
  String documentName = '';

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
          widget.requestModel.roomOrTool == 'ROOM'
              ? 'Approve Room Borrow Request'
              : 'Approve Item Borrow request', //Label to be created
          style: TextStyle(
              fontFamily: "Europa", fontSize: 19, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: widget.requestModel.roomOrTool == 'ROOM' ? roomForm : itemForm,
      ),
    );
  }

  Widget get roomForm {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20),
            Text("Guests can do and don't*", //Label to be created
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start),
            SizedBox(height: 2),
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
            requestAgreementFormComponent,
            termsAcknowledegmentText,
            bottomActionButtons,
          ],
        ),
      ),
    );
  }

  Widget get itemForm {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //SizedBox(height: 20),
            // Text("Guests can do and don't*", //Label to be created
            //     style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.w600,
            //     ),
            //     textAlign: TextAlign.start),
            // SizedBox(height: 10),
            // TextFormField(
            //   onFieldSubmitted: (v) {
            //     FocusScope.of(context).unfocus();
            //   },
            //   onChanged: (enteredValue) {
            //     doAndDonts = enteredValue;
            //     setState(() {});
            //   },
            //   decoration: InputDecoration(
            //     hintText:
            //         "Tell your borrower do and dont's", //Label to be created
            //     hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
            //     // labelText: 'No. of volunteers',
            //   ),
            //   keyboardType: TextInputType.text,
            //   validator: (value) {
            //     if (value.isEmpty) {
            //       return "Please enter the do's and dont's"; //Label to be created
            //     } else {
            //       doAndDonts = value;
            //       setState(() {});
            //       return null;
            //     }
            //   },
            // ),

            requestAgreementFormComponent,

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

            termsAcknowledegmentText,
            bottomActionButtons,
          ],
        ),
      ),
    );
  }

  Widget get termsAcknowledegmentText {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
            widget.requestModel.roomOrTool == 'ROOM'
                ? "I acknowledge that you can use the room on the mentioned dates." //Label to be created
                : "I acknowledge that you can use the item on the mentioned dates.", //Label to be created
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start),
        SizedBox(height: 15),
        Text(
            widget.requestModel.roomOrTool == 'ROOM'
                ? "Note: Please instruct on how to reach the location and do and don't accordingly." //Label to be created
                : "Note: Please create an agreement if you have specific instructions and/or requirements.", //Label to be created
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
      ],
    );
  }

  Widget get bottomActionButtons {
    return Row(
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
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
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
                } else if (documentName == '') {
                  _key.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Select an agreement type'),
                    ),
                  );
                } else {
                  if (widget.requestModel.roomOrTool == 'ROOM') {
                    await storeAcceptorDataBorrowRequest(
                      model: widget.requestModel,
                      acceptorEmail: SevaCore.of(context).loggedInUser.email,
                      doAndDonts: doAndDonts,
                      selectedAddress: selectedAddress,
                      location: location,
                      acceptorName: SevaCore.of(context).loggedInUser.fullname,
                    );
                    borrowRequestSetHasCreatedAgreement(
                        requestModel: widget.requestModel);
                  } else {
                    await storeAcceptorDataBorrowRequest(
                      model: widget.requestModel,
                      acceptorEmail: SevaCore.of(context).loggedInUser.email,
                      doAndDonts: doAndDonts,
                      selectedAddress: selectedAddress,
                      location: location,
                      acceptorName: SevaCore.of(context).loggedInUser.fullname,
                    );
                    borrowRequestSetHasCreatedAgreement(
                        requestModel: widget.requestModel);
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
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;

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
    );
  }

  Widget get requestAgreementFormComponent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Agreement', //Label to be created
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.68,
              child: Text(
                'Create/Use agreement between you and borrower on how your item/place can be used.',
                style: TextStyle(fontSize: 15),
                softWrap: true, //Label to be created
              ),
            ),
            Image(
              width: 60,
              image: AssetImage(
                  'lib/assets/images/request_offer_agreement_icon.png'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(documentName != '' ? 'view ' : ''), //Label to be created
                GestureDetector(
                    child: Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Text(
                        documentName != ''
                            ? documentName
                            : 'No Agreement Selected', //Label to be created
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: documentName != ''
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                        softWrap: true,
                      ),
                    ),
                    onTap: () async {
                      if (documentName != '') {
                        await openPdfViewer(
                            borrowAgreementLinkFinal, documentName, context);
                      } else {
                        return null;
                      }
                    }),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(right: 12),
              width: 100,
              height: 32,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(0),
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 1),
                    Spacer(),
                    Text(
                      S.of(context).change,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => RequestOfferAgreementForm(
                        isRequest: true,
                        roomOrTool: widget.requestModel.roomOrTool,
                        requestModel: widget.requestModel,
                        communityId: widget.requestModel.communityId,
                        timebankId: widget.requestModel.timebankId,
                        onPdfCreated: (pdfLink, documentNameFinal) {
                          borrowAgreementLinkFinal = pdfLink;
                          documentName = documentNameFinal;
                          widget.requestModel.borrowAgreementLink = pdfLink;
                          widget.requestModel.hasBorrowAgreement =
                              pdfLink == '' ? false : true;
                          // when request is created check if above value is stored in document
                          setState(() => {});
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
