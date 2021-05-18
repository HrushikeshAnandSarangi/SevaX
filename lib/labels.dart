import 'package:flutter/cupertino.dart';

class L {
  L.of(BuildContext context) {}

  //OFFERS LABELS STARTS HERE
  String get option_one => "Spot On";
  String get option_two => "One Time";

  String get minimum_credit_title => "Minimum Credits*";
  String get minimum_credit_hint => "Provide minimum credits you require";

  String get offer_invitation_notification_title => "Offer Invitation";
  String get offer_invitation_notification_subtitle =>
      " has invited you to accept its offer.";

  String get invitation_accepted => "Invitation Accepted";
  String get invitation_accepted_subtitle =>
      " has accepted your offer and has shared an invitation.";
  String get accept_offer_invitation_confirmation =>
      "By acceting, a task will be added to your pending tasks.";
  //OFFERS LABELS ENDS HERE
}
