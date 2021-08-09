import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/requestOfferAgreementForm.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

import '../../labels.dart';

class ApproveLendingOffer extends StatefulWidget {
  final String timeBankId;
  final String userId;
  final OfferModel offerModel;
  final BuildContext parentContext;
  final VoidCallback onTap;

  ApproveLendingOffer({
    this.timeBankId,
    this.userId,
    this.offerModel,
    this.parentContext,
    this.onTap,
  });

  @override
  _ApproveLendingOfferState createState() => _ApproveLendingOfferState();
}

class _ApproveLendingOfferState extends State<ApproveLendingOffer> {
  GeoFirePoint location;
  String additionalInstructionsText = '';

  //TEMP VALUES
  String placeOrItem = 'PLACE';

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
          L.of(context).approve_lending_offer,
          style: TextStyle(
              fontFamily: "Europa", fontSize: 19, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: approveForm,
      ),
    );
  }

  Widget get approveForm {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 35, right: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            requestedByWidget,
            SizedBox(height: 20),
            OfferDurationWidget(
              title: placeOrItem == LendingType.PLACE.readable
                  ? L.of(context).date_to_check_in_out
                  : L.of(context).date_to_borrow_and_return,
            ),
            SizedBox(height: 15),
            Text(L.of(context).addditional_instructions + '*',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start),
            SizedBox(height: 2),
            TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (enteredValue) {
                additionalInstructionsText = enteredValue;
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: placeOrItem == LendingType.PLACE.readable
                    ? L.of(context).additional_instructions_hint_place
                    : L.of(context).additional_instructions_hint_item,
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                // labelText: 'No. of volunteers',
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty) {
                  return L.of(context).addditional_instructions_error_text;
                } else {
                  additionalInstructionsText = value;
                  setState(() {});
                  return null;
                }
              },
            ),
            // LocationPickerWidget(
            //   selectedAddress: selectedAddress,
            //   location: location,
            //   onChanged: (LocationDataModel dataModel) {
            //     setState(() {
            //       location = dataModel.geoPoint;
            //       selectedAddress = dataModel.location;
            //     });
            //   },
            // ),
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
        SizedBox(height: 25),
        Text(
            placeOrItem ==
                    LendingType.PLACE
                        .readable //widget.offerModel.placeOrItem == 'PLACE'
                ? L.of(context).lending_approve_terms_place
                : L.of(context).lending_approve_terms_item,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start),
        SizedBox(height: 25),
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
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Colors.grey[300],
            child: Text(
              S.of(context).reject,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              //Potential borrower is rejected
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
        ),
        Spacer(),
        Container(
          height: 32,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Colors.grey[300],
            child: Text(
              S.of(context).acknowledge,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              //Lender acknowledges user to borrow. Update data accordingly.
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
        ),
        SizedBox(width: 5),
        Container(
          height: 32,
          child: CustomElevatedButton(
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
                id: widget.offerModel.sevaUserId,
                name: widget.offerModel.fullName,
                photoUrl: widget.offerModel.photoUrlImage,
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

  Widget get requestedByWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          L.of(context).requested_by,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 42,
              backgroundImage: CachedNetworkImageProvider(
                'https://www.pngitem.com/pimgs/m/404-4042710_circle-profile-picture-png-transparent-png.png',
              ),
            ),
            SizedBox(width: 25),
            Container(
              child: Expanded(
                child: Text(
                  'Adam Smith', //borrower name here from offer model
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
// Widget get requestAgreementFormComponent {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(height: 15),
//       Text(
//         L.of(context).agreement,
//         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//       ),
//       SizedBox(height: 10),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             width: 250, //MediaQuery.of(context).size.width * 0.68,
//             child: Text(
//               'Agreement text',
//               style: TextStyle(fontSize: 15),
//               softWrap: true,
//             ),
//           ),
//           Image(
//             width: 60,
//             image: AssetImage(
//                 'lib/assets/images/request_offer_agreement_icon.png'),
//           ),
//         ],
//       ),
//       SizedBox(height: 20),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(documentName != '' ? 'view ' : ''),
//               GestureDetector(
//                   child: Container(
//                     alignment: Alignment.topLeft,
//                     width: 200, //MediaQuery.of(context).size.width * 0.55,
//                     child: Text(
//                       documentName != ''
//                           ? documentName
//                           : 'No Agreement Selected Label',
//                       style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: documentName != ''
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey),
//                       softWrap: true,
//                     ),
//                   ),
//                   onTap: () async {
//                     if (documentName != '') {
//                       await openPdfViewer(
//                           borrowAgreementLinkFinal, documentName, context);
//                     } else {
//                       return null;
//                     }
//                   }),
//             ],
//           ),
//           Container(
//             alignment: Alignment.bottomCenter,
//             margin: EdgeInsets.only(right: 12),
//             width: 100,
//             height: 32,
//             child: FlatButton(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: EdgeInsets.all(0),
//               color: Theme.of(context).primaryColor,
//               child: Row(
//                 children: <Widget>[
//                   SizedBox(width: 1),
//                   Spacer(),
//                   Text(
//                     'Change',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                   Spacer(
//                     flex: 1,
//                   ),
//                 ],
//               ),
//               onPressed: () {
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     fullscreenDialog: true,
//                 //     builder: (context) => RequestOfferAgreementForm(
//                 //       isRequest: true,
//                 //       placeOrItem: widget.offerModel.placeOrItem,
//                 //       requestModel: widget.offerModel,
//                 //       communityId: widget.offerModel.communityId,
//                 //       timebankId: widget.offerModel.timebankId,
//                 //       onPdfCreated: (pdfLink, documentNameFinal) {
//                 //         borrowAgreementLinkFinal = pdfLink;
//                 //         documentName = documentNameFinal;
//                 //         widget.offerModel.borrowAgreementLink = pdfLink;
//                 //         widget.offerModel.hasBorrowAgreement =
//                 //             pdfLink == '' ? false : true;
//                 //         // when request is created check if above value is stored in document
//                 //         setState(() => {});
//                 //       },
//                 //     ),
//                 //   ),
//                 // );
//               },
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
