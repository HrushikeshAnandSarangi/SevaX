import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';

class InvitationManager {
  Map<String, InvitationViaLink> cacheList;
  BuildContext _context;
  BuildContext progressContext;
  BuildContext finalConfirmationContext;

  InvitationManager() {
    cacheList = HashMap();
  }

  void initDialogForProgress({BuildContext context}) {
    _context = context;
  }

  void showProgress({String title}) {
    showDialog(
      context: _context,
      builder: (context) {
        progressContext = context;
        return AlertDialog(
          title: Text(title),
          content: LinearProgressIndicator(),
        );
      },
    );
  }

  void hideProgress() {
    Navigator.of(progressContext).pop();
  }

  InvitationViaLink getInvitationForEmailFromCache({String inviteeEmail}) {
    return cacheList[inviteeEmail];
  }

  Future<InvitationStatus> checkInvitationStatus(
    String email,
    String timebankId,
  ) async {
    if (cacheList.containsKey(email)) {
      return InvitationStatus.isInvited(invitation: cacheList[email]);
    }

    var invitationStatus = await Firestore.instance
        .collection('invitations')
        .where('data.inviteeEmail', isEqualTo: email)
        .where('data.timebankId', isEqualTo: timebankId)
        .getDocuments();
    if (invitationStatus.documents.length > 0) {
      var invitationData =
          InvitationViaLink.fromMap(invitationStatus.documents.first.data);
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
    InvitationViaLink invitation,
  }) async {
    String invitationTitle = S.of(_context).invited_to_timebank_message;

    var mailContent =
        '''<p>${SevaCore.of(_context).loggedInUser.fullname} has invited you to join their "${invitation.timebankTitle}" Seva Community. Seva means "selfless service" in Sanskrit. Seva Communities are based on a mutual-reciprocity system, where community members help each other out in exchange for Seva Credits that can be redeemed for services they need. To learn more about being a part of a Seva Community, here's a short explainer video. <a href="https://youtu.be/xe56UJyQ9ws">https://youtu.be/xe56UJyQ9ws</a>   <br><br>Here is what you'll need to know: <br>First, depending on where you click the link from, whether it's your web browser or mobile phone, the link will either take you to our main <a href="https://www.sevaxapp.com">https://www.sevaxapp.com</a>   web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website, you will automatically become a member of the "${invitation.timebankTitle}" Seva Community.<br><br>Click to Join ${SevaCore.of(_context).loggedInUser.fullname} and their Seva Community via this dynamic link at <a href="${invitation.invitationLink}">${invitation.invitationLink}</a>. Please do not share this link with any one.<br><br>Thank you for being a part of our Seva Exchange movement!<br>-the Seva Exchange team<br>Please email us at support@sevaexchange.com if you have any questions or issues joining with the link given.</p>''';

    return await mailCodeToInvitedMember(
      mailContent: mailContent,
      mailReciever: invitation.inviteeEmail,
      mailSender: invitation.senderEmail,
      mailSubject: invitationTitle,
    ).then((_) => true).catchError((_) => false);
  }

  Future<bool> inviteMemberToTimebankViaLink({
    InvitationViaLink invitation,
    BuildContext context,
  }) async {
    return await createDynamicLinkFor(
      communityId: invitation.communityId,
      inviteeEmail: invitation.inviteeEmail,
      primaryTimebankId: invitation.timebankId,
    )
        .then((String invitationLink) async {
          String invitationTitle = S.of(context).invited_to_timebank_message;

          var mailContent =
              '''<p>${SevaCore.of(_context).loggedInUser.fullname} has invited you to join their "${invitation.timebankTitle}" Seva Community. Seva means "selfless service" in Sanskrit. Seva Communities are based on a mutual-reciprocity system, where community members help each other out in exchange for Seva Credits that can be redeemed for services they need. To learn more about being a part of a Seva Community, here's a short explainer video. <a href="https://youtu.be/xe56UJyQ9ws">https://youtu.be/xe56UJyQ9ws</a>   <br><br>Here is what you'll need to know: <br>First, depending on where you click the link from, whether it's your web browser or mobile phone, the link will either take you to our main <a href="https://www.sevaxapp.com">https://www.sevaxapp.com</a>   web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores, where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website, you will automatically become a member of the "${invitation.timebankTitle}" Seva Community.<br><br>Click to Join ${SevaCore.of(_context).loggedInUser.fullname} and their Seva Community via this dynamic link at <a href="${invitationLink}">${invitationLink}</a>. Please do not share this link with any one.<br><br>Thank you for being a part of our Seva Exchange movement!<br>-the Seva Exchange team<br>Please email us at support@sevaexchange.com if you have any questions or issues joining with the link given.</p>''';

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
    InvitationViaLink invitation,
  }) async {
    return await Firestore.instance
        .collection('invitations')
        .add({
          'invitationType': 'INVITATION_FOR_TIMEBANK',
          'data': invitation.toMap(),
        })
        .then((_) => true)
        .catchError((_) => false);
  }

  static Future<bool> registerMemberToCommunity({
    @required String communityId,
    @required String primaryTimebankId,
    @required String memberJoiningSevaUserId,
    @required String newMemberJoinedEmail,
  }) async {
    return await _addMemberToTimebank(
      communityId: communityId,
      primaryTimebankId: primaryTimebankId,
      memberJoiningSevaUserId: memberJoiningSevaUserId,
      newMemberJoinedEmail: newMemberJoinedEmail,
    ).commit().then((onValue) => true).catchError((onError) => false);
  }

  static WriteBatch _addMemberToTimebank({
    @required String communityId,
    @required String primaryTimebankId,
    @required String memberJoiningSevaUserId,
    @required String newMemberJoinedEmail,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var timebankRef = Firestore.instance
        .collection('timebanknew')
        .document(primaryTimebankId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(newMemberJoinedEmail);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    batch.updateData(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
      'currentCommunity': communityId,
    });

    var addToCommunityRef =
        Firestore.instance.collection('communities').document(communityId);
    batch.updateData(addToCommunityRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    return batch;
  }

  static Future<bool> mailCodeToInvitedMember({
    String mailSender,
    String mailReciever,
    String mailSubject,
    String mailContent,
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

class InvitationStatus {
  bool isInvited;
  InvitationViaLink invitation;

  InvitationStatus.notYetInvited() {
    this.isInvited = false;
  }

  InvitationStatus.isInvited({InvitationViaLink invitation}) {
    this.isInvited = true;
  }
}

//export to  a new  file
@Deprecated('Class no longer used as we now use normal flow')
class OfferInvitationManager {
  static Future<bool> handleInvitationNotificationForRequestCreatedFromOffer({
    RequestModel requestModel,
    OfferModel offerModel,
    TimebankModel timebankModel,
    String currentCommunity,
    String senderSevaUserID,
  }) async {
    //if this if from offer
    if (offerModel == null) return true;
    switch (offerModel.type) {
      case RequestType.CASH:
      case RequestType.GOODS:
        return await createNotificaitonForInvitee(
          requestModel: requestModel,
          offerModel: offerModel,
          timebankModel: timebankModel,
          currentCommunity: currentCommunity,
          senderSevaUserID: senderSevaUserID,
        ).then((value) => true).catchError((onError) => false);
        break;

      case RequestType.TIME:
        return true;

      default:
        return true;
    }
  }

  static Future<bool> createNotificaitonForInvitee({
    RequestModel requestModel,
    OfferModel offerModel,
    TimebankModel timebankModel,
    String currentCommunity,
    String senderSevaUserID,
  }) async {
    //add to invited members
    WriteBatch batchWrite = Firestore.instance.batch();
    batchWrite.updateData(
        Firestore.instance.collection('requests').document(requestModel.id), {
      'invitedUsers': FieldValue.arrayUnion([offerModel.sevaUserId])
    });

    NotificationsModel invitationNotification = getNotificationForInvitation(
      currentCommunity: currentCommunity,
      senderSevaUserID: senderSevaUserID,
      inviteeSevaUserId: offerModel.sevaUserId,
      requestModel: requestModel,
      timebankModel: timebankModel,
    );
    batchWrite.setData(
      Firestore.instance
          .collection('users')
          .document(offerModel.email)
          .collection('notifications')
          .document(invitationNotification.id),
      invitationNotification.toMap(),
    );

    return await batchWrite
        .commit()
        .then((value) => true)
        .catchError((onError) => false);
  }

  static NotificationsModel getNotificationForInvitation({
    String inviteeSevaUserId,
    RequestModel requestModel,
    String currentCommunity,
    String senderSevaUserID,
    TimebankModel timebankModel,
  }) {
    return NotificationsModel(
      id: utils.Utils.getUuid(),
      timebankId: timebankModel.id,
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
