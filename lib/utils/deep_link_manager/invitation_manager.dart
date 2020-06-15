import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/helpers/mailer.dart';

class InvitationManager {
  Map<String, InvitationViaLink> cacheList;
  BuildContext _context;
  BuildContext progressContext;
  BuildContext finalConfirmationContext;

  InvitationManager() {
    cacheList = new HashMap();
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
    String invitationTitle = AppLocalizations.of(_context)
        .translate("invitations", "invitation_email_title");

    var mailContent = AppLocalizations.of(_context)
        .translate("invitations", "email_body")
        .replaceAll('***', invitation.timebankTitle);
    mailContent = mailContent.replaceAll('###', invitation.invitationLink);
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
      isFromBulkInvite: 'true',
    )
        .then((String invitationLink) async {
          String invitationTitle = AppLocalizations.of(context)
              .translate("invitations", "invitation_email_title");

          var mailContent = AppLocalizations.of(context)
              .translate("invitations", "email_body")
              .replaceAll('***', invitation.timebankTitle);

          mailContent = mailContent.replaceAll('###', invitationLink);

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
