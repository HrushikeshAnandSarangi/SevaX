import 'package:flutter/cupertino.dart';

class L {
  L.of(BuildContext context) {}
  //OFFERS LABELS STARTS HERE
  // NOTIFICATIONS
  String get invitation_accepted =>
      "Invitation Accepted."; //done in mobile codebase
  String get invitation_accepted_subtitle =>
      " has accepted your offer and has shared an invitation."; //done in mobile codebase

  String get offer_invitation_notification_title =>
      "Offer Invitation"; //done in mobile codebase

  String get offer_invitation_notification_subtitle => //done in mobile codebase
      " has invited you to accept an offer.";
  String get accept_offer_invitation_confirmation => //done in mobile codebase
      "This task will be added to your Pending Tasks, after you approve it.";
  String
      get entered_credits_less_than_minimum_credits => //done in mobile codebase
          "Entered credits should be greater than minimum credits";
  String get option_one => "Spot On"; //done in mobile codebase
  String get option_two => "One Time"; //done in mobile codebase
  String get minimum_credit_title =>
      "Minimum Credits*"; //done in mobile codebase
  String get minimum_credit_hint =>
      "Provide minimum credits you require"; //done in mobile codebase

  //Time Offer New labels
  String get minimum_credits_offer =>
      "This offer does not meet your minimum credit requirement.";
  String get minimum_credits_hint =>
      "Please provide the minimum credits you require to accept this offer.";

  //OFFERS LABELS ENDS HERE
  String get borrow_request_title => "Borrow Request"; //done in mobile codebase
  String get registration_link => "Registration Link"; //done in mobile codebase
  String get registration_link_hint =>
      "Ex: Eventbrite link, etc."; //done in mobile codebase
  String get request_closed => "Request closed"; //done in mobile codebase
  String get speaker_claim_credits => 'Claim credits'; //done in mobile codebase
  String get requested_for_completion =>
      "Your completed request is pending approval."; //done in mobile codebase
  String get this_request_has_now_ended => "This request has now ended";
  String get maximum_no_of_participants_reached => //done in mobile codebase
      "Maximum number of participants reached";
  String get reject_request_completion => //done in mobile codebase
      "Are you sure you want to reject this request for completion?";

  //Started Migrating below on 2nd June 3:55PM
  String get join_community_alert => //already in json
      "This action is only available to members of Community **CommunityName. Please request to join the community first before you can perform this action.";
  String get switch_community => //done in mobile codebase //already in json
      "You need to switch Seva Communities in order to access Groups in another Community.";
  String get sign_in_alert =>
      "You need to sign in or register to view this."; //done in mobile codebase //already in json
  String get explore_page_subtitle_text => //done in mobile codebase //already in json
      "Find communities near you or online communities that interest you. You can offer to volunteer your services or request any assistance or search for Community Events.";

  String get no_groups_text =>
      "You are currently not part of any groups. You can either join one or create a new group.";
  String get explore_page_title_text =>
      "Explore Opportunities"; //done in mobile codebase
  String get select_speaker_hint =>
      "Ex: Name of speaker."; //done in mobile codebase

  String get my_groups => "My Groups"; //done in mobile codebase
  String get speaker_reject_invite_dialog => //done in mobile codebase
      "Are you sure you want to reject this invitation to speak?";
  String get onetomanyrequest_create_new_event => //done in mobile codebase
      "A new event will be created and linked to this request.";
  String get speaker_requested_completion_notification =>
      "This request has been completed."; //done in mobile codebase
  String get request_completed_by_speaker =>
      "This request has been completed and is awaiting your approval."; //done in mobile codebase
  String get speaker => 'Speaker'; //done in mobile codebase

  String get speaker_completion_rejected_notification_1 => "Request rejected.";
  String get speaker_completion_rejected_notification_2 =>
      "Request rejected by **creatorName"; //to be confirmed
  String get you_are_the_speaker => "You are the speaker for: ";
  String get select_a_speaker => "Please select a Speaker*";
  String get selected_speaker => "Selected Speaker";
  String get speaker_accepted_invite_notification =>
      "This request has been accepted by speaker_name.";
  String get oneToManyRequestSpeakerAcceptRequest =>
      'Are you sure you want to accept this request?';
  String get resetPasswordSuccess =>
      'An email has been sent. Please follow the steps in the email to reset your password.';
  String get bundlePricingInfoButton =>
      'There is a limit to the number of transactions in the free tier. You will be charged \$2 for a bundle of 50 transactions.';
  String get maximumNoOfParticipants =>
      'This request has a maximum number of participants. That limit has been reached.';
  String get insufficientSevaCreditsDialog =>
      'You do not have sufficient Seva credits to create this request. You need to have *** more Seva credits';
  String get adminNotificationInsufficientCredits =>
      ' Has Insufficient Credits To Create Requests';
  String get adminNotificationInsufficientCreditsNeeded => 'Credits Needed: ';
  String get oneToManyRequestSpeakerWithdrawDialog =>
      'Please confirm that you would like to withdraw as a speaker';
  String get speakerRejectedNotificationLabel =>
      ' rejected the Speaker invitation for ';
  String get speaker_rejected => 'Speaker Rejected';
  String get people_applied_for_request =>
      ' people have applied for this request';
  String get oneToManyRequestCreatorCompletingRequestDialog =>
      'Are you sure you want to accept and complete this request?';
  String get duration_of_session => 'Duration of Session: ';
  String get time_to_prepare => 'Time to prepare: ';
  String get hours => 'hours';
  String get speaker_complete_page_text_1 =>
      'I acknowledge that speaker_name has completed the request. The list of members provided above attended the request.';
  String get speaker_complete_page_text_2 =>
      'Note: The hours will be credited to the speaker and to the attendees upon your approval. This list of attendees cannot be modified after approval.';
  String get action_restricted_by_owner =>
      'This action is Restricted for you by the owner of the seva Community.';
  String get select_a_speaker_dialog => 'Select a Speaker';
  String get accepted_this_request => 'You have accepted this request.';
  String get in_label => 'in';
  String get onetomanyrequest_member_invite_notif_subtitle =>
      'admin_name in community_name has invited you to join the webinar_name on date_webinar at time_webinar. Tap to accept the invitation.';

  String get onetomanyrequest_title_hint => "Ex: Implicit Bias webinar.";
  String get onetomanyrequest_participants_or_credits_hint => "Ex: 40.";
  String get speaker_invite_notification =>
      "Added you as the Speaker for request: ";
  String get speaker_claim_form_field_title =>
      "How much prep time did you require for this request?";
  String get speaker_claim_form_field_title_hint => "Prep time in hours";
  String get speaker_claim_form_text_1 =>
      "I acknowledge that I have completed the session for the request.";
  String get speaker_claim_form_text_2 =>
      "Upon completing the one to many request, the combined prep time and session hours will be credited to you.";

//SandBox Labels
  String get sandbox_community => "Sandbox Community";
  String get sandbox_dialog_title => "Sandbox seva community";
  String get sandbox_dialog_subtitle =>
      "Sandbox Seva communities are created for instructional purposes only. Any credits earned or debited will not count towards your account.";
  String get sandbox_already_created_1 =>
      "You have already created a sandbox community.";
  String get sandbox_already_created_2 =>
      "Only one sandbox community is currently allowed for each SevaX member.";
}
