import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

class InvitationManager {
  Map<String, InvitationViaLink> cacheList = HashMap();
  BuildContext? _context;
  BuildContext? progressContext;
  BuildContext? finalConfirmationContext;

  InvitationManager();

  void initDialogForProgress({BuildContext? context}) {
    _context = context;
  }

  void showProgress({String? title}) {
    showDialog(
      context: _context!,
      builder: (context) {
        progressContext = context;
        return AlertDialog(
          title: Text(title ?? ''),
          content: LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }

  void hideProgress() {
    Navigator.of(progressContext!).pop();
  }

  InvitationViaLink getInvitationForEmailFromCache({String? inviteeEmail}) {
    return cacheList[inviteeEmail] ?? InvitationViaLink.empty();
  }

  Future<InvitationStatus> checkInvitationStatus(
    String email,
    String timebankId,
  ) async {
    if (cacheList.containsKey(email)) {
      return InvitationStatus.isInvited(invitation: cacheList[email]!);
    }

    var invitationStatus = await CollectionRef.invitations
        .where('data.inviteeEmail', isEqualTo: email)
        .where('data.timebankId', isEqualTo: timebankId)
        .get();
    if (invitationStatus.docs.length > 0) {
      var invitationData = InvitationViaLink.fromMap(
          invitationStatus.docs.first.data() as Map<String, dynamic>);
      cacheList[email] = invitationData;
      return InvitationStatus.isInvited(invitation: invitationData);
    } else {
      return InvitationStatus.notYetInvited();
    }
  }

  void dispose() {
    cacheList.clear();
  }

  Future<bool> resendInvitationToMember({
    InvitationViaLink? invitation,
  }) async {
    String invitationTitle = S.of(_context!).invited_to_timebank_message;

    var mailContent =
        '''<p>${SevaCore.of(_context!).loggedInUser.fullname} has invited you to join their "${invitation!.timebankTitle}" Seva Community. Seva means "selfless service" in Sanskrit. Seva Communities are based on a mutual-reciprocity system, where community members help each other out in exchange for Seva Credits that can be redeemed for services they need. To learn more about being a part of a Seva Community, here's a short explainer video. <a href="https://youtu.be/xe56UJyQ9ws">https://youtu.be/xe56UJyQ9ws</a>   <br><br>Here is what you'll need to know: <br>First, depending on where you click the link from, whether it's your web browser or mobile phone, the link will either take you to our main <a href="https://www.sevaxapp.com">https://www.sevaxapp.com</a>   web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website, you will automatically become a member of the "${invitation.timebankTitle}" Seva Community.<br><br>Click to Join ${SevaCore.of(_context!).loggedInUser.fullname} and their Seva Community via this dynamic link at <a href="${invitation.invitationLink}">${invitation.invitationLink}</a>. Please do not share this link with any one.<br><br>Thank you for being a part of our Seva Exchange movement!<br>-the Seva Exchange team<br>Please email us at support@sevaexchange.com if you have any questions or issues joining with the link given.</p>''';

    return await mailCodeToInvitedMember(
      mailContent: mailContent,
      mailReciever: invitation!.inviteeEmail,
      mailSender: invitation.senderEmail,
      mailSubject: invitationTitle,
    ).then((_) => true).catchError((_) => false);
  }

  Future<bool> inviteMemberToTimebankViaLink({
    InvitationViaLink? invitation,
    BuildContext? context,
  }) async {
    return await createDynamicLinkFor(
      communityId: invitation!.communityId,
      inviteeEmail: invitation.inviteeEmail,
      primaryTimebankId: invitation.timebankId,
    )
        .then((String invitationLink) async {
          String invitationTitle = S.of(context!).invited_to_timebank_message;

          var mailContent =
              '''<p>${SevaCore.of(_context!).loggedInUser.fullname} has invited you to join their "${invitation.timebankTitle}" Seva Community. Seva means "selfless service" in Sanskrit. Seva Communities are based on a mutual-reciprocity system, where community members help each other out in exchange for Seva Credits that can be redeemed for services they need. To learn more about being a part of a Seva Community, here's a short explainer video. <a href="https://youtu.be/xe56UJyQ9ws">https://youtu.be/xe56UJyQ9ws</a>   <br><br>Here is what you'll need to know: <br>First, depending on where you click the link from, whether it's your web browser or mobile phone, the link will either take you to our main <a href="https://www.sevaxapp.com">https://www.sevaxapp.com</a>   web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website, you will automatically become a member of the "${invitation.timebankTitle}" Seva Community.<br><br>Click to Join ${SevaCore.of(_context!).loggedInUser.fullname} and their Seva Community via this dynamic link at <a href="${invitationLink}">${invitationLink}</a>. Please do not share this link with any one.<br><br>Thank you for being a part of our Seva Exchange movement!<br>-the Seva Exchange team<br>Please email us at support@sevaexchange.com if you have any questions or issues joining with the link given.</p>''';

          invitation.setInvitationLink(invitationLink);
          await mailCodeToInvitedMember(
            mailContent: mailContent,
            mailReciever: invitation.inviteeEmail,
            mailSender: invitation.senderEmail,
            mailSubject: invitationTitle,
          );
        })
        .then(
          (_) => registerRecordInDatabase(
            invitation: invitation,
          ),
        )
        .then((_) => true)
        .catchError((_) => false);
  }

  Future<bool> registerRecordInDatabase({
    InvitationViaLink? invitation,
  }) async {
    return await CollectionRef.invitations
        .add({
          'invitationType': 'INVITATION_FOR_TIMEBANK',
          'data': invitation!.toMap(),
        })
        .then((_) => true)
        .catchError((_) => false);
  }

  static Future<bool> registerMemberToCommunity({
    required String communityId,
    required String primaryTimebankId,
    required String memberJoiningSevaUserId,
    required String newMemberJoinedEmail,
    required User adminCredentials,
    required String newMemberFullName,
    required String newMemberPhotoUrl,
  }) async {
    return await _addMemberToTimebank(
      communityId: communityId,
      primaryTimebankId: primaryTimebankId,
      memberJoiningSevaUserId: memberJoiningSevaUserId,
      newMemberJoinedEmail: newMemberJoinedEmail,
      adminCredentials: adminCredentials,
      newMemberFullName: newMemberFullName,
      newMemberPhotoUrl: newMemberPhotoUrl,
    ).then((batch) {
      return batch
          .commit()
          .then((onValue) => true)
          .catchError((onError) => false);
    });
  }

  static Future<WriteBatch> _addMemberToTimebank(
      {required String communityId,
      required String primaryTimebankId,
      required String memberJoiningSevaUserId,
      required String newMemberJoinedEmail,
      required User adminCredentials,
      required String newMemberFullName,
      required String newMemberPhotoUrl}) async {
    //add to timebank members

    // log('CHECK DATA: ' + timebankModel.name + ' ' + timebankModel.id);

    WriteBatch batch = CollectionRef.batch;
    var timebankRef = CollectionRef.timebank.doc(primaryTimebankId);

    var newMemberDocumentReference =
        CollectionRef.users.doc(newMemberJoinedEmail);

    batch.update(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    batch.update(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
      'currentCommunity': communityId,
    });

    var addToCommunityRef = CollectionRef.communities.doc(communityId);
    batch.update(addToCommunityRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    var entryExitLogReference = CollectionRef.timebank
        .doc(primaryTimebankId)
        .collection('entryExitLogs')
        .doc();

    var timebankDetals =
        await utils.getTimeBankForId(timebankId: primaryTimebankId);

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.JOINED_VIA_LINK.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup': false,
      'memberDetails': {
        'email': newMemberJoinedEmail,
        'id': memberJoiningSevaUserId,
        'fullName': newMemberFullName,
        'photoUrl': newMemberPhotoUrl,
      },
      'adminDetails': {
        'email': adminCredentials.email,
        'id': adminCredentials.uid,
        'fullName': adminCredentials.displayName,
        'photoUrl': adminCredentials.photoURL,
      },
      'associatedTimebankDetails': {
        //Need to check if timebankModel data is correct or null
        'timebankId': primaryTimebankId,
        'timebankTitle': timebankDetals!.name,
        'missionStatement': timebankDetals.missionStatement,
      }
    });

    return batch;
  }

  static Future<bool> mailCodeToInvitedMember({
    String? mailSender,
    String? mailReciever,
    String? mailSubject,
    String? mailContent,
  }) async {
    return SevaMailer.createAndSendEmail(
      mailContent: MailContent.createMail(
        mailSender: mailSender,
        mailReciever: mailReciever,
        mailContent: mailContent,
        mailSubject: mailSubject,
      ),
    );
  }
}

class InvitationViaLink {
  InvitationViaLink({
    this.communityId,
    this.inviteeEmail,
    this.primaryTimebankId,
    this.senderEmail,
    this.timebankId,
    this.timebankTitle,
    this.invitationLink,
  });

  String? communityId;
  String? inviteeEmail;
  String? primaryTimebankId;
  String? senderEmail;
  String? timebankId;
  String? timebankTitle;
  String? invitationLink;

  factory InvitationViaLink.empty() {
    return InvitationViaLink();
  }

  static InvitationViaLink fromMap(Map<String, dynamic> map) {
    return InvitationViaLink(
      communityId: map['data']['communityId'],
      inviteeEmail: map['data']['inviteeEmail'],
      primaryTimebankId: map['data']['primaryTimebankId'],
      senderEmail: map['data']['senderEmail'],
      timebankId: map['data']['timebankId'],
      timebankTitle: map['data']['timebankTitle'],
      invitationLink: map['data']['invitationLink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'inviteeEmail': inviteeEmail,
      'primaryTimebankId': primaryTimebankId,
      'senderEmail': senderEmail,
      'timebankId': timebankId,
      'timebankTitle': timebankTitle,
      'invitationLink': invitationLink,
    };
  }

  void setInvitationLink(String invitationLink) {
    this.invitationLink = invitationLink;
  }
}

class InvitationStatus {
  final bool isInvited;
  final InvitationViaLink invitation;

  InvitationStatus.notYetInvited()
      : isInvited = false,
        invitation = InvitationViaLink.empty();

  InvitationStatus.isInvited({required InvitationViaLink invitation})
      : isInvited = true,
        invitation = invitation;
}

//export to  a new  file
@Deprecated('Class no longer used as we now use normal flow')
class OfferInvitationManager {
  static Future<bool> handleInvitationNotificationForRequestCreatedFromOffer({
    RequestModel? requestModel,
    OfferModel? offerModel,
    TimebankModel? timebankModel,
    String? currentCommunity,
    String? senderSevaUserID,
  }) async {
    //if this if from offer
    if (offerModel == null) return true;
    switch (offerModel.type) {
      case RequestType.CASH:
      case RequestType.GOODS:
        return await createNotificaitonForInvitee(
          requestModel: requestModel!,
          offerModel: offerModel,
          timebankModel: timebankModel!,
          currentCommunity: currentCommunity!,
          senderSevaUserID: senderSevaUserID!,
        ).then((value) => true).catchError((onError) => false);
        break;

      case RequestType.TIME:
        return true;

      default:
        return true;
    }
  }

  static Future<bool> createNotificaitonForInvitee({
    RequestModel? requestModel,
    OfferModel? offerModel,
    TimebankModel? timebankModel,
    String? currentCommunity,
    String? senderSevaUserID,
  }) async {
    //add to invited members
    WriteBatch batchWrite = CollectionRef.batch;
    batchWrite.update(CollectionRef.requests.doc(requestModel!.id), {
      'invitedUsers': FieldValue.arrayUnion([offerModel!.sevaUserId])
    });

    NotificationsModel invitationNotification = getNotificationForInvitation(
      currentCommunity: currentCommunity!,
      senderSevaUserID: senderSevaUserID!,
      inviteeSevaUserId: offerModel.sevaUserId!,
      requestModel: requestModel,
      timebankModel: timebankModel!,
    );
    batchWrite.set(
      CollectionRef.users
          .doc(offerModel.email)
          .collection('notifications')
          .doc(invitationNotification.id),
      invitationNotification.toMap(),
    );

    return await batchWrite
        .commit()
        .then((value) => true)
        .catchError((onError) => false);
  }

  static NotificationsModel getNotificationForInvitation({
    String? inviteeSevaUserId,
    RequestModel? requestModel,
    String? currentCommunity,
    String? senderSevaUserID,
    TimebankModel? timebankModel,
  }) {
    return NotificationsModel(
      id: utils.Utils.getUuid(),
      timebankId: timebankModel!.id,
      data: RequestInvitationModel(
        requestModel: requestModel,
        timebankModel: timebankModel,
      ).toMap(),
      isRead: false,
      type: NotificationType.RequestInvite,
      communityId: currentCommunity,
      senderUserId: senderSevaUserID,
      targetUserId: inviteeSevaUserId,
    );
  }
}
