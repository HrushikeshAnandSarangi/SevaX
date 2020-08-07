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

  String get request_failure_message => Intl.message(
        'Sending request failed somehow, please try again later!',
        name: 'request_failure_message',
      );

  String get request_submitted => Intl.message(
        'Request submitted',
        name: 'request_submitted',
      );

  String get request_failed => Intl.message(
        'Request failed!',
        name: 'request_failed',
      );

  String get hosted_by => Intl.message(
        'Hosted by',
        name: 'hosted_by',
      );

  String get no_approved_members => Intl.message(
        'No Approved members yet.',
        name: 'no_approved_members',
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

  String get withdraw_request_failure => Intl.message(
        'You cannot withdraw request since already approved',
        name: 'withdraw_request_failure',
      );

  String get already_approved => Intl.message(
        'Already Approved',
        name: 'already_approved',
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

  String timebank_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Timebank Request', other: 'Timebank Requests', args: [count])}',
        name: 'timebank_request',        
        args: [count],
      );

  String personal_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Personal Request', other: 'Personal Requests', args: [count])}',
        name: 'personal_request',        
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

  String get blocked_members => Intl.message(
        'Blocked Members',
        name: 'blocked_members',
      );

  String get no_blocked_members => Intl.message(
        'No blocked members',
        name: 'no_blocked_members',
      );

  String get confirm_location => Intl.message(
        'confirm location',
        name: 'confirm_location',
      );

  String get reject_task_completion => Intl.message(
        'I am rejecting your task completion request because',
        name: 'reject_task_completion',
      );

  String get no_message => Intl.message(
        'No Messages',
        name: 'no_message',
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

  String get validation_error_offer_class_hours => Intl.message(
        'Please enter the hours required for the class',
        name: 'validation_error_offer_class_hours',
      );

  String get validation_error_offer_title => Intl.message(
        'Please enter the subject of your offer',
        name: 'validation_error_offer_title',
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

  String get pending_requests => Intl.message(
        'pending requests',
        name: 'pending_requests',
      );

  String get pending_projects => Intl.message(
        'pending projects',
        name: 'pending_projects',
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

  String get no_data => Intl.message(
        'No data found !',
        name: 'no_data',
      );

  String get i_want_to_volunteer => Intl.message(
        'I want to volunteer.',
        name: 'i_want_to_volunteer',
      );

  String get help_about_us => Intl.message(
        'About Us',
        name: 'help_about_us',
      );

  String get feedback_messagae => Intl.message(
        'Please let us know about your valuable feedback',
        name: 'feedback_messagae',
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

  String get private_timebank_alert_hint => Intl.message(
        'Please be informed that Private Timebanks do not have a free option. You will need to provide your billing details to continue to create this Timebank',
        name: 'private_timebank_alert_hint',
      );

  String get private_timebank_alert => Intl.message(
        'Private Timebank alert',
        name: 'private_timebank_alert',
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

  String get updating_feed => Intl.message(
        'Updating post',
        name: 'updating_feed',
      );

  String get update_feed => Intl.message(
        'Update post',
        name: 'update_feed',
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
