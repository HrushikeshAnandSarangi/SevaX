import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ApproveDonationDialog extends StatelessWidget {
  final DonationApproveModel donationApproveModel;
  final String timeBankId;
  final String notificationId;
  final String userId;
  final RequestModel requestModel;
  final OfferModel offermodel;
  final BuildContext parentContext;
  final VoidCallback onTap;

  ApproveDonationDialog({
    this.donationApproveModel,
    this.timeBankId,
    this.notificationId,
    this.userId,
    this.requestModel,
    this.offermodel,
    this.parentContext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getCloseButton(context),
              Container(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      donationApproveModel.donorPhotoUrl ??
                          defaultUserImageURL),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  donationApproveModel.donorName ?? S.of(context).anonymous,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  donationApproveModel.requestTitle ??
                      S.of(context).request_title,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  donationApproveModel.donationDetails ??
                      S.of(context).request_description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                    "${S.of(context).by_accepting} ${donationApproveModel.donorName}  ${S.of(context).will_added_to_donors}",
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
                      color:Theme.of(context).primaryColor,
                      child: Text(
                        S.of(context).acknowledge,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //donation approved
                        onTap?.call();
                      },
                    ),
                  ),
//                  Padding(
//                    padding: EdgeInsets.all(4.0),
//                  ),
//                  Container(
//                    width: double.infinity,
//                    child: CustomElevatedButton(
//                      color:Theme.of(context).primaryColor,
//                      child: Text(
//                        S.of(context).modify,
//                        style: TextStyle(
//                            color: Colors.white, fontFamily: 'Europa'),
//                      ),
//                      onPressed: () async {
//                        //donation approved
//                        // update donation status
//                        Navigator.of(context).pop();
//                      },
//                    ),
//                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Container(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        S.of(context).message,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        // donation declined
                        createChat(
                          context: context,
                          requestModel: requestModel,
                          offerModel: offermodel,
                          notificationId: notificationId,
                          userId: userId,
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

  void acknowledgeDonation({
    DonationApproveModel model,
    String notificationId,
  }) {
    FirestoreManager.readUserNotification(
        notificationId, donationApproveModel.donorEmail);
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

  Future createChat({
    RequestModel requestModel,
    OfferModel offerModel,
    String userId,
    BuildContext context,
    String notificationId,
  }) async {
    var timeBankId = requestModel != null
        ? requestModel.timebankId
        : offermodel != null
            ? offermodel.timebankId
            : '';
    var userid = requestModel != null
        ? requestModel.sevaUserId
        : offermodel != null
            ? offermodel.sevaUserId
            : '';
    TimebankModel timebankModel =
        await getTimeBankForId(timebankId: timeBankId);
    UserModel user = await FirestoreManager.getUserForId(sevaUserId: userId);
    UserModel loggedInUser =
        await FirestoreManager.getUserForId(sevaUserId: userid);
    ParticipantInfo sender, reciever;
    if (requestModel != null) {
      switch (requestModel.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          sender = ParticipantInfo(
            id: loggedInUser.sevaUserID,
            name: loggedInUser.fullname,
            photoUrl: loggedInUser.photoURL,
            type: ChatType.TYPE_PERSONAL,
          );
          break;

        case RequestMode.TIMEBANK_REQUEST:
          sender = ParticipantInfo(
            id: timebankModel.id,
            type: timebankModel.parentTimebankId ==
                    FlavorConfig.values
                        .timebankId //check if timebank is primary timebank
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
            name: timebankModel.name,
            photoUrl: timebankModel.photoUrl,
          );
          break;
      }
    } else if (offermodel != null) {
      sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        name: loggedInUser.fullname,
        photoUrl: loggedInUser.photoURL,
        type: ChatType.TYPE_PERSONAL,
      );
    }

    reciever = ParticipantInfo(
      id: user.sevaUserID,
      name: user.fullname,
      photoUrl: user.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    List<String> showToCommunities = [];

    try {
      String communityId1 = requestModel != null
          ? requestModel.communityId
          : offerModel != null
              ? offerModel.communityId
              : null;

      String communityId2;
      if (requestModel != null) {
        communityId2 =
            requestModel.participantDetails[user.email]['communityId'];
      } else if (offerModel != null) {
        communityId2 =
            offerModel.participantDetails[user.sevaUserID]['communityId'];
      } else {
        communityId2 = null;
      }

      if (communityId1 != null &&
          communityId2 != null &&
          communityId1.isNotEmpty &&
          communityId2.isNotEmpty &&
          communityId1 != communityId2) {
        showToCommunities = [communityId1, communityId2];
      }
    } catch (e) {
      logger.e(e);
    }

    createAndOpenChat(
      isTimebankMessage: offermodel != null
          ? false
          : requestModel != null
              ? requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
              : false,
      context: parentContext,
      timebankId: timeBankId,
      showToCommunities:
          showToCommunities.isNotEmpty ? showToCommunities : null,
      interCommunity: showToCommunities.isNotEmpty,
      communityId: loggedInUser.currentCommunity,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: false,
      onChatCreate: () {
        Navigator.pop(context);
      },
    );
  }

//  if (requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
//  FirestoreManager.readUserNotification(
//  notificationId, SevaCore.of(context).loggedInUser.email);
//  } else {
//  readTimeBankNotification(
//  notificationId: notificationId,
//  timebankId: requestModel.timebankId,
//  );
//  }
}
