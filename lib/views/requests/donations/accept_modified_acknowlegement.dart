import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class HandleModifiedAcknowlegementForDonationBuilder {
  late String timeBankId;
  late String notificationId;
  late RequestMode requestMode;
  late String userId;
  late String communityId;
  late BuildContext parentContext;

  late String entityTitle;
  late String entityImageURL;
  late String requestTitle;
  late String donationAmount;
  late String creatorSevaUserId;
  late String description;

  late String donationId;
  late String donorEmail;
}

class HandleModifiedAcknowlegementForDonation extends StatelessWidget {
  final HandleModifiedAcknowlegementForDonationBuilder builder;

  HandleModifiedAcknowlegementForDonation({
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HandlerForModificationManager.getCloseButton(context),
              Container(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    builder.entityImageURL,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  builder.entityTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  builder.requestTitle,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  builder.description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(S.of(context).accept_modified_amount_finalized,
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
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).acknowledge,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Europa',
                        ),
                      ),
                      onPressed: () async {
                        //update status of donation
                        await HandlerForModificationManager
                            .acknowledeModificationInDonation(
                          donationId: builder.donationId,
                          donorEmail: builder.donorEmail,
                          notificationId: builder.notificationId,
                        ).then((_) {
                          HandlerForModificationManager.handleSuuccess();
                        }).catchError((e) {
                          HandlerForModificationManager.handleFailure(e);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CustomElevatedButton(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).message,
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        // donation declined
                        await HandlerForModificationManager.createChat(
                          context: context,
                          notificationId: builder.notificationId,
                          userId: builder.userId,
                          creatorSevaUserId: builder.creatorSevaUserId,
                          parentContext: builder.parentContext,
                          requestMode: builder.requestMode,
                          timeBankId: builder.timeBankId,
                          loggedInUser: SevaCore.of(context).loggedInUser,
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

class HandlerForModificationManager {
  static Widget getCloseButton(BuildContext context) {
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

  static Function handleSuuccess = () {};

  static Function handleFailure = (e) {};

  static Future<bool> acknowledeModificationInDonation({
    String? donorEmail,
    String? notificationId,
    String? donationId,
  }) async {
    return await _getBatchForUpdates(
      donationId: donationId,
      donorEmail: donorEmail,
      notificationId: notificationId,
    ).commit().then((value) => true).catchError((onError) => false);
  }

  static WriteBatch _getBatchForUpdates({
    String? donorEmail,
    String? notificationId,
    String? donationId,
  }) {
    ///This notification is always directed towards member
    /// as member can only donate as of now

    var batch = CollectionRef.batch;
    batch.update(
        CollectionRef.users
            .doc(donorEmail)
            .collection('notifications')
            .doc(notificationId),
        {'isRead': true});

    batch.update(CollectionRef.donations.doc(donationId),
        {'donationStatus': 'MEMBER_ACKNOWLEDGED_MODIFICATION'});

    return batch;
  }

  static Future createChat({
    required String userId,
    required String creatorSevaUserId,
    required BuildContext context,
    required String notificationId,
    required String timeBankId,
    required RequestMode requestMode,
    required BuildContext parentContext,
    required UserModel loggedInUser,
  }) async {
    ParticipantInfo sender, reciever;

    switch (requestMode) {
      case RequestMode.PERSONAL_REQUEST:
        UserModel fundRaiserDetails =
            await FirestoreManager.getUserForId(sevaUserId: creatorSevaUserId);

        reciever = ParticipantInfo(
          id: fundRaiserDetails.sevaUserID,
          name: fundRaiserDetails.fullname,
          photoUrl: fundRaiserDetails.photoURL,
          type: ChatType.TYPE_PERSONAL,
        );
        break;

      case RequestMode.TIMEBANK_REQUEST:
        TimebankModel? timebankModel =
            await getTimeBankForId(timebankId: timeBankId);

        if (timebankModel == null) {
          throw Exception('Timebank not found for id: $timeBankId');
        }

        reciever = ParticipantInfo(
          id: timebankModel.id,
          type: timebankModel.parentTimebankId ==
                  FlavorConfig
                      .values.timebankId //check if timebank is primary timebank
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
          name: timebankModel.name,
          photoUrl: timebankModel.photoUrl,
        );
        break;
    }

    sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      name: loggedInUser.fullname,
      photoUrl: loggedInUser.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    createAndOpenChat(
      isTimebankMessage: requestMode == RequestMode.TIMEBANK_REQUEST,
      context: parentContext,
      timebankId: timeBankId,
      communityId: loggedInUser.currentCommunity ?? '',
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: false,
      feedId: '', // Provide appropriate value if available
      showToCommunities: const [], // Provide appropriate value if available
      entityId: '', // Provide appropriate value if available
      onChatCreate: () {
        Navigator.pop(context);
      },
    );
  }

  static Future createChatForDispute({
    required ParticipantInfo sender,
    required ParticipantInfo receiver,
    required BuildContext context,
    required String timeBankId,
    required bool isTimebankMessage,
    required String communityId,
    required bool interCommunity,
    required List<String> showToCommunities,
    required String entityId,
  }) async {
    logger.i(showToCommunities);
    createAndOpenChat(
      isTimebankMessage: isTimebankMessage,
      context: context,
      timebankId: timeBankId,
      communityId: communityId,
      sender: sender,
      reciever: receiver,
      isFromRejectCompletion: false,
      interCommunity: interCommunity,
      showToCommunities: showToCommunities,
      entityId: entityId,
      feedId: '', // Provide appropriate value if available
      onChatCreate: () {
        Navigator.pop(context);
      },
    );
  }
}
