import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/calender_event_confirm_dialog.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;

class OfferJoinRequestDialog extends StatefulWidget {
  // final RequestInvitationModel requestInvitationModel;
  final String offerId;
  final String requestId;
  final int requestStartDate;
  final int requestEndDate;
  final String requestTitle;

  final String timeBankId;
  final String notificationId;
  final UserModel userModel;
  final TimeOfferParticipantsModel timeOfferParticipantsModel;

  OfferJoinRequestDialog({
    this.timeBankId,
    this.notificationId,
    this.userModel,
    this.offerId,
    this.requestId,
    this.timeOfferParticipantsModel,
    this.requestStartDate,
    this.requestEndDate,
    this.requestTitle,
  });

  @override
  _OfferJoinRequestDialogState createState() => _OfferJoinRequestDialogState();
}

class _OfferJoinRequestDialogState extends State<OfferJoinRequestDialog> {
  _OfferJoinRequestDialogState();

  BuildContext progressContext;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.timeOfferParticipantsModel
                        .participantDetails.photourl ??
                    defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                widget.timeOfferParticipantsModel.participantDetails.fullname,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                widget.timeOfferParticipantsModel.participantDetails.bio ??
                    "${S.of(context).timebank} name not updated",
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     widget.requestStartDate.toString() +
            //         ' to ' +
            //         widget.requestEndDate.toString(),
            //     maxLines: 5,
            //     overflow: TextOverflow.ellipsis,
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            Center(
              child: Text(
                  "By acceting this invitation, a task will be added in your tasks.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Text(
                      S.of(context).accept,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      //Once approvedp
                      CommunityModel communityModel = CommunityModel({});
                      await Firestore.instance
                          .collection('communities')
                          .document(widget.userModel.currentCommunity)
                          .get()
                          .then((value) {
                        communityModel = CommunityModel(value.data);
                        setState(() {});
                      });
                      AcceptorModel acceptorModel = AcceptorModel(
                        memberPhotoUrl: widget.userModel.photoURL,
                        communityId: widget.userModel.currentCommunity,
                        communityName: communityModel.name,
                        memberName: widget.userModel.fullname,
                        memberEmail: widget.userModel.email,
                        timebankId: communityModel.primary_timebank,
                      );

                      if (widget.userModel.calendarId != null) {
                        showDialog(
                          context: context,
                          builder: (_context) {
                            return CalenderEventConfirmationDialog(
                              title: widget.requestTitle,
                              isrequest: true,
                              cancelled: () async {
                                approveInvitationForVolunteerRequest(
                                  allowedCalender: false,
                                  notificationId: widget.notificationId,
                                  user: widget.userModel,
                                  acceptorModel: acceptorModel,
                                  offerId: widget.offerId,
                                  requestId: widget.requestId,
                                );
                                Navigator.pop(_context);
                                Navigator.of(context).pop();
                              },
                              addToCalender: () async {
                                approveInvitationForVolunteerRequest(
                                    offerId: widget.offerId,
                                    requestId: widget.requestId,
                                    allowedCalender: true,
                                    notificationId: widget.notificationId,
                                    user: widget.userModel,
                                    acceptorModel: acceptorModel);
                                Navigator.pop(_context);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      } else {
                        approveInvitationForVolunteerRequest(
                            allowedCalender: false,
                            offerId: widget.offerId,
                            requestId: widget.requestId,
                            notificationId: widget.notificationId,
                            user: widget.userModel,
                            acceptorModel: acceptorModel);

                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      S.of(context).decline,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      declineInvitationbRequest(
                        requestId: widget.requestId,
                        notificationId: widget.notificationId,
                        userModel: widget.userModel,
                        offerId: widget.offerId,
                      );

                      if (progressContext != null) {
                        Navigator.pop(progressContext);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void calenderConfirmation(BuildContext context) {}

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void declineInvitationbRequest({
    String notificationId,
    UserModel userModel,
    String requestId,
    String offerId,
  }) {
    rejectInviteRequest(
      requestId: requestId,
      rejectedUserId: userModel.sevaUserID,
      notificationId: notificationId,
    );

    Firestore.instance
        .collection('offers')
        .document(offerId)
        .collection('offerAcceptors')
        .document(notificationId)
        .updateData({
      'status': 'REJECTED',
    });
    FirestoreManager.readUserNotification(notificationId, userModel.email);
  }

  void approveInvitationForVolunteerRequest({
    String requestId,
    String offerId,
    String notificationId,
    UserModel user,
    bool allowedCalender,
    AcceptorModel acceptorModel,
  }) {
    acceptInviteRequest(
      requestId: requestId,
      acceptedUserEmail: user.email,
      acceptedUserId: user.sevaUserID,
      notificationId: notificationId,
      allowedCalender: allowedCalender,
      acceptorModel: acceptorModel,
    );

    //Update accetor document
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .collection('offerAcceptors')
        .document(notificationId)
        .updateData({
      'status': 'ACCEPTED',
    });

    Firestore.instance.collection('offers').document(offerId).updateData({
      'individualOfferDataModel.isAccepted': true,
    });

    FirestoreManager.readUserNotification(notificationId, user.email);
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
