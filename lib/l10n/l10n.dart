// File generated with arbify_flutter.
// DO NOT MODIFY BY HAND.
// ignore_for_file: lines_longer_than_80_chars, non_constant_identifier_names
// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class S {
  final String localeName;

  const S(this.localeName);

  static const delegate = ArbifyLocalizationsDelegate();

  static Future<S> load(Locale locale) {
    final localeName = Intl.canonicalizedLocale(locale.toString());

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  }

  static S of(BuildContext context) => Localizations.of<S>(context, S);

  String get check_met => Intl.message(
        'Checking, if we met before',
        name: 'check_met',
      );

  String get we_met => Intl.message(
        'We met before',
        name: 'we_met',
      );

  String get hang_on => Intl.message(
        'Hang on tight',
        name: 'hang_on',
      );

  String get updating => Intl.message(
        'Updating',
        name: 'updating',
      );

  String get skipping => Intl.message(
        'Skipping',
        name: 'skipping',
      );

  String get skills => Intl.message(
        'skills',
        name: 'skills',
      );

  String get interests => Intl.message(
        'interests',
        name: 'interests',
      );

  String get email => Intl.message(
        'email',
        name: 'email',
      );

  String get password => Intl.message(
        'password',
        name: 'password',
      );

  String get login_agreement_message1 => Intl.message(
        'By continuing, you agree to SevaX',
        name: 'login_agreement_message1',
      );

  String get login_agreement_terms_link => Intl.message(
        'Terms of Service',
        name: 'login_agreement_terms_link',
      );

  String get login_agreement_message2 => Intl.message(
        'We will manage information as described in our',
        name: 'login_agreement_message2',
      );

  String get login_agreement_privacy_link => Intl.message(
        'Privacy Policy',
        name: 'login_agreement_privacy_link',
      );

  String get and => Intl.message(
        'and',
        name: 'and',
      );

  String get login_agreement_payment_link => Intl.message(
        'Payment Policy',
        name: 'login_agreement_payment_link',
      );

  String get new_user => Intl.message(
        'New User',
        name: 'new_user',
      );

  String get sign_up => Intl.message(
        'Sign up',
        name: 'sign_up',
      );

  String get sign_in => Intl.message(
        'Sign in',
        name: 'sign_in',
      );

  String get forgot_password => Intl.message(
        'Forgot Password',
        name: 'forgot_password',
      );

  String get reset => Intl.message(
        'Reset',
        name: 'reset',
      );

  String get sign_in_with_google => Intl.message(
        'Sign in with Google',
        name: 'sign_in_with_google',
      );

  String get or => Intl.message(
        'or',
        name: 'or',
      );

  String get sign_in_with_apple => Intl.message(
        'Sign in with Apple',
        name: 'sign_in_with_apple',
      );

  String get check_internet => Intl.message(
        'Please check your internet connection.',
        name: 'check_internet',
      );

  String get dismiss => Intl.message(
        'Dismiss',
        name: 'dismiss',
      );

  String get enter_email => Intl.message(
        'Enter email',
        name: 'enter_email',
      );

  String get your_email => Intl.message(
        'Your email address',
        name: 'your_email',
      );

  String get reset_password => Intl.message(
        'Reset Password',
        name: 'reset_password',
      );

  String get cancel => Intl.message(
        'Cancel',
        name: 'cancel',
      );

  String get validation_error_invalid_email => Intl.message(
        'Email is not valid',
        name: 'validation_error_invalid_email',
      );

  String get validation_error_invalid_password => Intl.message(
        'Password must be 6 characters long',
        name: 'validation_error_invalid_password',
      );

  String get change_password => Intl.message(
        'Change password',
        name: 'change_password',
      );

  String get enter_password => Intl.message(
        'Enter password',
        name: 'enter_password',
      );

  String get reset_password_message => Intl.message(
        'We\'ve sent the reset link to your email address',
        name: 'reset_password_message',
      );

  String get reset_dynamic_link_message => Intl.message(
        'Please check your email to set your password. Then enter that password here.',
        name: 'reset_dynamic_link_message',
      );

  String get close => Intl.message(
        'Close',
        name: 'close',
      );

  String get loading => Intl.message(
        'Loading',
        name: 'loading',
      );

  String get your_details => Intl.message(
        'Your details',
        name: 'your_details',
      );

  String get add_photo => Intl.message(
        'Add Photo',
        name: 'add_photo',
      );

  String get full_name => Intl.message(
        'Full Name',
        name: 'full_name',
      );

  String get confirm => Intl.message(
        'Confirm',
        name: 'confirm',
      );

  String get validation_error_full_name => Intl.message(
        'Name cannot be empty',
        name: 'validation_error_full_name',
      );

  String get validation_error_password_mismatch => Intl.message(
        'Passwords do not match',
        name: 'validation_error_password_mismatch',
      );

  String get add_photo_hint => Intl.message(
        'Do you want to add profile pic?',
        name: 'add_photo_hint',
      );

  String get skip_and_register => Intl.message(
        'Skip and register',
        name: 'skip_and_register',
      );

  String get creating_account => Intl.message(
        'Creating account',
        name: 'creating_account',
      );

  String get update_photo => Intl.message(
        'Update Photo',
        name: 'update_photo',
      );

  String get validation_error_email_registered => Intl.message(
        'This email already registered',
        name: 'validation_error_email_registered',
      );

  String get gallery => Intl.message(
        'Gallery',
        name: 'gallery',
      );

  String get camera => Intl.message(
        'Camera',
        name: 'camera',
      );

  String get email_sent_to => Intl.message(
        'We sent an email to',
        name: 'email_sent_to',
      );

  String get verify_account => Intl.message(
        'to verify your account',
        name: 'verify_account',
      );

  String get resend_email => Intl.message(
        'Resend mail',
        name: 'resend_email',
      );

  String get login_after_verification => Intl.message(
        'Please login once you have verified your email.',
        name: 'login_after_verification',
      );

  String get verification_sent => Intl.message(
        'Verification email sent',
        name: 'verification_sent',
      );

  String get verification_sent_desc => Intl.message(
        'Verification email was sent to your registered email',
        name: 'verification_sent_desc',
      );

  String get log_in => Intl.message(
        'Log in',
        name: 'log_in',
      );

  String get check_email => Intl.message(
        'Now check your email.',
        name: 'check_email',
      );

  String get thanks => Intl.message(
        'Thanks!',
        name: 'thanks',
      );

  String get eula_title => Intl.message(
        'EULA Agreement',
        name: 'eula_title',
      );

  String get eula_delcaration => Intl.message(
        'I agree that I am willing to adhere to these Terms and Conditions.',
        name: 'eula_delcaration',
      );

  String get proceed => Intl.message(
        'Proceed',
        name: 'proceed',
      );

  String get skills_description => Intl.message(
        'What skills are you good at that you\'d like to share with your community?',
        name: 'skills_description',
      );

  String get no_matching_skills => Intl.message(
        'No matching skills found',
        name: 'no_matching_skills',
      );

  String get search => Intl.message(
        'Search',
        name: 'search',
      );

  String get update => Intl.message(
        'Update',
        name: 'update',
      );

  String get next => Intl.message(
        'Next',
        name: 'next',
      );

  String get skip => Intl.message(
        'Skip',
        name: 'skip',
      );

  String get interests_description => Intl.message(
        'What are some of your interests and passions that you would be willing to share with your community?',
        name: 'interests_description',
      );

  String get no_matching_interests => Intl.message(
        'No matching interests found',
        name: 'no_matching_interests',
      );

  String get bio => Intl.message(
        'Bio',
        name: 'bio',
      );

  String get bio_description => Intl.message(
        'Please tell us a little about yourself in a few sentences. For example, what makes you unique.',
        name: 'bio_description',
      );

  String get bio_hint => Intl.message(
        'Tell us a little about yourself.',
        name: 'bio_hint',
      );

  String get validation_error_bio_empty => Intl.message(
        'It\'s easy, please fill few words about you.',
        name: 'validation_error_bio_empty',
      );

  String get validation_error_bio_min_characters => Intl.message(
        'Min 50 characters *',
        name: 'validation_error_bio_min_characters',
      );

  String get join => Intl.message(
        'Join',
        name: 'join',
      );

  String get joined => Intl.message(
        'Joined',
        name: 'joined',
      );

  String get timebanks_near_you => Intl.message(
        'Timebanks near you',
        name: 'timebanks_near_you',
      );

  String get find_your_timebank => Intl.message(
        'Find your Timebank',
        name: 'find_your_timebank',
      );

  String get looking_existing_timebank => Intl.message(
        'Looking for an existing Timebank to join',
        name: 'looking_existing_timebank',
      );

  String get find_timebank_help_text => Intl.message(
        'Type your Timebank name. Ex: Alaska (min 1 char)',
        name: 'find_timebank_help_text',
      );

  String get no_timebanks_found => Intl.message(
        'No Timebanks found',
        name: 'no_timebanks_found',
      );

  String get timebank => Intl.message(
        'Timebank',
        name: 'timebank',
      );

  String get created_by => Intl.message(
        'Created by',
        name: 'created_by',
      );

  String get create_timebank => Intl.message(
        'Create a Timebank',
        name: 'create_timebank',
      );

  String get timebank_gps_hint => Intl.message(
        'Please make sure you have GPS turned on to see the list of Timebanks around you',
        name: 'timebank_gps_hint',
      );

  String get create_timebank_confirmation => Intl.message(
        'Are you sure you want to create a new Timebank - as opposed to joining an existing Timebank? Creating a new Timebank implies that you will be responsible for administering the Timebank - including adding members and managing members’ needs, timely replying to members questions, bringing about conflict resolutions, and hosting monthly potlucks. In order to become a member of an existing Timebank, you will need to know the name of the Timebank and either have an invitation code or submit a request to join the Timebank.',
        name: 'create_timebank_confirmation',
      );

  String get try_later => Intl.message(
        'Please try again later',
        name: 'try_later',
      );

  String get log_out => Intl.message(
        'Logout',
        name: 'log_out',
      );

  String get log_out_confirmation => Intl.message(
        'Are you sure you want to logout?',
        name: 'log_out_confirmation',
      );

  String get requested => Intl.message(
        'Requested',
        name: 'requested',
      );

  String get rejected => Intl.message(
        'Rejected',
        name: 'rejected',
      );

  String get join_timebank_code_message => Intl.message(
        'Enter the code you received from your admin to see the volunteer opportunities.',
        name: 'join_timebank_code_message',
      );

  String get join_timebank_request_invite => Intl.message(
        'Request Invite',
        name: 'join_timebank_request_invite',
      );

  String get join_timebank_request_invite_hint => Intl.message(
        'If you don\'t have a code, Click',
        name: 'join_timebank_request_invite_hint',
      );

  String get join_timbank_already_requested => Intl.message(
        'You already requested to this Timebank. Please wait untill request is accepted',
        name: 'join_timbank_already_requested',
      );

  String get join_timebank_question => Intl.message(
        'Why do you want to join the',
        name: 'join_timebank_question',
      );

  String get reason => Intl.message(
        'Reason',
        name: 'reason',
      );

  String get validation_error_general_text => Intl.message(
        'Please enter some text',
        name: 'validation_error_general_text',
      );

  String get send_request => Intl.message(
        'Send Request',
        name: 'send_request',
      );

  String get code_not_found => Intl.message(
        'Code not found',
        name: 'code_not_found',
      );

  String get validation_error_wrong_timebank_code => Intl.message(
        'code was not registered, please check the code and try again!',
        name: 'validation_error_wrong_timebank_code',
      );

  String get validation_error_join_code_expired => Intl.message(
        'Code Expired!',
        name: 'validation_error_join_code_expired',
      );

  String get join_code_expired_hint => Intl.message(
        'code has been expired, please request the admin for a new one!',
        name: 'join_code_expired_hint',
      );

  String get awesome => Intl.message(
        'Awesome!',
        name: 'awesome',
      );

  String get timebank_onboarding_message => Intl.message(
        'You have been onboarded to',
        name: 'timebank_onboarding_message',
      );

  String get successfully => Intl.message(
        'Successfully',
        name: 'successfully',
      );

  String get validation_error_timebank_join_code_redeemed => Intl.message(
        'Timebank code already redeemed',
        name: 'validation_error_timebank_join_code_redeemed',
      );

  String get validation_error_timebank_join_code_redeemed_self => Intl.message(
        'The Timebank code that you have provided has already been redeemed earlier by you. Please request the Timebank admin for a new code.',
        name: 'validation_error_timebank_join_code_redeemed_self',
      );

  String get code_expired => Intl.message(
        'Code Expired!',
        name: 'code_expired',
      );

  String get enter_code_to_verify => Intl.message(
        'Please enter PIN to verify',
        name: 'enter_code_to_verify',
      );

  String get creating_join_request => Intl.message(
        'Creating Join Request',
        name: 'creating_join_request',
      );

  String get feeds => Intl.message(
        'Feeds',
        name: 'feeds',
      );

  String get projects => Intl.message(
        'Projects',
        name: 'projects',
      );

  String get offers => Intl.message(
        'Offers',
        name: 'offers',
      );

  String get requests => Intl.message(
        'Requests',
        name: 'requests',
      );

  String get about => Intl.message(
        'About',
        name: 'about',
      );

  String get members => Intl.message(
        'Members',
        name: 'members',
      );

  String get manage => Intl.message(
        'Manage',
        name: 'manage',
      );

  String get your_tasks => Intl.message(
        'Your Tasks',
        name: 'your_tasks',
      );

  String get your_groups => Intl.message(
        'Your Groups',
        name: 'your_groups',
      );

  String get pending => Intl.message(
        'Pending',
        name: 'pending',
      );

  String get not_accepted => Intl.message(
        'Not Accepted',
        name: 'not_accepted',
      );

  String get completed => Intl.message(
        'Completed',
        name: 'completed',
      );

  String get protected_timebank => Intl.message(
        'Protected Timebank',
        name: 'protected_timebank',
      );

  String get protected_timebank_group_creation_error => Intl.message(
        'You cannot create groups in a protected Timebank',
        name: 'protected_timebank_group_creation_error',
      );

  String get groups_help_text => Intl.message(
        'Groups Help',
        name: 'groups_help_text',
      );

  String get payment_data_syncing => Intl.message(
        'Payment Data Syncing',
        name: 'payment_data_syncing',
      );

  String get actions_not_allowed => Intl.message(
        'Actions not allowed, Please contact admin',
        name: 'actions_not_allowed',
      );

  String get configure_billing => Intl.message(
        'Configure Billing',
        name: 'configure_billing',
      );

  String get limit_badge_contact_admin => Intl.message(
        'Action not allowed, please contact the admin',
        name: 'limit_badge_contact_admin',
      );

  String get limit_badge_billing_failed => Intl.message(
        'Billing Failed, Click below to configure billing',
        name: 'limit_badge_billing_failed',
      );

  String get limit_badge_delete_in_progress => Intl.message(
        'Your request to delete has been received by us. We are processing the request. You will be notified once it is completed.',
        name: 'limit_badge_delete_in_progress',
      );

  String get bottom_nav_explore => Intl.message(
        'Explore',
        name: 'bottom_nav_explore',
      );

  String get bottom_nav_notifications => Intl.message(
        'Notifications',
        name: 'bottom_nav_notifications',
      );

  String get bottom_nav_home => Intl.message(
        'Home',
        name: 'bottom_nav_home',
      );

  String get bottom_nav_messages => Intl.message(
        'Messages',
        name: 'bottom_nav_messages',
      );

  String get bottom_nav_profile => Intl.message(
        'Profile',
        name: 'bottom_nav_profile',
      );

  String get ok => Intl.message(
        'Ok',
        name: 'ok',
      );

  String get no_group_message => Intl.message(
        'Groups help you to organize your specific activities, you don\'t have any. Try',
        name: 'no_group_message',
      );

  String get creating_one => Intl.message(
        'creating one',
        name: 'creating_one',
      );

  String get general_stream_error => Intl.message(
        'Something went wrong, please try again',
        name: 'general_stream_error',
      );

  String get no_pending_task => Intl.message(
        'No pending tasks',
        name: 'no_pending_task',
      );

  String get from => Intl.message(
        'From',
        name: 'from',
      );

  String get until => Intl.message(
        'Until',
        name: 'until',
      );

  String get posted_by => Intl.message(
        'Posted By',
        name: 'posted_by',
      );

  String get posted_date => Intl.message(
        'Post Date',
        name: 'posted_date',
      );

  String get enter_hours => Intl.message(
        'Enter hours',
        name: 'enter_hours',
      );

  String get select_hours => Intl.message(
        'Select hours',
        name: 'select_hours',
      );

  String hour(num count) => Intl.message(
        '${Intl.plural(count, one: 'Hour', other: 'Hours', args: [count])}',
        name: 'hour',        
        args: [count],
      );

  String get validation_error_task_minutes => Intl.message(
        'Minutes cannot be Empty',
        name: 'validation_error_task_minutes',
      );

  String get minutes => Intl.message(
        'minutes',
        name: 'minutes',
      );

  String get limit_exceeded => Intl.message(
        'Limit exceeded!',
        name: 'limit_exceeded',
      );

  String get task_max_hours_of_credit => Intl.message(
        'Hours of credit from this request.',
        name: 'task_max_hours_of_credit',
      );

  String get validation_error_invalid_hours => Intl.message(
        'Please enter valid number of hours!',
        name: 'validation_error_invalid_hours',
      );

  String get please_wait => Intl.message(
        'Please wait...',
        name: 'please_wait',
      );

  String get task_max_request_message => Intl.message(
        'You can only request a maximum of',
        name: 'task_max_request_message',
      );

  String get there_are_currently_none => Intl.message(
        'There are currently none',
        name: 'there_are_currently_none',
      );

  String get no_completed_task => Intl.message(
        'You have not completed any tasks',
        name: 'no_completed_task',
      );

  String get completed_tasks => Intl.message(
        'Completed Tasks',
        name: 'completed_tasks',
      );

  String get seva_credits => Intl.message(
        'Seva Credits',
        name: 'seva_credits',
      );

  String get no_notifications => Intl.message(
        'No Notifications',
        name: 'no_notifications',
      );

  String get personal => Intl.message(
        'Personal',
        name: 'personal',
      );

  String get notifications_signed_up_for => Intl.message(
        'You had signed up for',
        name: 'notifications_signed_up_for',
      );

  String get on => Intl.message(
        'on',
        name: 'on',
      );

  String get notifications_event_modification => Intl.message(
        '. The Event Owner has modified this event. Make sure the changes made are right for you and apply again.',
        name: 'notifications_event_modification',
      );

  String get notification_timebank_join => Intl.message(
        'Timebank Join',
        name: 'notification_timebank_join',
      );

  String get notifications_added_you => Intl.message(
        'has added you to',
        name: 'notifications_added_you',
      );

  String get notifications_request_rejected_by => Intl.message(
        'Request rejected by',
        name: 'notifications_request_rejected_by',
      );

  String get notifications_join_request => Intl.message(
        'Join request',
        name: 'notifications_join_request',
      );

  String get notifications_requested_join => Intl.message(
        'has requested you to join',
        name: 'notifications_requested_join',
      );

  String get notifications_tap_to_view => Intl.message(
        'Tap to view join request',
        name: 'notifications_tap_to_view',
      );

  String get notifications_task_rejected_by => Intl.message(
        'Task completion rejected by',
        name: 'notifications_task_rejected_by',
      );

  String get notifications_approved_for => Intl.message(
        'approved the task completion for',
        name: 'notifications_approved_for',
      );

  String get notifications_credited => Intl.message(
        'Credited',
        name: 'notifications_credited',
      );

  String get notifications_credited_to => Intl.message(
        'have been credited to your account.',
        name: 'notifications_credited_to',
      );

  String get congrats => Intl.message(
        'Congrats',
        name: 'congrats',
      );

  String get notifications_debited => Intl.message(
        'Debited',
        name: 'notifications_debited',
      );

  String get notifications_debited_to => Intl.message(
        'has been debited from your account',
        name: 'notifications_debited_to',
      );

  String get notifications_offer_accepted => Intl.message(
        'Offer Accepted',
        name: 'notifications_offer_accepted',
      );

  String get notifications_shown_interest => Intl.message(
        'has shown interest in your offer',
        name: 'notifications_shown_interest',
      );

  String get notifications_invited_to_join => Intl.message(
        'has invited you to join',
        name: 'notifications_invited_to_join',
      );

  String get notifications_group_join_invite => Intl.message(
        'Group join invite',
        name: 'notifications_group_join_invite',
      );

  String get notifications_new_member_signup => Intl.message(
        'New member signed up',
        name: 'notifications_new_member_signup',
      );

  String get notifications_credits_for => Intl.message(
        'Credits for',
        name: 'notifications_credits_for',
      );

  String get notifications_signed_for_class => Intl.message(
        'Signed up for class',
        name: 'notifications_signed_for_class',
      );

  String get notifications_feedback_request => Intl.message(
        'Feedback request',
        name: 'notifications_feedback_request',
      );

  String get notifications_was_deleted => Intl.message(
        'was deleted!',
        name: 'notifications_was_deleted',
      );

  String get notifications_could_not_delete => Intl.message(
        'couldn\'t be deleted!',
        name: 'notifications_could_not_delete',
      );

  String get notifications_successfully_deleted => Intl.message(
        '*** has been successfully deleted.',
        name: 'notifications_successfully_deleted',
      );

  String get notifications_could_not_deleted => Intl.message(
        'couldn\'t be deleted because you have pending transactions!',
        name: 'notifications_could_not_deleted',
      );

  String get notifications_incomplete_transaction => Intl.message(
        'We couldn\'t process you request for deletion of ***, as you are still having open transactions which are as :',
        name: 'notifications_incomplete_transaction',
      );

  String get one_to_many_offers => Intl.message(
        'one to many offers',
        name: 'one_to_many_offers',
      );

  String get open_requests => Intl.message(
        'open requests',
        name: 'open_requests',
      );

  String get delete => Intl.message(
        'Delete',
        name: 'delete',
      );

  String get delete_notification_confirmation => Intl.message(
        'Are you sure you want to delete this notification?',
        name: 'delete_notification_confirmation',
      );

  String get delete_notification => Intl.message(
        'Delete notification',
        name: 'delete_notification',
      );

  String get notifications_approved_by => Intl.message(
        'Request approved by',
        name: 'notifications_approved_by',
      );

  String get notifications_request_accepted_by => Intl.message(
        'Request accepted by',
        name: 'notifications_request_accepted_by',
      );

  String get notifications_waiting_for_approval => Intl.message(
        'waiting for your approval.',
        name: 'notifications_waiting_for_approval',
      );

  String get notifications_by_approving => Intl.message(
        'By approving',
        name: 'notifications_by_approving',
      );

  String get notifications_will_be_added_to => Intl.message(
        'will be added to the event',
        name: 'notifications_will_be_added_to',
      );

  String get approve => Intl.message(
        'Approve',
        name: 'approve',
      );

  String get decline => Intl.message(
        'Decline',
        name: 'decline',
      );

  String get bio_not_updated => Intl.message(
        'Bio not yet updated',
        name: 'bio_not_updated',
      );

  String get start_new_post => Intl.message(
        'Start a new post....',
        name: 'start_new_post',
      );

  String get gps_on_reminder => Intl.message(
        'Please make sure you have GPS turned on.',
        name: 'gps_on_reminder',
      );

  String get empty_feed => Intl.message(
        'Your feed is empty',
        name: 'empty_feed',
      );

  String get report_feed => Intl.message(
        'Report Feed',
        name: 'report_feed',
      );

  String get report_feed_confirmation_message => Intl.message(
        'Do you want to report this feed?',
        name: 'report_feed_confirmation_message',
      );

  String get already_reported => Intl.message(
        'Already reported!',
        name: 'already_reported',
      );

  String get feed_reported => Intl.message(
        'You already reported this feed',
        name: 'feed_reported',
      );

  String get no_projects_message => Intl.message(
        'No projects available.Try',
        name: 'no_projects_message',
      );

  String get help => Intl.message(
        'Help',
        name: 'help',
      );

  String get tasks => Intl.message(
        'Tasks',
        name: 'tasks',
      );

  String get my_requests => Intl.message(
        'My Requests',
        name: 'my_requests',
      );

  String get select_request => Intl.message(
        'Select Request',
        name: 'select_request',
      );

  String get protected_timebank_request_creation_error => Intl.message(
        'You cannot post requests in a protected Timebank',
        name: 'protected_timebank_request_creation_error',
      );

  String get request_delete_confirmation_message => Intl.message(
        'Are you sure you want to delete this request?',
        name: 'request_delete_confirmation_message',
      );

  String get no => Intl.message(
        'No',
        name: 'no',
      );

  String get yes => Intl.message(
        'Yes',
        name: 'yes',
      );

  String get number_of_volunteers_required => Intl.message(
        'Number of volunteers required',
        name: 'number_of_volunteers_required',
      );

  String get withdraw => Intl.message(
        'Withdraw',
        name: 'withdraw',
      );

  String get accept => Intl.message(
        'Accept',
        name: 'accept',
      );

  String get no_approved_members => Intl.message(
        'No Approved members yet',
        name: 'no_approved_members',
      );

  String get view_approved_members => Intl.message(
        'View Approved Members',
        name: 'view_approved_members',
      );

  String get request => Intl.message(
        'Request',
        name: 'request',
      );

  String get applied => Intl.message(
        'Applied',
        name: 'applied',
      );

  String get accepted => Intl.message(
        'Accepted',
        name: 'accepted',
      );

  String get default_text => Intl.message(
        'Default',
        name: 'default_text',
      );
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: 'en'),
  ];

  @override
  bool isSupported(Locale locale) => [
        'en',
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
