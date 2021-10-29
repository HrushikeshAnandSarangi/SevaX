import 'package:flutter/material.dart';

class L {
  // <------Enhanced Billing UI Labels Below ------> //
  L.of(BuildContext context) {}

//   String get browse_requests_by_category => "Browse requests by category";

// // // //   // <------------ PENDING START ------------>

// // // //   String get offer => "Offer"; //it's in flavor config file so cannot add it.
// // // //   String get minimum_credits => "Minimum Credits"; //can't find where to replace
// // // //   String get applied_for_request =>
// // // //       "You have accepted the request"; //cant find where to replace
// // // //   String get nearby_settings_content => //already in arbify
// // // //       "This indicates the distance that the user is willing to travel to complete a Request for a Seva Community or participate in an Event";
// // // //   String get kilometer => "Kilometer"; //cant find where to replace
// // // //   String get mile => "Mile"; //cant find where to replace
// // // //   // <------------ PENDING END ------------>

// // // // <-----------      new label 8th June  --------->
// // //   String get offering_amount => "Offering Amount";
// // //   // String get offering_goods => "Offering Goods";

// // //   String get onetomany_createoffer_note =>
// // //       "Note: Upon completing the one to many offer, the combined prep time and session hours will be credited to you.";

// //   String get no_timeline_found => "No timeline found";

// //   String get add_to_calender => "Add to calender";

// //   String get profanity_text_alert =>
// //       'The SevaX App has a policy of not allowing profane or explicit language. Please revise your text.';

// // //   String get bundlePricingInfoButton =>
// // //       'There is a limit to the number of transactions in the free tier. You will be charged \$2 for a bundle of 50 transactions.'; //done in web // ask shubam or umesh
// // //   String get sandbox_already_created_1 =>
// // //       "Only one sandbox community is currently allowed for each SevaX member."; //done in web // ask  umesh
// // //   String get provide_skills =>
// // //       "Provide the list of Skills that you require for this request"; //done in web // not in edit request in mob
// // //   String get speaker_claim_credits => 'Claim credits'; //done in mobile & web
// // //   String get requested_for_completion =>
// // //       "Your completed request is pending approval."; //done in mobile & web
// // //   String get join_community_alert => //already in json  //done in web
// // //       "This action is only available to members of Community **CommunityName. Please request to join the community first before you can perform this action.";
// // //   String get sign_in_alert =>
// // //       "You need to sign in or register to view this."; //done in web //already in json
// // //   String get resetPasswordSuccess =>
// // //       'An email has been sent. Please follow the steps in the email to reset your password.'; //done in web //not matching

// // //   String get onetomanyrequest_title_hint =>
// // //       "Ex: Implicit Bias webinar."; //done in web  //labels are not migrated  ,other hints not in arbify //not in edit request

// // //   String get sandbox_community =>
// // //       "Sandbox Community"; //done in web // ask umesh

// // //   String get you_are_on_enterprise_plan =>
// // //       "You are on Enterprise Plan"; //done in web // ask umesh
// // //   String get sandbox_dialog_title =>
// // //       "Sandbox seva community"; //done in web // ask umesh
// // //   String get sandbox_create_community_alert =>
// // //       "Are you sure you want to create a sandbox community?"; //done in web // ask umesh

// // //   //new labels to be updated

// // //   String get add_event_to_calender => "Add event to calender";

// // //   String get add_to_calender => "Add to calender";

// // //   String get do_you_want_addto_calender =>
// // //       "Do you want to add this event to your calendar?";

// // //   String get add_to_google_calender => "Add to Google Calendar";

// // //   String get add_to_outlook => "Add to Outlook";

// // //   String get add_to_ical => "Add to ical ";

// // //   String get calender_sync => "calendar_sync";

// // //   String get something_went_wrong => "something went wrong";

// // //   String get featured_communities => "Featured communities";

// // //   String get browse_by_category => "Browse community by category";

// // //   // String get explore_searchbar_hinttext =>
// // //   //     'Try "Osaka" "Postal Code" "Location"';

// // //   String get find => "Find";

// // //   String get any_category => "any category";
// // //   String get new_york => "New york | USA";

// // //   String get join_webinar
// // //   => "join webinar";

// // //   String get pledge_goods_supplies => " has pledge to donate good/supplies";
// // //   String get credits_debited => "seva credits debited";
// // //   String get credits_credited => "Seva credits Credited";

// // //   String get credits_debited_msg =>
// // //       "Seva Credits have been debited from your account";

// //   String get users => "Users";

// // //   String get completed_the_request => " Completed the request";

// // //  String get error_loading_data =>
// // //  'Error Loading Data';
// //   String get likes => "likes";

// // //   String get create_virtual_offer => "create virtual offer";
// // //   String get create_public_offer => "create public offer";
// // //   String get onetomany_offers => "onetomany offers";

// // //   String get amount_lessthan_donation_amount =>
// // //       "Entered amount is less than minimum donation amount.";

// // //   String get user_name_not_availble => "User name not available";

// // //   String get document => "Document";

// // //   String get users => "Users";

// // //   String get cash_request_title_hint => "Ex: Fundraiser for women’s shelter...";

// // //   String get error_loading_data => 'Error Loading Data';
// // //   String get likes => "likes";

// // //   String get anonymous_user => "Anonymous user";

// // //   String get filtering_blocked_content => "Filtering blocked content";

// // //   String get filtering_past_requests_content =>
// // //       "Filtering past requests content";

// // //   String get approved_member => "Approved Members";

// // //   String get send_csv_file => "Send CSV File";
// // //   String get success => "success";
// // //   String get failure => "Failure";

// // //   String get yang_2020 => "Yang 2020";

// // //   String get current => "current";

// // //   String get card_holder => "Card Holder";

// // //   String get hours_not_updated => "hours not updated";

// // //   String get request_approved => "Request Approved";

// // //   String get request_has_been_assigned_to_a_member =>
// // //       "Request has been assigned to a member";

// // //   String get borrow_request_for_place => "Borrow request for place";

// // //   String get borrow_request_for_item => "Borrow Request for item";

// // //   String get clear_all => "Clear All";

// // //   String get message_room_join => "Message room join";

// // //   String get message_room_remove => "Message room remove";

// // //   String get item_received_alert_dialouge =>
// // //       "'If you have you received your item/place back click the button below to complete this.'";

// // //   String get request_ended =>
// // //       "This request has now ended. Tap to complete the request";

// // //   String get request_ended_emailsent_msg =>
// // //       "The request has completed and an email has been sent to you. Tap to leave a feedback.";

// // //   String get lender_acknowledged_request_completion =>
// // //       "The Lender has acknowledged completion of this request. Tap to leave a feedback.";

// // // //<------------------below labels are done------------->

// // // // //DO BELOW OF THIS VISHNU
// // // //   String get no_groups_text =>
// // // //       "You are currently not part of any groups. You can either join one or create a new group."; //(done in mobile)
// // // //   String get kilometers => "Kilometers"; //done in web
// // // //   String get miles => "Miles"; //done in web
// // // //  String get continue_to_signin => "Continue to Sign in"; //done in web
// // // //  String get request_to_join => "Request to join"; //done in web

// //   String get images_help_convey_theme_of_request =>
// //       'Images helps to convey the theme of your request';

// //   String get max_image_size => 'Maximum size: 5MB';

// //   String get exp_date => "Exp. Date";

// //   String get camera_not_available => "Camera not available";

// //   String get loading_camera => "Loading Camera...";

// //   String get internet_connection_lost => 'Internet connection lost';

// //   String get update_available => 'Update Available';

// //   String get update_app => "Update App";

// //   String get update_msg =>
// //       "There is an update available with the app, Please tap on update to use the latest version of the app";

// //   String get member_permission => "Member Permission";

// //   String get copy_and_share_code => 'Code Generated: Copy the code and share to your friends';

// //   String get copy_community_code => "Copy Community Code";

// //   String get copy_code => "Copy Code";

// //   String get share_code_msg => "You can share the code to invite them to your seva community";

// //   String get no_pending_join_request => 'No pending join requests';

// //   String get attend => "Attend";

// //   String get requested_by => "Requested By";

// //   String get location_not_provided => "Location not provided";

// //   String get request_approved_by_msg => 'Your request has been approved by ';

// //   String get instruction_for_stay => 'Instruction for the stay';

// //   String get request_agreement_not_available => 'Request agreement not available';

// //   String get click_to_view_request_agreement => 'Click to view request agreement';

// //   String get enter_prep_time => 'Enter Prep Time';

// //   String get enter_delivery_time => 'Enter Delivery Time';

// //   String get choose_item_agreement => "Select Item(s) Agreement";

// //   String get choose_place_agreement => "Select Place Agreement";

// //   String get usage_term => "Usage term*";

// //   String get quite_hours_allowed => "Quiet hours allowed";

// //   String get pets_allowed => "Pets Allowed";

// //   String get max_occupants => "Maximum occupants";

// //   String get security_deposits => "Security Deposit";

// //   String get person_of_contact_details => "Person of contact details";

// //   String get any_specific_conditions => "Any specific condition(s)";

// //   String get description_of_item => "Description of item(s)";

// //   String get place_returned_hint_text => 'Ex: place must be returned in the same condition.';

// //   String get attending => "Attending";

// //   String get invited_speaker => "Invited Speaker";

// //   String get description_not_updated => "Description not yet updated";

// //   String get terms_acknowledgement_text => "I accept the terms of use as per the agreement";

// //   String get agreement => "Agreement";

// //   String get review_before_proceding_text => "Please review the agreement below before proceeding.";

// //   String get review_agreement => "Review Agreement";

// //   String get guests_can_do_and_dont => "Guests can do and don't*";

// //   String get snackbar_select_agreement_type => "Select an agreement type";

// //   String get add_manual_time => "Add Manual Time";

// //   String get trustworthiness => "Trustworthiness";

// //   String get reliabilitysocre => "Reliabilityscore";

// //   String get cv_not_available => "CV not available";

// //   String get change_document => "Change document";

// //   String get add_document => "Add document";

// //   String get sign_up_with_apple => 'Sign up with Apple';

// //   String get sign_up_with_google => 'Sign up with Google';

// //   // labels on june 10
// //   String get do_you_want_to_add => "Do you want to add this";

// //   String get event_to_calender => "event to calender";

// //   String get seva_community_name_not_updated => "Seva Community name not updated";

// //   String get create_new => "Create New";

// //   String get no_agrreement => "No Agreement";

// //   String get fixed => "Fixed";

// //   String get long_term_month_to_month => 'Long-term (Month to Month)';

// //   String get request_offer_agreement_hint_text => "Ex :3";

// //   String get request_offer_agreement_hint_text2 => "Ex: \$300";

// //   String get request_offer_agreement_hint_text3 =>
// //       'Ex: Gas-powered lawnmower in mint condition with full tank of gas.';

// //   String get request_offer_agreement_tool_widget_text =>
// //       "Stipulations regarding returned item in unsatisfactory condition.";

// //   String get request_offer_agreement_hint_text4 =>
// //       'Ex: Lawnmower must be cleaned and operable with a full tank of gas.';

// //   String get document_name => "Document Name*";

// //   String get please_enter_doc_name => "Please enter document name";

// //   String get other_details => "Other Details";

// //   String get request_offer_agreement_hint_text5 =>
// //       "Ex: LANDLORD'S LIABILITY. The Guest and any of their guests hereby indemnify and hold harmless the Landlord against any and all claims of personal injury or property damage or loss arising from the use of the Premises regardless of the nature of the accident, injury or loss. The Guest expressly recognizes that any insurance for property damage or loss which the Landlord may maintain on the property does not cover the personal property of Tenant and that Tenant should purchase their own insurance for their guests if such coverage is desired.";

// //   String get use => "use";

// //   String get approve_borrow_request => 'Approve Room Borrow Request';

// //   String get approve_item_borrow => 'Approve Item Borrow request';

// //   String get approve_borrow_hint_text1 => "Tell your borrower do and dont's";

// //   String get approve_borrow_alert_msg1 => "Please enter the do's and dont's";

// //   String get approve_borrow_no_agreement_selected => "No Agreement Selected";

// //   String get approve_borrow_terms_acknowledgement_text3 =>
// //       "Note: Please instruct on how to reach the location and do and don't accordingly.";

// //   String get approve_borrow_terms_acknowledgement_text4 =>
// //       "Note: Please create an agreement if you have specific instructions and/or requirements.";

// //   String get error_was_thrown => "Error was Thrown";

// //   String get max_250_characters => '* max 250 characters';

// //   String get doc_pdf => "Document.pdf";

// //   String get credits => "Credits:";

// //   String get could_not_launch => "Could not launch";

// //   String get need_a_place => "Need a  place";

// //   String get item => "Item";

// //   String get borrow => "Borrow";

// //   String get choose_skills_for_request => "Choose skills for request";

// //   String get creating_request_with_underscore_not_allowed =>
// //       'Creating request with "_" is not allowed';

// //   String get selected_skills => "Selected Skills";

// //   String get request_tools_description => "Request tools description*";

// //   String get seva => "Seva";

// //   String get test_community => "Test Community";

// //   String get you_already_created_test_community => 'You already created a test community.';

// //   String get selected_value => "Selected value :";

// //   String get upgrade_plan_msg1 => "Sorry Couldn't fetch data";

// //   String get upgrade_plan_disable_msg1 => 'This feature is disabled for your community';

// //   String get upgrade_plan_disable_msg2 =>
// //       'This is currently not permitted. Please see the following link for more information: http://web.sevaxapp.com/';

// //   String get upgrade_plan_disable_msg3 =>
// //       'This is currently not permitted. Please contact the Community Creator for more information';

// //   String get edit_name => "Edit Name";

// //   String get sponsored_by => "Sponsored By";

// //   String get sponsor_name => "Sponsor name";

// //   String get no_search_result_found => "No search result found";

// //   String get join_seva_community => "Join Seva Community";

// //   String get please_switch_to_access => 'Please switch seva community to access ';

// //   String get please_join_seva_to_access => 'Please join seva community to access ';

// //   String get no_events_available => "No Events Available";

// //   String get ack => "Ack";

// //   String get enter_the_amount_received => "Enter the amount recieved";

// //   String get virtual_requests => "Virtual requests";

// //   String get name_not_available => "Name not available";

// //   String get attended_by => "Attended by";

// //   String get reset_list => "Reset list";

// //   String get join_community_to_view_updates => "To view and receive updates join the community";

// //   String get join_chat => "Join Chat";

// // //<------------------below labels are done------------->

// // // //DO BELOW OF THIS VISHNU
// // //   String get no_groups_text =>
// // //       "You are currently not part of any groups. You can either join one or create a new group."; //(done in mobile)
// // //   String get kilometers => "Kilometers"; //done in web
// // //   String get miles => "Miles"; //done in web
// // //  String get continue_to_signin => "Continue to Sign in"; //done in web
// // //  String get request_to_join => "Request to join"; //done in web

// // //  String get event => "Event"; //done in web
// // //   String get part_of_sevax =>
// // //       "Part of SevaX Global Network of Communities"; //done in web
// // //  String get access_not_available => "Access not available"; //done in web
// // //   String get upcoming_events =>
// // //       "Upcoming Events"; //done in web (but code is commented out)
// // //   String get latest_requests =>
// // //       "Latest Requests"; //done in web (but code is commented out)

// // //   String get event_description => "Event Description"; //done in web
// // //  String get hours => 'hours'; //done in web
// // // String get hour => 'hour'; //done in web

// // //   String get min_credits_error =>
// // //       "Minimum credits cannot be empty or zero"; //done in web
// // //   //OFFERS LABELS STARTS HERE
// // //   String get offer_description_error =>
// // //       "Please give a detailed description of the class you’re offering.";
// // //   String get invitation_accepted =>
// // //       "Invitation Accepted."; //done in mobile & web
// // //   String get invitation_accepted_subtitle =>
// // //       " has accepted your offer."; //done in mobile & web
// // //   String get offer_invitation_notification_title =>
// // //       "Offer Invitation"; //done in mobile & web
// // //   String get offer_invitation_notification_subtitle =>
// // //       " has invited you to accept an offer."; //done in mobile & web
// // //   String get accept_offer_invitation_confirmation =>
// // //       "This task will be added to your Pending Tasks, after you approve it."; //done in mobile & web
// // //   String get minimum_credit_title => "Minimum Credits*"; //done in mobile & web
// // //   String get minimum_credit_hint =>
// // //       "Provide minimum credits you require"; //done in mobile & web
// // //   String get option_one => "Standing Offer"; //done in mobile & web
// // //   String get option_two => "One Time"; //done in mobile & web
// // //   String get minimum_credits_offer => //done in web
// // //       "This offer does not meet your minimum credit requirement.";
// // //   String get speaker_claim_form_field_title =>
// // //       "How much prep time did you require for this request?"; //done in web
// // //   String get speaker_claim_form_field_title_hint =>
// // //       "Prep time in hours"; //done in web
// // //   String get speaker_claim_form_text_1 =>
// // //       "I acknowledge that I have completed the session for the request."; //done in web
// // //   String get speaker_claim_form_text_2 =>
// // //       "Upon completing the one to many request, the combined prep time and session hours will be credited to you."; //done in web
// // //   String get registration_link => "Registration Link"; //done in mobile & web
// // //   String get registration_link_hint =>
// // //       "Ex: Eventbrite link, etc."; //done in mobile & web
// // //   String get request_closed => "Request closed"; //done in mobile & web

// // // String get total_no_of_participants =>
// // //       "Total No. of Participants*"; //done in web

// // //     String get onetomanyrequest_create_new_event => //done in mobile & web
// // //       "A new event will be created and linked to this request.";
// // //  String get time_to_prepare => 'Time to prepare: '; //done in web
// // //   String get this_request_has_now_ended =>
// // //       "This request has now ended"; //done in web
// // //   String get maximumNoOfParticipants =>
// // //       'This request has a maximum number of participants. That limit has been reached.'; //done in web
// // //   String get reject_request_completion => //done in mobile & web
// // //       "Are you sure you want to reject this request for completion?";
// // //   String get speaker_reject_invite_dialog => //done in mobile & web
// // //       "Are you sure you want to reject this invitation to speak?";

// // //   String get explore_page_title_text =>
// // //       "Explore Opportunities"; //done in mobile & web
// // //   String get explore_page_subtitle_text => //done in mobile & web //already in json
// // //       "Find communities near you or online communities that interest you. You can offer to volunteer your services or request any assistance or search for Community Events.";

// // //   String get my_groups => "My Groups"; //done in mobile & web

// // //   String get speaker_requested_completion_notification =>
// // //       "This request has been completed."; //done web
// // //   String get request_completed_by_speaker =>
// // //       "This request has been completed and is awaiting your approval."; //done in mobile & web
// // //   String get speaker => 'Speaker'; //done in mobile & web
// // //   String get speaker_completion_rejected_notification_1 =>
// // //       "Request rejected."; //done in web
// // //   String get speaker_accepted_invite_notification =>
// // //       "This request has been accepted by **speakerName."; //done in web
// // //   String get you_are_the_speaker => "You are the speaker for: "; //done in web
// // //   String get select_a_speaker => "Please select a Speaker*"; //done in web

// // //   String get selected_speaker => "Selected Speaker"; //done in web

// // //   String get oneToManyRequestSpeakerAcceptRequest =>
// // //       'Are you sure you want to accept this request?'; //done in web

// // //    String get insufficientSevaCreditsDialog =>
// // //       'You do not have sufficient Seva credits to create this request. You need to have *** more Seva credits'; //done in web

// // // String get adminNotificationInsufficientCreditsNeeded =>
// // //       'Credits Needed: '; //done in web

// // //   String get adminNotificationInsufficientCredits =>
// // //       ' Has Insufficient Credits To Create Requests'; //done in web

// // //   String get oneToManyRequestSpeakerWithdrawDialog =>
// // //       'Please confirm that you would like to withdraw as a speaker'; //done in web
// // //   String get speakerRejectedNotificationLabel =>
// // //       ' rejected the Speaker invitation for '; //done in web
// // //    String get select_speaker_hint =>
// // //       "Ex: Name of speaker."; //done in mobile & web
// // //   String get speaker_rejected => 'Speaker Rejected'; //done in web
// // //   String get people_applied_for_request =>
// // //       ' people have applied for this request'; //done in web
// // //  String get oneToManyRequestCreatorCompletingRequestDialog =>
// // //       'Are you sure you want to accept and complete this request?'; //done in web
// // // String get onetomanyrequest_participants_or_credits_hint =>
// // //       "Ex: 40."; //done in web

// // //   String get speaker_complete_page_text_1 =>
// // //       'I acknowledge that speaker_name has completed the request. The list of members provided above attended the request.'; //done in web
// // //   String get speaker_complete_page_text_2 =>
// // //       'Note: The hours will be credited to the speaker and to the attendees upon your approval. This list of attendees cannot be modified after approval.'; //done in web
// // //   String get action_restricted_by_owner =>
// // //       'This action is Restricted for you by the owner of the seva Community.'; //done in web
// // //   String get accepted_this_request =>
// // //       'You have accepted this request.'; //done in web

// // //   String get select_a_speaker_dialog => 'Select a speaker';
// // //  String get duration_of_session => 'Duration of Session: '; //done in web

// // //   String get speaker_invite_notification =>
// // //       "Added you as the Speaker for request: "; //done in web

// // //   String get sandbox_dialog_subtitle =>
// // //       "Sandbox Seva communities are created for instructional purposes only. Any credits earned or debited will not count towards your account."; //done in web

// // //Lending Offer Labels Below
// //   String get approve_lending_offer => "Approve Lending Offer";

// //   String get addditional_instructions => "Additional Instructions";

// //   String get addditional_instructions_error_text => "Please enter additional instructions";

// //   String get additional_instructions_hint_item => "Ex: Lawnmower is available next door";

// //   String get lending_approve_terms_item =>
// //       "I acknowledge that you can lend the item(s) on the mentioned dates.";

// //   String get lending_approve_terms_place =>
// //       "I acknowledge that you can lend the place on the mentioned dates.";

// //   String get lending => "Lending";

// //   String get cannot_approve_multiple_borrowers_place =>
// //       "You cannot approve multiple borrowers at once. Currently  **name is checked in. Once  **name has checked out you can approve this request.";

// //   String get borrower_responsibilities => "Borrower Responsibilities";

// //   String get borrower_responsibilities_subtext =>
// //       "Please check applicable sections to be added in the agreement.";

// //   String get liability_damage => "Liability for damage";

// //   String get use_disclaimer => "Use/Disclaimer";

// //   String get delivery_return_equipment => "Delivery and Return of Equipment";

// //   String get maintain_repair => "Maintenance and Repair";

// //   String get place_agreement_name_hint => "Ex: House for the weekend..";

// // //below labels yet to be added
// //   String get add_new_place => "Add New Place";

// //   String get update_place => "Update Place";

// //   String get add_images_to_place => "Add One/Multiple Images of the place";

// //   String get name_of_place => "Name of your place";

// //   String get name_place => "Name of Place";

// //   String get name_item => "Name of Item";

// //   String get amenities => "Amenities";

// //   String get amenities_hint => "Please select Amenities guests can utilize";

// //   String get no_of_guests => "Number of guests";

// //   String get bed_roooms => "Bed Rooms for guests";

// //   String get house_rules => "House Rules";

// //   String get estimated_value_items => "Estimated value of Item(s)";

// //   String get contact_information => "Contact Information";

// //   String get add_place => "Add Place";

// //   String get lending_offer => "Lending";

// //   String get lending_offer_title_hint => "Ex:Lawnmower";

// //   String get lending_offer_desc_hint => "Describe your lending";

// //   String get validation_error_place_name => "Please enter name of your place";

// //   String get validation_error_no_of_guests => "Please enter no of guests can stay";

// //   String get validation_error_no_of_rooms => "Please enter no of rooms available";

// //   String get validation_error_no_estimated_value_room =>
// //       "Please enter an estimated value for the place";

// //   String get validation_error_no_estimated_value_item =>
// //       "Please enter an estimated value for the item";

// //   String get validation_error_common_spaces => "Please specify common spaces";

// //   String get validation_error_house_rules => "Please specify house rules";

// //   String get validation_error_amenities => "Please select amenities";

// //   String get validation_error_house_images => "Please add place images";

// //   String get common_spaces_hint => "Ex: Sofa bed 1, Couch 1, Floor Mattress 1";

// //   String get place => "Place";

// //   String get items => "Item(s)";

// //   String get updating_place => "Updating place";

// //   String get creating_place => "Creating Place";

// //   String get bed_rooms => "Bedroom(s)";

// //   String get guests => "Guest(s)";

// //   String get creating_place_error => "There was error creating your place, Please try again.";

// //   String get updating_place_error => "There was error creating your place, Please try again.";

// //   String get sevax => "SevaX";

// //   String get plans => "Plans";

// //   String get invoice_history => "Invoice History";

// //   String get subscription_period => "Subscription Period";

// //   String get effective_date => "Effective Date";

// //   String get invoice_amount => "Invoice Amount";

// //   String get next_invoice_date => "Next Invoice Date";

// //   String get monthly => "Monthly";

// //   String get download => "Download";

// //   String get annual => "Annual";

// //   String get inactive => "Inactive";

// //   String get date_not_available => "Date not available";

// //   String get not_available => "not available";

// //   String get edit_current_plan => "Edit Current Plan";

// //   String get cancel_plan => "Cancel Plan";

// //   String get card_ending_with => "Card ending with ";

// //   String get show_previous_invoices => "show previous invoices";

// //   String get show_less_invoices => "show less invoices";

// //   String get my_cards => "My Cards";

// //   String get payment_method => "Payment Method";

// //   String get pay_by => "Pay by";

// //   String get country => "Country";

// //   String get company => "Company";

// //   String get additional => "Additional";

// //   String get usd => "USD";

// //   String get to_do => "To Do";

// //   String get one_to_many_offer_attende => "One to Many Offer Attendee";

// //   String get one_to_many_offer_speaker => "One to Many Offer Speaker";

// //   String get time_request_volunteer => "Time Request Volunteer";

// //   String get time_offer_volunteer => "Accepted Time Offer";

// //   String get one_to_many_request_speaker => "One to Many Request Speaker";

// //   String get one_to_many_request_attende => "One to Many Request attendee";

// //   String get completed_one_to_many_offer_attende_title => "This one to many offer has completed.";

// //   String get completed_one_to_many_offer_attende_subtitle =>
// //       "This one to many offer has completed.";

// //   String get completed_one_to_many_offer_speaker_title => "This one to many offer has completed.";

// //   String get completed_one_to_many_offer_speaker_subtitle =>
// //       "This one to many offer has completed.";

// //   String get completed_one_to_many_request_attende_title => "This one to many offer has completed.";

// //   String get completed_one_to_many_request_attende_subtitle =>
// //       "This one to many offer has completed.";

// //   String get completed_one_to_many_request_speaker_title => "This one to many offer has completed.";

// //   String get completed_one_to_many_request_speaker_subtitle =>
// //       "This one to many offer has completed.";

// // //ToDO List

// //   String get to_do_one_to_many_offer_attende_title => "This one to many offer has completed.";

// //   String get to_do_one_to_many_offer_attende_subtitle => "This one to many offer has completed.";

// //   String get to_do_one_to_many_reuqest_speaker_title => "This one to many reuqest has completed.";

// //   String get to_do_one_to_many_reuqest_speaker_subtitle =>
// //       "This one to many request has completed.";

// //   String get to_do_one_to_many_request_attende_title => "This one to many offer has completed.";

// //   String get to_do_one_to_many_request_attende_subtitle => "This one to many offer has completed.";

// //   String get to_do_one_to_many_request_speaker_title => "This one to many offer has completed.";

// //   String get to_do_one_to_many_request_speaker_subtitle => "This one to many offer has completed.";

// // //   // <------------ PENDING START ------------>
// // //   String get no_groups_text =>
// // //       "You are currently not part of any groups. You can either join one or create a new group."; //(only for mobile)
// // //   String get offer => "Offer"; //it's in flavor config file so cannot add it.
// // //   String get minimum_credits => "Minimum Credits"; //can't find where to replace
// // //   String get applied_for_request =>
// // //       "You have accepted the request"; //cant find where to replace
// // //   String get nearby_settings_content => //already in arbify
// // //       "This indicates the distance that the user is willing to travel to complete a Request for a Seva Community or participate in an Event";
// // //   String get kilometer => "Kilometer"; //cant find where to replace
// // //   String get mile => "Mile"; //cant find where to replace
// // //   // <------------ PENDING END ------------>

// // //TODO PENDING LIST
// //   String get one_to_many_attendee_offer => "One to Many Offer Attendee";

// //   String get one_to_many_speaker_offer => "One to Many Offer Speaker";

// //   String get one_to_many_attendee_request => "One to Many Request Attendee";

// //   String get one_to_many_speaker_request => "One to Many Offer Speaker";

// // //RECURRING EVENTS
// //   String get do_not_copy => "Do not copy";

// //   String get proceed_with_copying => "Proceed with copying.";

// //   String get copy_requests_in_events =>
// //       "You have requested to make this a recurring event. Would you like to include all the requests within this event over to all the remaining events?";

// // // //
// // // //
// // // // <----------- BELOW DONE IN WEB ------------>
// // // //
// // // //
// // //DO BELOW OF THIS VISHNU
// //   String get kilometers => "Kilometers"; //done in web
// //   String get miles => "Miles"; //done in web
// //   String get continue_to_signin => "Continue to Sign in"; //done in web
// //   String get access_not_available => "Access not available"; //done in web
// //   String get no_interests_added => "No interests added"; //done in web
// //   String get no_skills_added => "No skills added"; //done in web
// //   String get part_of_sevax => "Part of SevaX Global Network of Communities"; //done in web
// //   String get upcoming_events => "Upcoming Events"; //done in web (but code is commented out)
// //   String get latest_requests => "Latest Requests"; //done in web (but code is commented out)
// //   String get provide_skills =>
// //       "Provide the list of Skills that you require for this request"; //done in web
// //   String get event_description => "Event Description"; //done in web
// //   String get request_to_join => "Request to join"; //done in web
// //   String get event => "Event"; //done in web
// //   String get min_credits_error => "Minimum credits cannot be empty or zero"; //done in web
// // //OFFERS LABELS STARTS HERE
// //   String get offer_description_error =>
// //       "Please give a detailed description of the class you’re offering.";

// //   String get invitation_accepted => "Invitation Accepted."; //done in mobile & web
// //   String get invitation_accepted_subtitle => " has accepted your offer."; //done in mobile & web
// //   String get offer_invitation_notification_title => "Offer Invitation"; //done in mobile & web
// //   String get offer_invitation_notification_subtitle =>
// //       " has invited you to accept an offer."; //done in mobile & web
// //   String get accept_offer_invitation_confirmation =>
// //       "This task will be added to your Pending Tasks, after you approve it."; //done in mobile & web
// //   String get minimum_credit_title => "Minimum Credits*"; //done in mobile & web
// //   String get minimum_credit_hint => "Provide minimum credits you require"; //done in mobile & web
// //   String get option_one => "Standing Offer"; //done in mobile & web
// //   String get option_two => "One Time"; //done in mobile & web
// //   String get minimum_credits_offer => //done in web
// //       "This offer does not meet your minimum credit requirement.";

// //   String get speaker_claim_form_field_title =>
// //       "How much prep time did you require for this request?"; //done in web
// //   String get speaker_claim_form_field_title_hint => "Prep time in hours"; //done in web
// //   String get speaker_claim_form_text_1 =>
// //       "I acknowledge that I have completed the session for the request."; //done in web
// //   String get speaker_claim_form_text_2 =>
// //       "Upon completing the one to many request, the combined prep time and session hours will be credited to you."; //done in web
// //   String get registration_link => "Registration Link"; //done in mobile & web
// //   String get registration_link_hint => "Ex: Eventbrite link, etc."; //done in mobile & web
// //   String get request_closed => "Request closed"; //done in mobile & web
// //   String get speaker_claim_credits => 'Claim credits'; //done in mobile & web
// //   String get requested_for_completion =>
// //       "Your completed request is pending approval."; //done in mobile & web
// //   String get this_request_has_now_ended => "This request has now ended"; //done in web
// //   String get maximumNoOfParticipants =>
// //       'This request has a maximum number of participants. That limit has been reached.'; //done in web
// //   String get reject_request_completion => //done in mobile & web
// //       "Are you sure you want to reject this request for completion?";

// //   String get speaker_reject_invite_dialog => //done in mobile & web
// //       "Are you sure you want to reject this invitation to speak?";

// //   String get join_community_alert => //already in json  //done in web
// //       "This action is only available to members of Community **CommunityName. Please request to join the community first before you can perform this action.";

// //   String get switch_community => //done in mobile & web //already in json
// //       "You need to switch Seva Communities in order to access Groups in another Community.";

// //   String get sign_in_alert =>
// //       "You need to sign in or register to view this."; //done in web //already in json
// //   String get explore_page_title_text => "Explore Opportunities"; //done in mobile & web
// //   String get explore_page_subtitle_text => //done in mobile & web //already in json
// //       "Find communities near you or online communities that interest you. You can offer to volunteer your services or request any assistance or search for Community Events.";

// //   String get select_speaker_hint => "Ex: Name of speaker."; //done in mobile & web
// //   String get my_groups => "My Groups"; //done in mobile & web
// //   String get onetomanyrequest_create_new_event => //done in mobile & web
// //       "A new event will be created and linked to this request.";

// //   String get speaker_requested_completion_notification =>
// //       "This request has been completed."; //done web
// //   String get request_completed_by_speaker =>
// //       "This request has been completed and is awaiting your approval."; //done in mobile & web
// //   String get speaker => 'Speaker'; //done in mobile & web
// //   String get speaker_completion_rejected_notification_1 => "Request rejected."; //done in web
// //   String get you_are_the_speaker => "You are the speaker for: "; //done in web
// //   String get select_a_speaker => "Please select a Speaker*"; //done in web
// //   String get selected_speaker => "Selected Speaker"; //done in web
// //   String get speaker_accepted_invite_notification =>
// //       "This request has been accepted by **speakerName."; //done in web
// //   String get oneToManyRequestSpeakerAcceptRequest =>
// //       'Are you sure you want to accept this request?'; //done in web
// //   String get resetPasswordSuccess =>
// //       'An email has been sent. Please follow the steps in the email to reset your password.'; //done in web
// //   String get bundlePricingInfoButton =>
// //       'There is a limit to the number of transactions in the free tier. You will be charged \$2 for a bundle of 50 transactions.'; //done in web
// //   String get insufficientSevaCreditsDialog =>
// //       'You do not have sufficient Seva credits to create this request. You need to have *** more Seva credits'; //done in web
// //   String get adminNotificationInsufficientCredits =>
// //       ' Has Insufficient Credits To Create Requests'; //done in web
// //   String get adminNotificationInsufficientCreditsNeeded => 'Credits Needed: '; //done in web
// //   String get oneToManyRequestSpeakerWithdrawDialog =>
// //       'Please confirm that you would like to withdraw as a speaker'; //done in web
// //   String get speakerRejectedNotificationLabel =>
// //       ' rejected the Speaker invitation for '; //done in web
// //   String get speaker_rejected => 'Speaker Rejected'; //done in web
// //   String get people_applied_for_request => ' people have applied for this request'; //done in web
// //   String get oneToManyRequestCreatorCompletingRequestDialog =>
// //       'Are you sure you want to accept and complete this request?'; //done in web
// //   String get duration_of_session => 'Duration of Session: '; //done in web
// //   String get time_to_prepare => 'Time to prepare: '; //done in web
// //   String get hours => 'hours'; //done in web
// //   String get hour => 'hour'; //done in web
// //   String get speaker_complete_page_text_1 =>
// //       'I acknowledge that speaker_name has completed the request. The list of members provided above attended the request.'; //done in web
// //   String get speaker_complete_page_text_2 =>
// //       'Note: The hours will be credited to the speaker and to the attendees upon your approval. This list of attendees cannot be modified after approval.'; //done in web
// //   String get action_restricted_by_owner =>
// //       'This action is Restricted for you by the owner of the seva Community.'; //done in web
// //   String get accepted_this_request => 'You have accepted this request.'; //done in web
// //   String get onetomanyrequest_member_invite_notif_subtitle =>
// //       'admin_name in community_name has invited you to join the webinar_name on date_webinar at time_webinar. Tap to accept the invitation.'; // done in web
// //   String get select_a_speaker_dialog => 'Select a speaker';

// //   String get onetomanyrequest_title_hint => "Ex: Implicit Bias webinar."; //done in web
// //   String get total_no_of_participants => "Total No. of Participants*"; //done in web
// //   String get onetomanyrequest_participants_or_credits_hint => "Ex: 40."; //done in web
// //   String get speaker_invite_notification => "Added you as the Speaker for request: "; //done in web
// //   String get sandbox_already_created_1 =>
// //       "Only one sandbox community is currently allowed for each SevaX member."; //done in web
// //   String get sandbox_community => "Sandbox Community"; //done in web
// //   String get sandbox_dialog_title => "Sandbox seva community"; //done in web
// //   String get sandbox_create_community_alert =>
// //       "Are you sure you want to create a sandbox community?"; //done in web
// //   String get you_are_on_enterprise_plan => "You are on Enterprise Plan"; //done in web
// //   String get sandbox_dialog_subtitle =>
// //       "Sandbox Seva communities are created for instructional purposes only. Any credits earned or debited will not count towards your account."; //done in web

// // // labels added on june 11
// //   String get create_community_upload_image_text => "Upload an image to represent your community";

// //   String get create_community_select_categories_text => "Select categories for your community";

// //   String get create_community_negative_threshold_text => "Negative credits threshold";

// //   String get choose_plan => "Choose Plan";

// //   String get new_comminity_message => "Select a child or branch community";

// //   String get go_to_community_chat => "View child community Messaging Rooms";

// //   String get no_child_communities => "No child communities";

// //   String get community_chat => "Child Messaging Rooms";

// // // }

// //   String get add_cover_picture => "Add Cover Picture";

// //   String get or_drag_and_drop => "or drag and drop";

// //   String get cover_picture_label => "Seva Community Cover Picture";

// //   String get cover_picture_label_group => "Group Cover Picture";

// //   String get cover_picture_label_event => "Event Cover Picture";

// //   String get crop_photo => "Crop Photo";

// //   String get my_request_categories => "My Request Subcategories";

// //   String get add_new_request_category => "Add new request subcategory";

// //   String get edit_request_category => "Edit subcategory";

// //   String get add_new_subcategory => "Add new subcategory";

// //   String get add_new_subcategory_hint => "Subcategory title";

// //   String get select_photo => "Select Photo";

// //   String get photo_selected => "Photo Selected";

// //   String get please_enter_title => "Please enter title";

// //   String get request_category_exists => "Request subcategory exists";

// //   String get no_subcategories_created => "No Request Subcategories Created";

// //   String get change_pricing_options => 'Change Pricing Options';

// //   String get occurrences => "Occurrences";

// // //13 july
// //   String get share_post_new => 'Share Post';

// //   String get this_is_a_repeating_request => "This is a repeating request";

// //   String get other_payment_title_hint => "Ex: IndieGoGo or Revolut";

// //   String get other_payment_details_hint => "Ex: Email, Phone Number, ID";

// //   String get other_payment_details => "Payment Method Details";

// //   String get other_payment_name => "Payment Method Name";

// //   String get deleted_events_create_request_message =>
// //       "This event is going to be deleted. As a result, requests cannot be created.";

// //   String get communities => "Communities";

// // // 28th July
// //   String get accept_offer_invitation_confirmation_to_do_tasks =>
// //       "This task will be added to your To Do list, after you approve it.";

// // //29th july
// //   String get careers_explore => "Careers";

// //   String get communities_explore => "Communities";

// //   String get discover_explore => "Discover";

// //   String get diversity_belonging_explore => "Diversity Belonging";

// //   String get guidebooks_explore => "Guidebooks";

// //   String get hosting_explore => "Hosting";

// //   String get host_a_community_explore => "Host a community";

// //   String get organize_an_event_explore => "Organize an event";

// //   String get policies_explore => "Policies";

// //   String get news_explore => "News";

// //   String get trust_and_safety_explore => "Trust & Safety";

// // //30th July
// //   String get loan_success => "You have donated credits successfully";

// //   String get yes => "Yes";

// //   String get no => "No";

// //   //3rd August 2021
// //   // String get admin_borrow_request_received_back_check =>
// //   //     "If you have received your item/place back click the button below to complete this.";

// //   String get borrow_request_title => "Borrow Request";

// //   String get your_location => "Your location";

// //   String get your_location_subtext => "location will help members to connect easily.";

// //   String get refund_deposit => "Refundable Deposit Needed?";

// //   String get maintain_clean => "Maintenance and Cleanliness";

// //   // 4th August
// //   String get provide_address => "Please provide particular area or zipcode";

// //   String get borrow_request_lender => "Borrow Request Lender";

// //   String get borrow_request_lender_pending_return_check =>
// //       "Borrow Request Lender - Return Acknowledgment Pending (tap to complete request)";

// //   String get borrow_request_creator_awaiting_confirmation =>
// //       "Borrow Request - Awaiting Lender Confirmation";

// //   String get details_of_the_request => "Details of the Request";

// //   String get details_of_the_request_subtext_item =>
// //       "Please provide details of the item(s); agreement and location";

// //   String get details_of_the_request_subtext_place =>
// //       "Please provide details of the place; agreement and location";

// //   String get accept_borrow_request => "Accept Borrow Request";

// //   String get provide_item_for_lending => "Provide item(s) for lending";

// //   String get provide_place_for_lending => "Provide a place for lending*";

// //   String get address => 'Address';

// //   String get address_of_location => 'Address of location';

// //   String get send => 'Send';

// //   //4th aug
// //   String get request_payment_description => "Payment Method*";

// //   String get accept_borrow_agreement_page_hint =>
// //       "Please fill in your Item details, agreement and location of your place to help the borrower.";

// //   String get accept_borrow_agreement_place_title => "Details of the offer";

// //   //below labels yet to be added lending item labels
// //   String get add_new_item => "Add New Item";

// //   String get update_item => "Update Item";

// //   String get add_images_to_item => "Add One/Multiple Images of the item";

// //   String get name_of_item => "Name of your item";

// //   String get add_item => "Add Item";

// //   String get validation_error_item_name => "Please enter name of your item";

// //   String get validation_error_item_images => "Please add item images";

// //   String get updating_item => "Updating item";

// //   String get creating_item => "Creating item";

// //   String get creating_item_error => "There was error creating your item, Please try again.";

// //   String get updating_item_error => "There was error creating your item, Please try again.";

// //   String get applied_for_request => 'You have accepted the request';

// //   String get agreement_to_be_signed => 'Agreement to be signed';

// //   String get agreement_signed => 'You have signed the agreement';

// //   String get responses => 'Responses';
// //   String get you_have_received_responses => 'You have received ** response***.';
// //   String get lenders => "Lenders";
// //   String get already_accepted_lender => "You have already accepted a lender for this request.";

// //   //10 Aug
// //   String get borrow_request_agreement => 'Borrow Request Agreement';

// //   String get lending_offer_agreement => 'Lending Offer Agreement';

// //   String get lease_duration => 'Lease Duration: ';

// //   String get agreement_id => 'Agreement ID: ';

// //   String get agreement_details => 'Agreement Details: ';

// //   String get lenders_specific_conditions => "Lender's Specific Conditions: ";

// //   String get terms_of_service => 'Terms of Service: ';

// //   String get please_note => 'Please Note:';

// //   String get borrow_lender_dispute =>
// //       'In the real world and online, communities and community members sometimes disagree. If you have a dispute with another Community member, we hope that you will be able to work it out amicably." ';

// //   String get civil_code_dispute =>
// //       'Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: "A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party." ';

// //   String get agreement_amending_disclaimer =>
// //       'If the lender and borrower adjust the return date of the item as defined in the agreement, it is the responsibility of the parties involved to maintain the agreement extension and it is not included in this process or the responsibility of Seva Exchange.';

// //   String get lender => 'Lender';

// //   String get borrower => 'Borrower';

// //   String get lender_acknowledged_feedback =>
// //       "The Lender has acknowledged completion of this request. Tap to leave a feedback.";

// //   String get offering_place_to => 'You are offering a place to ';
// //   String get offering_items_to => 'You are offering item(s) to ';

// //   String get length_of_stay => 'Length of stay between:  ';

// //   String get items_returned => 'Item(s) Returned';
// //   String get checked_in => 'Checked In';
// //   String get checked_out => 'Checked Out';
// //   String get check_out => 'Check Out';
// //   String get check_in => 'Check In';
// //   String get check_in_pending => 'Check in pending';

// //   String get returned_items => 'Returned Item(s)';
// //   String get lent_to => 'Lent to: ';
// //   String get place_not_added => 'Place not added';
// //   String get items_not_added => 'Item(s) not added';

// //   String get offer_agreement_not_available => 'Request agreement not available';

// //   String get click_to_view_offer_agreement => 'Click to view offer agreement';
// //   String get join_borrow_request => 'Invited to accept request';
// //   String get lender_not_created_agreement => 'Lender has not created an agreement for this offer';
// //   String get admin_borrow_request_received_back_check =>
// //       "If you have received your item/place back click the button below to complete this."; //add again label changed
// //   String get please_add_amenities => "Please add Amenities";
// //   String get items_taken => "Item(s) taken";
// //   String get arrived => "Arrived";
// //   String get departed => "Departed";

// //   String get please_return_by => "Please return by: ";
// //   String get items_returned_to_lender => "You have returned the item(s) to the lender, ";
// //   String get exchanged_completed => "Exchange completed";
// //   String get your_departure_date_is => "Your departure date is:";
// //   String get you_departed_on => "You departed on:";
// //   String get arrival => "Arrival";
// //   String get arrive => "Arrival";
// //   String get departure => "Departure";
// //   String get notes => "Notes";
// //   String get share_feedback_place => "You can leave a appreciation review for your host.";
// //   String get share_feedback_item => "Please provide your valuable feedback about your exchange.";

// // //Borrow/Lending idle notifications Labels below
// //   String get idle_borrow_request_first_warning =>
// //       "*** weeks have passed without any interest. please re-evaluate this request or withdraw.";
// //   String get idle_borrow_request_second_warning =>
// //       "*** weeks have passed without any interest. Please note that this request will be deleted if there is still no acitivty after 14 more days";
// //   String get idle_borrow_request_third_warning_deleted =>
// //       "This request has now been deleted due to inactivity for the past 6 weeks.";

// //   String get idle_lending_offer_first_warning =>
// //       "*** weeks have passed without any interest. please re-evaluate this offer or withdraw.";
// //   String get idle_lending_offer_second_warning =>
// //       "*** weeks have passed without any interest. Please note that this offer will be deleted if there is still no acitivty after 14 more days";
// //   String get idle_lending_offer_third_warning_deleted =>
// //       "This offer has now been deleted due to inactivity for the past 6 weeks.";
// //   String get idle_for_4_weeks => " has been idle for 4 weeks";
// //   String get idle_for_2_weeks => " has been idle for 2 weeks";

// //   String get change_departure_date => 'Change departure date?';
// //   String get tab_to_leave_feedback => 'Tap to leave a feedback.';
// //   String get lending_offer_return_items_hint => 'Click here if you have returned the item(s).';
// //   String get lending_offer_return_place_hint => 'Click here if you have checked out of the place';

// //   String get check_out_alert => 'Are you sure you want to check out?';
// //   String get add_new => "Add new";
// //   String get end_date_after_offer_end_date_place =>
// //       "The check out date is after the offer end date. Please edit your offer end date or select a date before offer end date to approve this request.";
// //   String get end_date_after_offer_end_date_item =>
// //       "The return date is after the offer end date. Please edit your offer end date or select a date before offer end date to approve this request.";
// //   String get completed_lending_offer => "Completed Lending Offer";

// //   //Transaction Details Labels - Requests
// //   String get error_loading_status => "error loading status";
// //   String get download_pdf => "Download PDF";

// //   String get time_applied_request_tag => "applied for request";
// //   String get time_withdrawn_request_tag => "withdrew from request";
// //   String get time_request_approved_tag => "request was approved";
// //   String get time_request_rejected_tag => "request was rejected";
// //   String get time_claim_credits_tag => "claimed credits";
// //   String get time_claim_accepted_tag => "claim accepted";
// //   String get time_claim_declined_tag => "claim declined";

// //   String get goods_pledged_by_donor_tag => "goods pledged by donor";
// //   String get goods_acknowledged_donation_tag => "goods donation acknowledged";
// //   String get goods_donation_modified_by_creator_tag => "goods donation modified by creator";
// //   String get goods_donation_modified_by_donor_tag => "goods donation modified by donor";
// //   String get goods_donation_creator_rejected_tag => "goods donation rejected";

// //   String get money_acknowledged_donation_tag => "money donation acknowledged";
// //   String get money_donation_modified_by_creator_tag => "money donation modified by creator";
// //   String get money_donation_modified_by_donor_tag => "money donation modified by donor";
// //   String get money_donation_creator_rejected_tag => "money donation rejected";

// //   String get account_balance => "Account Balance\n";

// //   String get item_s => "item(s)";
// //   String get sent => "Sent";

// //   //6th Aug
// //   String get completed_events => "Completed Events";

// //   //todo::17th sep update labels
// //   String get any_distance => "Any Distance";
// //   String get sponsor_details => "Sponsor Details";
// //   String get add_sponsor => "Add Sponsor";
// //   String get donate_text => "Donate";
// //   String get try_oska_postal_code => "Try \"Oska\" \"Postal Code\"";
// //   String get new_message_text => "new message";
// //   String get new_messages_text => "new messages";
// //   String get external_url_text => "External Url";
// //   String get deletion_request_text => "Deletion Request";
// //   String get has_worked_for_text => "has worked for";
// //   String get hours_text => "hours";
// //   String get has_reviewed_this_request_text => "has reviewed this request";
// //   String get tap_to_share_feedback_text => "Tap to share feedback";
// //   String get people_signed_up_text => "people signed up";
// //   String get has_invited_you_to_join_their => "has invited you to join their";
// //   String get seva_community_seva_means_selfless_service_in_Sanskrit =>
// //       "Seva Community. Seva means \"selfless service\" in Sanskrit";
// //   String get seva_ommunities_are_based_on_a_mutual_reciprocity_system =>
// //       "Seva Communities are based on a mutual-reciprocity system";
// //   String get where_community_members_help_each_other_out_in_exchange_for_seva_credits_that_can_be_redeemed_for_services_they_need =>
// //       "where community members help each other out in exchange for Seva Credits that can be redeemed for services they need";
// //   String get to_learn_more_about_being_a_part_of_a_Seva_Community_here_s_a_short_explainer_video =>
// //       "To learn more about being a part of a Seva Community, here\'s a short explainer video";
// //   String get here_is_what_you_ll_need_to_know => "Here is what you'll need to know";
// //   String get first_text => "First";
// //   String get depending_on_where_you_click_the_link_from_whether_it_s_your_web_browser_or_mobile_phone =>
// //       "depending on where you click the link from, whether it\'s your web browser or mobile phone";
// //   String get the_link_will_either_take_you_to_our_main =>
// //       "the link will either take you to our main";
// //   String get web_page_where_you_can_register_on_the_web_directly_or_it_will_take_you_from_your_mobile_phone_to_the_App_or_google_play_stores =>
// //       "web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores";
// //   String get where_you_can_download_our_SevaX_App_Once_you_have_registered_on_the_SevaX_mobile_app_or_the_website =>
// //       "where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website";
// //   String get you_can_explore_Seva_Communities_near_you_Type_in_the =>
// //       "you can explore Seva Communities near you. Type in the";
// //   String get and_enter_code_text => "and enter code";
// //   String get when_prompted_text => "when prompted";
// //   String get click_to_Join_text => "Click to Join";
// //   String get and_their_Seva_Community_via_this_dynamic_link_at =>
// //       "and their Seva Community via this dynamic link at";
// //   String get thank_you_for_being_a_part_of_our_Seva_Exchange_movement_the_Seva_Exchange_team_Please_email_us_at =>
// //       "Thank you for being a part of our Seva Exchange movement!\n-the Seva Exchange team\n\nPlease email us at support@sevaexchange.com";
// //   String get if_you_have_any_questions_or_issues_joining_with_the_link_given =>
// //       "if you have any questions or issues joining with the link given";
// //   String get you_are_signing_up_for_this_test => "You are signing up for this";
// //   String get doing_so_will_debit_a_total_of => "Doing so will debit a total of";
// //   String get credits_from_you_after_you_say_ok => "credits from you after you say OK";
// //   String get you_don_t_have_enough_credit_to_signup_for_this_class =>
// //       "You don\'t have enough credit to signup for this class";
// //   String get name_not_updated_text => "name not updated";
// //   String get notification_for_new_messages => "Notification for new messages";
// //   String get feeds_notification_text => "Feeds notification";
// //   String get posting_to_text => "Posting to";
// //   String get edit_subsequent_requests => "Edit subsequent requests";
// //   String get edit_this_request_only => "Edit this request only";
// //   String get this_action_is_restricted_for_you_by_the_owner_of_this =>
// //       "This action is restricted for you by the owner of this";

// // ////////////////////////////////////////////////////////////////------------------------------------>
// //   ///
// //   ///
// //   ///todo: 20th september updated labels (ALL Below have been integrated to code)
// //   String get lending_offer_title_hint_item => "Ex: Offering to lend a lawnmower.";
// //   String get lending_offer_description_hint_item =>
// //       "Provide a detailed description of the item you would like to lend.";
// //   String get lending_offer_description_hint_place =>
// //       "Provide a detailed description of the place you would like to lend including number of rooms, number of beds, etc.";
// //   String get name_of_item_hint => "Ex: Lawnmower";
// //   String get bath_rooms => "Bathroom(s)";
// //   String get item_returned_hint_text => 'Ex: item(s) must be returned in the same condition.';
// //   String get common_spaces => "Common Space";
// //   String get house_rules_hint => "Ex: No Smoking";
// //   String get borrow_request_title_hint_item => "Ex: Lawnmower";
// //   String get borrow_request_description_hint_item =>
// //       "Provide a detailed description of the item you would like to borrow.";
// //   String get borrow_request_description_hint_place =>
// //       "Provide a detailed description of the place you would like to borrow including number of rooms, number of beds, etc.";
// //   String get accept_borrow_agreement_place_hint =>
// //       "Please provide details about your place, the proposed agreement and location of the property.";
// //   String get select_a_place_lending => "Select a place to lend*";
// //   String get select_item_for_lending => "Select an item to lend*";

// //   String get search_agreement_hint_place => "Enter name of a property agreement template";
// //   String get search_agreement_hint_item => "Enter name of an item agreement template";
// //   String get accept_place_borrow_request => "Accept Place Borrow Request";
// //   String get accept_item_borrow_request => "Accept Item Borrow request";
// //   String get accept_place_lending_offer => "Accept Place Lending Offer";
// //   String get accept_item_lending_offer => "Accept Item Lending Offer";
// //   String get request_agreement_form_component_text =>
// //       'Create the proposed agreement between you and the borrower regarding the property. Use previous agreements if appropriate.';
// //   String get lender_not_accepted_request_msg_place =>
// //       "Lender is providing the property request with no agreement required";
// //   String get lender_not_accepted_request_msg_item =>
// //       "Lender is providing the item(s) request with no agreement required";
// //   String get already_accepted_lender_place =>
// //       "You have already accepted a property for this request";
// //   String get already_accepted_lender_item => "You have already accepted an item for this request";
// //   String get admin_borrow_request_received_back_check_place =>
// //       "If you have received your place back from the borrower, please click the button below to complete this transaction";
// //   String get admin_borrow_request_received_back_check_item =>
// //       "If you have received your item(s) back from the borrower, please click the button below to complete this transaction";

// //   String get lend => "Lend";

// //   String get date_to_check_in_out => "Date of Check In and expected Check Out";

// // //Lending offers labels updates below ////---------------->
// //   String get estimated_value_hint_place =>
// //       " (This is the amount based on the property's rental value, including amenities)";
// //   String get estimated_value_hint_item => " (This is the amount based on the item's current value)";
// //   String get lending_offer_location_hint =>
// //       'Provide the information regarding the location you would like to lend';
// //   String get end_date_after_offer_end_date =>
// //       "The dates selected are outside the scope of this offer. Please review and edit your requested dates to approve this request.";
// //   String get lending_offer_check_in_tag => 'Lending Offer - Check In';
// //   String get lending_offer_check_out_tag => 'Lending Offer - Check Out';

// //   String get would_like_to_accept_offer => "Would you like to accept this offer?";
// //   String get withdraw_lending_offer => 'Click here if you want to withdraw your request';
// //   String get borrower_departed_provide_feedback =>
// //       'You checked out as noted above. Tap to leave a feedback.';
// //   String get validation_error_no_of_bathrooms => "Please enter no of bathrooms available";
// // // ----------------------------------------------------------------------------------->

// // //new labels
// //   String get offer_start_date_validation => "Please enter start date";
// //   String get lease_start_date => 'Lease Start Date: ';
// //   String get agreement_accepted => 'Accepted without agreement';

// //-------------------------------------------------------->
// //-------------------------------------------------------->
// // 24th September - LABEL UPDATES (more updates to be added)

// // 29th September - LABEL UPDATES (more updates to be added) ------------------------>
//   //Finalised By Anitha Below ------------------->
//   String get agreement_damage_liability =>
//       "The Borrower is responsible for the full cost of repair or replacement of any or all of the item(s) or properties that are damaged, lost, or stolen from the time the Borrower assumes custody until it is returned to the Lender, unless otherwise agreed at the time the agreement is finalized. If the item(s) or property(s) is lost, stolen or damaged, Borrower agrees to promptly notify the Lender Representative designated above.";
//   String get agreement_user_disclaimer =>
//       "The Borrower shall be responsible for the proper use and deployment of the item(s) or property. The Borrower shall be responsible for training anyone using the item(s) on the proper use of the item(s) in accordance with any item(s) use procedures.";

//   String get agreement_delivery_return =>
//       "The item(s) subject to this Agreement shall remain with Lender. The Borrower shall be responsible for the safe packaging, proper import, export, shipping and receiving of the item(s). The item(s) shall be returned within a reasonable amount of time after the loan duration end date identified.";
//   String get agreement_maintain_and_repair =>
//       'Except for reasonable wear and tear, Item(s) shall be returned to Lender in as good condition as when received by the Borrower. During the loan duration and prior to return, the Borrower agrees to assume all responsibility for maintenance and repair.';

//   String get agreement_refund_deposit =>
//       "The Borrower will provide a refundable deposit as defined within the agreement with the Lender. The criteria established regarding the condition of the item(s) or property upon return will also be defined in the agreement.";
//   String get agreement_maintain_and_clean =>
//       "All item(s) or property borrowed must be returned in a condition similar to the condition it is received by the Borrower, unless otherwise noted in the agreement. Specific details related to the item(s) or property and the Lender's requirements upon return should be noted in the contract and agreed upon prior to the Borrower's receipt.";
// //Above Finalised by Anitha
//   String get estimated_value_item_hint => "Ex: \$100";
//   String get estimated_value_place_hint => "Ex: \$2000";
//   String get place_agreement_name_hint_place => "Ex: Room in New York";
//   String get place_agreement_name_hint_item =>
//       "Ex: Lawnmower for the weekend"; //done
//   String get seva_exchange_text_new =>
//       "By continuing, you agree to Seva Exchange's"; //done
//   String get agree_to_signature_legal_text => //done
//       "By accepting the conditions, your electronic signature is assumed and you are responsible for all terms within this agreement.";
//   String get choose_previous_agreement => "Choose Previous Agreement";
//   String get borrower_returned_items_feedback =>
//       'You returned item(s). Tap to leave a feedback.';
//   String get cannot_approve_multiple_borrowers_item =>
//       "You cannot approve multiple borrowers at once. Currently the item(s) are with **name. Once returned you can approve this request.";

//change ownership nlabels
  // String get change_ownership_successful =>
  //     "You have successfully transferred ownership of **groupName to **newOwnerName.";
  // String get changed_ownership_of_text => "changed ownership of";
  // String get to_text => "to";
  // String get credits_credited => "Seva Credits Earned";
  // String get transfer_ownership_text => "Transfer Ownership";
  // String get you_have_been_made_the_new_owner_of_group_name_subtitle => "You have been made the new owner of";
  // String get direction_for_manage_transfer_ownership =>
  //     "Go to your group Manage tab and then select a new group member to transfer ownership.";
  // String get be_sure_message_text => "Be sure to check with the member first by messaging them.";
  // String get removed_you_from_text => "removed you from";
  // String get note_for_transfer_ownership_notification =>
  //     "Note: If you cannot fulfil this role or if you believe this was done in error please click here.";
  // String get transfer_of_group_ownership_update => "Transfer of group ownership update.";
  // String get directions_text => "Directions";
  // String get link_for_demo_video_text => "Link for demo video:";

  //todo:: lables
  //
  String get seva_credit_s => "Seva Credit(s)";
  String get minimum_ten_characters => "Enter minimum 10 Characters ";
}
