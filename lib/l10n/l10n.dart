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

  String get sign_in_with_apple => Intl.message(
        'Sign in with Apple',
        name: 'sign_in_with_apple',
      );

  String get or => Intl.message(
        'or',
        name: 'or',
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

  String get camera => Intl.message(
        'Camera',
        name: 'camera',
      );

  String get gallery => Intl.message(
        'Gallery',
        name: 'gallery',
      );

  String get check_email => Intl.message(
        'Now check your email.',
        name: 'check_email',
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

  String get join_timebank_request_invite_hint => Intl.message(
        'If you don\'t have a code, Click',
        name: 'join_timebank_request_invite_hint',
      );

  String get join_timebank_request_invite => Intl.message(
        'Request Invite',
        name: 'join_timebank_request_invite',
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
        'The Event Owner has modified this event. Make sure the changes made are right for you and apply again.',
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

  String get delete_notification => Intl.message(
        'Delete notification',
        name: 'delete_notification',
      );

  String get delete_notification_confirmation => Intl.message(
        'Are you sure you want to delete this notification?',
        name: 'delete_notification_confirmation',
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
        'No Approved members yet.',
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

  String get access_denied => Intl.message(
        'Access denied.',
        name: 'access_denied',
      );

  String get not_authorized_create_request => Intl.message(
        'You are not authorized to create a request.',
        name: 'not_authorized_create_request',
      );

  String get add_requests => Intl.message(
        'Add Requests',
        name: 'add_requests',
      );

  String get no_requests_available => Intl.message(
        'No requests available.Try',
        name: 'no_requests_available',
      );

  String get fetching_location => Intl.message(
        'Fetching location',
        name: 'fetching_location',
      );

  String get edit => Intl.message(
        'Edit',
        name: 'edit',
      );

  String get title => Intl.message(
        'Title',
        name: 'title',
      );

  String get mission_statement => Intl.message(
        'Mission Statement',
        name: 'mission_statement',
      );

  String get organizer => Intl.message(
        'Organiser',
        name: 'organizer',
      );

  String get delete_project => Intl.message(
        'Delete Project',
        name: 'delete_project',
      );

  String get create_project => Intl.message(
        'Create a Project',
        name: 'create_project',
      );

  String get edit_project => Intl.message(
        'Edit Project',
        name: 'edit_project',
      );

  String timebank_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Timebank Project', other: 'Timebank Projects', args: [count])}',
        name: 'timebank_project',        
        args: [count],
      );

  String personal_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Personal Project', other: 'Personal Projects', args: [count])}',
        name: 'personal_project',        
        args: [count],
      );

  String get project_logo => Intl.message(
        'Project Logo',
        name: 'project_logo',
      );

  String get project_name => Intl.message(
        'Project Name',
        name: 'project_name',
      );

  String get name_hint => Intl.message(
        'Ex: Pets-in-town, Citizen collab',
        name: 'name_hint',
      );

  String get validation_error_project_name_empty => Intl.message(
        'Project name cannot be empty',
        name: 'validation_error_project_name_empty',
      );

  String get project_duration => Intl.message(
        'Project Duration',
        name: 'project_duration',
      );

  String get project_mission_statement_hint => Intl.message(
        'Ex: A bit more about your project which will help to associate with',
        name: 'project_mission_statement_hint',
      );

  String get validation_error_mission_empty => Intl.message(
        'Mission statement cannot be empty.',
        name: 'validation_error_mission_empty',
      );

  String get email_hint => Intl.message(
        'example@example.com',
        name: 'email_hint',
      );

  String get phone_number => Intl.message(
        'Phone Number',
        name: 'phone_number',
      );

  String get project_location => Intl.message(
        'Your project location.',
        name: 'project_location',
      );

  String get project_location_hint => Intl.message(
        'Project location will help your members to locate',
        name: 'project_location_hint',
      );

  String get save_as_template => Intl.message(
        'Save as Template',
        name: 'save_as_template',
      );

  String get validation_error_no_date => Intl.message(
        'Please mention the start and end date of the project',
        name: 'validation_error_no_date',
      );

  String get creating_project => Intl.message(
        'Creating project',
        name: 'creating_project',
      );

  String get validation_error_location_mandatory => Intl.message(
        'Location is Mandatory',
        name: 'validation_error_location_mandatory',
      );

  String get validation_error_add_project_location => Intl.message(
        'Please add location to your project',
        name: 'validation_error_add_project_location',
      );

  String get updating_project => Intl.message(
        'Updating Project',
        name: 'updating_project',
      );

  String get save => Intl.message(
        'Save',
        name: 'save',
      );

  String get template_title => Intl.message(
        'Provide a unique name for the template',
        name: 'template_title',
      );

  String get template_hint => Intl.message(
        'Template Name',
        name: 'template_hint',
      );

  String get validation_error_template_name => Intl.message(
        'Template name cannot be empty',
        name: 'validation_error_template_name',
      );

  String get validation_error_template_name_exists => Intl.message(
        'Template name is already in use.Please provide another name',
        name: 'validation_error_template_name_exists',
      );

  String get add_location => Intl.message(
        'Add Location',
        name: 'add_location',
      );

  String get delete_confirmation => Intl.message(
        'Are your sure you want to delete',
        name: 'delete_confirmation',
      );

  String get accidental_delete_enabled => Intl.message(
        'Accidental Deletion enabled',
        name: 'accidental_delete_enabled',
      );

  String get accidental_delete_enabled_description => Intl.message(
        'This ** has \"Prevent Accidental Delete\" enabled. Please uncheck that box (in the \"Manage\" tab) before attempting to delete the **.',
        name: 'accidental_delete_enabled_description',
      );

  String get deletion_request_being_processed => Intl.message(
        'Your request for deletion is being processed.',
        name: 'deletion_request_being_processed',
      );

  String get deletion_request_progress_description => Intl.message(
        'Your request to delete has been received by us. We are processing the request. You will be notified once it is completed.',
        name: 'deletion_request_progress_description',
      );

  String get submitting_request => Intl.message(
        'Submitting request...',
        name: 'submitting_request',
      );

  String get advisory_for_timebank => Intl.message(
        'All relevant information including projects, requests and offers under the group will be deleted!',
        name: 'advisory_for_timebank',
      );

  String get advisory_for_projects => Intl.message(
        'All requests associated to this request would be removed',
        name: 'advisory_for_projects',
      );

  String get deletion_request_recieved => Intl.message(
        'We have received your request to delete this ***. We are sorry to see you go. We will examine your request and (in some cases) get in touch with you offline before we process the deletion of the ***',
        name: 'deletion_request_recieved',
      );

  String get request_submitted => Intl.message(
        'Request submitted',
        name: 'request_submitted',
      );

  String get request_failed => Intl.message(
        'Request failed!',
        name: 'request_failed',
      );

  String get request_failure_message => Intl.message(
        'Sending request failed somehow, please try again later!',
        name: 'request_failure_message',
      );

  String get hosted_by => Intl.message(
        'Hosted by',
        name: 'hosted_by',
      );

  String get creator_of_request_message => Intl.message(
        'You are the creator of this request.',
        name: 'creator_of_request_message',
      );

  String get applied_for_request => Intl.message(
        'You have applied for the request.',
        name: 'applied_for_request',
      );

  String get particpate_in_request_question => Intl.message(
        'Do you want to participate in this request?',
        name: 'particpate_in_request_question',
      );

  String get apply => Intl.message(
        'Apply',
        name: 'apply',
      );

  String get protected_timebank_alert_dialog => Intl.message(
        'You cannot accept requests in a protected Timebank',
        name: 'protected_timebank_alert_dialog',
      );

  String get already_approved => Intl.message(
        'Already Approved',
        name: 'already_approved',
      );

  String get withdraw_request_failure => Intl.message(
        'You cannot withdraw request since already approved',
        name: 'withdraw_request_failure',
      );

  String get find_volunteers => Intl.message(
        'Find Volunteers',
        name: 'find_volunteers',
      );

  String get invited => Intl.message(
        'Invited',
        name: 'invited',
      );

  String get favourites => Intl.message(
        'Favourites',
        name: 'favourites',
      );

  String get past_hired => Intl.message(
        'Past Hired',
        name: 'past_hired',
      );

  String get type_team_member_name => Intl.message(
        'Type your team members name',
        name: 'type_team_member_name',
      );

  String get validation_error_search_min_characters => Intl.message(
        'Search requires minimum 3 characters',
        name: 'validation_error_search_min_characters',
      );

  String get no_user_found => Intl.message(
        'No user found',
        name: 'no_user_found',
      );

  String get approved => Intl.message(
        'Approved',
        name: 'approved',
      );

  String get invite => Intl.message(
        'Invite',
        name: 'invite',
      );

  String get name_not_available => Intl.message(
        'Name is not available',
        name: 'name_not_available',
      );

  String get create_request => Intl.message(
        'Create Request',
        name: 'create_request',
      );

  String get create_project_request => Intl.message(
        'Create Project Request',
        name: 'create_project_request',
      );

  String get set_duration => Intl.message(
        'Click to Set Duration',
        name: 'set_duration',
      );

  String get request_title => Intl.message(
        'Request title*',
        name: 'request_title',
      );

  String get request_title_hint => Intl.message(
        'Ex: Small carpentry work...',
        name: 'request_title_hint',
      );

  String get request_subject => Intl.message(
        'Please enter the subject of your request',
        name: 'request_subject',
      );

  String get request_duration => Intl.message(
        'Request duration',
        name: 'request_duration',
      );

  String get request_description => Intl.message(
        'Request description*',
        name: 'request_description',
      );

  String get request_description_hint => Intl.message(
        'Your Request and any #hashtags',
        name: 'request_description_hint',
      );

  String get number_of_volunteers => Intl.message(
        'No. of volunteers*',
        name: 'number_of_volunteers',
      );

  String get validation_error_volunteer_count => Intl.message(
        'Please enter the number of volunteers needed',
        name: 'validation_error_volunteer_count',
      );

  String get validation_error_volunteer_count_negative => Intl.message(
        'No. of volunteers cannot be lesser than 0',
        name: 'validation_error_volunteer_count_negative',
      );

  String get validation_error_volunteer_count_zero => Intl.message(
        'No. of volunteers cannot be 0',
        name: 'validation_error_volunteer_count_zero',
      );

  String personal_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Personal Request', other: 'Personal Requests', args: [count])}',
        name: 'personal_request',        
        args: [count],
      );

  String timebank_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Timebank Request', other: 'Timebank Requests', args: [count])}',
        name: 'timebank_request',        
        args: [count],
      );

  String get validation_error_same_start_date_end_date => Intl.message(
        'You have provided identical date and time for the Start and End. Please provide an End time that is after the Start time.',
        name: 'validation_error_same_start_date_end_date',
      );

  String get validation_error_empty_recurring_days => Intl.message(
        'Recurring days cannot be empty',
        name: 'validation_error_empty_recurring_days',
      );

  String get creating_request => Intl.message(
        'Creating Request',
        name: 'creating_request',
      );

  String get updating_request => Intl.message(
        'Updating Request',
        name: 'updating_request',
      );

  String get insufficient_credits_for_request => Intl.message(
        'Your seva credits are not sufficient to create the request.',
        name: 'insufficient_credits_for_request',
      );

  String get assign_to_volunteers => Intl.message(
        'Assign to volunteers',
        name: 'assign_to_volunteers',
      );

  String members_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'member selected', other: 'members selected', args: [count])}',
        name: 'members_selected',        
        args: [count],
      );

  String volunteers_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'volunteer selected', other: 'volunteers selected', args: [count])}',
        name: 'volunteers_selected',        
        args: [count],
      );

  String get timebank_max_seva_credit_message1 => Intl.message(
        'Seva Credits will be credited to the Timebank for this request. Note that each participant will receive a maximum of',
        name: 'timebank_max_seva_credit_message1',
      );

  String get timebank_max_seva_credit_message2 => Intl.message(
        'credits for completing this request.',
        name: 'timebank_max_seva_credit_message2',
      );

  String get personal_max_seva_credit_message1 => Intl.message(
        'Seva Credits are required for this request. It will be debited from your balance. Note that each participant will receive a maximum of',
        name: 'personal_max_seva_credit_message1',
      );

  String get personal_max_seva_credit_message2 => Intl.message(
        'credits for completing this request.',
        name: 'personal_max_seva_credit_message2',
      );

  String get unassigned => Intl.message(
        'Unassigned',
        name: 'unassigned',
      );

  String get assign_to_project => Intl.message(
        'Assign to project',
        name: 'assign_to_project',
      );

  String get assign_to_one_project => Intl.message(
        'Please assign to one project',
        name: 'assign_to_one_project',
      );

  String get tap_to_select => Intl.message(
        'Tap to select one or more...',
        name: 'tap_to_select',
      );

  String get repeat => Intl.message(
        'Repeat',
        name: 'repeat',
      );

  String get repeat_on => Intl.message(
        'Repeat on',
        name: 'repeat_on',
      );

  String get ends => Intl.message(
        'Ends',
        name: 'ends',
      );

  String get after => Intl.message(
        'After',
        name: 'after',
      );

  String get occurences => Intl.message(
        'Occurences',
        name: 'occurences',
      );

  String get done => Intl.message(
        'Done',
        name: 'done',
      );

  String get date_time => Intl.message(
        'date & time',
        name: 'date_time',
      );

  String get start => Intl.message(
        'Start',
        name: 'start',
      );

  String get end => Intl.message(
        'End',
        name: 'end',
      );

  String get time => Intl.message(
        'Time',
        name: 'time',
      );

  String get date_selection_issue => Intl.message(
        'Date Selection issue',
        name: 'date_selection_issue',
      );

  String get validation_error_end_date_greater => Intl.message(
        'End Date cannot be before Start Date',
        name: 'validation_error_end_date_greater',
      );

  String get unblock => Intl.message(
        'Unblock',
        name: 'unblock',
      );

  String get no_blocked_members => Intl.message(
        'No blocked members',
        name: 'no_blocked_members',
      );

  String get blocked_members => Intl.message(
        'Blocked Members',
        name: 'blocked_members',
      );

  String get confirm_location => Intl.message(
        'confirm location',
        name: 'confirm_location',
      );

  String get no_message => Intl.message(
        'No Message',
        name: 'no_message',
      );

  String get reject_task_completion => Intl.message(
        'I am rejecting your task completion request because',
        name: 'reject_task_completion',
      );

  String get type_message => Intl.message(
        'Type a message',
        name: 'type_message',
      );

  String get failed_to_load_post => Intl.message(
        'Couldn\'t load the post!',
        name: 'failed_to_load_post',
      );

  String get admin => Intl.message(
        'Admin',
        name: 'admin',
      );

  String get new_message_room => Intl.message(
        'New Message Room',
        name: 'new_message_room',
      );

  String get messaging_room_name => Intl.message(
        'Messaging Room Name',
        name: 'messaging_room_name',
      );

  String get new_chat => Intl.message(
        'New Chat',
        name: 'new_chat',
      );

  String get frequently_contacted => Intl.message(
        'FREQUENTLY CONTACTED',
        name: 'frequently_contacted',
      );

  String get groups => Intl.message(
        'Groups',
        name: 'groups',
      );

  String get timebank_members => Intl.message(
        'Timebank Members',
        name: 'timebank_members',
      );

  String get add_participants => Intl.message(
        'Add Participants',
        name: 'add_participants',
      );

  String get participants => Intl.message(
        'Participants',
        name: 'participants',
      );

  String get messaging_room => Intl.message(
        'Messaging Room',
        name: 'messaging_room',
      );

  String get creating_messaging_room => Intl.message(
        'Creating Room...',
        name: 'creating_messaging_room',
      );

  String get updating_messaging_room => Intl.message(
        'Updating Room...',
        name: 'updating_messaging_room',
      );

  String get messaging_room_note => Intl.message(
        'Please provide a message room subject and optional group icon',
        name: 'messaging_room_note',
      );

  String get exit_messaging_room => Intl.message(
        'Exit Messaging Room',
        name: 'exit_messaging_room',
      );

  String get exit_messaging_room_admin_confirmation => Intl.message(
        'You are admin of this messaging room, are you sure you want to exit the Messaging room',
        name: 'exit_messaging_room_admin_confirmation',
      );

  String get no_frequent_contacts => Intl.message(
        'No Frequent Contacts',
        name: 'no_frequent_contacts',
      );

  String get sending => Intl.message(
        'Sending...',
        name: 'sending',
      );

  String get create => Intl.message(
        'Create',
        name: 'create',
      );

  String get add_caption => Intl.message(
        'Add a caption',
        name: 'add_caption',
      );

  String get tap_for_photo => Intl.message(
        'Tap for photo',
        name: 'tap_for_photo',
      );

  String get validation_error_room_name => Intl.message(
        'Name can\'t be empty',
        name: 'validation_error_room_name',
      );

  String get chat_block_warning => Intl.message(
        'will no longer be available to send you messages and engage with the content you create',
        name: 'chat_block_warning',
      );

  String get delete_chat_confirmation => Intl.message(
        'Are you sure you want to delete this chat',
        name: 'delete_chat_confirmation',
      );

  String get block => Intl.message(
        'Block',
        name: 'block',
      );

  String get exit_messaging_room_user_confirmation => Intl.message(
        'Are you sure you want to exit the Messaging room',
        name: 'exit_messaging_room_user_confirmation',
      );

  String get exit => Intl.message(
        'Exit',
        name: 'exit',
      );

  String get delete_chat => Intl.message(
        'Delete chat',
        name: 'delete_chat',
      );

  String get group => Intl.message(
        'Group',
        name: 'group',
      );

  String get shared_post => Intl.message(
        'Shared a post',
        name: 'shared_post',
      );

  String get change_ownership => Intl.message(
        'Change Ownership',
        name: 'change_ownership',
      );

  String get change_ownership_invite => Intl.message(
        'has invited you to be the new owner of the Timebank',
        name: 'change_ownership_invite',
      );

  String get notifications_insufficient_credits => Intl.message(
        'Your seva credits are not sufficient to approve the credit request.',
        name: 'notifications_insufficient_credits',
      );

  String get completed_task_in => Intl.message(
        'completed the task in',
        name: 'completed_task_in',
      );

  String get by_approving_you_accept => Intl.message(
        'By approving, you accept that',
        name: 'by_approving_you_accept',
      );

  String get reject => Intl.message(
        'Reject',
        name: 'reject',
      );

  String get no_comments => Intl.message(
        'No Comments',
        name: 'no_comments',
      );

  String get reason_to_join => Intl.message(
        'Reason to join',
        name: 'reason_to_join',
      );

  String get reason_not_mentioned => Intl.message(
        'Reason not mentioned',
        name: 'reason_not_mentioned',
      );

  String get allow => Intl.message(
        'Allow',
        name: 'allow',
      );

  String get updating_timebank => Intl.message(
        'Updating Timebank..',
        name: 'updating_timebank',
      );

  String get no_bookmarked_offers => Intl.message(
        'No offers bookmarked',
        name: 'no_bookmarked_offers',
      );

  String get create_offer => Intl.message(
        'Create Offer',
        name: 'create_offer',
      );

  String get individual_offer => Intl.message(
        'Individual offer',
        name: 'individual_offer',
      );

  String get one_to_many => Intl.message(
        'One to many',
        name: 'one_to_many',
      );

  String get update_offer => Intl.message(
        'Update Offer',
        name: 'update_offer',
      );

  String get creating_offer => Intl.message(
        'Creating offer',
        name: 'creating_offer',
      );

  String get updating_offer => Intl.message(
        'Updating offer',
        name: 'updating_offer',
      );

  String get offer_error_creating => Intl.message(
        'There was error creating your offer, Please try again.',
        name: 'offer_error_creating',
      );

  String get offer_error_updating => Intl.message(
        'There was error updating offer, Please try again.',
        name: 'offer_error_updating',
      );

  String get offer_title_hint => Intl.message(
        'Ex babysitting',
        name: 'offer_title_hint',
      );

  String get offer_description => Intl.message(
        'Offer description',
        name: 'offer_description',
      );

  String get offer_description_hint => Intl.message(
        'Your offer and any #hashtags',
        name: 'offer_description_hint',
      );

  String get availablity => Intl.message(
        'Availability',
        name: 'availablity',
      );

  String get availablity_description => Intl.message(
        'Describe my availability',
        name: 'availablity_description',
      );

  String get one_to_many_offer_hint => Intl.message(
        'Ex teaching a python class..',
        name: 'one_to_many_offer_hint',
      );

  String get offer_duration => Intl.message(
        'Offer duration',
        name: 'offer_duration',
      );

  String get offer_prep_hours => Intl.message(
        'No. of preparation hours',
        name: 'offer_prep_hours',
      );

  String get offer_prep_hours_required => Intl.message(
        'No. of preparation hours required',
        name: 'offer_prep_hours_required',
      );

  String get offer_number_class_hours => Intl.message(
        'No. of class hours',
        name: 'offer_number_class_hours',
      );

  String get offer_number_class_hours_required => Intl.message(
        'No. of class hours required',
        name: 'offer_number_class_hours_required',
      );

  String get offer_size_class => Intl.message(
        'Size of class',
        name: 'offer_size_class',
      );

  String get offer_enter_participants => Intl.message(
        'Enter the number of participants',
        name: 'offer_enter_participants',
      );

  String get offer_class_description => Intl.message(
        'Class description',
        name: 'offer_class_description',
      );

  String get offer_description_error => Intl.message(
        'Please enter some class description',
        name: 'offer_description_error',
      );

  String get offer_start_end_date => Intl.message(
        'Please enter start and end date',
        name: 'offer_start_end_date',
      );

  String get validation_error_offer_title => Intl.message(
        'Please enter the subject of your offer',
        name: 'validation_error_offer_title',
      );

  String get validation_error_offer_class_hours => Intl.message(
        'Please enter the hours required for the class',
        name: 'validation_error_offer_class_hours',
      );

  String get validation_error_hours_not_int => Intl.message(
        'Entered number of hours is not valid',
        name: 'validation_error_hours_not_int',
      );

  String get validation_error_offer_prep_hour => Intl.message(
        'Please enter your preperation time',
        name: 'validation_error_offer_prep_hour',
      );

  String get validation_error_location => Intl.message(
        'Please select location',
        name: 'validation_error_location',
      );

  String get validation_error_class_size_int => Intl.message(
        'Size of class can\'t be in decimal',
        name: 'validation_error_class_size_int',
      );

  String get validation_error_class_size => Intl.message(
        'Please enter valid size of class',
        name: 'validation_error_class_size',
      );

  String get validation_error_offer_credit => Intl.message(
        'We cannot publish this Class. There are insufficient credits from the class. Please revise the Prep time or the number of students and submit the offer again',
        name: 'validation_error_offer_credit',
      );

  String get posted_on => Intl.message(
        'Posted on',
        name: 'posted_on',
      );

  String get location => Intl.message(
        'Location',
        name: 'location',
      );

  String get offered_by => Intl.message(
        'Offered by',
        name: 'offered_by',
      );

  String get you_created_offer => Intl.message(
        'You created this offer',
        name: 'you_created_offer',
      );

  String get you_have => Intl.message(
        'You have',
        name: 'you_have',
      );

  String get not_yet => Intl.message(
        'not yet',
        name: 'not_yet',
      );

  String get signed_up_for => Intl.message(
        'signed up for',
        name: 'signed_up_for',
      );

  String get bookmarked => Intl.message(
        'bookmarked',
        name: 'bookmarked',
      );

  String get this_offer => Intl.message(
        'this offer',
        name: 'this_offer',
      );

  String get details => Intl.message(
        'Details',
        name: 'details',
      );

  String get no_offers => Intl.message(
        'No Offers',
        name: 'no_offers',
      );

  String get your_earnings => Intl.message(
        'Your earnings',
        name: 'your_earnings',
      );

  String get timebank_earnings => Intl.message(
        'Timebank earnings',
        name: 'timebank_earnings',
      );

  String get no_participants_yet => Intl.message(
        'No Participants yet',
        name: 'no_participants_yet',
      );

  String get bookmarked_offers => Intl.message(
        'Bookmarked Offers',
        name: 'bookmarked_offers',
      );

  String get my_offers => Intl.message(
        'My Offers',
        name: 'my_offers',
      );

  String get offer_help => Intl.message(
        'Offers Help',
        name: 'offer_help',
      );

  String get report_members => Intl.message(
        'Report Member',
        name: 'report_members',
      );

  String get report_member_inform => Intl.message(
        'Please inform, why you are reporting this user.',
        name: 'report_member_inform',
      );

  String get report_member_provide_details => Intl.message(
        'Please provide as much detail as possible',
        name: 'report_member_provide_details',
      );

  String get report => Intl.message(
        'Report',
        name: 'report',
      );

  String get reporting_member => Intl.message(
        'Reporting member',
        name: 'reporting_member',
      );

  String get no_data => Intl.message(
        'No data found !',
        name: 'no_data',
      );

  String get reported_by => Intl.message(
        'Reported by',
        name: 'reported_by',
      );

  String user(num count) => Intl.message(
        '${Intl.plural(count, one: 'user', other: 'users', args: [count])}',
        name: 'user',        
        args: [count],
      );

  String get user_removed_from_group => Intl.message(
        'User is successfully removed from the group',
        name: 'user_removed_from_group',
      );

  String get user_removed_from_group_failed => Intl.message(
        'User cannot be deleted from this group',
        name: 'user_removed_from_group_failed',
      );

  String get user_has => Intl.message(
        'User has',
        name: 'user_has',
      );

  String get pending_projects => Intl.message(
        'pending projects',
        name: 'pending_projects',
      );

  String get pending_requests => Intl.message(
        'pending requests',
        name: 'pending_requests',
      );

  String get pending_offers => Intl.message(
        'pending offers',
        name: 'pending_offers',
      );

  String get clear_transaction => Intl.message(
        'Please clear the transactions and try again.',
        name: 'clear_transaction',
      );

  String get remove_self_from_group_error => Intl.message(
        'Cannot remove yourself from the group. Instead, please try deleting the group.',
        name: 'remove_self_from_group_error',
      );

  String get user_removed_from_timebank => Intl.message(
        'User is successfully removed from the Timebank',
        name: 'user_removed_from_timebank',
      );

  String get user_removed_from_timebank_failed => Intl.message(
        'User cannot be deleted from this Timebank',
        name: 'user_removed_from_timebank_failed',
      );

  String get member_reported => Intl.message(
        'Member reported successfully',
        name: 'member_reported',
      );

  String get member_reporting_failed => Intl.message(
        'Failed to report member! Try again',
        name: 'member_reporting_failed',
      );

  String get reported_member_click_to_view => Intl.message(
        'Click here to view reported users of this Timebank',
        name: 'reported_member_click_to_view',
      );

  String get reported_users => Intl.message(
        'Reported Users',
        name: 'reported_users',
      );

  String get reported_members => Intl.message(
        'Reported Members',
        name: 'reported_members',
      );

  String get search_something => Intl.message(
        'Search Something',
        name: 'search_something',
      );

  String get i_want_to_volunteer => Intl.message(
        'I want to volunteer.',
        name: 'i_want_to_volunteer',
      );

  String get help_about_us => Intl.message(
        'About Us',
        name: 'help_about_us',
      );

  String get help_training_video => Intl.message(
        'Training Video',
        name: 'help_training_video',
      );

  String get help_contact_us => Intl.message(
        'Contac Us',
        name: 'help_contact_us',
      );

  String get help_version => Intl.message(
        'Version',
        name: 'help_version',
      );

  String get feedback => Intl.message(
        'Feedback',
        name: 'feedback',
      );

  String get send_feedback => Intl.message(
        'Send feedback',
        name: 'send_feedback',
      );

  String get enter_feedback => Intl.message(
        'Please enter your feedback',
        name: 'enter_feedback',
      );

  String get feedback_messagae => Intl.message(
        'Please let us know about your valuable feedback',
        name: 'feedback_messagae',
      );

  String get create_timebank_description => Intl.message(
        'A TimeBank is a community of volunteers that give and receive time to each other and to the larger community',
        name: 'create_timebank_description',
      );

  String get timebank_logo => Intl.message(
        'Timebank Logo',
        name: 'timebank_logo',
      );

  String get timebank_name => Intl.message(
        'Name your Timebank',
        name: 'timebank_name',
      );

  String get timebank_name_hint => Intl.message(
        'Ex: Pets-in-town, Citizen collab',
        name: 'timebank_name_hint',
      );

  String get timebank_name_error => Intl.message(
        'Timebank name cannot be empty',
        name: 'timebank_name_error',
      );

  String get timebank_name_exists_error => Intl.message(
        'Please choose another name for the Timebank. This Timebank name already exists',
        name: 'timebank_name_exists_error',
      );

  String get timbank_about_hint => Intl.message(
        'Ex: A bit more about your Timebank',
        name: 'timbank_about_hint',
      );

  String get timebank_tell_more => Intl.message(
        'Tell us more about your Timebank.',
        name: 'timebank_tell_more',
      );

  String get timebank_select_tax_percentage => Intl.message(
        'Select Tax percentage',
        name: 'timebank_select_tax_percentage',
      );

  String get timebank_current_tax_percentage => Intl.message(
        'Current Tax Percentage',
        name: 'timebank_current_tax_percentage',
      );

  String get timebank_location => Intl.message(
        'Your Timebank location.',
        name: 'timebank_location',
      );

  String get timebank_location_hint => Intl.message(
        'List the place or address where your community meets (such as a cafe, library, or church.).',
        name: 'timebank_location_hint',
      );

  String get timebank_name_exists => Intl.message(
        'Timebank name already exists !',
        name: 'timebank_name_exists',
      );

  String get timebank_location_error => Intl.message(
        'Please add the location of your Timebank',
        name: 'timebank_location_error',
      );

  String get timebank_logo_error => Intl.message(
        'Timebank logo is mandatory',
        name: 'timebank_logo_error',
      );

  String get creating_timebank => Intl.message(
        'Creating Timebank',
        name: 'creating_timebank',
      );

  String get timebank_billing_error => Intl.message(
        'Please configure your personal information details',
        name: 'timebank_billing_error',
      );

  String get timebank_configure_profile_info => Intl.message(
        'Configure profile information',
        name: 'timebank_configure_profile_info',
      );

  String get timebank_profile_info => Intl.message(
        'Profile Information',
        name: 'timebank_profile_info',
      );

  String get validation_error_required_fields => Intl.message(
        'Field cannot be left blank*',
        name: 'validation_error_required_fields',
      );

  String get state => Intl.message(
        'State',
        name: 'state',
      );

  String get city => Intl.message(
        'City',
        name: 'city',
      );

  String get zip => Intl.message(
        'Zip',
        name: 'zip',
      );

  String get country => Intl.message(
        'Country',
        name: 'country',
      );

  String get street_add1 => Intl.message(
        'Street Address 1',
        name: 'street_add1',
      );

  String get street_add2 => Intl.message(
        'Street Address 2',
        name: 'street_add2',
      );

  String get company_name => Intl.message(
        'Company name',
        name: 'company_name',
      );

  String get continue_text => Intl.message(
        'Continue',
        name: 'continue_text',
      );

  String get private_timebank => Intl.message(
        'Private Timebank',
        name: 'private_timebank',
      );

  String get updating_details => Intl.message(
        'Updating details',
        name: 'updating_details',
      );

  String get edit_profile_information => Intl.message(
        'Edit Profile Information',
        name: 'edit_profile_information',
      );

  String get selected_users_before => Intl.message(
        'Selected users before',
        name: 'selected_users_before',
      );

  String get private_timebank_alert => Intl.message(
        'Private Timebank alert',
        name: 'private_timebank_alert',
      );

  String get private_timebank_alert_hint => Intl.message(
        'Please be informed that Private Timebanks do not have a free option. You will need to provide your billing details to continue to create this Timebank',
        name: 'private_timebank_alert_hint',
      );

  String get additional_notes => Intl.message(
        'Additional Notes',
        name: 'additional_notes',
      );

  String get prevent_accidental_delete => Intl.message(
        'Prevent accidental delete',
        name: 'prevent_accidental_delete',
      );

  String get update_request => Intl.message(
        'Update Request',
        name: 'update_request',
      );

  String get timebank_offers => Intl.message(
        'Timebank Offers',
        name: 'timebank_offers',
      );

  String other(num count) => Intl.message(
        '${Intl.plural(count, one: 'Other', other: 'Others', args: [count])}',
        name: 'other',        
        args: [count],
      );

  String get plan_details => Intl.message(
        'Plan Details',
        name: 'plan_details',
      );

  String get on_community_plan => Intl.message(
        'You are on Community Plan',
        name: 'on_community_plan',
      );

  String get change_plan => Intl.message(
        'change plan',
        name: 'change_plan',
      );

  String get your_community_on_the => Intl.message(
        'Your community is on the',
        name: 'your_community_on_the',
      );

  String get plan_yearly_1500 => Intl.message(
        'paying yearly for \$1500 and additional charges of',
        name: 'plan_yearly_1500',
      );

  String get plan_details_quota1 => Intl.message(
        'per transaction billed monthly upon exceeding free monthly quota',
        name: 'plan_details_quota1',
      );

  String get paying => Intl.message(
        'paying',
        name: 'paying',
      );

  String get charges_of => Intl.message(
        'yearly and additional charges of',
        name: 'charges_of',
      );

  String get per_transaction_quota => Intl.message(
        'per transaction billed annualy upon exceeding free monthly quota',
        name: 'per_transaction_quota',
      );

  String get status => Intl.message(
        'Status',
        name: 'status',
      );

  String get view_selected_plans => Intl.message(
        'View selected plans',
        name: 'view_selected_plans',
      );

  String get monthly_subscription => Intl.message(
        'Monthly subscriptions',
        name: 'monthly_subscription',
      );

  String subscription(num count) => Intl.message(
        '${Intl.plural(count, one: 'Subscription', other: 'Subscriptions', args: [count])}',
        name: 'subscription',        
        args: [count],
      );

  String get card_details => Intl.message(
        'CARD DETAILS',
        name: 'card_details',
      );

  String get add_new => Intl.message(
        'Add New',
        name: 'add_new',
      );

  String get no_cards_available => Intl.message(
        'No cards available',
        name: 'no_cards_available',
      );

  String get default_card_note => Intl.message(
        'Note : long press to make a card default',
        name: 'default_card_note',
      );

  String get bank_name => Intl.message(
        'Bank Name',
        name: 'bank_name',
      );

  String get default_card => Intl.message(
        'Default Card',
        name: 'default_card',
      );

  String get already_default_card => Intl.message(
        'This card is already added as default card',
        name: 'already_default_card',
      );

  String get make_default_card => Intl.message(
        'Make this card as default',
        name: 'make_default_card',
      );

  String get card_added => Intl.message(
        'Card Added',
        name: 'card_added',
      );

  String get card_sync => Intl.message(
        'It may take couple of minutes to synchronize your payment',
        name: 'card_sync',
      );

  String get select_group => Intl.message(
        'Select Group',
        name: 'select_group',
      );

  String get delete_feed => Intl.message(
        'Delete feed',
        name: 'delete_feed',
      );

  String get deleting_feed => Intl.message(
        'Deleting feed..',
        name: 'deleting_feed',
      );

  String get delete_feed_confirmation => Intl.message(
        'Are you sure you want to delete this news feed?',
        name: 'delete_feed_confirmation',
      );

  String get create_feed => Intl.message(
        'Create Post',
        name: 'create_feed',
      );

  String get create_feed_hint => Intl.message(
        'Text, URL and Hashtags',
        name: 'create_feed_hint',
      );

  String get create_feed_placeholder => Intl.message(
        'What would you like to share*',
        name: 'create_feed_placeholder',
      );

  String get creating_feed => Intl.message(
        'Creating post',
        name: 'creating_feed',
      );

  String get location_not_added => Intl.message(
        'Location not added',
        name: 'location_not_added',
      );

  String get category => Intl.message(
        'Category',
        name: 'category',
      );

  String get select_category => Intl.message(
        'Please select a category',
        name: 'select_category',
      );

  String get photo_credits => Intl.message(
        'Photo Credits',
        name: 'photo_credits',
      );

  String get change_image => Intl.message(
        'Change image',
        name: 'change_image',
      );

  String get change_attachment => Intl.message(
        'Change Attachment',
        name: 'change_attachment',
      );

  String get add_image => Intl.message(
        'Add Image',
        name: 'add_image',
      );

  String get add_attachment => Intl.message(
        'Add Image / Document',
        name: 'add_attachment',
      );

  String get validation_error_file_size => Intl.message(
        'Files larger than 10 MB are not allowed',
        name: 'validation_error_file_size',
      );

  String get large_file_size => Intl.message(
        'Large file alert',
        name: 'large_file_size',
      );

  String get update_feed => Intl.message(
        'Update post',
        name: 'update_feed',
      );

  String get updating_feed => Intl.message(
        'Updating post',
        name: 'updating_feed',
      );

  String get notification_alerts => Intl.message(
        'Notification alerts',
        name: 'notification_alerts',
      );

  String get request_accepted => Intl.message(
        'Member has accepted a request and is waiting for approval',
        name: 'request_accepted',
      );

  String get request_completed => Intl.message(
        'Member claims time credits and is waiting for approval',
        name: 'request_completed',
      );

  String get join_request_message => Intl.message(
        'Member request to join a',
        name: 'join_request_message',
      );

  String get offer_debit => Intl.message(
        'Debit for one to many offer',
        name: 'offer_debit',
      );

  String get member_exits => Intl.message(
        'Member exits a',
        name: 'member_exits',
      );

  String get deletion_request_message => Intl.message(
        'Deletion request could not be processed (Due to pending transactions)',
        name: 'deletion_request_message',
      );

  String get recieved_credits_one_to_many => Intl.message(
        'Received Credit for one to many offer',
        name: 'recieved_credits_one_to_many',
      );

  String get click_to_see_interests => Intl.message(
        'Click here to see your interests',
        name: 'click_to_see_interests',
      );

  String get click_to_see_skills => Intl.message(
        'Click here to see your skills',
        name: 'click_to_see_skills',
      );

  String get my_language => Intl.message(
        'My Language',
        name: 'my_language',
      );

  String get my_timezone => Intl.message(
        'My Timezone',
        name: 'my_timezone',
      );

  String get select_timebank => Intl.message(
        'Select Timebank',
        name: 'select_timebank',
      );

  String get name => Intl.message(
        'Name',
        name: 'name',
      );

  String get add_bio => Intl.message(
        'Add your bio',
        name: 'add_bio',
      );

  String get enter_name => Intl.message(
        'Enter name',
        name: 'enter_name',
      );

  String get update_name => Intl.message(
        'Update name',
        name: 'update_name',
      );

  String get enter_name_hint => Intl.message(
        'Please enter name to update',
        name: 'enter_name_hint',
      );

  String get update_bio => Intl.message(
        'Update bio',
        name: 'update_bio',
      );

  String get update_bio_hint => Intl.message(
        'Please enter bio to update',
        name: 'update_bio_hint',
      );

  String get enter_bio => Intl.message(
        'Enter bio',
        name: 'enter_bio',
      );

  String get available_as_needed => Intl.message(
        'Available as needed - Open to Offers',
        name: 'available_as_needed',
      );

  String get would_be_unblocked => Intl.message(
        'would be unblocked',
        name: 'would_be_unblocked',
      );

  String get jobs => Intl.message(
        'Jobs',
        name: 'jobs',
      );

  String get hours_worked => Intl.message(
        'Hours worked',
        name: 'hours_worked',
      );

  String get less => Intl.message(
        'Less',
        name: 'less',
      );

  String get more => Intl.message(
        'More',
        name: 'more',
      );

  String get no_ratings_yet => Intl.message(
        'No ratings yet',
        name: 'no_ratings_yet',
      );

  String get message => Intl.message(
        'Message',
        name: 'message',
      );

  String get not_completed_any_tasks => Intl.message(
        'not completed any tasks',
        name: 'not_completed_any_tasks',
      );

  String get review_earnings => Intl.message(
        'Review Earnings',
        name: 'review_earnings',
      );

  String get no_transactions_yet => Intl.message(
        'You do not have any transaction yet',
        name: 'no_transactions_yet',
      );

  String get anonymous => Intl.message(
        'Anonymous',
        name: 'anonymous',
      );

  String get date => Intl.message(
        'Date',
        name: 'date',
      );

  String get search_template_hint => Intl.message(
        'Enter name of a Project Template',
        name: 'search_template_hint',
      );

  String get create_project_from_template => Intl.message(
        'Create Project from Template',
        name: 'create_project_from_template',
      );

  String get create_new_project => Intl.message(
        'Create new Project',
        name: 'create_new_project',
      );

  String get no_templates_found => Intl.message(
        'No templates found',
        name: 'no_templates_found',
      );

  String get select_template => Intl.message(
        'Please select a Template from the list of available Templates',
        name: 'select_template',
      );

  String get template_alert => Intl.message(
        'Template alert',
        name: 'template_alert',
      );

  String get new_project => Intl.message(
        'New Project',
        name: 'new_project',
      );

  String get review_feedback_message => Intl.message(
        'Take a moment to reflect on your experience and share your appreciation by writing a short review.',
        name: 'review_feedback_message',
      );

  String get submit => Intl.message(
        'Submit',
        name: 'submit',
      );

  String get review => Intl.message(
        'Review',
        name: 'review',
      );

  String get redirecting_to_messages => Intl.message(
        'Redirecting to messages',
        name: 'redirecting_to_messages',
      );

  String get completing_task => Intl.message(
        'Completing task',
        name: 'completing_task',
      );

  String get total_spent => Intl.message(
        'Total Spent',
        name: 'total_spent',
      );

  String get has_worked_for => Intl.message(
        'has worked for',
        name: 'has_worked_for',
      );

  String get email_not_updated => Intl.message(
        'User email not updated',
        name: 'email_not_updated',
      );

  String get no_pending_requests => Intl.message(
        'No pending requests',
        name: 'no_pending_requests',
      );

  String get choose_suitable_plan => Intl.message(
        'Choose a suitable plan',
        name: 'choose_suitable_plan',
      );

  String get click_for_more_info => Intl.message(
        'Click here for more info',
        name: 'click_for_more_info',
      );

  String get taking_to_new_timebank => Intl.message(
        'Taking you to your new Timebank...',
        name: 'taking_to_new_timebank',
      );

  String get bill_me => Intl.message(
        'Bill Me',
        name: 'bill_me',
      );

  String get bill_me_info1 => Intl.message(
        'This is available only to users who have prior arrangements with Seva Exchange. Please send an email to billme@sevaexchange.com for details',
        name: 'bill_me_info1',
      );

  String get bill_me_info2 => Intl.message(
        'Only users who have been approved a priori can check the “Bill Me” box. If you would like to do this, please send an email to billme@sevaexchange.com',
        name: 'bill_me_info2',
      );

  String get billable_transactions => Intl.message(
        'Billable transactions',
        name: 'billable_transactions',
      );

  String get currently_active => Intl.message(
        'Currently Active',
        name: 'currently_active',
      );

  String get choose => Intl.message(
        'Choose',
        name: 'choose',
      );

  String get plan_change => Intl.message(
        'Plan change',
        name: 'plan_change',
      );

  String get ownership_success => Intl.message(
        'Congratulations! You are now the new owner of the Timebank',
        name: 'ownership_success',
      );

  String get change => Intl.message(
        'Change',
        name: 'change',
      );

  String get contact_seva_to_change_plan => Intl.message(
        'Please contact SevaX support to change the plans',
        name: 'contact_seva_to_change_plan',
      );

  String get changing_ownership_of => Intl.message(
        'Changing ownership of this',
        name: 'changing_ownership_of',
      );

  String get to_other_admin => Intl.message(
        'to another admin.',
        name: 'to_other_admin',
      );

  String get change_to => Intl.message(
        'Change to',
        name: 'change_to',
      );

  String get invitation_sent1 => Intl.message(
        'We have sent your transfer of ownership invitation. You will remain to be the owner of Timebank',
        name: 'invitation_sent1',
      );

  String get invitation_sent2 => Intl.message(
        'until',
        name: 'invitation_sent2',
      );

  String get invitation_sent3 => Intl.message(
        'accepts the invitation and provides their new billing information.',
        name: 'invitation_sent3',
      );

  String get by_accepting_owner_timebank => Intl.message(
        'By accepting, you will become owner of the timebank',
        name: 'by_accepting_owner_timebank',
      );

  String get select_user => Intl.message(
        'Please select a user',
        name: 'select_user',
      );

  String get change_ownership_pending_task_message => Intl.message(
        'You have pending tasks. Please complete tasks before ownership can be transferred',
        name: 'change_ownership_pending_task_message',
      );

  String get change_ownership_pending_payment1 => Intl.message(
        'You have payment pending of',
        name: 'change_ownership_pending_payment1',
      );

  String get change_ownership_pending_payment2 => Intl.message(
        '. Please complete these payment before ownership can be transferred',
        name: 'change_ownership_pending_payment2',
      );

  String get search_admin => Intl.message(
        'Search Admin',
        name: 'search_admin',
      );

  String get change_ownership_message1 => Intl.message(
        'You are the new owner of Timebank',
        name: 'change_ownership_message1',
      );

  String get change_ownership_message2 => Intl.message(
        'You need to accept it to complete the process',
        name: 'change_ownership_message2',
      );

  String get change_ownership_advisory => Intl.message(
        'You are required to provide billing details for this Timebank - including the new billing address. The transfer of ownership will not be completed until this is done.',
        name: 'change_ownership_advisory',
      );

  String get change_ownership_already_invited => Intl.message(
        'already invited.',
        name: 'change_ownership_already_invited',
      );

  String get donate => Intl.message(
        'Donate',
        name: 'donate',
      );

  String get donate_to_timebank => Intl.message(
        'Donate seva credits to Timebank',
        name: 'donate_to_timebank',
      );

  String get insufficient_credits_to_donate => Intl.message(
        'You do not have sufficient credits to donate!',
        name: 'insufficient_credits_to_donate',
      );

  String get current_seva_credit => Intl.message(
        'Your current seva credits is',
        name: 'current_seva_credit',
      );

  String get donate_message => Intl.message(
        'On click of donate your balance will be adjusted',
        name: 'donate_message',
      );

  String get zero_credit_donation_error => Intl.message(
        'You cannot donate 0 credits',
        name: 'zero_credit_donation_error',
      );

  String get negative_credit_donation_error => Intl.message(
        'You cannot donate lesser than 0 credits',
        name: 'negative_credit_donation_error',
      );

  String get empty_credit_donation_error => Intl.message(
        'Donate some credits',
        name: 'empty_credit_donation_error',
      );

  String get number_of_seva_credit => Intl.message(
        'No of seva credits',
        name: 'number_of_seva_credit',
      );

  String get donation_success => Intl.message(
        'You have donated credits successfully',
        name: 'donation_success',
      );

  String get sending_invitation => Intl.message(
        'Sending invitation...',
        name: 'sending_invitation',
      );

  String get ownership_transfer_error => Intl.message(
        'Error occurred! Please come back later and try again.',
        name: 'ownership_transfer_error',
      );

  String get add_members => Intl.message(
        'Add members',
        name: 'add_members',
      );

  String get group_logo => Intl.message(
        'Group logo',
        name: 'group_logo',
      );

  String get name_your_group => Intl.message(
        'Name your group',
        name: 'name_your_group',
      );

  String get bit_more_about_group => Intl.message(
        'Ex: A bit more about your group',
        name: 'bit_more_about_group',
      );

  String get private_group => Intl.message(
        'Private Group',
        name: 'private_group',
      );

  String get is_pin_at_right_place => Intl.message(
        'Is this pin at a right place?',
        name: 'is_pin_at_right_place',
      );

  String get find_timebanks => Intl.message(
        'Find Timebanks',
        name: 'find_timebanks',
      );

  String get groups_within => Intl.message(
        'Groups within',
        name: 'groups_within',
      );

  String get edit_group => Intl.message(
        'Edit Group',
        name: 'edit_group',
      );

  String get view_requests => Intl.message(
        'View requests',
        name: 'view_requests',
      );

  String get delete_group => Intl.message(
        'Delete Group',
        name: 'delete_group',
      );

  String get settings => Intl.message(
        'Settings',
        name: 'settings',
      );

  String get invite_members => Intl.message(
        'Invite Members',
        name: 'invite_members',
      );

  String get invite_via_code => Intl.message(
        'Invite via code',
        name: 'invite_via_code',
      );

  String get bulk_invite_users_csv => Intl.message(
        'Bulk invite users by CSV',
        name: 'bulk_invite_users_csv',
      );

  String get csv_message1 => Intl.message(
        'Download the CSV template to',
        name: 'csv_message1',
      );

  String get csv_message2 => Intl.message(
        'fill the users you would like to add',
        name: 'csv_message2',
      );

  String get csv_message3 => Intl.message(
        'then upload the CSV.',
        name: 'csv_message3',
      );

  String get download_sample_csv => Intl.message(
        'Download sample CSV file',
        name: 'download_sample_csv',
      );

  String get choose_csv => Intl.message(
        'Choose CSV file to bulk invite Members',
        name: 'choose_csv',
      );

  String get csv_size_limit => Intl.message(
        'NOTE : Maximum file size is 1 MB',
        name: 'csv_size_limit',
      );

  String get uploading_csv => Intl.message(
        'Uploading CSV File',
        name: 'uploading_csv',
      );

  String get uploaded_successfully => Intl.message(
        'Uploaded Successfully',
        name: 'uploaded_successfully',
      );

  String get csv_error => Intl.message(
        'Please select a CSV file first before uploading',
        name: 'csv_error',
      );

  String get upload => Intl.message(
        'Upload',
        name: 'upload',
      );

  String get large_file_alert => Intl.message(
        'Large file alert',
        name: 'large_file_alert',
      );

  String get csv_large_file_message => Intl.message(
        'Files larger than 1 MB are not allowed',
        name: 'csv_large_file_message',
      );

  String get not_found => Intl.message(
        'not found',
        name: 'not_found',
      );

  String get resend_invite => Intl.message(
        'Resend Invitation',
        name: 'resend_invite',
      );

  String get add => Intl.message(
        'Add',
        name: 'add',
      );

  String get no_codes_generated => Intl.message(
        'No codes generated yet.',
        name: 'no_codes_generated',
      );

  String get not_yet_redeemed => Intl.message(
        'Not yet redeemed',
        name: 'not_yet_redeemed',
      );

  String get redeemed_by => Intl.message(
        'Redeemed by',
        name: 'redeemed_by',
      );

  String get timebank_code => Intl.message(
        'Timebank code :',
        name: 'timebank_code',
      );

  String get expired => Intl.message(
        'Expired',
        name: 'expired',
      );

  String get active => Intl.message(
        'Active',
        name: 'active',
      );

  String get share_code => Intl.message(
        'Share code',
        name: 'share_code',
      );

  String get invite_message => Intl.message(
        'Timebanks are communities that allow you to volunteer and also receive time credits towards getting things done for you. Use the code',
        name: 'invite_message',
      );

  String get invite_prompt => Intl.message(
        'when prompted to join this Timebank. Please download the app from the links provided at https://sevaexchange.page.link/sevaxapp',
        name: 'invite_prompt',
      );

  String get code_generated => Intl.message(
        'Code generated',
        name: 'code_generated',
      );

  String get is_your_code => Intl.message(
        'is your code.',
        name: 'is_your_code',
      );

  String get publish_code => Intl.message(
        'Publish code',
        name: 'publish_code',
      );

  String get invite_via_email => Intl.message(
        'Invite members via email',
        name: 'invite_via_email',
      );

  String get no_member_found => Intl.message(
        'No member found',
        name: 'no_member_found',
      );

  String get declined => Intl.message(
        'Declined',
        name: 'declined',
      );

  String get search_by_email_name => Intl.message(
        'Search members via email,name',
        name: 'search_by_email_name',
      );

  String get no_groups_found => Intl.message(
        'No groups found',
        name: 'no_groups_found',
      );

  String get no_image_available => Intl.message(
        'No Image Avaialable',
        name: 'no_image_available',
      );

  String get group_description => Intl.message(
        'Groups within a Timebank allow for granular activities. You can join one of the groups below or create your own group',
        name: 'group_description',
      );

  String get updating_users => Intl.message(
        'Updating Users',
        name: 'updating_users',
      );

  String get admins_organizers => Intl.message(
        'Admins & Organizers',
        name: 'admins_organizers',
      );

  String get enter_reason_to_exit => Intl.message(
        'Enter reason to exit',
        name: 'enter_reason_to_exit',
      );

  String get enter_reason_to_exit_hint => Intl.message(
        'Please enter reason to exit',
        name: 'enter_reason_to_exit_hint',
      );

  String get member_removal_confirmation => Intl.message(
        'Are you sure you want to remove',
        name: 'member_removal_confirmation',
      );

  String get loan => Intl.message(
        'Loan',
        name: 'loan',
      );

  String get loan_seva_credit_to_user => Intl.message(
        'Loan seva credits to user',
        name: 'loan_seva_credit_to_user',
      );

  String get timebank_seva_credit => Intl.message(
        'Your timebank seva credits is',
        name: 'timebank_seva_credit',
      );

  String get timebank_loan_message => Intl.message(
        'On click of Approve, Timebank balance will be adjusted',
        name: 'timebank_loan_message',
      );

  String get loan_zero_credit_error => Intl.message(
        'You cannot loan 0 credits',
        name: 'loan_zero_credit_error',
      );

  String get negative_credit_loan_error => Intl.message(
        'You cannot loan lesser than 0 credits',
        name: 'negative_credit_loan_error',
      );

  String get empty_credit_loan_error => Intl.message(
        'Loan some credits',
        name: 'empty_credit_loan_error',
      );

  String get loan_success => Intl.message(
        'You have loaned credits successfully',
        name: 'loan_success',
      );

  String get co_ordinators => Intl.message(
        'Coordinators',
        name: 'co_ordinators',
      );

  String get remove => Intl.message(
        'Remove',
        name: 'remove',
      );

  String get promote => Intl.message(
        'Promote',
        name: 'promote',
      );

  String get demote => Intl.message(
        'Demote',
        name: 'demote',
      );

  String get billing => Intl.message(
        'Billing',
        name: 'billing',
      );

  String get edit_timebank => Intl.message(
        'Edit Timebank',
        name: 'edit_timebank',
      );

  String get delete_timebank => Intl.message(
        'Delete Timebank',
        name: 'delete_timebank',
      );

  String get remove_user => Intl.message(
        'Remove User',
        name: 'remove_user',
      );

  String get exit_user => Intl.message(
        'Exit User',
        name: 'exit_user',
      );

  String get transfer_data_hint => Intl.message(
        'Transfer ownership of this user\'s data to another user, like group ownership.',
        name: 'transfer_data_hint',
      );

  String get transfer_to => Intl.message(
        'Transfer to',
        name: 'transfer_to',
      );

  String get search_user => Intl.message(
        'Search a user',
        name: 'search_user',
      );

  String get transer_hint_data_deletion => Intl.message(
        'All data not transferred will be deleted.',
        name: 'transer_hint_data_deletion',
      );

  String get user_removal_success => Intl.message(
        'User is successfully removed from the timebank',
        name: 'user_removal_success',
      );

  String get error_occured => Intl.message(
        'Error occurred! Please come back later and try again.',
        name: 'error_occured',
      );

  String get create_group => Intl.message(
        'Create Group',
        name: 'create_group',
      );

  String get group_exists => Intl.message(
        'Group name already exists',
        name: 'group_exists',
      );

  String get group_subset => Intl.message(
        'Group is a subset of a Timebank that may be temporary. Ex: committees, project teams.',
        name: 'group_subset',
      );

  String get part_of => Intl.message(
        'Part of',
        name: 'part_of',
      );

  String get global_timebank => Intl.message(
        'SevaX Global Network of Timebanks',
        name: 'global_timebank',
      );

  String get getting_volunteers => Intl.message(
        'Getting volunteers...',
        name: 'getting_volunteers',
      );

  String get no_volunteers_yet => Intl.message(
        'No Volunteers joined yet.',
        name: 'no_volunteers_yet',
      );

  String get read_less => Intl.message(
        'Read Less',
        name: 'read_less',
      );

  String get read_more => Intl.message(
        'Read More',
        name: 'read_more',
      );

  String get admin_not_available => Intl.message(
        'Admin not Available',
        name: 'admin_not_available',
      );

  String get admin_cannot_create_message => Intl.message(
        'Admins cannot create message',
        name: 'admin_cannot_create_message',
      );

  String get volunteers => Intl.message(
        'Volunteer(s)',
        name: 'volunteers',
      );

  String get and_others => Intl.message(
        'and others',
        name: 'and_others',
      );

  String get admins => Intl.message(
        'Admins',
        name: 'admins',
      );

  String get remove_as_admin => Intl.message(
        'Remove as admin',
        name: 'remove_as_admin',
      );

  String get add_as_admin => Intl.message(
        'Add as admin',
        name: 'add_as_admin',
      );

  String get view_profile => Intl.message(
        'View profile',
        name: 'view_profile',
      );

  String get remove_member => Intl.message(
        'Remove member',
        name: 'remove_member',
      );

  String get from_timebank_members => Intl.message(
        'from Timebank members?',
        name: 'from_timebank_members',
      );

  String get no_volunteers_available => Intl.message(
        'No volunteers available',
        name: 'no_volunteers_available',
      );

  String get select_volunteer => Intl.message(
        'Select volunteers',
        name: 'select_volunteer',
      );

  String get no_requests => Intl.message(
        'No Requests',
        name: 'no_requests',
      );

  String get switching_timebank => Intl.message(
        'Switching Timebank',
        name: 'switching_timebank',
      );

  String get tap_to_delete => Intl.message(
        'Tap to delete this item',
        name: 'tap_to_delete',
      );

  String get clear => Intl.message(
        'Clear',
        name: 'clear',
      );

  String get currently_selected => Intl.message(
        'Currently selected',
        name: 'currently_selected',
      );

  String get tap_to_remove_tooltip => Intl.message(
        'items (tap to remove)',
        name: 'tap_to_remove_tooltip',
      );

  String get timebank_exit => Intl.message(
        'Timebank Exit',
        name: 'timebank_exit',
      );

  String get has_exited_from => Intl.message(
        'has exited from',
        name: 'has_exited_from',
      );

  String get tap_to_view_details => Intl.message(
        'Tap to view details',
        name: 'tap_to_view_details',
      );

  String get invited_to_timebank_message => Intl.message(
        'Awesome! You are invited to join a Timebank',
        name: 'invited_to_timebank_message',
      );

  String get invitation_email_body => Intl.message(
        '',
        name: 'invitation_email_body',
      );

  String get open_settings => Intl.message(
        'Open Settings',
        name: 'open_settings',
      );

  String get failed_to_fetch_location => Intl.message(
        'Failed to fetch location',
        name: 'failed_to_fetch_location',
      );

  String get marker => Intl.message(
        'Marker',
        name: 'marker',
      );

  String get missing_permission => Intl.message(
        'Missing Permission',
        name: 'missing_permission',
      );

  String get pdf_document => Intl.message(
        'PDF Document',
        name: 'pdf_document',
      );

  String get profanity_alert => Intl.message(
        'Profanity alert',
        name: 'profanity_alert',
      );

  String get profanity_image_alert => Intl.message(
        'The SevaX App has a policy of not allowing profane, explicit or violent images. Please use another image.',
        name: 'profanity_image_alert',
      );

  String get profanity_text_alert => Intl.message(
        'The SevaX App has a policy of not allowing profane or explicit language. Please revise your text.',
        name: 'profanity_text_alert',
      );

  String get upload_cv_resume => Intl.message(
        'Upload my CV/Resume',
        name: 'upload_cv_resume',
      );

  String get cv_message => Intl.message(
        'CV will help out to provide more details',
        name: 'cv_message',
      );

  String get replace_cv => Intl.message(
        'Replace CV',
        name: 'replace_cv',
      );

  String get choose_pdf_file => Intl.message(
        'Choose pdf file',
        name: 'choose_pdf_file',
      );

  String get validation_error_cv_size => Intl.message(
        'NOTE : Maximum file size is 10 MB',
        name: 'validation_error_cv_size',
      );

  String get validation_error_cv_not_selected => Intl.message(
        'Please select a CV file first before uploading',
        name: 'validation_error_cv_not_selected',
      );

  String get enter_reason_to_delete => Intl.message(
        'Enter reason to delete',
        name: 'enter_reason_to_delete',
      );

  String get enter_reason_to_delete_error => Intl.message(
        'Please enter reason to delete',
        name: 'enter_reason_to_delete_error',
      );

  String get max_credits => Intl.message(
        'Maximum credits*',
        name: 'max_credits',
      );

  String get max_credit_hint => Intl.message(
        'Maximum credits to be given per volunteer',
        name: 'max_credit_hint',
      );

  String get dont_allow => Intl.message(
        'Don\'t Allow',
        name: 'dont_allow',
      );

  String get push_notification_message => Intl.message(
        'The SevaX App would like to send you Push Notifications. Notifications may include alerts and reminders.',
        name: 'push_notification_message',
      );

  String get only_pdf_files_allowed => Intl.message(
        'Only Pdf files are allowed',
        name: 'only_pdf_files_allowed',
      );

  String get delete_request => Intl.message(
        'Delete Request',
        name: 'delete_request',
      );

  String get delete_offer => Intl.message(
        'Delete Offer',
        name: 'delete_offer',
      );

  String get delete_request_confirmation => Intl.message(
        'Are you sure you want to delete this request?',
        name: 'delete_request_confirmation',
      );

  String get delete_offer_confirmation => Intl.message(
        'Are you sure you want to delete this offer?',
        name: 'delete_offer_confirmation',
      );

  String get extension_alert => Intl.message(
        'Extension alert',
        name: 'extension_alert',
      );

  String get only_csv_allowed => Intl.message(
        'Only CSV files are allowed',
        name: 'only_csv_allowed',
      );

  String get no_members => Intl.message(
        'No Members',
        name: 'no_members',
      );

  String get will_be_added_to_request => Intl.message(
        '*** will be automatically added to the request.',
        name: 'will_be_added_to_request',
      );

  String get cancel_offer => Intl.message(
        'Cancel Offer',
        name: 'cancel_offer',
      );

  String get cancel_offer_confirmation => Intl.message(
        'Are you sure you want to cancel the offer?',
        name: 'cancel_offer_confirmation',
      );

  String get recurring => Intl.message(
        'Recurring',
        name: 'recurring',
      );

  String get request_credits_again => Intl.message(
        'Are you sure you want to request for credits again?',
        name: 'request_credits_again',
      );

  String get cant_perfrom_action_offer => Intl.message(
        'You can\'t perform action before the offer ends.',
        name: 'cant_perfrom_action_offer',
      );

  String get time_left => Intl.message(
        'Time left',
        name: 'time_left',
      );

  String get days_available => Intl.message(
        'Days Available',
        name: 'days_available',
      );

  String get this_is_repeating_event => Intl.message(
        'This is a repeating event',
        name: 'this_is_repeating_event',
      );

  String get edit_this_event => Intl.message(
        'Edit this event only',
        name: 'edit_this_event',
      );

  String get edit_subsequent_event => Intl.message(
        'Edit subsequent events',
        name: 'edit_subsequent_event',
      );

  String get left => Intl.message(
        'left',
        name: 'left',
      );

  String get cant_exit_group => Intl.message(
        'You cannot exit from this group',
        name: 'cant_exit_group',
      );

  String get cant_exit_timebank => Intl.message(
        'cannot exit from this timebank',
        name: 'cant_exit_timebank',
      );

  String get add_image_url => Intl.message(
        'Add Image Url',
        name: 'add_image_url',
      );

  String get image_url => Intl.message(
        'Image Url',
        name: 'image_url',
      );

  String day(num count) => Intl.message(
        '${Intl.plural(count, one: 'Day', other: 'Days', args: [count])}',
        name: 'day',        
        args: [count],
      );

  String year(num count) => Intl.message(
        '${Intl.plural(count, one: 'Year', other: 'Years', args: [count])}',
        name: 'year',        
        args: [count],
      );

  String get lifetime => Intl.message(
        'Lifetime',
        name: 'lifetime',
      );

  String get raised => Intl.message(
        'Raised',
        name: 'raised',
      );

  String get donated => Intl.message(
        'Donated',
        name: 'donated',
      );

  String get items_collected => Intl.message(
        'Items collected',
        name: 'items_collected',
      );

  String get items_donated => Intl.message(
        'Items donated',
        name: 'items_donated',
      );

  String get donations => Intl.message(
        'Donations',
        name: 'donations',
      );

  String get items => Intl.message(
        'Items',
        name: 'items',
      );

  String get enter_valid_amount => Intl.message(
        'Enter valid amount',
        name: 'enter_valid_amount',
      );

  String get minmum_amount => Intl.message(
        'Minimum amount is',
        name: 'minmum_amount',
      );

  String get select_goods_category => Intl.message(
        'Select a goods category',
        name: 'select_goods_category',
      );

  String get pledge => Intl.message(
        'Pledge',
        name: 'pledge',
      );

  String get do_it_later => Intl.message(
        'Do it later',
        name: 'do_it_later',
      );

  String get tell_what_you_donated => Intl.message(
        'Tell us what you have donated',
        name: 'tell_what_you_donated',
      );

  String get describe_goods => Intl.message(
        'Describe your goods and select from checkbox below',
        name: 'describe_goods',
      );

  String get payment_link_description => Intl.message(
        'Please use the link down below to donate and once done take a pledge on how much you have donated.',
        name: 'payment_link_description',
      );

  String get donation_description_one => Intl.message(
        'Great, you have choose to donate for',
        name: 'donation_description_one',
      );

  String get donation_description_two => Intl.message(
        'a minimum donations is',
        name: 'donation_description_two',
      );

  String get donation_description_three => Intl.message(
        'USD. Please click on the below link to fo the donation.',
        name: 'donation_description_three',
      );

  String get add_amount_donated => Intl.message(
        'Add amount that you have donated.',
        name: 'add_amount_donated',
      );

  String get amount_donated => Intl.message(
        'Amount Donated?',
        name: 'amount_donated',
      );

  String get acknowledge => Intl.message(
        'Acknowledge',
        name: 'acknowledge',
      );

  String get modify => Intl.message(
        'Modify',
        name: 'modify',
      );

  String get by_accepting => Intl.message(
        'By accepting,',
        name: 'by_accepting',
      );

  String get will_added_to_donors => Intl.message(
        'will be added to donors list.',
        name: 'will_added_to_donors',
      );

  String get no_donation_yet => Intl.message(
        'No donations yet',
        name: 'no_donation_yet',
      );

  String get donation_acknowledge => Intl.message(
        'Donation acknowledge',
        name: 'donation_acknowledge',
      );

  String get cv_resume => Intl.message(
        'CV/Resume',
        name: 'cv_resume',
      );

  String get pledged => Intl.message(
        'Pledged',
        name: 'pledged',
      );

  String get goods => Intl.message(
        'Goods',
        name: 'goods',
      );

  String get cash => Intl.message(
        'Cash',
        name: 'cash',
      );

  String get received => Intl.message(
        'Received',
        name: 'received',
      );

  String get total => Intl.message(
        'Total',
        name: 'total',
      );

  String get recurringDays_err => Intl.message(
        'Recurring days cannot be empty',
        name: 'recurringDays_err',
      );

  String get calendars_popup_desc => Intl.message(
        'You can sync the calendar for SevaX events with your Google, Outlook or iCal calendars. Select the appropriate icon to sync the calendar.',
        name: 'calendars_popup_desc',
      );

  String get notifications_demoted_title => Intl.message(
        'You have been demoted from Admin',
        name: 'notifications_demoted_title',
      );

  String get notifications_demoted_subtitle_phrase => Intl.message(
        'has demoted you from being an Admin for the',
        name: 'notifications_demoted_subtitle_phrase',
      );

  String get notifications_promoted_title => Intl.message(
        'You have been promoted to Admin',
        name: 'notifications_promoted_title',
      );

  String get notifications_promoted_subtitle_phrase => Intl.message(
        'has promoted you to be the Admin for the',
        name: 'notifications_promoted_subtitle_phrase',
      );

  String get notifications_approved_withdrawn_title => Intl.message(
        'Member withdrawn',
        name: 'notifications_approved_withdrawn_title',
      );

  String get notifications_approved_withdrawn_subtitle => Intl.message(
        'has withdrawn from',
        name: 'notifications_approved_withdrawn_subtitle',
      );

  String get otm_offer_cancelled_title => Intl.message(
        'One to many offer Cancelled',
        name: 'otm_offer_cancelled_title',
      );

  String get otm_offer_cancelled_subtitle => Intl.message(
        'Offer cancelled by Creator',
        name: 'otm_offer_cancelled_subtitle',
      );

  String get notifications_credited_msg => Intl.message(
        'Seva coins has been credited to your account',
        name: 'notifications_credited_msg',
      );

  String get notifications_debited_msg => Intl.message(
        'Seva coinsMoMonthlyed from your account',
        name: 'notifications_debited_msg',
      );

  String get recurring_list_heading => Intl.message(
        'Recurring list',
        name: 'recurring_list_heading',
      );

  String get recuring_weekly_on => Intl.message(
        'Weekly on',
        name: 'recuring_weekly_on',
      );

  String get invoice_and_reports => Intl.message(
        'Invoice and Reports',
        name: 'invoice_and_reports',
      );

  String get invoice_reports_list => Intl.message(
        'Invoice/Reports List',
        name: 'invoice_reports_list',
      );

  String get invoice_note1 => Intl.message(
        'This invoice is for the billing period of',
        name: 'invoice_note1',
      );

  String get invoice_note2 => Intl.message(
        'Greetings from ***companyname. Here is the invoice for your usage of ***appname services for the period above. Additional information about your individual service charges and billing history is available in the billing section under the Manage tab.',
        name: 'invoice_note2',
      );

  String get initial_charges => Intl.message(
        'Initial Charges',
        name: 'initial_charges',
      );

  String get additional_billable_transactions => Intl.message(
        'Additional Billable Transactions',
        name: 'additional_billable_transactions',
      );

  String get discounted_transactions_msg => Intl.message(
        'Discounted Billable Transactions as per your current plan',
        name: 'discounted_transactions_msg',
      );

  String get address_header => Intl.message(
        'Bill to Address',
        name: 'address_header',
      );

  String get account_no => Intl.message(
        'Account Number',
        name: 'account_no',
      );

  String get billing_stmt => Intl.message(
        'Billing Statement',
        name: 'billing_stmt',
      );

  String get billing_stmt_no => Intl.message(
        'Statement Number',
        name: 'billing_stmt_no',
      );

  String get billing_stmt_date => Intl.message(
        'Statement Date',
        name: 'billing_stmt_date',
      );

  String get request_type => Intl.message(
        'Request type*',
        name: 'request_type',
      );

  String get request_type_time => Intl.message(
        'Time',
        name: 'request_type_time',
      );

  String get request_type_cash => Intl.message(
        'Cash',
        name: 'request_type_cash',
      );

  String get request_type_goods => Intl.message(
        'Goods',
        name: 'request_type_goods',
      );

  String get request_description_hint_goods => Intl.message(
        'Ex: Specify the cause of requesting goods and any #hashtags',
        name: 'request_description_hint_goods',
      );

  String get request_target_donation => Intl.message(
        'Target Donation*',
        name: 'request_target_donation',
      );

  String get request_target_donation_hint => Intl.message(
        'Ex: \$100',
        name: 'request_target_donation_hint',
      );

  String get request_min_donation => Intl.message(
        'Minimum amount per member*',
        name: 'request_min_donation',
      );

  String get request_goods_description => Intl.message(
        'Select list of goods for donation*',
        name: 'request_goods_description',
      );

  String get request_goods_address => Intl.message(
        'Which address goods to be received*',
        name: 'request_goods_address',
      );

  String get request_goods_address_hint => Intl.message(
        'Donors will use the below given address to send the items. Add additional details to the request details specify address only here.',
        name: 'request_goods_address_hint',
      );

  String get request_goods_address_inputhint => Intl.message(
        'Address Only',
        name: 'request_goods_address_inputhint',
      );

  String get request_payment_description => Intl.message(
        'Payment Details*',
        name: 'request_payment_description',
      );

  String get request_payment_description_hint => Intl.message(
        'SevaX doesn\'t process any payment you should have your own address for collection of payments, Plese provide one of the below paypal, zelpay (or) ACH details',
        name: 'request_payment_description_hint',
      );

  String get request_payment_description_inputhint => Intl.message(
        'Ex: https://www.paypal.com/johndoe',
        name: 'request_payment_description_inputhint',
      );

  String get request_min_donation_hint => Intl.message(
        'Ex: \$10',
        name: 'request_min_donation_hint',
      );

  String get validation_error_target_donation_count => Intl.message(
        'Please enter the number of target donation needed',
        name: 'validation_error_target_donation_count',
      );

  String get validation_error_target_donation_count_negative => Intl.message(
        'Please enter the number of target donation needed',
        name: 'validation_error_target_donation_count_negative',
      );

  String get validation_error_target_donation_count_zero => Intl.message(
        'Please enter the number of target donation needed',
        name: 'validation_error_target_donation_count_zero',
      );

  String get validation_error_min_donation_count => Intl.message(
        'Please enter the number of min donation needed',
        name: 'validation_error_min_donation_count',
      );

  String get validation_error_min_donation_count_negative => Intl.message(
        'Please enter the number of min donation needed',
        name: 'validation_error_min_donation_count_negative',
      );

  String get validation_error_min_donation_count_zero => Intl.message(
        'Please enter the number of min donation needed',
        name: 'validation_error_min_donation_count_zero',
      );

  String get request_description_hint_cash => Intl.message(
        'Ex: Specify the cause of fund raising and any #hashtags',
        name: 'request_description_hint_cash',
      );

  String get demotion_from_admin_to_member => Intl.message(
        'Demotion from admin to member',
        name: 'demotion_from_admin_to_member',
      );

  String get promotion_to_admin_from_member => Intl.message(
        'Promotion to admin from member',
        name: 'promotion_to_admin_from_member',
      );

  String get feedback_one_to_many_offer => Intl.message(
        'Feedback for One-to-many offer',
        name: 'feedback_one_to_many_offer',
      );

  String get sure_to_cancel_one_to_many_offer => Intl.message(
        'Are you sure you would like to cancel this One-to-Many offer',
        name: 'sure_to_cancel_one_to_many_offer',
      );

  String get proceed_with_cancellation => Intl.message(
        'Click OK to proceed with the cancelation, Otherwise, press cancel',
        name: 'proceed_with_cancellation',
      );

  String get members_signed_up_advisory => Intl.message(
        'People have already signed up for the offer. Canceling the offer would result in these users getting back the SevaCredits. Click OK to proceed with the cancelation. Otherwise, press cancel.',
        name: 'members_signed_up_advisory',
      );

  String get notification_one_to_many_offer_canceled_title => Intl.message(
        'A One-to-Many offer that you signed up for is canceled',
        name: 'notification_one_to_many_offer_canceled_title',
      );

  String get notification_one_to_many_offer_canceled_subtitle => Intl.message(
        'You had signed up for ***offerTItle. Due to unforeseen circumstances, ***name had to cancel this offer. You will receive credits for any unused SevaCredits.',
        name: 'notification_one_to_many_offer_canceled_subtitle',
      );

  String get nearby_settings_title => Intl.message(
        'Distance that I am willing to travel',
        name: 'nearby_settings_title',
      );

  String get nearby_settings_content => Intl.message(
        'This indicates the distance that the user is willing to travel to complete a Request for a Timebank or participate in a Project',
        name: 'nearby_settings_content',
      );

  String get amount => Intl.message(
        'Amount',
        name: 'amount',
      );

  String get only_images_types_allowed => Intl.message(
        'Only image types are allowed ex:jpg, png\'',
        name: 'only_images_types_allowed',
      );

  String get i_pledged_amount => Intl.message(
        'I pledge to donate this amount',
        name: 'i_pledged_amount',
      );

  String get i_received_amount => Intl.message(
        'I acknowledge that I have received',
        name: 'i_received_amount',
      );

  String get acknowledge_desc_one => Intl.message(
        'Note: Please check the amount that you have received from',
        name: 'acknowledge_desc_one',
      );

  String get acknowledge_desc_two => Intl.message(
        'This may be lower than the pledged amount due to a transaction fee. If there is a mismatch, please message',
        name: 'acknowledge_desc_two',
      );

  String get acknowledge_desc_donor_one => Intl.message(
        'Note: Please be sure that the amount you transfer to',
        name: 'acknowledge_desc_donor_one',
      );

  String get acknowledge_desc_donor_two => Intl.message(
        'matches the amount pledged above (subject to any transaction fee)',
        name: 'acknowledge_desc_donor_two',
      );

  String get acknowledge_received => Intl.message(
        'I acknowledge that i have received below',
        name: 'acknowledge_received',
      );

  String get acknowledge_donated => Intl.message(
        'I acknowledge that i have donated below',
        name: 'acknowledge_donated',
      );

  String get amount_pledged => Intl.message(
        'Amount pledged',
        name: 'amount_pledged',
      );

  String get amount_received_from => Intl.message(
        'Amount received from',
        name: 'amount_received_from',
      );

  String get donations_received => Intl.message(
        'Donations received',
        name: 'donations_received',
      );

  String get donations_requested => Intl.message(
        'Donation requested',
        name: 'donations_requested',
      );

  String get pledge_modified => Intl.message(
        'Your pledged was modified',
        name: 'pledge_modified',
      );

  String get donation_completed => Intl.message(
        'Donation completed',
        name: 'donation_completed',
      );

  String get donation_completed_desc => Intl.message(
        'Your donation is successfully completed. A receipt has been emailed to you.',
        name: 'donation_completed_desc',
      );

  String get pledge_modified_by_donor => Intl.message(
        'Your pledged was modified by donor',
        name: 'pledge_modified_by_donor',
      );

  String get has_cash_donation => Intl.message(
        'Has a request for cash donation',
        name: 'has_cash_donation',
      );

  String get has_goods_donation => Intl.message(
        'Has requested for goods donation',
        name: 'has_goods_donation',
      );

  String get cash_donation_invite => Intl.message(
        'has a request for cash donation. Tap to donate any amount that you can',
        name: 'cash_donation_invite',
      );

  String get goods_donation_invite => Intl.message(
        'has a request for donation of specific goods. You can tap to donate any goods that you can',
        name: 'goods_donation_invite',
      );

  String get failed_load_image => Intl.message(
        'Failed to load image. Try different image',
        name: 'failed_load_image',
      );

  String get request_updated => Intl.message(
        'Request Updated',
        name: 'request_updated',
      );

  String get demoted => Intl.message(
        'DEMOTED',
        name: 'demoted',
      );

  String get promoted => Intl.message(
        'PROMOTED',
        name: 'promoted',
      );

  String get seva_coins_debited => Intl.message(
        'Seva Coins debited',
        name: 'seva_coins_debited',
      );

  String get debited => Intl.message(
        'Debited',
        name: 'debited',
      );

  String get member_reported_title => Intl.message(
        'Member Reported',
        name: 'member_reported_title',
      );

  String get cannot_be_deleted => Intl.message(
        'cannot be deleted',
        name: 'cannot_be_deleted',
      );

  String get cannot_be_deleted_desc => Intl.message(
        'Your request to delete **requestData.entityTitle cannot be completed at this time. There are pending transactions. Tap here to view the details.',
        name: 'cannot_be_deleted_desc',
      );

  String get delete_request_success => Intl.message(
        '**requestTitle you requested to delete has been successfully deleted!',
        name: 'delete_request_success',
      );

  String get community => Intl.message(
        'Community',
        name: 'community',
      );

  String get stock_images => Intl.message(
        'Stock Images',
        name: 'stock_images',
      );

  String get choose_image => Intl.message(
        'Choose Image',
        name: 'choose_image',
      );

  String get timebank_has_parent => Intl.message(
        'Timebank has parent',
        name: 'timebank_has_parent',
      );

  String get timebank_location_has_parent_hint_text => Intl.message(
        'If your timebank is associated with a parent timebank select below',
        name: 'timebank_location_has_parent_hint_text',
      );

  String get select_parent_timebank => Intl.message(
        'Select Parent timebank',
        name: 'select_parent_timebank',
      );

  String get look_for_existing_siblings => Intl.message(
        'Feed is visible to following timebanks',
        name: 'look_for_existing_siblings',
      );

  String get none => Intl.message(
        'None',
        name: 'none',
      );

  String get find_your_parent_timebank => Intl.message(
        'Find your parent timebank if you are part of',
        name: 'find_your_parent_timebank',
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
