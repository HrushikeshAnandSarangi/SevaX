import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class L {
  L.of(BuildContext context) {}

//   // <------------ PENDING START ------------>

//   String get offer => "Offer"; //it's in flavor config file so cannot add it.
//   String get minimum_credits => "Minimum Credits"; //can't find where to replace
//   String get applied_for_request =>
//       "You have accepted the request"; //cant find where to replace
//   String get nearby_settings_content => //already in arbify
//       "This indicates the distance that the user is willing to travel to complete a Request for a Seva Community or participate in an Event";
//   String get kilometer => "Kilometer"; //cant find where to replace
//   String get mile => "Mile"; //cant find where to replace
//   // <------------ PENDING END ------------>


    //new labels to be updated

// String get add_event_to_calender =>
// "Add event to calender";

// String get add_to_calender =>
// "Add to calender";

// String get do_you_want_addto_calender =>
// "Do you want to add this event to your calendar?";

// String get add_to_google_calender =>
// "Add to Google Calendar";

// String get add_to_outlook =>
// "Add to Outlook";

// String get add_to_ical =>
// "Add to ical ";

// String get calender_sync =>
// "calendar_sync";

// String get something_went_wrong =>
// "something went wrong";

// String get featured_communities =>
// "Featured communities";

// String get browse_by_category =>
// "Browse community by category";

// String get explore_searchbar_hinttext =>
// 'Try "Osaka" "Postal Code" "Location"';

// String get find =>
// "Find";

// String get any_category =>
// "any category";
// String get new_york =>
// "New york | USA";

// String get join_webinar =>
// "join webinar";

// String get pledge_goods_supplies =>
// " has pledge to donate good/supplies";
// String get credits_debited =>
// "seva credits debited";
// String get credits_credited =>
// "Seva credits Credited";

// String get credits_debited_msg =>
// "Seva Credits have been debited from your account";

// String get accepted_offer_msg =>
// "You have accepted this offer.";

// String get completed_the_request =>
// " Completed the request";

// String get deletion_request =>
//  "Deletion Request";

//  String get create_virtual_offer =>
//  "create virtual offer";
//  String get create_public_offer =>
//  "create public offer";
//  String get onetomany_offers =>
//  "onetomany offers";

//  String get amount_lessthan_donation_amount =>
//  "Entered amount is less than minimum donation amount.";

//  String get user_name_not_availble =>
//  "User name not available";

//  String get document =>
//  "Document";

//  String get users =>
//  "Users";

//  String get cash_request_title_hint =>
//  "Ex: Fundraiser for women’s shelter...";

//  String get error_loading_data =>
//  'Error Loading Data';
// String get likes =>
// "likes";

// String get anonymous_user =>
//  "Anonymous user";

//  String get filtering_blocked_content =>
//  "Filtering blocked content";

//  String get filtering_past_requests_content =>
// "Filtering past requests content";

// String get approved_member =>
// "Approved Members";

// String get send_csv_file =>
// "Send CSV File";
// String get success =>
// "success";
// String get failure =>
// "Failure";

// String get yang_2020 =>
// "Yang 2020";

// String get current =>
// "current";

// String get card_holder =>
// "Card Holder";

// String get hours_not_updated =>
// "hours not updated";

// String get request_approved =>
// "Request Approved";

// String get request_has_been_assigned_to_a_member =>
// "Request has been assigned to a member";

// String get borrow_request_for_place =>
// "Borrow request for place";

// String get borrow_request_for_item =>
// "Borrow Request for item";

// String get clear_all =>
// "Clear All";

// String get message_room_join =>
// "Message room join";

// String get message_room_remove =>
// "Message room remove";

// String get item_received_alert_dialouge =>
// "'If you have you received your item/place back click the button below to complete this.'";

// String get request_ended =>
// "This request has now ended. Tap to complete the request";

// String get request_ended_emailsent_msg =>
// "The request has completed and an email has been sent to you. Tap to leave a feedback.";

// String get lender_acknowledged_request_completion =>
// "The Lender has acknowledged completion of this request. Tap to leave a feedback.";

// <-----------      new label 8th June  --------->
String get onetomany_createoffer_note =>
    "Note: Upon completing the one to many offer, the combined prep time and session hours will be credited to you.";

//
//Below cound not find in mob - vishnu
//
String get no_interests_added =>
    "No interests added"; //done in web  // ask  shubam or umesh
String get no_skills_added =>
    "No skills added"; //done in web  // ask  shubam or umesh

String get bundlePricingInfoButton =>
    'There is a limit to the number of transactions in the free tier. You will be charged \$2 for a bundle of 50 transactions.'; //done in web // ask shubam or umesh
String get sandbox_already_created_1 =>
    "Only one sandbox community is currently allowed for each SevaX member."; //done in web // ask  umesh
String get provide_skills =>
    "Provide the list of Skills that you require for this request"; //done in web // not in edit request in mob
String get speaker_claim_credits => 'Claim credits'; //done in mobile & web
String get requested_for_completion =>
    "Your completed request is pending approval."; //done in mobile & web
String get join_community_alert => //already in json  //done in web
    "This action is only available to members of Community **CommunityName. Please request to join the community first before you can perform this action.";
String get sign_in_alert =>
    "You need to sign in or register to view this."; //done in web //already in json
String get resetPasswordSuccess =>
    'An email has been sent. Please follow the steps in the email to reset your password.'; //done in web //not matching

String get onetomanyrequest_title_hint =>
    "Ex: Implicit Bias webinar."; //done in web  //labels are not migrated  ,other hints not in arbify //not in edit request

String get sandbox_community => "Sandbox Community"; //done in web // ask umesh

String get you_are_on_enterprise_plan =>
    "You are on Enterprise Plan"; //done in web // ask umesh
String get sandbox_dialog_title =>
    "Sandbox seva community"; //done in web // ask umesh
String get sandbox_create_community_alert =>
    "Are you sure you want to create a sandbox community?"; //done in web // ask umesh



// added on 9th june

String get  images_help_convey_theme_of_request =>
'Images helps to convey the theme of your request';

String get max_image_size =>
'Maximum size: 5MB';

String get exp_date =>
"Exp. Date";
String get camera_not_available =>
"Camera not available";

String get loading_camera =>
"Loading Camera...";

String get internet_connection_lost =>
'Internet connection lost';

String get update_available =>
'Update Available';
String get update_app =>
"Update App";

String get update_msg =>
 "There is an update available with the app, Please tap on update to use the latest version of the app";

 String get member_permission =>
 "Member Permission";

 String get    copy_and_share_code    =>
 'Code Generated: Copy the code and share to your friends';

 String get copy_community_code =>
 "Copy Community Code";

 String get copy_code =>
 "Copy Code";

 String get share_code_msg =>
 "You can share the code to invite them to your seva community";

String get no_pending_join_request =>
'No pending join requests';

String get attend =>
"Attend";

String get requested_by =>
"Requested By";

String get location_not_provided =>
"Location not provided";

String get request_approved_by_msg =>
'Your request has been approved by ';

String get instruction_for_stay =>
'Instruction for the stay';

String get request_agreement_not_available =>
'Request agreement not available';

String get click_to_view_request_agreement =>
'Click to view request agreement';

String get enter_prep_time =>
'Enter Prep Time';

String get enter_delivery_time=>
 'Enter Delivery Time';

 String get choose_document =>
 "Choose Document";

 
 String get usage_term =>
 "Usage term*";

 String get quite_hours_allowed =>
 "Quiet hours allowed";
 
 String get pets_allowed =>
 "Pets Allowed";

String get max_occupants =>
 "Maximum occupants";

 String get security_deposits =>
  "Security Deposit";

 String get person_of_contact_details =>
   "Person of contact details";

 String get any_specific_conditions =>
   "Any specific condition(s)";

  
String get item_returned_hint_text =>

   'Ex: item must be returned in the same condition.';
String get description_of_item =>
   "Description of item(s)";

 String get attending =>
   "Attending";

 String get invited_speaker =>
   "Invited Speaker";
 String get description_not_updated =>
    "Description not yet updated";
 String get terms_acknowledgement_text =>
"I accept the terms of use as per the agreement";
String get agreement  =>
"Agreement";
String get lender_not_accepted_request_msg =>
"Lender has not created an agreement for this request";

String get review_before_proceding_text =>
"Please review the agreement below before proceeding.";

String get review_agreement =>
"Review Agreement";

String get guests_can_do_and_dont =>
"Guests can do and don't*";

String get snackbar_select_agreement_type =>
"Select an agreement type";
String get add_manual_time =>
"Add Manual Time";

String get trustworthiness =>
 "Trustworthiness";
 String get reliabilitysocre =>
 "Reliabilityscore";
 String get cv_not_available =>
 "CV not available";

 String get change_document =>
"Change document";
String get add_document =>
"Add document";

String get sign_up_with_apple =>
  'Sign up with Apple';
  
String get sign_up_with_google =>
  'Sign up with Google';
//<------------------below labels are done------------->

// //DO BELOW OF THIS VISHNU
//   String get no_groups_text =>
//       "You are currently not part of any groups. You can either join one or create a new group."; //(done in mobile)
//   String get kilometers => "Kilometers"; //done in web
//   String get miles => "Miles"; //done in web
//  String get continue_to_signin => "Continue to Sign in"; //done in web
//  String get request_to_join => "Request to join"; //done in web

//  String get event => "Event"; //done in web
//   String get part_of_sevax =>
//       "Part of SevaX Global Network of Communities"; //done in web
//  String get access_not_available => "Access not available"; //done in web
//   String get upcoming_events =>
//       "Upcoming Events"; //done in web (but code is commented out)
//   String get latest_requests =>
//       "Latest Requests"; //done in web (but code is commented out)

//   String get event_description => "Event Description"; //done in web
//  String get hours => 'hours'; //done in web
// String get hour => 'hour'; //done in web

//   String get min_credits_error =>
//       "Minimum credits cannot be empty or zero"; //done in web
//   //OFFERS LABELS STARTS HERE
//   String get offer_description_error =>
//       "Please give a detailed description of the class you’re offering.";
//   String get invitation_accepted =>
//       "Invitation Accepted."; //done in mobile & web
//   String get invitation_accepted_subtitle =>
//       " has accepted your offer."; //done in mobile & web
//   String get offer_invitation_notification_title =>
//       "Offer Invitation"; //done in mobile & web
//   String get offer_invitation_notification_subtitle =>
//       " has invited you to accept an offer."; //done in mobile & web
//   String get accept_offer_invitation_confirmation =>
//       "This task will be added to your Pending Tasks, after you approve it."; //done in mobile & web
//   String get minimum_credit_title => "Minimum Credits*"; //done in mobile & web
//   String get minimum_credit_hint =>
//       "Provide minimum credits you require"; //done in mobile & web
//   String get option_one => "Standing Offer"; //done in mobile & web
//   String get option_two => "One Time"; //done in mobile & web
//   String get minimum_credits_offer => //done in web
//       "This offer does not meet your minimum credit requirement.";
//   String get speaker_claim_form_field_title =>
//       "How much prep time did you require for this request?"; //done in web
//   String get speaker_claim_form_field_title_hint =>
//       "Prep time in hours"; //done in web
//   String get speaker_claim_form_text_1 =>
//       "I acknowledge that I have completed the session for the request."; //done in web
//   String get speaker_claim_form_text_2 =>
//       "Upon completing the one to many request, the combined prep time and session hours will be credited to you."; //done in web
//   String get registration_link => "Registration Link"; //done in mobile & web
//   String get registration_link_hint =>
//       "Ex: Eventbrite link, etc."; //done in mobile & web
//   String get request_closed => "Request closed"; //done in mobile & web

// String get total_no_of_participants =>
//       "Total No. of Participants*"; //done in web

//     String get onetomanyrequest_create_new_event => //done in mobile & web
//       "A new event will be created and linked to this request.";
//  String get time_to_prepare => 'Time to prepare: '; //done in web
//   String get this_request_has_now_ended =>
//       "This request has now ended"; //done in web
//   String get maximumNoOfParticipants =>
//       'This request has a maximum number of participants. That limit has been reached.'; //done in web
//   String get reject_request_completion => //done in mobile & web
//       "Are you sure you want to reject this request for completion?";
//   String get speaker_reject_invite_dialog => //done in mobile & web
//       "Are you sure you want to reject this invitation to speak?";

//   String get explore_page_title_text =>
//       "Explore Opportunities"; //done in mobile & web
//   String get explore_page_subtitle_text => //done in mobile & web //already in json
//       "Find communities near you or online communities that interest you. You can offer to volunteer your services or request any assistance or search for Community Events.";

//   String get my_groups => "My Groups"; //done in mobile & web

//   String get speaker_requested_completion_notification =>
//       "This request has been completed."; //done web
//   String get request_completed_by_speaker =>
//       "This request has been completed and is awaiting your approval."; //done in mobile & web
//   String get speaker => 'Speaker'; //done in mobile & web
//   String get speaker_completion_rejected_notification_1 =>
//       "Request rejected."; //done in web
//   String get speaker_accepted_invite_notification =>
//       "This request has been accepted by **speakerName."; //done in web
//   String get you_are_the_speaker => "You are the speaker for: "; //done in web
//   String get select_a_speaker => "Please select a Speaker*"; //done in web

//   String get selected_speaker => "Selected Speaker"; //done in web

//   String get oneToManyRequestSpeakerAcceptRequest =>
//       'Are you sure you want to accept this request?'; //done in web

//    String get insufficientSevaCreditsDialog =>
//       'You do not have sufficient Seva credits to create this request. You need to have *** more Seva credits'; //done in web

// String get adminNotificationInsufficientCreditsNeeded =>
//       'Credits Needed: '; //done in web

//   String get adminNotificationInsufficientCredits =>
//       ' Has Insufficient Credits To Create Requests'; //done in web

//   String get oneToManyRequestSpeakerWithdrawDialog =>
//       'Please confirm that you would like to withdraw as a speaker'; //done in web
//   String get speakerRejectedNotificationLabel =>
//       ' rejected the Speaker invitation for '; //done in web
//    String get select_speaker_hint =>
//       "Ex: Name of speaker."; //done in mobile & web
//   String get speaker_rejected => 'Speaker Rejected'; //done in web
//   String get people_applied_for_request =>
//       ' people have applied for this request'; //done in web
//  String get oneToManyRequestCreatorCompletingRequestDialog =>
//       'Are you sure you want to accept and complete this request?'; //done in web
// String get onetomanyrequest_participants_or_credits_hint =>
//       "Ex: 40."; //done in web

//   String get speaker_complete_page_text_1 =>
//       'I acknowledge that speaker_name has completed the request. The list of members provided above attended the request.'; //done in web
//   String get speaker_complete_page_text_2 =>
//       'Note: The hours will be credited to the speaker and to the attendees upon your approval. This list of attendees cannot be modified after approval.'; //done in web
//   String get action_restricted_by_owner =>
//       'This action is Restricted for you by the owner of the seva Community.'; //done in web
//   String get accepted_this_request =>
//       'You have accepted this request.'; //done in web

//   String get select_a_speaker_dialog => 'Select a speaker';
//  String get duration_of_session => 'Duration of Session: '; //done in web

//   String get speaker_invite_notification =>
//       "Added you as the Speaker for request: "; //done in web

//   String get sandbox_dialog_subtitle =>
//       "Sandbox Seva communities are created for instructional purposes only. Any credits earned or debited will not count towards your account."; //done in web
}

// // <--------  IRRELEVANT FOR NOW  --------->
// // String get borrow_request_title => "Borrow Request"; //done in mobile
