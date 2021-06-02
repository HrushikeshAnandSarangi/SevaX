import 'package:flutter/cupertino.dart';

class L {
  L.of(BuildContext context) {}

  //OFFERS LABELS STARTS HERE
// NOTIFICATIONS
//

  String get invitation_accepted => "Invitation Accepted";
  String get invitation_accepted_subtitle =>
      " has accepted your offer and has shared an invitation.";

  String get offer_invitation_notification_title => "Offer Invitation";
  String get offer_invitation_notification_subtitle =>
      " has invited you to accept an offer.";

  String get accept_offer_invitation_confirmation =>
      "By accepting, a task will be added to your pending tasks.";
  String get entered_credits_less_than_minimum_credits =>
      "Entered credits should be greater than minimum credits";

  String get option_one => "Spot On";
  String get option_two => "One Time";

  String get minimum_credit_title => "Minimum Credits*";
  String get minimum_credit_hint => "Provide minimum credits you require";

  String get borrow_request_title => "Borrow Request";

  String get select_a_speaker => "Select a speaker";
  String get registration_link => "Registration Link";
  String get registration_link_hint => "Ex: Eventbrite link, etc.";
  String get request_closed => "Request closed";
  String get complete => "Complete";
  String get this_request_has_now_ended => "This request has now ended";
  String get maximum_no_of_participants_reached =>
      "Maximum number of participants reached";
  String get reject_request_completion =>
      "Are you sure you want to reject request completion?";

  //OFFERS LABELS ENDS HERE
}
