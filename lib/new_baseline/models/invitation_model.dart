import 'dart:collection';

class InvitationViaLink {
  final String senderEmail;
  final String inviteeEmail;
  final String communityId;
  final String timebankId;
  final String timebankTitle;
  late String invitationLink;

  InvitationViaLink.createInvitation({
    required this.senderEmail,
    required this.inviteeEmail,
    required this.communityId,
    required this.timebankId,
    required this.timebankTitle,
  });

  InvitationViaLink setInvitationLink(String invitationLink) {
    this.invitationLink = invitationLink;
    return this;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapForInvitation = HashMap();
    mapForInvitation['senderEmail'] = this.senderEmail;
    mapForInvitation['inviteeEmail'] = this.inviteeEmail;
    mapForInvitation['communityId'] = this.communityId;
    mapForInvitation['timebankId'] = this.timebankId;
    mapForInvitation['timebankTitle'] = this.timebankTitle;
    mapForInvitation['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    mapForInvitation['invitationLink'] = this.invitationLink;

    return mapForInvitation;
  }

  factory InvitationViaLink.fromMap(Map<String, dynamic> data) {
    return InvitationViaLink.createInvitation(
      communityId: data['data']['communityId'],
      inviteeEmail: data['data']['inviteeEmail'],
      senderEmail: data['data']['senderEmail'],
      timebankId: data['data']['timebankId'],
      timebankTitle: data['data']['timebankTitle'],
    ).setInvitationLink(data['data']['invitationLink']);
  }
}
