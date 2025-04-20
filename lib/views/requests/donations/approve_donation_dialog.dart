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
  final OfferModel offerModel; // Fixed variable name (was offermodel)
  final BuildContext parentContext;
  final VoidCallback? onTap; // Made nullable with ?

  const ApproveDonationDialog({
    // Added const constructor
    Key? key, // Added key parameter
    required this.donationApproveModel,
    required this.timeBankId,
    required this.notificationId,
    required this.userId,
    required this.requestModel,
    required this.offerModel, // Fixed variable name
    required this.parentContext,
    required this.onTap,
  }) : super(key: key); // Added super with key

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            // Added const
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
              const Padding(
                // Added const
                padding: EdgeInsets.all(4.0),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0), // Added const
                child: Text(
                  donationApproveModel.donorName ?? S.of(context).anonymous,
                  style: const TextStyle(
                    // Added const
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10), // Added const
                child: Text(
                  donationApproveModel.requestTitle ??
                      S.of(context).request_title,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Added const
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
                    style: const TextStyle(
                      // Added const
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center),
              ),
              const Padding(
                // Added const
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0), // Added const
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).acknowledge,
                        style: const TextStyle(
                            // Added const
                            color: Colors.white,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        //donation approved
                        onTap
                            ?.call(); // Use safe call with ?. since onTap is nullable
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Changed accentColor to colorScheme.secondary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0), // Added const
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).message,
                        style: const TextStyle(
                            // Added const
                            color: Colors.white,
                            fontFamily: 'Europa'),
                      ),
                      onPressed: () async {
                        // donation declined
                        await createChat(
                          context: context,
                          requestModel: requestModel,
                          offerModel: offerModel, // Fixed variable name
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
    required DonationApproveModel model, // Added required
    required String notificationId, // Added required
  }) {
    FirestoreManager.readUserNotification(
        notificationId, donationApproveModel.donorEmail ?? '');
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Added const
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            // Added const
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

  Future<void> createChat({
    // Added return type <void>
    RequestModel? requestModel, // Made nullable with ?
    OfferModel? offerModel, // Fixed variable name and made nullable with ?
    required String userId, // Added required
    required BuildContext context, // Added required
    required String notificationId, // Added required
  }) async {
    var timeBankId = requestModel != null
        ? requestModel.timebankId
        : offerModel != null
            ? offerModel.timebankId
            : '';
    var userid = requestModel != null
        ? requestModel.sevaUserId
        : offerModel != null
            ? offerModel.sevaUserId
            : '';
    TimebankModel? timebankModel =
        await getTimeBankForId(timebankId: timeBankId ?? '');
    UserModel user = await FirestoreManager.getUserForId(sevaUserId: userId);
    UserModel loggedInUser =
        await FirestoreManager.getUserForId(sevaUserId: userid ?? '');
    ParticipantInfo? sender, reciever; // Made nullable with ?

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
            id: timebankModel!.id,
            type: timebankModel.parentTimebankId ==
                    FlavorConfig.values
                        .timebankId //check if timebank is primary timebank
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
            name: timebankModel.name,
            photoUrl: timebankModel.photoUrl,
          );
          break;
        default: // Added default case
          sender = null;
          break;
      }
    } else if (offerModel != null) {
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
      String? communityId1 = requestModel != null // Made nullable with ?
          ? requestModel.communityId
          : offerModel != null
              ? offerModel.communityId
              : null;

      String? communityId2; // Made nullable with ?
      if (requestModel != null) {
        communityId2 = requestModel.participantDetails != null &&
                requestModel.participantDetails?[user.email] != null
            ? requestModel.participantDetails?[user.email]?['communityId']
            : null;
      } else if (offerModel != null) {
        communityId2 = offerModel.participantDetails != null &&
                offerModel.participantDetails?[user.sevaUserID] != null
            ? offerModel.participantDetails?[user.sevaUserID]?['communityId']
            : null;
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

    if (sender != null) {
      // Added null check
      await createAndOpenChat(
        // Added await
        isTimebankMessage: offerModel != null // Fixed variable name
            ? false
            : requestModel != null
                ? requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
                : false,
        context: parentContext,
        timebankId: timeBankId ?? '',
        showToCommunities:
            showToCommunities.isNotEmpty ? showToCommunities : [],
        interCommunity: showToCommunities.isNotEmpty,
        communityId: loggedInUser.currentCommunity ?? '',
        sender: sender,
        reciever: reciever!, // Non-null assertion since it's initialized above
        isFromRejectCompletion: false,
        feedId: requestModel?.id ?? offerModel?.id ?? '', // Provide feedId
        entityId: requestModel?.id ?? offerModel?.id ?? '', // Provide entityId
        onChatCreate: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
