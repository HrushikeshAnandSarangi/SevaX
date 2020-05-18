import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';

Future<bool> resentInvitationLink({
  InvitationViaLink invitation,
}) async {
  await mailCodeToInvitedMember(
    mailContent:
        "You have been invited to to ${invitation.timebankTitle} timebank, you can join the same by clicking on the link ${invitation.invitationLink}.",
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
