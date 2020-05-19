import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';

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
    print("from database----------------------");

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
    return await mailCodeToInvitedMember(
      mailContent:
          "You have been invited again to ${invitation.timebankTitle} timebank, you can join the same by clicking on the link ${invitation.invitationLink}.",
      mailReciever: invitation.inviteeEmail,
      mailSender: invitation.senderEmail,
      mailSubject: "Awesome!, You've recieved an invitation.",
    ).then((_) => true).catchError((_) => false);
  }

  Future<bool> inviteMemberToTimebankViaLink({
    InvitationViaLink invitation,
  }) async {
    return await createDynamicLinkFor(
      communityId: invitation.communityId,
      inviteeEmail: invitation.inviteeEmail,
    )
        .then((String invitationLink) async {
          invitation.setInvitationLink(invitationLink);
          await mailCodeToInvitedMember(
            mailContent:
                "You have been invited to to ${invitation.timebankTitle} timebank, you can join the same by clicking on the link $invitationLink.",
            mailReciever: invitation.inviteeEmail,
            mailSender: invitation.senderEmail,
            mailSubject: "Awesome!, You've recieved an invitation.",
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
    print(
        "________________________________________registerRecordInDatabase _ started");
    return await Firestore.instance
        .collection('invitations')
        .add({
          'invitationType': 'INVITATION_FOR_TIMEBANK',
          'data': invitation.toMap(),
        })
        .then((_) => true)
        .catchError((_) => false);
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
