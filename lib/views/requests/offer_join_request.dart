import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
    required this.timeBankId,
    required this.notificationId,
    required this.userModel,
    required this.offerId,
    required this.requestId,
    required this.timeOfferParticipantsModel,
    required this.requestStartDate,
    required this.requestEndDate,
    required this.requestTitle,
  });

  @override
  _OfferJoinRequestDialogState createState() => _OfferJoinRequestDialogState();
}

class _OfferJoinRequestDialogState extends State<OfferJoinRequestDialog> {
  _OfferJoinRequestDialogState();

  late BuildContext progressContext;

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
                widget.timeOfferParticipantsModel.participantDetails.fullname!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 70,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  widget.timeOfferParticipantsModel.participantDetails.bio ??
                      "${S.of(context).bio} ${S.of(context).name_not_updated_text}",
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
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
                  S
                      .of(context)
                      .accept_offer_invitation_confirmation_to_do_tasks,
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
                  child: CustomElevatedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    elevation: 2.0,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).accept,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      //Once approvedp
                      CommunityModel communityModel = CommunityModel({});
                      await CollectionRef.communities
                          .doc(widget.userModel.currentCommunity)
                          .get()
                          .then((value) {
                        communityModel = CommunityModel(
                            value.data() as Map<String, dynamic>);
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

                      approveInvitationForVolunteerRequest(
                          allowedCalender: false,
                          offerId: widget.offerId,
                          requestId: widget.requestId,
                          notificationId: widget.notificationId,
                          user: widget.userModel,
                          acceptorModel: acceptorModel);

                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Container(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    elevation: 2.0,
                    textColor: Colors.white,
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
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

  void declineInvitationbRequest({
    String? notificationId,
    UserModel? userModel,
    String? requestId,
    String? offerId,
  }) {
    rejectInviteRequestForOffer(
      requestId: requestId!,
      rejectedUserId: userModel!.sevaUserID!,
      notificationId: notificationId!,
    );

    CollectionRef.offers
        .doc(offerId)
        .collection('offerAcceptors')
        .doc(notificationId)
        .update({
      'status': 'REJECTED',
    });
    FirestoreManager.readUserNotification(notificationId, userModel.email!);
  }

  void approveInvitationForVolunteerRequest({
    required String requestId,
    required String offerId,
    required String notificationId,
    required UserModel user,
    required bool allowedCalender,
    required AcceptorModel acceptorModel,
  }) {
    acceptOfferInvite(
      requestId: requestId,
      acceptedUserEmail: user.email!,
      acceptedUserId: user.sevaUserID!,
      notificationId: notificationId,
      allowedCalender: allowedCalender,
      acceptorModel: acceptorModel,
    );
    //Update accetor document
    CollectionRef.offers
        .doc(offerId)
        .collection('offerAcceptors')
        .doc(notificationId)
        .update({
      'status': 'ACCEPTED',
    });

    CollectionRef.offers.doc(offerId).update({
      'individualOfferDataModel.isAccepted': true,
    });

    FirestoreManager.readUserNotification(notificationId, user.email!);
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
