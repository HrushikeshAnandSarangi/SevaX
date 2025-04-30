import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/individual_offer.dart';
import 'package:sevaexchange/ui/screens/offers/pages/one_to_many_offer.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/users_circle_avatar_list.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

@deprecated
class OfferCardView extends StatefulWidget {
  final OfferModel? offerModel;
  TimebankModel? timebankModel;
  String? sevaUserIdOffer;
  bool? isAdmin = false;
  OfferCardView({this.offerModel, this.timebankModel});
  @override
  State<StatefulWidget> createState() {
    return OfferCardViewState();
  }
}

class OfferCardViewState extends State<OfferCardView> {
  @override
  void initState() {
    super.initState();
    FirestoreManager.getTimeBankForId(
            timebankId: widget.offerModel!.timebankId!)
        .then((timebank) {
      widget.timebankModel = timebank;
      if (isAccessAvailable(
              timebank!, SevaCore.of(context).loggedInUser.sevaUserID!) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
        if (widget.isAdmin == false) {
          setState(() {
            widget.timebankModel = timebank;
            widget.isAdmin = true;
          });
        }
      }
    });
  }

  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );
  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
  @override
  Widget build(BuildContext context) {
    FirestoreManager.getTimeBankForId(
            timebankId: widget.offerModel!.timebankId!)
        .then((timebank) {
      if (isAccessAvailable(
              timebank!, SevaCore.of(context).loggedInUser.sevaUserID!) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {}
    });
    return Scaffold(
      // appBar: AppBar(
      //   actions: <Widget>[
      //     widget.offerModel.sevaUserId ==
      //             SevaCore.of(context).loggedInUser.sevaUserID
      //         ? IconButton(
      //             icon: Icon(Icons.delete),
      //             onPressed: () {
      //               showDialog(
      //                   context: context,
      //                   builder: (BuildContext viewcontext) {
      //                     return AlertDialog(
      //                       title: Text(
      //                         'Are you sure you want to delete this offer?',
      //                       ),
      //                       actions: <Widget>[
      //                         CustomTextButton(
      //                           padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      //                           color: Theme.of(context).accentColor,
      //                           textColor: FlavorConfig.values.buttonTextColor,
      //                           child: Text(
      //                             'Yes',
      //                             style: TextStyle(
      //                               fontSize: dialogButtonSize,
      //                             ),
      //                           ),
      //                           onPressed: () {
      //                             deleteOffer(offerModel: widget.offerModel);
      //                             Navigator.pop(viewcontext);
      //                             Navigator.pop(context);
      //                           },
      //                         ),
      //                         CustomTextButton(
      //                           child: Text(
      //                             'No',
      //                             style: TextStyle(
      //                               fontSize: dialogButtonSize,
      //                               color: Colors.red,
      //                             ),
      //                           ),
      //                           onPressed: () {
      //                             Navigator.pop(viewcontext);
      //                           },
      //                         ),
      //                       ],
      //                     );
      //                   });
      //             },
      //           )
      //         : Offstage()
      //   ],
      //   title: Text(
      //     "Offer Details",
      //     style: TextStyle(fontSize: 18),
      //   ),
      //   elevation: 0.5,
      // ),
      body: FutureBuilder<Object>(
          future: FirestoreManager.getUserForId(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            UserModel userModel = snapshot.data! as UserModel;
            String usertimezone = userModel.timezone!;
            return SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(),
                      child: Container(
                        padding: EdgeInsets.all(14.0),
                        child: Container(
                          padding: EdgeInsets.all(0),
                          color: widget.offerModel!.color,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SafeArea(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            getOfferTitle(
                                                offerDataModel:
                                                    widget.offerModel!),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          CustomListTile(
                                            leading: Icon(
                                              Icons.access_time,
                                              color: Colors.grey,
                                            ),
                                            title: Text(
                                              'Posted on',
                                              style: titleStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              DateFormat(
                                                      'EEEEEEE, MMMM dd h:mm a',
                                                      Locale(AppConfig.prefs!
                                                              .getString(
                                                                  'language_code')!)
                                                          .toLanguageTag())
                                                  .format(
                                                getDateTimeAccToUserTimezone(
                                                    dateTime: DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            widget.offerModel!
                                                                .timestamp!),
                                                    timezoneAbb:
                                                        SevaCore.of(context)
                                                            .loggedInUser
                                                            .timezone!),
                                              ),
                                              style: subTitleStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: Offstage(
                                              offstage: widget
                                                      .offerModel!.sevaUserId !=
                                                  SevaCore.of(context)
                                                      .loggedInUser
                                                      .sevaUserID,
                                              child: Container(
                                                height: 30,
                                                width: 80,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromRGBO(
                                                      44,
                                                      64,
                                                      140,
                                                      1,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    switch (widget.offerModel!
                                                        .offerType) {
                                                      case OfferType
                                                          .INDIVIDUAL_OFFER:
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                IndividualOffer(
                                                              offerModel: widget
                                                                  .offerModel!,
                                                              timebankId: widget
                                                                  .offerModel!
                                                                  .timebankId!,
                                                              timebankModel: widget
                                                                  .timebankModel!,
                                                              loggedInMemberUserId:
                                                                  SevaCore.of(
                                                                          context)
                                                                      .loggedInUser
                                                                      .sevaUserID!,
                                                            ),
                                                          ),
                                                        );
                                                        break;
                                                      case OfferType
                                                          .GROUP_OFFER:
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                OneToManyOffer(
                                                              offerModel: widget
                                                                  .offerModel,
                                                              timebankId: widget
                                                                  .offerModel!
                                                                  .timebankId!,
                                                              timebankModel: widget
                                                                  .timebankModel,
                                                              loggedInMemberUserId:
                                                                  SevaCore.of(
                                                                          context)
                                                                      .loggedInUser
                                                                      .sevaUserID,
                                                            ),
                                                          ),
                                                        );
                                                        break;
                                                    }
                                                  },
                                                  child: Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          CustomListTile(
                                            leading: Icon(
                                              Icons.location_on,
                                              color: Colors.grey,
                                            ),
                                            title: Text(
                                              "Location",
                                              style: titleStyle,
                                              maxLines: 1,
                                            ),
                                            subtitle: Text(
                                              widget
                                                  .offerModel!.selectedAdrress!,
                                              style: subTitleStyle,
                                              maxLines: 1,
                                            ),
                                          ),
                                          CustomListTile(
                                            leading: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                            title: Text(
                                              "Offered by ${widget.offerModel!.fullName}",
                                              style: titleStyle,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            child: RichTextView(
                                                text: getOfferDescription(
                                                    offerDataModel:
                                                        widget.offerModel!)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: UserCircleAvatarList(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(' '),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  getBottombar(),
                ],
              ),
            );
          }),
    );
  }

  String? offerStatusLabel;
  // Future _makePostRequest(OfferModel offerModel) async {
  //   String url = '${FlavorConfig.values.cloudFunctionBaseURL}/acceptOffer';
  //   Map<String, String> headers = {"Content-type": "application/json"};
  //   Map<String, String> body = {
  //     'id': offerModel.id,
  //     'email': offerModel.email,
  //     'notificationId': utils.Utils.getUuid(),
  //     'acceptorSevaId': SevaCore.of(context).loggedInUser.sevaUserID,
  //     'timebankId': FlavorConfig.values.timebankId,
  //     'sevaUserId': offerModel.sevaUserId,
  //     'communityId': SevaCore.of(context).loggedInUser.currentCommunity,
  //     'acceptorEmailId': SevaCore.of(context).loggedInUser.email,
  //   };
  //   setState(() {
  //     widget.offerModel.acceptedOffer = true;
  //   });
  //   Response response =
  //       await post(url, headers: headers, body: json.encode(body));
  //   int statusCode = response.statusCode;
  //   if (statusCode == 200) {
  //     print("Request completed successfully");
  //   } else {
  //     print("Request failed");
  //   }
  // }

  bool isAccepted = false;
  BuildContext? dialogContext;
  Widget getBottombar() {
    isAccepted =
        getOfferParticipants(offerDataModel: widget.offerModel!).contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white54, boxShadow: [
          BoxShadow(color: Colors.grey[300]!, offset: Offset(2.0, 2.0))
        ]),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: widget.offerModel!.sevaUserId !=
                                  SevaCore.of(context).loggedInUser.sevaUserID
                              ? 'You have${isAccepted ? '' : " not yet"} accepted this offer.'
                              : "You created this offer",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: widget.offerModel!.sevaUserId ==
                        SevaCore.of(context).loggedInUser.sevaUserID ||
                    getOfferParticipants(offerDataModel: widget.offerModel!)
                        .contains(SevaCore.of(context).loggedInUser.sevaUserID),
                child: Container(
                  width: 100,
                  height: 32,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(44, 64, 140, 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(0),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 1),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(44, 64, 140, 1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          getOfferParticipants(
                                      offerDataModel: widget.offerModel!)
                                  .contains(SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID)
                              ? S.of(context).accepted
                              : S.of(context).accept,
                          style: TextStyle(
                            color: isAccepted ? Colors.red : Colors.white,
                          ),
                        ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      if (true) {
                        confirmationDialog(
                          context: context,
                          title:
                              "You are signing up for this ${widget.offerModel!.groupOfferDataModel!.classTitle!.trim()}. Doing so will debit a total of ${widget.offerModel!.groupOfferDataModel!.numberOfClassHours} credits from you after you say OK.",
                          onConfirmed: () {
                            var myUserID =
                                SevaCore.of(context).loggedInUser.sevaUserID;
                            FirebaseFirestore.instance
                                .collection('offers')
                                .doc(widget.offerModel!.id)
                                .update({
                              'groupOfferDataModel.signedUpMembers':
                                  FieldValue.arrayUnion(
                                [myUserID],
                              )
                            });
                          },
                        );
                        Navigator.of(context).pop();
                      } else {
                        errorDialog(
                          context: context,
                          error:
                              "You don't have enough credit to signup for this class",
                        );
                      }
                      // if (widget.timebankModel != null &&
                      //     widget.timebankModel.protected &&
                      //     !(widget.timebankModel.admins.contains(
                      //         SevaCore.of(context).loggedInUser.sevaUserID))) {
                      //   _showProtectedTimebankMessage();
                      //   return;
                      // }
                      // showDialog(
                      //     barrierDismissible: false,
                      //     context: context,
                      //     builder: (createDialogContext) {
                      //       dialogContext = createDialogContext;
                      //       return AlertDialog(
                      //         title: Text('Please wait..'),
                      //         content: LinearProgressIndicator(),
                      //       );
                      //     });
                      // var isAccepted = getOfferParticipants(
                      //         offerDataModel: widget.offerModel)
                      //     .contains(
                      //         SevaCore.of(context).loggedInUser.sevaUserID);
                      // CollectionRef
                      //     offers
                      //     .doc(widget.offerModel.id)
                      //     .update({
                      //   'offerAcceptors': isAccepted
                      //       ? FieldValue.arrayRemove(
                      //           [SevaCore.of(context).loggedInUser.sevaUserID])
                      //       : FieldValue.arrayUnion(
                      //           [SevaCore.of(context).loggedInUser.sevaUserID])
                      // });
                      // widget.sevaUserIdOffer = widget.offerModel.sevaUserId;
                      // var tempOutput =   List<String>.from(
                      //   getOfferParticipants(offerDataModel: widget.offerModel),
                      // );
                      // tempOutput
                      //     .add(SevaCore.of(context).loggedInUser.sevaUserID);
                      // widget.offerModeferType == OfferType.GROUP_OFFER
                      //     ? widget
                      //         .offerModel.groupOfferDataModel.signedUpMembers
                      //     : widget.offerModel.individualOfferDataModel
                      //         .offerAcceptors = tempOutput;
                      // await _makePostRequest(widget.offerModel);
                      // Navigator.of(dialogContext).pop();
                      // Navigator.of(context).pop();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteOffer({
    required OfferModel offerModel,
  }) async {
    return await FirebaseFirestore.instance
        .collection('offers')
        .doc(offerModel.id)
        .delete();
  }
}
