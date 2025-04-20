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

  static S of(BuildContext context) {
    final s = Localizations.of<S>(context, S);
    if (s == null) throw FlutterError('No S found in context');
    return s;
  }

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

  String get skills => Intl.message(
        'Skills',
        name: 'skills',
      );

  String get interests => Intl.message(
        'Interests',
        name: 'interests',
      );

  String get email => Intl.message(
        'Email',
        name: 'email',
      );

  String get password => Intl.message(
        'Password',
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
        ' We will manage information as described in our',
        name: 'login_agreement_message2',
      );

  String get login_agreement_privacy_link => Intl.message(
        'Privacy Policy',
        name: 'login_agreement_privacy_link',
      );

  String get and => Intl.message(
        ' and',
        name: 'and',
      );

  String get login_agreement_payment_link => Intl.message(
        'Payment Policy',
        name: 'login_agreement_payment_link',
      );

  String get new_user => Intl.message(
        'New User? ',
        name: 'new_user',
      );

  String get sign_up => Intl.message(
        'Sign Up',
        name: 'sign_up',
      );

  String get sign_in => Intl.message(
        'Sign in',
        name: 'sign_in',
      );

  String get forgot_password => Intl.message(
        'Forgot Password? ',
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
        'Please check your email to set your password. Then enter that password here',
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

  String get email_sent_to => Intl.message(
        '\n\nWe sent an email to\n',
        name: 'email_sent_to',
      );

  String get verify_account => Intl.message(
        ' to verify\nyour account',
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
        'Please list as many as skills that you are willing to share with others within your community.',
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
        'Please list as many of your interests or passions that you are willing to share with others within your community.',
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
        'Please tell us a little bit about yourself in a few sentences.For example, you can tell us what makes you unique.',
        name: 'bio_description',
      );

  String get bio_hint => Intl.message(
        'Ex: What makes me unique is',
        name: 'bio_hint',
      );

  String get validation_error_bio_empty => Intl.message(
        'Its easy, please fill few words about you.',
        name: 'validation_error_bio_empty',
      );

  String get validation_error_bio_min_characters => Intl.message(
        '*min 50 characters',
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
        'Seva Communities near you',
        name: 'timebanks_near_you',
      );

  String get find_your_timebank => Intl.message(
        'Find your Seva Community',
        name: 'find_your_timebank',
      );

  String get looking_existing_timebank => Intl.message(
        'Looking for an existing Seva Community to join?\nEnter ZIP/ Postal Code or city, state, country',
        name: 'looking_existing_timebank',
      );

  String get find_timebank_help_text => Intl.message(
        'Enter the name or location of your community.',
        name: 'find_timebank_help_text',
      );

  String get no_timebanks_found => Intl.message(
        'No Seva Communities found',
        name: 'no_timebanks_found',
      );

  String get timebank => Intl.message(
        'Seva Community',
        name: 'timebank',
      );

  String get created_by => Intl.message(
        'Created by ',
        name: 'created_by',
      );

  String get create_timebank => Intl.message(
        'Create a Seva Community',
        name: 'create_timebank',
      );

  String get timebank_gps_hint => Intl.message(
        'Please make sure you have GPS turned on to see the list of Seva Communities around you',
        name: 'timebank_gps_hint',
      );

  String get create_timebank_confirmation => Intl.message(
        'Are you sure you want to create a new Seva Community - as opposed to joining an existing Seva Community? Creating a new Seva Community implies that you will be responsible for administering the Seva Community - including adding members and managing members’ needs, timely replying to members questions, bringing about conflict resolutions, and hosting monthly potlucks. In order to become a member of an existing Seva Community, you will need to know the name of the Seva Community and either have an invitation code or submit a request to join the Seva Community.',
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
        'REQUESTED',
        name: 'requested',
      );

  String get rejected => Intl.message(
        'REJECTED',
        name: 'rejected',
      );

  String get join_timebank_code_message => Intl.message(
        'Enter the code you received from your Seva Community admin to join now.',
        name: 'join_timebank_code_message',
      );

  String get join_timebank_request_invite_hint => Intl.message(
        'If you dont have a code, Click',
        name: 'join_timebank_request_invite_hint',
      );

  String get join_timebank_request_invite => Intl.message(
        'Request Invite',
        name: 'join_timebank_request_invite',
      );

  String get join_timbank_already_requested => Intl.message(
        'You already requested to this Seva Community. Please wait untill request is accepted',
        name: 'join_timbank_already_requested',
      );

  String get join_timebank_question => Intl.message(
        'Why do you want to join this',
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
        'successfully.',
        name: 'successfully',
      );

  String get validation_error_timebank_join_code_redeemed => Intl.message(
        'Seva Community code already redeemed',
        name: 'validation_error_timebank_join_code_redeemed',
      );

  String get validation_error_timebank_join_code_redeemed_self => Intl.message(
        'The Seva Community code that you have provided has already been redeemed earlier by you. Please request the Seva Community admin for a new code.',
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
        'Events',
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
        'Member(s)',
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
        'Restricted Seva Community',
        name: 'protected_timebank',
      );

  String get protected_timebank_group_creation_error => Intl.message(
        'You cannot create groups in a protected Seva Community',
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
        'OK',
        name: 'ok',
      );

  String get no_group_message => Intl.message(
        'Groups help you to organize your specific \n activities, you don\'t have any. Try ',
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
        'From:',
        name: 'from',
      );

  String get until => Intl.message(
        'Until',
        name: 'until',
      );

  String get posted_by => Intl.message(
        'Posted By:',
        name: 'posted_by',
      );

  String get posted_date => Intl.message(
        'PostDate:',
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

  String get validation_error_task_minutes => Intl.message(
        'Minutes cannot be Empty',
        name: 'validation_error_task_minutes',
      );

  String get minutes => Intl.message(
        'Minutes',
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
        'On',
        name: 'on',
      );

  String get notifications_event_modification => Intl.message(
        '. The Event Organizer has modified this event. Make sure the changes made are right for you and apply again',
        name: 'notifications_event_modification',
      );

  String get notification_timebank_join => Intl.message(
        'Seva Community Join',
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
        'has requested to join',
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
        'has invited you to join the',
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
        'We couldn\'t process you request for deletion of ***, as you are still having open transactions which are as : \n',
        name: 'notifications_incomplete_transaction',
      );

  String get one_to_many_offers => Intl.message(
        'one to many offers\n',
        name: 'one_to_many_offers',
      );

  String get open_requests => Intl.message(
        'open requests\n',
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
        'No events available.Try',
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
        'You cannot post requests in a protected Seva Community',
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
        'Number of volunteers required:',
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
        'No approved members yet.',
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
        'applied',
        name: 'applied',
      );

  String get accepted => Intl.message(
        'Accepted',
        name: 'accepted',
      );

  String get default_text => Intl.message(
        'DEFAULT',
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
        'Organizer',
        name: 'organizer',
      );

  String get delete_project => Intl.message(
        'Delete Event',
        name: 'delete_project',
      );

  String get create_project => Intl.message(
        'Create an Event',
        name: 'create_project',
      );

  String get edit_project => Intl.message(
        'Edit Event',
        name: 'edit_project',
      );

  String get project_logo => Intl.message(
        'Event Image',
        name: 'project_logo',
      );

  String get project_name => Intl.message(
        'Event Name',
        name: 'project_name',
      );

  String get name_hint => Intl.message(
        'Ex: Pets-in-town, Citizen collab',
        name: 'name_hint',
      );

  String get validation_error_project_name_empty => Intl.message(
        'Event name cannot be empty',
        name: 'validation_error_project_name_empty',
      );

  String get project_duration => Intl.message(
        'Event duration',
        name: 'project_duration',
      );

  String get project_mission_statement_hint => Intl.message(
        'Tell us why this event is happening. How will it help your community',
        name: 'project_mission_statement_hint',
      );

  String get validation_error_mission_empty => Intl.message(
        'Mission statement cannot be empty.',
        name: 'validation_error_mission_empty',
      );

  String get email_hint => Intl.message(
        'Ex: example@example.com',
        name: 'email_hint',
      );

  String get phone_number => Intl.message(
        'Phone Number',
        name: 'phone_number',
      );

  String get project_location => Intl.message(
        'Your event location',
        name: 'project_location',
      );

  String get project_location_hint => Intl.message(
        'Please specify the exact address.',
        name: 'project_location_hint',
      );

  String get save_as_template => Intl.message(
        'Save as Template',
        name: 'save_as_template',
      );

  String get validation_error_no_date => Intl.message(
        'Please mention the start and end date.',
        name: 'validation_error_no_date',
      );

  String get creating_project => Intl.message(
        'Creating an event',
        name: 'creating_project',
      );

  String get validation_error_location_mandatory => Intl.message(
        'Location is Mandatory',
        name: 'validation_error_location_mandatory',
      );

  String get validation_error_add_project_location => Intl.message(
        'Please add location to your event',
        name: 'validation_error_add_project_location',
      );

  String get updating_project => Intl.message(
        'Updating an event',
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
        'Ex: Template Name',
        name: 'template_hint',
      );

  String get validation_error_template_name => Intl.message(
        'Template name cannot be empty',
        name: 'validation_error_template_name',
      );

  String get validation_error_template_name_exists => Intl.message(
        'Template name is already in use.\nPlease provide another name',
        name: 'validation_error_template_name_exists',
      );

  String get add_location => Intl.message(
        'Add Location',
        name: 'add_location',
      );

  String get delete_confirmation => Intl.message(
        'Are your sure you want to delete ',
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
        'All relevant information including events, requests and offers under the group will be deleted!',
        name: 'advisory_for_timebank',
      );

  String get advisory_for_projects => Intl.message(
        'All events associated to this request would be removed',
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
        'You have accepetd the request',
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
        'You cannot accept requests in a protected Seva Community',
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
        'Find Members',
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
        'Previously Selected',
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
        'Name not available',
        name: 'name_not_available',
      );

  String get create_request => Intl.message(
        'Create Request',
        name: 'create_request',
      );

  String get create_project_request => Intl.message(
        'Create an Event Request',
        name: 'create_project_request',
      );

  String get set_duration => Intl.message(
        ' Click to Set Duration',
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
        '  Request duration',
        name: 'request_duration',
      );

  String get request_description => Intl.message(
        'Request description*',
        name: 'request_description',
      );

  String get request_description_hint => Intl.message(
        'Please describe what you need to have done. \n \nExample, I need help removing weeds from  my small garden.',
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

  String get validation_error_same_start_date_end_date => Intl.message(
        'You have provided identical date and time for the Start and End. Please provide an End time that is after the Start time.',
        name: 'validation_error_same_start_date_end_date',
      );

  String get validation_error_empty_recurring_days => Intl.message(
        'Recurring days cannot be empty',
        name: 'validation_error_empty_recurring_days',
      );

  String get creating_request => Intl.message(
        'Creating Request...',
        name: 'creating_request',
      );

  String get updating_request => Intl.message(
        'Updating Request...',
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

  String get timebank_max_seva_credit_message1 => Intl.message(
        ' Seva Credits will be credited to the Seva Community for this request. Note that each participant will receive a maximum of ',
        name: 'timebank_max_seva_credit_message1',
      );

  String get timebank_max_seva_credit_message2 => Intl.message(
        ' credits for completing this request.',
        name: 'timebank_max_seva_credit_message2',
      );

  String get personal_max_seva_credit_message1 => Intl.message(
        ' Seva Credits are required for this request. It will be debited from your balance. Note that each participant will receive a maximum of ',
        name: 'personal_max_seva_credit_message1',
      );

  String get personal_max_seva_credit_message2 => Intl.message(
        ' credits for completing this request.',
        name: 'personal_max_seva_credit_message2',
      );

  String get unassigned => Intl.message(
        'Unassigned',
        name: 'unassigned',
      );

  String get assign_to_project => Intl.message(
        'Assign to an event',
        name: 'assign_to_project',
      );

  String get assign_to_one_project => Intl.message(
        'Please assign to one event',
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
        'End Date cannot be before Start Date ',
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
        'CONFIRM LOCATION',
        name: 'confirm_location',
      );

  String get no_message => Intl.message(
        'No Messages',
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
        'GROUPS',
        name: 'groups',
      );

  String get timebank_members => Intl.message(
        'SEVA COMMUNITY MEMBERS',
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
        'has invited you to be the new owner of the',
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
        'Updating Seva Community..',
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
        'Creating Offer',
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
        'Ex: babysitting, math tutoring',
        name: 'offer_title_hint',
      );

  String get offer_description => Intl.message(
        'Offer description',
        name: 'offer_description',
      );

  String get offer_description_hint => Intl.message(
        'Ex: Describe in detail what you are willing to offer. Please use #hashtags so members can easily search for this offer, such as #babysitting or #mathhelp',
        name: 'offer_description_hint',
      );

  String get availablity => Intl.message(
        'Availability',
        name: 'availablity',
      );

  String get availablity_description => Intl.message(
        'Tell us the days or times you are generally available or not available. Example, I\'m available only on weekends or weeknights after 6pm.',
        name: 'availablity_description',
      );

  String get one_to_many_offer_hint => Intl.message(
        'Ex: teaching a python class..',
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
        'Please give a detailed description of the class you’re offering.',
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
        'Seva Community earnings',
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
        'pending events',
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
        'User is successfully removed from the seva community',
        name: 'user_removed_from_timebank',
      );

  String get user_removed_from_timebank_failed => Intl.message(
        'User cannot be deleted from this Seva Community',
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
        'Click here to view reported users of this Seva Community',
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
        'About us',
        name: 'help_about_us',
      );

  String get help_training_video => Intl.message(
        'Training Video',
        name: 'help_training_video',
      );

  String get help_contact_us => Intl.message(
        'Contact Us',
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
        'Send Feedback',
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
        'A Seva Community is a community where members give and receive help to each other and the greater community through time, money or goods.',
        name: 'create_timebank_description',
      );

  String get timebank_logo => Intl.message(
        'Seva Community Image',
        name: 'timebank_logo',
      );

  String get timebank_name => Intl.message(
        'Name your Seva Community',
        name: 'timebank_name',
      );

  String get timebank_name_hint => Intl.message(
        'Ex: Evergreen Neighborhood, Acme Organization, XYZ Food Bank',
        name: 'timebank_name_hint',
      );

  String get timebank_name_error => Intl.message(
        'Seva Community name cannot be empty',
        name: 'timebank_name_error',
      );

  String get timebank_name_exists_error => Intl.message(
        'Please choose another name for the Seva Community. This Seva Community name already exists',
        name: 'timebank_name_exists_error',
      );

  String get timbank_about_hint => Intl.message(
        'Ex: A bit more about your Seva Community',
        name: 'timbank_about_hint',
      );

  String get timebank_tell_more => Intl.message(
        'Tell us more about your Seva Community.',
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
        'Your Seva Community location.',
        name: 'timebank_location',
      );

  String get timebank_location_hint => Intl.message(
        'Ex: List the place or address where your community meets (such as a cafe, library, or church.).',
        name: 'timebank_location_hint',
      );

  String get timebank_name_exists => Intl.message(
        'Seva Community name already exists !',
        name: 'timebank_name_exists',
      );

  String get timebank_location_error => Intl.message(
        'Please add the location of your Seva Community',
        name: 'timebank_location_error',
      );

  String get timebank_logo_error => Intl.message(
        'Seva Community image is mandatory',
        name: 'timebank_logo_error',
      );

  String get creating_timebank => Intl.message(
        'Creating Seva Community',
        name: 'creating_timebank',
      );

  String get timebank_billing_error => Intl.message(
        'Please configure your billing information details',
        name: 'timebank_billing_error',
      );

  String get timebank_configure_profile_info => Intl.message(
        'Configure billing information',
        name: 'timebank_configure_profile_info',
      );

  String get timebank_profile_info => Intl.message(
        'Billing Information',
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
        'ZIP Code',
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
        'Company Name',
        name: 'company_name',
      );

  String get continue_text => Intl.message(
        'Continue',
        name: 'continue_text',
      );

  String get private_timebank => Intl.message(
        'Private Seva Community',
        name: 'private_timebank',
      );

  String get updating_details => Intl.message(
        'Updating details',
        name: 'updating_details',
      );

  String get edit_profile_information => Intl.message(
        'Edit Account Information',
        name: 'edit_profile_information',
      );

  String get selected_users_before => Intl.message(
        ' Selected users before ',
        name: 'selected_users_before',
      );

  String get private_timebank_alert => Intl.message(
        'Private Seva Community alert',
        name: 'private_timebank_alert',
      );

  String get private_timebank_alert_hint => Intl.message(
        'Please be informed that Private Seva Communities do not have a free option. You will need to provide your billing details to continue to create this Seva Community',
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
        'Seva Community Offers',
        name: 'timebank_offers',
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

  String get card_details => Intl.message(
        'CARD DETAILS',
        name: 'card_details',
      );

  String get add_new => Intl.message(
        'Add New Card',
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
        'Deleting feed',
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
        'Ex: Text, URL and Hashtags',
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
        'Select Category',
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
        'Add image',
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
        'Notifications Alerts',
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
        'Member request to join a ',
        name: 'join_request_message',
      );

  String get offer_debit => Intl.message(
        'Debit for one to many offer ',
        name: 'offer_debit',
      );

  String get member_exits => Intl.message(
        'Member exits a ',
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
        'Select a Seva Community',
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
        ' would be unblocked',
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
        'Date:',
        name: 'date',
      );

  String get search_template_hint => Intl.message(
        'Enter name of a Event Template',
        name: 'search_template_hint',
      );

  String get create_project_from_template => Intl.message(
        'Create an Event from Template',
        name: 'create_project_from_template',
      );

  String get create_new_project => Intl.message(
        'Create new Event',
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
        'New Event',
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
        'Taking you to your new Seva Community...',
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
        'Congratulations! You are now the new owner of the Seva Community ',
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
        'Changing ownership',
        name: 'changing_ownership_of',
      );

  String get to_other_admin => Intl.message(
        ' to another admin.',
        name: 'to_other_admin',
      );

  String get change_to => Intl.message(
        'Change to',
        name: 'change_to',
      );

  String get invitation_sent1 => Intl.message(
        'We have sent your transfer of ownership invitation. You will remain to be the owner of Seva Community ',
        name: 'invitation_sent1',
      );

  String get invitation_sent2 => Intl.message(
        ' until ',
        name: 'invitation_sent2',
      );

  String get invitation_sent3 => Intl.message(
        'accepts the invitation and provides their new account information.',
        name: 'invitation_sent3',
      );

  String get by_accepting_owner_timebank => Intl.message(
        'You have been designated the new owner of the ________ Seva Community. In order to complete the process, please select the Accept button to continue to the confirmation process.',
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
        'You have payment pending of ',
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
        'You are the new owner of',
        name: 'change_ownership_message1',
      );

  String get change_ownership_message2 => Intl.message(
        ' You need to accept it to complete the process',
        name: 'change_ownership_message2',
      );

  String get change_ownership_advisory => Intl.message(
        ' You are required to provide billing details for this Seva Community - including the new billing address. The transfer of ownership will not be completed until this is done.',
        name: 'change_ownership_advisory',
      );

  String get change_ownership_already_invited => Intl.message(
        ' already invited.',
        name: 'change_ownership_already_invited',
      );

  String get donate => Intl.message(
        'Donate',
        name: 'donate',
      );

  String get donate_to_timebank => Intl.message(
        'Donate seva credits to Seva Community',
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
        'Add Members',
        name: 'add_members',
      );

  String get group_logo => Intl.message(
        'Group Image',
        name: 'group_logo',
      );

  String get name_your_group => Intl.message(
        'Name your specific Group',
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
        'Find Seva Communities',
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
        'Bulk invite users using a CSV file',
        name: 'bulk_invite_users_csv',
      );

  String get csv_message1 => Intl.message(
        'First, create a .csv file template and add the users that you want to invite to your Seva Community. Please see the format below for the two fields to include in your file. Then, select the Upload button to add the file. Note: do not upload any extra fields nor try to upload other spreadsheet file formats other than the .csv file.',
        name: 'csv_message1',
      );

  String get csv_message2 => Intl.message(
        'fill the users you would like to add ',
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
        'Please upload only CSV file with users full name and email address',
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
        'Seva Community code : ',
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
        'Seva Communities allow you to volunteer and receive Seva credits that can be used by you for getting the community to help you with getting things done for you. Use the code',
        name: 'invite_message',
      );

  String get invite_prompt => Intl.message(
        'when prompted to join this community. Please download the SevaX app from the links provided at https://sevaexchange.page.link/sevaxapp',
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
        'No Member found',
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
        'No Image Available',
        name: 'no_image_available',
      );

  String get group_description => Intl.message(
        'Groups within a Seva Community allow for those with shared interests to meet regularly and organize separately.',
        name: 'group_description',
      );

  String get updating_users => Intl.message(
        'Updating Members',
        name: 'updating_users',
      );

  String get admins_organizers => Intl.message(
        'Admin(s) & Super Admin(s)',
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
        'Donate seva credits to user',
        name: 'loan_seva_credit_to_user',
      );

  String get timebank_seva_credit => Intl.message(
        'Your Seva Community seva credits is',
        name: 'timebank_seva_credit',
      );

  String get timebank_loan_message => Intl.message(
        'On click of Donate, Seva Community balance will be adjusted.',
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
        'You have donated credits successfully',
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
        'Edit Seva Community',
        name: 'edit_timebank',
      );

  String get delete_timebank => Intl.message(
        'Delete Seva Community',
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
        'User is successfully removed from the Seva Community',
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
        'Group is a subset of a community who share common goals or interests. (Finance Committee, Parent Teacher Assoc., LGBTQ)',
        name: 'group_subset',
      );

  String get part_of => Intl.message(
        'Part of',
        name: 'part_of',
      );

  String get global_timebank => Intl.message(
        'SevaX Global Network of Communities',
        name: 'global_timebank',
      );

  String get getting_volunteers => Intl.message(
        'Getting volunteers...',
        name: 'getting_volunteers',
      );

  String get no_volunteers_yet => Intl.message(
        'No Members joined yet',
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
        'Admin(s) cannot create message',
        name: 'admin_cannot_create_message',
      );

  String get volunteers => Intl.message(
        'Volunteer(s)',
        name: 'volunteers',
      );

  String get and_others => Intl.message(
        'and Others',
        name: 'and_others',
      );

  String get admins => Intl.message(
        'Admin(s)',
        name: 'admins',
      );

  String get remove_as_admin => Intl.message(
        'Remove as admin',
        name: 'remove_as_admin',
      );

  String get add_as_admin => Intl.message(
        'Add as Admin',
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
        'from Seva Community members?',
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
        'Switching Seva Community',
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
        'Seva Community Exit',
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
        'Awesome! You are invited to join a Seva Community',
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
        'Failed to fetch location*',
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
        'Upload your CV or resume',
        name: 'upload_cv_resume',
      );

  String get cv_message => Intl.message(
        'Uploading your CV or resume helps us match you better to opportunities.',
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
        'Note: The maximum size for the CV / Resume is 10 Mb',
        name: 'validation_error_cv_size',
      );

  String get validation_error_cv_not_selected => Intl.message(
        'Please select a CV / Resume file first before you upload',
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

  String get delete_request_confirmation => Intl.message(
        'Are you sure you want to delete this request?',
        name: 'delete_request_confirmation',
      );

  String get will_be_added_to_request => Intl.message(
        'will be added to the request.',
        name: 'will_be_added_to_request',
      );

  String get updating => Intl.message(
        'Updating',
        name: 'updating',
      );

  String get skipping => Intl.message(
        'Skipping',
        name: 'skipping',
      );

  String get check_email => Intl.message(
        'Now check your email.',
        name: 'check_email',
      );

  String get thanks => Intl.message(
        'Thanks!',
        name: 'thanks',
      );

  String get hour => Intl.message(
        'hour',
        name: 'hour',
      );

  String timebank_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Seva Community Project', other: 'Seva Community Projects', args: [
              count
            ])}',
        name: 'timebank_project',
        args: [count],
      );

  String personal_project(num count) => Intl.message(
        '${Intl.plural(count, one: 'Personal Project', other: 'Personal Projects', args: [
              count
            ])}',
        name: 'personal_project',
        args: [count],
      );

  String personal_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Personal Request', other: 'Personal Requests', args: [
              count
            ])}',
        name: 'personal_request',
        args: [count],
      );

  String timebank_request(num count) => Intl.message(
        '${Intl.plural(count, one: 'Seva Community Request', other: 'Seva Community Requests', args: [
              count
            ])}',
        name: 'timebank_request',
        args: [count],
      );

  String members_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'member selected', other: 'members selected', args: [
              count
            ])}',
        name: 'members_selected',
        args: [count],
      );

  String volunteers_selected(num count) => Intl.message(
        '${Intl.plural(count, one: 'volunteer selected', other: 'volunteers selected', args: [
              count
            ])}',
        name: 'volunteers_selected',
        args: [count],
      );

  String user(num count) => Intl.message(
        '${Intl.plural(count, one: 'user', other: 'users', args: [count])}',
        name: 'user',
        args: [count],
      );

  String get other => Intl.message(
        'Other (Please write in details below.)',
        name: 'other',
      );

  String subscription(num count) => Intl.message(
        '${Intl.plural(count, one: 'Subscription', other: 'Subscriptions', args: [
              count
            ])}',
        name: 'subscription',
        args: [count],
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
        'cannot exit from this seva community',
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
        'Item(s) Picked-up',
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
        'Select a goods / supplies category',
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
        'Describe the type of goods or supplies you donated and select from the list of items below.',
        name: 'describe_goods',
      );

  String get payment_link_description => Intl.message(
        'Please use the link down below to donate and once done take a pledge on how much you have donated.',
        name: 'payment_link_description',
      );

  String get donation_description_one => Intl.message(
        'Great! You have chosen to donate to',
        name: 'donation_description_one',
      );

  String get donation_description_two => Intl.message(
        'a donation of no less than',
        name: 'donation_description_two',
      );

  String get donation_description_three => Intl.message(
        ' USD.',
        name: 'donation_description_three',
      );

  String get add_amount_donated => Intl.message(
        'Add the amount you have pledged to donate',
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
        'Money',
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
        'Money',
        name: 'request_type_cash',
      );

  String get request_type_goods => Intl.message(
        'Goods / Supplies',
        name: 'request_type_goods',
      );

  String get request_description_hint_goods => Intl.message(
        'Ex: Specify the cause of requesting goods / supplies and any #hashtags',
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
        'Provide the list of Goods/Supplies that you need*',
        name: 'request_goods_description',
      );

  String get request_goods_address => Intl.message(
        'Provide address where the donor should ship*',
        name: 'request_goods_address',
      );

  String get request_goods_address_hint => Intl.message(
        'Ex: Donors will use the address below to ship the Goods/Supplies.',
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
        'SevaX does not process the payment. Please select from among PayPal, ZellePay or ACH in the drop down and provide the appropriate details for each method. The donor will complete the donation outside the SevaX app.',
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
        'Ex: Specify the cause for fundraising. Include any #hashtags',
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
        'This indicates the distance that the user is willing to travel to complete a Request for a Seva Community or participate in an Event',
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
        'I acknowledge that our community/organization has received',
        name: 'i_received_amount',
      );

  String get acknowledge_desc_one => Intl.message(
        'Note: Please check the amount that you have received from',
        name: 'acknowledge_desc_one',
      );

  String get acknowledge_desc_two => Intl.message(
        'This may be more or less than the pledged amount. If there is a discrepancy in the amount, please message the member.',
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
        'Requested Donation',
        name: 'donations_requested',
      );

  String get pledge_modified => Intl.message(
        'Your pledged amount for donation was not acknowledged',
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
        'Donor has modified the pledge amount',
        name: 'pledge_modified_by_donor',
      );

  String get has_cash_donation => Intl.message(
        'Has a request for money donation',
        name: 'has_cash_donation',
      );

  String get has_goods_donation => Intl.message(
        'Has requested for goods / supplies donation',
        name: 'has_goods_donation',
      );

  String get cash_donation_invite => Intl.message(
        'has a request for money donation. Tap to donate any amount that you can',
        name: 'cash_donation_invite',
      );

  String get goods_donation_invite => Intl.message(
        'has a request for donation of specific goods / supplies. You can tap to donate any goods that you can',
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
        'community',
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
        'Seva Community has a parent',
        name: 'timebank_has_parent',
      );

  String get timebank_location_has_parent_hint_text => Intl.message(
        'If your Seva community is associated with a parent Seva Community, please select from the dropdown below',
        name: 'timebank_location_has_parent_hint_text',
      );

  String get select_parent_timebank => Intl.message(
        'Select Parent Seva Communities',
        name: 'select_parent_timebank',
      );

  String get look_for_existing_siblings => Intl.message(
        'Your post is visible to the following Seva Communities:',
        name: 'look_for_existing_siblings',
      );

  String get none => Intl.message(
        'None',
        name: 'none',
      );

  String get find_your_parent_timebank => Intl.message(
        'Find your parent Seva Community if you are part of',
        name: 'find_your_parent_timebank',
      );

  String get look_for_existing_timebank_title => Intl.message(
        'Looking for existing Seva Community',
        name: 'look_for_existing_timebank_title',
      );

  String get copied_to_clipboard => Intl.message(
        'Copied to Clipboard',
        name: 'copied_to_clipboard',
      );

  String get delete_comment_msg => Intl.message(
        'Are you sure want to delete comment?',
        name: 'delete_comment_msg',
      );

  String get goods_modified_by_donor => Intl.message(
        'Donor has modified goods / supplies',
        name: 'goods_modified_by_donor',
      );

  String get goods_modified_by_creator => Intl.message(
        'Your goods / supplies for donation was not acknowledged',
        name: 'goods_modified_by_creator',
      );

  String get amount_modified_by_creator_desc => Intl.message(
        'The amount that you pledged for this donation is different from the amount acknowledged by the creator. Tap to change your pledge amount.',
        name: 'amount_modified_by_creator_desc',
      );

  String get goods_modified_by_creator_desc => Intl.message(
        'The goods / supplies that you donated for this donation is different from the goods acknowledged by the creator. Tap to change your goods details.',
        name: 'goods_modified_by_creator_desc',
      );

  String get amount_modified_by_donor_desc => Intl.message(
        'The amount which you acknowledged for this donation is different from the amount confirmed by the Donor. Tap to change the confirmation amount.',
        name: 'amount_modified_by_donor_desc',
      );

  String get goods_modified_by_donor_desc => Intl.message(
        'The goods / supplies which you acknowledged for this donation is different from the goods confirmed by the Donor. Tap to change the confirmation goods.',
        name: 'goods_modified_by_donor_desc',
      );

  String get imageurl_alert => Intl.message(
        'Web Image URL alert',
        name: 'imageurl_alert',
      );

  String get image_url_alert_desc => Intl.message(
        'Please add a image URL to continue',
        name: 'image_url_alert_desc',
      );

  String get enter_valid_link => Intl.message(
        'Enter valid payment link',
        name: 'enter_valid_link',
      );

  String get target_amount_less_than_min_amount => Intl.message(
        'Minimum amount cannot be greater than target amount',
        name: 'target_amount_less_than_min_amount',
      );

  String get failed_load_image_title => Intl.message(
        'Failed to load',
        name: 'failed_load_image_title',
      );

  String get image_url_hint => Intl.message(
        'Add Image Url ex: https://www.sevaexchange.com/sevalogo.png',
        name: 'image_url_hint',
      );

  String get request_details => Intl.message(
        'Request details',
        name: 'request_details',
      );

  String get skip_for_now => Intl.message(
        'Skip for now',
        name: 'skip_for_now',
      );

  String get would_like_to_donate => Intl.message(
        'Would you like to make a donation for this request?',
        name: 'would_like_to_donate',
      );

  String get total_goods_recevied => Intl.message(
        'Total Goods Received',
        name: 'total_goods_recevied',
      );

  String get total_amount_raised => Intl.message(
        'Total amount raised',
        name: 'total_amount_raised',
      );

  String get by_accepting_group_join => Intl.message(
        'By accepting, you will be added to',
        name: 'by_accepting_group_join',
      );

  String get group_join => Intl.message(
        'Group Join',
        name: 'group_join',
      );

  String get request_payment_descriptionZelle_inputhint => Intl.message(
        'Ex: Zellepay ID (phone or email)',
        name: 'request_payment_descriptionZelle_inputhint',
      );

  String get request_payment_ach_bank_name => Intl.message(
        'Bank Name*',
        name: 'request_payment_ach_bank_name',
      );

  String get request_payment_ach_bank_address => Intl.message(
        'Bank Address*',
        name: 'request_payment_ach_bank_address',
      );

  String get request_payment_ach_routing_number => Intl.message(
        'Routing Number*',
        name: 'request_payment_ach_routing_number',
      );

  String get request_payment_ach_account_no => Intl.message(
        'Account Number*',
        name: 'request_payment_ach_account_no',
      );

  String get enter_valid_bank_address => Intl.message(
        'Enter Bank Address',
        name: 'enter_valid_bank_address',
      );

  String get enter_valid_bank_name => Intl.message(
        'Enter Bank Name',
        name: 'enter_valid_bank_name',
      );

  String get enter_valid_account_number => Intl.message(
        'Enter Account Number',
        name: 'enter_valid_account_number',
      );

  String get enter_valid_routing_number => Intl.message(
        'Enter Routing Number',
        name: 'enter_valid_routing_number',
      );

  String get request_paymenttype_zellepay => Intl.message(
        'ZellePay',
        name: 'request_paymenttype_zellepay',
      );

  String get request_paymenttype_paypal => Intl.message(
        'PayPal',
        name: 'request_paymenttype_paypal',
      );

  String get request_paymenttype_ach => Intl.message(
        'ACH - Bank Account transfers within the US',
        name: 'request_paymenttype_ach',
      );

  String get goods_validation => Intl.message(
        'You have not selected any Goods/Supplies. Please select one or more before creating the Donation request.',
        name: 'goods_validation',
      );

  String get monthly_charges_of => Intl.message(
        'monthly and additional charges of',
        name: 'monthly_charges_of',
      );

  String get add_amount_donate => Intl.message(
        'Tell us the maximum amount you are willing to donate towards your community.',
        name: 'add_amount_donate',
      );

  String get add_amount_donate_empty => Intl.message(
        'Amount cannot be empty',
        name: 'add_amount_donate_empty',
      );

  String get add_goods_donate_empty => Intl.message(
        'Please select atleast one goods to offer.',
        name: 'add_goods_donate_empty',
      );

  String get offer_type => Intl.message(
        'Offer type*',
        name: 'offer_type',
      );

  String get request_goods_offer => Intl.message(
        'Provide the list of Goods/Supplies that you  can offer*',
        name: 'request_goods_offer',
      );

  String get offerReview => Intl.message(
        'You have received a review for the offer:',
        name: 'offerReview',
      );

  String get request_review_body_creator => Intl.message(
        'You have received a review for the request:',
        name: 'request_review_body_creator',
      );

  String get request_review_body_user => Intl.message(
        'You have received a review on the work that you did for the request:',
        name: 'request_review_body_user',
      );

  String get has_given_review => Intl.message(
        'has given you a review',
        name: 'has_given_review',
      );

  String get pledged_to_donate => Intl.message(
        'pledged to donate',
        name: 'pledged_to_donate',
      );

  String get computer => Intl.message(
        'Computer',
        name: 'computer',
      );

  String get total_donation_amount => Intl.message(
        'Total donation amount',
        name: 'total_donation_amount',
      );

  String get cash_offer => Intl.message(
        'Money Offer',
        name: 'cash_offer',
      );

  String get goods_offer => Intl.message(
        'Goods Offer',
        name: 'goods_offer',
      );

  String get time_offer => Intl.message(
        'Time Offer',
        name: 'time_offer',
      );

  String get offered => Intl.message(
        'Offered',
        name: 'offered',
      );

  String get offer_to_sent_at => Intl.message(
        'Send offer to address',
        name: 'offer_to_sent_at',
      );

  String get cash_request => Intl.message(
        'Money Request',
        name: 'cash_request',
      );

  String get goods_request => Intl.message(
        'Goods Request',
        name: 'goods_request',
      );

  String get time_request => Intl.message(
        'Time Request',
        name: 'time_request',
      );

  String get donations_cash_request => Intl.message(
        'Request Amount*',
        name: 'donations_cash_request',
      );

  String get donations_cash_request_hint => Intl.message(
        'Request Amount shouldn\'t be more than the offer amount',
        name: 'donations_cash_request_hint',
      );

  String get tell_what_you_get_donated => Intl.message(
        'Tell us what you would like to get donated',
        name: 'tell_what_you_get_donated',
      );

  String get signed_up => Intl.message(
        'Signed Up',
        name: 'signed_up',
      );

  String get accepted_offer => Intl.message(
        'Accepted Offer',
        name: 'accepted_offer',
      );

  String get accept_offer => Intl.message(
        'Accept Offer',
        name: 'accept_offer',
      );

  String get bookmark => Intl.message(
        'Bookmark',
        name: 'bookmark',
      );

  String get alert_before_exit => Intl.message(
        'Please confirm that you want to cancel editing. You will lose all changes if you confirm.',
        name: 'alert_before_exit',
      );

  String get payment_still_processing => Intl.message(
        'Your payment is still being processed. Please try this operation a little later',
        name: 'payment_still_processing',
      );

  String get cancel_editing_confirmation => Intl.message(
        'Please confirm that you want to cancel editing. You will lose all changes if you confirm.',
        name: 'cancel_editing_confirmation',
      );

  String get sending_feedback => Intl.message(
        'Sending Feedback',
        name: 'sending_feedback',
      );

  String get plan_changed => Intl.message(
        'Plan Changed',
        name: 'plan_changed',
      );

  String get changing_plan => Intl.message(
        'Changing plan',
        name: 'changing_plan',
      );

  String get upgrade_plan => Intl.message(
        'Upgrade Plan',
        name: 'upgrade_plan',
      );

  String get exhausted_free_quota => Intl.message(
        'You have exhausted your free quota of transactions,',
        name: 'exhausted_free_quota',
      );

  String get exhaust_limit_admin_message => Intl.message(
        'please contact the creator of the Seva Community to upgrade your plan',
        name: 'exhaust_limit_admin_message',
      );

  String get exhaust_limit_creator_message => Intl.message(
        'please upgrade your plan to continue.',
        name: 'exhaust_limit_creator_message',
      );

  String get exhaust_limit_user_message => Intl.message(
        'please contact the admin of the Seva Community to upgrade your plan',
        name: 'exhaust_limit_user_message',
      );

  String get needs_upgraded_plan => Intl.message(
        'The feature you have chosen needs an upgraded plan.',
        name: 'needs_upgraded_plan',
      );

  String get plan_upgrade_message_admin => Intl.message(
        'Please contact the creator of your Seva Community to activate this feature',
        name: 'plan_upgrade_message_admin',
      );

  String get plan_upgrade_message_user => Intl.message(
        'Please contact the admin of your Seva Community to activate this feature',
        name: 'plan_upgrade_message_user',
      );

  String get seva_community => Intl.message(
        'Seva Community',
        name: 'seva_community',
      );

  String get venmo_hint => Intl.message(
        'Ex: Provide your Venmo username',
        name: 'venmo_hint',
      );

  String get sevax_global_creation_error => Intl.message(
        '\"SevaX Global\" is a protected community. Only Admins can post content here.',
        name: 'sevax_global_creation_error',
      );

  String get alert => Intl.message(
        'Alert',
        name: 'alert',
      );

  String get cancelled_subscription => Intl.message(
        'Canceled subscription',
        name: 'cancelled_subscription',
      );

  String get subscription_cancellation => Intl.message(
        'Subscription cancelation',
        name: 'subscription_cancellation',
      );

  String get cancellation_failure_message => Intl.message(
        'We have received a request to cancel your subscription. While we are sorry to see you go, there are unpaid dues at this time. Please clear these dues and then attempt the cancelation again',
        name: 'cancellation_failure_message',
      );

  String get cancellation_success_message => Intl.message(
        'We are sorry to see you go. Your subscription is now canceled. Beginning at the conclusion of the current subscription period, your credit card will not be charged',
        name: 'cancellation_success_message',
      );

  String get request_paymenttype_venmo => Intl.message(
        'Venmo',
        name: 'request_paymenttype_venmo',
      );

  String get already_exists => Intl.message(
        'Already exists',
        name: 'already_exists',
      );

  String get add_to_request => Intl.message(
        'Add To Request?',
        name: 'add_to_request',
      );

  String get are_you_sure => Intl.message(
        'Are you sure want to',
        name: 'are_you_sure',
      );

  String get already_added => Intl.message(
        'already added to this request',
        name: 'already_added',
      );

  String get offer_updated => Intl.message(
        'Offer Updated',
        name: 'offer_updated',
      );

  String get clear_notications => Intl.message(
        'Are you sure you want to clear all notifications?',
        name: 'clear_notications',
      );

  String get select_project => Intl.message(
        'Select an event',
        name: 'select_project',
      );

  String get projects_here => Intl.message(
        'Events here',
        name: 'projects_here',
      );

  String get Suggested => Intl.message(
        'Suggested',
        name: 'Suggested',
      );

  String get entered => Intl.message(
        'Entered',
        name: 'entered',
      );

  String get only_community_admins_can_accept => Intl.message(
        'Only Community admins can accept offers of money / goods',
        name: 'only_community_admins_can_accept',
      );

  String get suggested => Intl.message(
        'Suggested',
        name: 'suggested',
      );

  String get cancel_subscription => Intl.message(
        'Cancel Subscription',
        name: 'cancel_subscription',
      );

  String get are_you_sure_subs_cancel => Intl.message(
        'Are you sure you want to cancel your subscription ?',
        name: 'are_you_sure_subs_cancel',
      );

  String get cancel_subscription_success_label => Intl.message(
        'Your subscription is now cancelled. At the conclusion of your current subscription period, your credit card will no longer be charged. You can continue to make transactions until you have reached the limit of your current plan.',
        name: 'cancel_subscription_success_label',
      );

  String get notifications_promoted_organizer_subtitle_phrase => Intl.message(
        'has promoted you to be the Organizer for the',
        name: 'notifications_promoted_organizer_subtitle_phrase',
      );

  String get notifications_organizer_demoted_subtitle_phrase => Intl.message(
        'has demoted you from being an Organizer for the ',
        name: 'notifications_organizer_demoted_subtitle_phrase',
      );

  String get timebank_about_hint => Intl.message(
        'Ex: Our Community is made up of local residents primarily from...',
        name: 'timebank_about_hint',
      );

  String get login_title => Intl.message(
        'Register or Sign into Your Account',
        name: 'login_title',
      );

  String get login_subtitle => Intl.message(
        'Use your email and password to access your account.',
        name: 'login_subtitle',
      );

  String get register => Intl.message(
        'Register',
        name: 'register',
      );

  String get register_subtitle => Intl.message(
        'Please create an account to begin giving and receiving',
        name: 'register_subtitle',
      );

  String get register_with => Intl.message(
        'Register with',
        name: 'register_with',
      );

  String get register_with_apple => Intl.message(
        'Register with Google',
        name: 'register_with_apple',
      );

  String get go_back => Intl.message(
        'Go Back',
        name: 'go_back',
      );

  String get step => Intl.message(
        'Step',
        name: 'step',
      );

  String get you_entered => Intl.message(
        'You entered',
        name: 'you_entered',
      );

  String get prev => Intl.message(
        'Prev',
        name: 'prev',
      );

  String get profile_details => Intl.message(
        'Profile Details',
        name: 'profile_details',
      );

  String get seva_community_info => Intl.message(
        'A Seva Community is a community of volunteers that give and receive time to each other and to the larger community.',
        name: 'seva_community_info',
      );

  String get seva_logo_info => Intl.message(
        'Upload a Image to represent your community',
        name: 'seva_logo_info',
      );

  String get what_is_community => Intl.message(
        'What is a Seva Community',
        name: 'what_is_community',
      );

  String get change_plan_confirm => Intl.message(
        'Change plan confirmation',
        name: 'change_plan_confirm',
      );

  String get upgrade_plan_confirm => Intl.message(
        'Are you sure you want to upgrade the plan ?',
        name: 'upgrade_plan_confirm',
      );

  String get contact_seva_team => Intl.message(
        'Please contact Sevax support for downgrading your plan',
        name: 'contact_seva_team',
      );

  String get clear_dues => Intl.message(
        'Please clear your dues and try again !',
        name: 'clear_dues',
      );

  String get add_new_card => Intl.message(
        'Add New Card',
        name: 'add_new_card',
      );

  String get card_number => Intl.message(
        'Card Number',
        name: 'card_number',
      );

  String get donation_offered => Intl.message(
        'Donation Offered',
        name: 'donation_offered',
      );

  String get acknowledged => Intl.message(
        'Acknowledged',
        name: 'acknowledged',
      );

  String get modified => Intl.message(
        'Modified',
        name: 'modified',
      );

  String get expiry_date => Intl.message(
        'Expiration Date',
        name: 'expiry_date',
      );

  String get trustworthiness => Intl.message(
        'Trustworthiness',
        name: 'trustworthiness',
      );

  String get reliability_score => Intl.message(
        'Reliability',
        name: 'reliability_score',
      );

  String get donation_dispute_info => Intl.message(
        'If there is discrepancy in the items received, please message the number.',
        name: 'donation_dispute_info',
      );

  String get part_of_seva_communication => Intl.message(
        'Part of SevaX global network of Communication',
        name: 'part_of_seva_communication',
      );

  String get no_near_communities => Intl.message(
        'No nearby Seva Communities',
        name: 'no_near_communities',
      );

  String get find_near_timebanks => Intl.message(
        'Find a Seva Community near you',
        name: 'find_near_timebanks',
      );

  String get gps_reminder_near => Intl.message(
        'Please make sure you have GPS turned on to see the list of Seva Communities around you',
        name: 'gps_reminder_near',
      );

  String get see_all => Intl.message(
        'See All',
        name: 'see_all',
      );

  String get see_less => Intl.message(
        'See Less',
        name: 'see_less',
      );

  String get start_request_date => Intl.message(
        'Start adding the first request',
        name: 'start_request_date',
      );

  String get seva_community_requests => Intl.message(
        'Seva Community Requests',
        name: 'seva_community_requests',
      );

  String get enter_max_credits => Intl.message(
        'Please enter maximum credits',
        name: 'enter_max_credits',
      );

  String get existing_requests => Intl.message(
        'Existing Requests',
        name: 'existing_requests',
      );

  String get edit_request => Intl.message(
        'Edit Request',
        name: 'edit_request',
      );

  String get description => Intl.message(
        'Description',
        name: 'description',
      );

  String get donation_address => Intl.message(
        'Donation Address',
        name: 'donation_address',
      );

  String get bank_address => Intl.message(
        'Bank Address',
        name: 'bank_address',
      );

  String get routing_number => Intl.message(
        'Routing number',
        name: 'routing_number',
      );

  String get last_option => Intl.message(
        'last option',
        name: 'last_option',
      );

  String get no_record_transactions_yet => Intl.message(
        'No recorded transactions yet !',
        name: 'no_record_transactions_yet',
      );

  String get task_desc => Intl.message(
        'Here is the list of pending tasks that are waiting for your acceptance, not accepted tasks and the tasks you have completed.',
        name: 'task_desc',
      );

  String get total_earned => Intl.message(
        'Total Earned',
        name: 'total_earned',
      );

  String get start_new_offer => Intl.message(
        'Start adding the first offer',
        name: 'start_new_offer',
      );

  String get compose_new_msg => Intl.message(
        'Compose new message',
        name: 'compose_new_msg',
      );

  String get admin_msg => Intl.message(
        'Admin Messages',
        name: 'admin_msg',
      );

  String get personal_messages => Intl.message(
        'Personal Messages',
        name: 'personal_messages',
      );

  String get messaging_room_logo => Intl.message(
        'Messaging Room Image',
        name: 'messaging_room_logo',
      );

  String get no_msg_yet => Intl.message(
        'No messages yet',
        name: 'no_msg_yet',
      );

  String get no_feeds_yet => Intl.message(
        'No feeds yet',
        name: 'no_feeds_yet',
      );

  String get add_new_feed => Intl.message(
        'Start adding the first feed',
        name: 'add_new_feed',
      );

  String get comments => Intl.message(
        'Comments',
        name: 'comments',
      );

  String get add_comment => Intl.message(
        'Add a comment...',
        name: 'add_comment',
      );

  String get view_prev_replies => Intl.message(
        'View Previous Replies',
        name: 'view_prev_replies',
      );

  String get reply => Intl.message(
        'Reply',
        name: 'reply',
      );

  String get liked => Intl.message(
        'Liked',
        name: 'liked',
      );

  String get like => Intl.message(
        'Like',
        name: 'like',
      );

  String get report_on => Intl.message(
        'Reports on',
        name: 'report_on',
      );

  String get switch_timebank => Intl.message(
        'Switch To Seva Community',
        name: 'switch_timebank',
      );

  String get type_group => Intl.message(
        'Type a group name',
        name: 'type_group',
      );

  String get admin_tools => Intl.message(
        'Admin Tools',
        name: 'admin_tools',
      );

  String get of_text => Intl.message(
        'of',
        name: 'of_text',
      );

  String get start_new_feed => Intl.message(
        'Start a new feed..',
        name: 'start_new_feed',
      );

  String get view_more_comments => Intl.message(
        'View more comments',
        name: 'view_more_comments',
      );

  String get people => Intl.message(
        'People',
        name: 'people',
      );

  String get replies => Intl.message(
        'Replies',
        name: 'replies',
      );

  String get near_by_timebank_search_hint => Intl.message(
        'Please type in your ZIP or postal code in the field or type in your city, state, and country to find a Seva Community near you.',
        name: 'near_by_timebank_search_hint',
      );

  String get near_by_timebank_subtitle => Intl.message(
        'Find a Seva Community near you. Don\'t see any near you? You can always create your own Seva Community for free and invite the people you know. Seva Communities are a safe and secure way to communicate with your friends and family.\nPlease type in your ZIP or postal code in the field or type in your city, state, and country to find a Seva Community near you.',
        name: 'near_by_timebank_subtitle',
      );

  String get near_by_timebank_title => Intl.message(
        'Find a Seva Community near you.',
        name: 'near_by_timebank_title',
      );

  String get timebank_about_title => Intl.message(
        'Tell us about your Seva Community',
        name: 'timebank_about_title',
      );

  String get who_can_see_feed => Intl.message(
        'Who can see your Feed?',
        name: 'who_can_see_feed',
      );

  String get notification_settings => Intl.message(
        'Notification Settings',
        name: 'notification_settings',
      );

  String get open_notification => Intl.message(
        'Open notifications',
        name: 'open_notification',
      );

  String get owners => Intl.message(
        'Super Admin(s)',
        name: 'owners',
      );

  String get make_owner => Intl.message(
        'Make Super Admin',
        name: 'make_owner',
      );

  String get owner => Intl.message(
        'Owner',
        name: 'owner',
      );

  String get add_to_existing_reqest => Intl.message(
        'Add to Existing Request',
        name: 'add_to_existing_reqest',
      );

  String get save_as_sponsored => Intl.message(
        'Save as Endorsed',
        name: 'save_as_sponsored',
      );

  String get create_feed_desc_hint => Intl.message(
        'Please share only relevant information to your Group,  Event, or Community. Example, you can talk about your latest volunteer exchange and post a photo of you or the person doing the task',
        name: 'create_feed_desc_hint',
      );

  String get admin_promoted_to_owner => Intl.message(
        'creator_name the creator of Community community_name has made you a Super Admin for this Community. This means that you will receive notifications for approvals within the community and you can create Community Requests, among other things',
        name: 'admin_promoted_to_owner',
      );

  String get owner_demoted_to_admin => Intl.message(
        'associatedName has demoted you from being a Super Admin for the groupName',
        name: 'owner_demoted_to_admin',
      );

  String get extra_amount_charge => Intl.message(
        'There is an additional cost of \$15 / month / community to create a Private Community',
        name: 'extra_amount_charge',
      );

  String get sponsored_groups => Intl.message(
        'Endorsed Groups',
        name: 'sponsored_groups',
      );

  String get endorsed_group_request_title => Intl.message(
        'Endorsed Group Approval Request',
        name: 'endorsed_group_request_title',
      );

  String get endorsed_group_request_desc => Intl.message(
        'user_name has created a group group_name. Please approve if this newly formed group is indeed endorsed by your organization, so it can be shown with the Endorsed Badge.',
        name: 'endorsed_group_request_desc',
      );

  String get endorsed_notification_title => Intl.message(
        'Group group_name requires your approval',
        name: 'endorsed_notification_title',
      );

  String get endorsed_notification_desc => Intl.message(
        'user_name has created a group group_name. They have requested this group to be approved - to allow the group to have an endorsed badge.',
        name: 'endorsed_notification_desc',
      );

  String get enable_gps => Intl.message(
        'You will need to enable location services on your browser: Chrome; Edge; Firefox; Safari to allow us to display nearby Communities.',
        name: 'enable_gps',
      );

  String get browser_support_info => Intl.message(
        'This browser is currently not supported in the current release. We recommend using Google Chrome for now to optimize your experience. Thank you for your patience.',
        name: 'browser_support_info',
      );

  String get project_message_room_invite => Intl.message(
        '',
        name: 'project_message_room_invite',
      );

  String get new_post_notification => Intl.message(
        'There is a new Post by ',
        name: 'new_post_notification',
      );

  String get new_message_notification => Intl.message(
        '',
        name: 'new_message_notification',
      );

  String get member_creates_transaction => Intl.message(
        'This is currently not permitted. Please contact the Community Creator ',
        name: 'member_creates_transaction',
      );

  String get creator_creates_transaction => Intl.message(
        'This is currently not permitted. Please see the following link for more information: ',
        name: 'creator_creates_transaction',
      );

  String get negative_threshold_title => Intl.message(
        'Threshold for negative credits',
        name: 'negative_threshold_title',
      );

  String get generate_report => Intl.message(
        'Generate Report',
        name: 'generate_report',
      );

  String get time_period => Intl.message(
        'Time period',
        name: 'time_period',
      );

  String get select_time_period => Intl.message(
        'Select Time Period',
        name: 'select_time_period',
      );

  String get select_transaction_type => Intl.message(
        'Select Transaction Types',
        name: 'select_transaction_type',
      );

  String get select_transaction_type_valid => Intl.message(
        'Select a transaction type',
        name: 'select_transaction_type_valid',
      );

  String get generating_report => Intl.message(
        'Generating Report',
        name: 'generating_report',
      );

  String get downloading_report => Intl.message(
        'Downloading Report',
        name: 'downloading_report',
      );

  String get specific_data_range => Intl.message(
        'Specific date range',
        name: 'specific_data_range',
      );

  String get year_to_date => Intl.message(
        'Year to date',
        name: 'year_to_date',
      );

  String get month_to_date => Intl.message(
        'Month to date',
        name: 'month_to_date',
      );

  String get reports => Intl.message(
        'Reports',
        name: 'reports',
      );

  String get reports_charging_info => Intl.message(
        'Reports are emailed to the creator of each community once a month. There is a cost of \$9.95 per report - which will be billed to the credit card on file to generate this report. By clicking Proceed, you are agreeing to this cost. Otherwise click Cancel.',
        name: 'reports_charging_info',
      );

  String get no_categories_available => Intl.message(
        'No categories Available',
        name: 'no_categories_available',
      );

  String get search_category => Intl.message(
        'Search Category',
        name: 'search_category',
      );

  String get choose_category => Intl.message(
        'Choose Category and Sub Category',
        name: 'choose_category',
      );

  String get suggested_categories => Intl.message(
        'Suggested Categories',
        name: 'suggested_categories',
      );

  String get manual_notification_title => Intl.message(
        'Manual time notification',
        name: 'manual_notification_title',
      );

  String get manual_notification_subtitle => Intl.message(
        'Admin **name has requested for **number hours of Seva Credit(s) towards Admin-related activities for Community **communityName',
        name: 'manual_notification_subtitle',
      );

  String get manual_time_request_title => Intl.message(
        'Status of your Seva Credit request',
        name: 'manual_time_request_title',
      );

  String get manual_time_request_subtitle => Intl.message(
        'Your request for ',
        name: 'manual_time_request_subtitle',
      );

  String get seva_community_events => Intl.message(
        'Seva Community Events',
        name: 'seva_community_events',
      );

  String get personal_events => Intl.message(
        'Personal Events',
        name: 'personal_events',
      );

  String get details_updated_success => Intl.message(
        'Details updated successfully.',
        name: 'details_updated_success',
      );

  String get manual_time_request_rejected => Intl.message(
        'Your request for **number Seva Credit(s) towards Admin-related activities for Community **communityName has been rejected.',
        name: 'manual_time_request_rejected',
      );

  String get manual_time_request_approved => Intl.message(
        'Your request for **number Seva Credit(s) towards Admin-related activities for Community **communityName has been approved.',
        name: 'manual_time_request_approved',
      );

  String get added_to_messaging_room => Intl.message(
        'Since you are volunteering for this event, you\'ve been added to the messaging room. You may leave this room at any time',
        name: 'added_to_messaging_room',
      );

  String get seva_community_event => Intl.message(
        'Seva Community Event',
        name: 'seva_community_event',
      );

  String get personal_event => Intl.message(
        'Personal Event',
        name: 'personal_event',
      );

  String get manual_time_add => Intl.message(
        'Add Manual Time',
        name: 'manual_time_add',
      );

  String get manual_time_textfield_hint => Intl.message(
        'Please provide a rationale for this request - to assist the approver',
        name: 'manual_time_textfield_hint',
      );

  String get manual_time_button_text => Intl.message(
        'Send Request',
        name: 'manual_time_button_text',
      );

  String get manual_time_title => Intl.message(
        'Request Seva Credits for Admin tasks performed',
        name: 'manual_time_title',
      );

  String get manual_time_info => Intl.message(
        'Admins can request Seva Credits for the time that they spend in performing Admin Tasks in the SevaX Application',
        name: 'manual_time_info',
      );

  String get exchanges => Intl.message(
        'Exchanges',
        name: 'exchanges',
      );

  String get create_event => Intl.message(
        'Create Event',
        name: 'create_event',
      );

  String get join_message_room_hint => Intl.message(
        'In order to view the messages in this Message Room, you need to join the room by clicking the \'Join Chat\' button below',
        name: 'join_message_room_hint',
      );

  String get join_message_room => Intl.message(
        ' **Message_room_creator_name has created a message room **message_room_name in the Community **community_name and invited you to join. Please accept or decline the invitation',
        name: 'join_message_room',
      );

  String get action_not_permitted => Intl.message(
        'Action not permitted',
        name: 'action_not_permitted',
      );

  String get contact_community_creator => Intl.message(
        'This is currently not permitted. Please contact the Community Creator for more information.',
        name: 'contact_community_creator',
      );

  String get follow_link_to_upgrade => Intl.message(
        'This is currently not permitted. Please see the following link for more information: **link_on_web_to_upgrade_plan',
        name: 'follow_link_to_upgrade',
      );

  String get would_like_to_accept_offer => Intl.message(
        'Would you like to accept this offer?',
        name: 'would_like_to_accept_offer',
      );

  String get account_information => Intl.message(
        'Account Information',
        name: 'account_information',
      );

  String get timebank_configure_accounr_info => Intl.message(
        'Configure account information',
        name: 'timebank_configure_accounr_info',
      );

  String get timebank_account_error => Intl.message(
        'Please configure your account information details',
        name: 'timebank_account_error',
      );

  String get timebank_about_hint_example => Intl.message(
        'Ex: Our Community is made up of local residents primarily from...',
        name: 'timebank_about_hint_example',
      );

  String get contact_for_enterprise_price => Intl.message(
        'To get a price estimate for Enterprise (SMB or large Enterprise), please contact our Sevax team.',
        name: 'contact_for_enterprise_price',
      );

  String get contact_for_nonprofitt_price => Intl.message(
        'To get a price estimate for non-profit, please contact our Sevax team.',
        name: 'contact_for_nonprofitt_price',
      );

  String get send_invitation => Intl.message(
        'Send Invitation',
        name: 'send_invitation',
      );

  String get selected_categories => Intl.message(
        'Selected Categories',
        name: 'selected_categories',
      );

  String get copied_community_code => Intl.message(
        'Copied Community Code',
        name: 'copied_community_code',
      );

  String get no_events => Intl.message(
        'No Events yes',
        name: 'no_events',
      );

  String get manage_notofications => Intl.message(
        'Manage Notifications',
        name: 'manage_notofications',
      );

  String get validation_error_bio_max_characters => Intl.message(
        '* max 250 characters',
        name: 'validation_error_bio_max_characters',
      );

  String get request_payment_description_hint_new => Intl.message(
        'SevaX does not process the payment. Please select from among  ACH, PayPal, Venmo, or ZellePay in the drop down and provide the appropriate details for each method. The donor will complete the donation outside the SevaX app.',
        name: 'request_payment_description_hint_new',
      );

  String get super_admin => Intl.message(
        'Super Admin',
        name: 'super_admin',
      );

  String get what_is_restricted_seva_community => Intl.message(
        'What is a Restricted Seva Community? ',
        name: 'what_is_restricted_seva_community',
      );

  String get cash_offer_title_hint => Intl.message(
        'Ex: \$50 for community center',
        name: 'cash_offer_title_hint',
      );

  String get cash_offer_desc_hint => Intl.message(
        'Describe in detail what you are willing to offer. Please use #hashtags so members can easily search for this offer, such as #fundraiser #community',
        name: 'cash_offer_desc_hint',
      );

  String get goods_offer_title_hint => Intl.message(
        'Ex: winter coats for homeless shelter',
        name: 'goods_offer_title_hint',
      );

  String get goods_offer_desc_hint => Intl.message(
        'Describe in detail what you are willing to offer. Please use #hashtags so members can easily search for this offer, such as #homeless #clothingdrive',
        name: 'goods_offer_desc_hint',
      );

  String get default_private_alert => Intl.message(
        'This plan is for private use only and cannot be made public.',
        name: 'default_private_alert',
      );

  String get member_joined_via_code_title => Intl.message(
        'New member has joined **communityName** via code',
        name: 'member_joined_via_code_title',
      );

  String get member_joined_via_code_subtitle => Intl.message(
        '**fullName** has joined **communityName** via code.',
        name: 'member_joined_via_code_subtitle',
      );

  String get no_posts_title => Intl.message(
        'There are currently no posts.',
        name: 'no_posts_title',
      );

  String get no_posts_description => Intl.message(
        'To create one, select the Create Post button.',
        name: 'no_posts_description',
      );

  String get no_requests_title => Intl.message(
        'There are currently no requests.',
        name: 'no_requests_title',
      );

  String get no_offers_title => Intl.message(
        'There are currently no offers.',
        name: 'no_offers_title',
      );

  String get no_events_title => Intl.message(
        'There are currently no events.',
        name: 'no_events_title',
      );

  String get no_content_common_description => Intl.message(
        'To create one click on the plus icon.',
        name: 'no_content_common_description',
      );

  String get feed_hint_back_press => Intl.message(
        'Clicking on the home button takes you to the Feeds section. Double clicking on home button from the group feed will take you back to the community feed.',
        name: 'feed_hint_back_press',
      );

  String get past_time_selected => Intl.message(
        'The time you selected is invalid because it is in the past.',
        name: 'past_time_selected',
      );

  String get invalid_time => Intl.message(
        'Invalid Time',
        name: 'invalid_time',
      );

  String get request_desc_hint_time => Intl.message(
        'Please describe what you need to have done. \n \nEx: I need help removing weeds from  my small garden.',
        name: 'request_desc_hint_time',
      );

  String get no_search_result_found => Intl.message(
        'No search result found',
        name: 'no_search_result_found',
      );

  String get select_child_timebank => Intl.message(
        'Select Child Seva Communities',
        name: 'select_child_timebank',
      );

  String get super_admins => Intl.message(
        'Super Admin(s)',
        name: 'super_admins',
      );

  String get gps_disabled_error => Intl.message(
        'Unable to fetch nearby communities because your GPS is not enabled.',
        name: 'gps_disabled_error',
      );

  String get no_options_available => Intl.message(
        'No Options Available',
        name: 'no_options_available',
      );

  String get select_timeline => Intl.message(
        'Select Timeline',
        name: 'select_timeline',
      );

  String get request_money_title_hint => Intl.message(
        'Ex: Fundraiser for women’s shelter...',
        name: 'request_money_title_hint',
      );

  String get request_money_desc_hint => Intl.message(
        'Ex: Fundraiser to expand women’s shelter...',
        name: 'request_money_desc_hint',
      );

  String get request_goods_title_hint => Intl.message(
        'Ex: Non-perishable goods for Food Bank...',
        name: 'request_goods_title_hint',
      );

  String get request_goods_desc_hint => Intl.message(
        'Ex: Local Food Bank has a shortage...',
        name: 'request_goods_desc_hint',
      );

  String get cannot_create_project => Intl.message(
        'Events can only be created by an admin. If you wish to create an event, please send a message to your admin.',
        name: 'cannot_create_project',
      );

  String get virtual => Intl.message(
        'Virtual',
        name: 'virtual',
      );

  String get public_to_sevax => Intl.message(
        'Public to SevaX Global',
        name: 'public_to_sevax',
      );

  String get your_skills => Intl.message(
        'Your Skills',
        name: 'your_skills',
      );

  String get your_interests => Intl.message(
        'Your Interests',
        name: 'your_interests',
      );

  String get feature_disabled => Intl.message(
        'This feature is disabled for your community',
        name: 'feature_disabled',
      );

  String get currently_not_permitted => Intl.message(
        'This is currently not permitted, Please see the following link for more information. http://www.web.sevaxapp.com/',
        name: 'currently_not_permitted',
      );

  String get provide_skills => Intl.message(
        'Provide the list of Skills that you require for this request',
        name: 'provide_skills',
      );

  String get event_description => Intl.message(
        'Event Description',
        name: 'event_description',
      );

  String get request_to_join => Intl.message(
        'Request to join',
        name: 'request_to_join',
      );

  String get event => Intl.message(
        'Event',
        name: 'event',
      );

  String get offer => Intl.message(
        'Offer',
        name: 'offer',
      );

  String get minimum_credits => Intl.message(
        'Minimum Credits',
        name: 'minimum_credits',
      );

  String get min_credits_error => Intl.message(
        'Minimum credits cannot be empty or zero',
        name: 'min_credits_error',
      );

  String get part_of_sevax => Intl.message(
        'Part of SevaX Global Network of Communities',
        name: 'part_of_sevax',
      );

  String get upcoming_events => Intl.message(
        'Upcoming Events',
        name: 'upcoming_events',
      );

  String get latest_requests => Intl.message(
        'Latest Requests',
        name: 'latest_requests',
      );

  String get continue_to_signin => Intl.message(
        'Continue to Sign in',
        name: 'continue_to_signin',
      );

  String get access_not_available => Intl.message(
        'Access not available',
        name: 'access_not_available',
      );

  String get switch_community => Intl.message(
        'You need to switch Seva Communities in order to access Groups in another Community.',
        name: 'switch_community',
      );

  String get join_community_alert => Intl.message(
        'This action is only available to members of Community **CommunityName. Please request to join the community first before you can perform this action.',
        name: 'join_community_alert',
      );

  String get no_interests_added => Intl.message(
        'No interests added',
        name: 'no_interests_added',
      );

  String get no_skills_added => Intl.message(
        'No skills added',
        name: 'no_skills_added',
      );

  String get kilometer => Intl.message(
        'Kilometer',
        name: 'kilometer',
      );

  String get kilometers => Intl.message(
        'Kilometers',
        name: 'kilometers',
      );

  String get miles => Intl.message(
        'Miles',
        name: 'miles',
      );

  String get mile => Intl.message(
        'Mile',
        name: 'mile',
      );

  String get sign_in_alert => Intl.message(
        'You need to sign in or register to view this.',
        name: 'sign_in_alert',
      );

  String get invitation_accepted => Intl.message(
        'Invitation Accepted.',
        name: 'invitation_accepted',
      );

  String get no_groups_text => Intl.message(
        'You are currently not part of any groups. You can either join one or create a new group.',
        name: 'no_groups_text',
      );

  String get my_groups => Intl.message(
        'My Groups',
        name: 'my_groups',
      );

  String get sandbox_community => Intl.message(
        'Sandbox Community',
        name: 'sandbox_community',
      );

  String get sandbox_dialog_title => Intl.message(
        'Sandbox seva community',
        name: 'sandbox_dialog_title',
      );

  String get select_a_speaker_dialog => Intl.message(
        'Select a speaker',
        name: 'select_a_speaker_dialog',
      );

  String get duration_of_session => Intl.message(
        'Duration of Session: ',
        name: 'duration_of_session',
      );

  String get time_to_prepare => Intl.message(
        'Time to prepare: ',
        name: 'time_to_prepare',
      );

  String get hours => Intl.message(
        'hours',
        name: 'hours',
      );

  String get you_are_the_speaker => Intl.message(
        'You are the speaker for: ',
        name: 'you_are_the_speaker',
      );

  String get select_a_speaker => Intl.message(
        'Please select a Speaker*',
        name: 'select_a_speaker',
      );

  String get selected_speaker => Intl.message(
        'Selected Speaker',
        name: 'selected_speaker',
      );

  String get minimum_credit_title => Intl.message(
        'Minimum Credits*',
        name: 'minimum_credit_title',
      );

  String get request_closed => Intl.message(
        'Request closed',
        name: 'request_closed',
      );

  String get speaker_claim_credits => Intl.message(
        'Claim credits',
        name: 'speaker_claim_credits',
      );

  String get option_one => Intl.message(
        'Standing Offer',
        name: 'option_one',
      );

  String get option_two => Intl.message(
        'One Time',
        name: 'option_two',
      );

  String get registration_link => Intl.message(
        'Registration Link',
        name: 'registration_link',
      );

  String get invitation_accepted_subtitle => Intl.message(
        ' has accepted your offer.',
        name: 'invitation_accepted_subtitle',
      );

  String get offer_invitation_notification_title => Intl.message(
        'Offer Invitation',
        name: 'offer_invitation_notification_title',
      );

  String get offer_invitation_notification_subtitle => Intl.message(
        ' has invited you to accept an offer.',
        name: 'offer_invitation_notification_subtitle',
      );

  String get accept_offer_invitation_confirmation => Intl.message(
        'This task will be added to your Pending Tasks, after you approve it.',
        name: 'accept_offer_invitation_confirmation',
      );

  String get minimum_credit_hint => Intl.message(
        'Provide minimum credits you require',
        name: 'minimum_credit_hint',
      );

  String get minimum_credits_offer => Intl.message(
        'This offer does not meet your minimum credit requirement.',
        name: 'minimum_credits_offer',
      );

  String get speaker_claim_form_field_title => Intl.message(
        'How much prep time did you require for this request?',
        name: 'speaker_claim_form_field_title',
      );

  String get speaker_claim_form_field_title_hint => Intl.message(
        'Prep time in hours',
        name: 'speaker_claim_form_field_title_hint',
      );

  String get speaker_claim_form_text_1 => Intl.message(
        'I acknowledge that I have completed the session for the request.',
        name: 'speaker_claim_form_text_1',
      );

  String get speaker_claim_form_text_2 => Intl.message(
        'Upon completing the one to many request, the combined prep time and session hours will be credited to you.',
        name: 'speaker_claim_form_text_2',
      );

  String get registration_link_hint => Intl.message(
        'Ex: Eventbrite link, etc.',
        name: 'registration_link_hint',
      );

  String get requested_for_completion => Intl.message(
        'Your completed request is pending approval.',
        name: 'requested_for_completion',
      );

  String get this_request_has_now_ended => Intl.message(
        'This request has now ended',
        name: 'this_request_has_now_ended',
      );

  String get maximumNoOfParticipants => Intl.message(
        'This request has a maximum number of participants. That limit has been reached.',
        name: 'maximumNoOfParticipants',
      );

  String get reject_request_completion => Intl.message(
        'Are you sure you want to reject this request for completion?',
        name: 'reject_request_completion',
      );

  String get speaker_reject_invite_dialog => Intl.message(
        'Are you sure you want to reject this invitation to speak?',
        name: 'speaker_reject_invite_dialog',
      );

  String get explore_page_title_text => Intl.message(
        'Explore Opportunities',
        name: 'explore_page_title_text',
      );

  String get explore_page_subtitle_text => Intl.message(
        'Find communities near you or online communities that interest you. You can offer to volunteer your services or request any assistance or search for Community Events.',
        name: 'explore_page_subtitle_text',
      );

  String get select_speaker_hint => Intl.message(
        'Ex: Name of speaker.',
        name: 'select_speaker_hint',
      );

  String get onetomanyrequest_create_new_event => Intl.message(
        'A new event will be created and linked to this request.',
        name: 'onetomanyrequest_create_new_event',
      );

  String get speaker_requested_completion_notification => Intl.message(
        'This request has been completed.',
        name: 'speaker_requested_completion_notification',
      );

  String get request_completed_by_speaker => Intl.message(
        'This request has been completed and is awaiting your approval.',
        name: 'request_completed_by_speaker',
      );

  String get speaker => Intl.message(
        'Speaker',
        name: 'speaker',
      );

  String get speaker_completion_rejected_notification_1 => Intl.message(
        'Request rejected.',
        name: 'speaker_completion_rejected_notification_1',
      );

  String get speaker_accepted_invite_notification => Intl.message(
        'This request has been accepted by **speakerName.',
        name: 'speaker_accepted_invite_notification',
      );

  String get oneToManyRequestSpeakerAcceptRequest => Intl.message(
        'Are you sure you want to accept this request?',
        name: 'oneToManyRequestSpeakerAcceptRequest',
      );

  String get resetPasswordSuccess => Intl.message(
        'An email has been sent. Please follow the steps in the email to reset your password.',
        name: 'resetPasswordSuccess',
      );

  String get bundlePricingInfoButton => Intl.message(
        'There is a limit to the number of transactions in the free tier. You will be charged \$2 for a bundle of 50 transactions.',
        name: 'bundlePricingInfoButton',
      );

  String get insufficientSevaCreditsDialog => Intl.message(
        'You do not have sufficient Seva credits to create this request. You need to have *** more Seva credits',
        name: 'insufficientSevaCreditsDialog',
      );

  String get adminNotificationInsufficientCredits => Intl.message(
        ' Has Insufficient Credits To Create Requests',
        name: 'adminNotificationInsufficientCredits',
      );

  String get adminNotificationInsufficientCreditsNeeded => Intl.message(
        'Credits Needed: ',
        name: 'adminNotificationInsufficientCreditsNeeded',
      );

  String get oneToManyRequestSpeakerWithdrawDialog => Intl.message(
        'Please confirm that you would like to withdraw as a speaker',
        name: 'oneToManyRequestSpeakerWithdrawDialog',
      );

  String get speakerRejectedNotificationLabel => Intl.message(
        ' rejected the Speaker invitation for ',
        name: 'speakerRejectedNotificationLabel',
      );

  String get speaker_rejected => Intl.message(
        'Speaker Rejected',
        name: 'speaker_rejected',
      );

  String get people_applied_for_request => Intl.message(
        ' people have applied for this request',
        name: 'people_applied_for_request',
      );

  String get oneToManyRequestCreatorCompletingRequestDialog => Intl.message(
        'Are you sure you want to accept and complete this request?',
        name: 'oneToManyRequestCreatorCompletingRequestDialog',
      );

  String get speaker_complete_page_text_1 => Intl.message(
        'I acknowledge that speaker_name has completed the request. The list of members provided above attended the request.',
        name: 'speaker_complete_page_text_1',
      );

  String get speaker_complete_page_text_2 => Intl.message(
        'Note: The hours will be credited to the speaker and to the attendees upon your approval. This list of attendees cannot be modified after approval.',
        name: 'speaker_complete_page_text_2',
      );

  String get action_restricted_by_owner => Intl.message(
        'This action is restricted for you by the owner of the Seva Community.',
        name: 'action_restricted_by_owner',
      );

  String get accepted_this_request => Intl.message(
        'You have accepted this request.',
        name: 'accepted_this_request',
      );

  String get onetomanyrequest_member_invite_notif_subtitle => Intl.message(
        'admin_name in community_name has invited you to join the webinar_name on date_webinar at time_webinar. Tap to accept the invitation.',
        name: 'onetomanyrequest_member_invite_notif_subtitle',
      );

  String get onetomanyrequest_title_hint => Intl.message(
        'Ex: Implicit Bias webinar.',
        name: 'onetomanyrequest_title_hint',
      );

  String get total_no_of_participants => Intl.message(
        'Total No. of Participants*',
        name: 'total_no_of_participants',
      );

  String get onetomanyrequest_participants_or_credits_hint => Intl.message(
        'Ex: 40.',
        name: 'onetomanyrequest_participants_or_credits_hint',
      );

  String get speaker_invite_notification => Intl.message(
        'Added you as the Speaker for request: ',
        name: 'speaker_invite_notification',
      );

  String get sandbox_already_created_1 => Intl.message(
        'Only one sandbox community is currently allowed for each SevaX member.',
        name: 'sandbox_already_created_1',
      );

  String get sandbox_create_community_alert => Intl.message(
        'Are you sure you want to create a sandbox community?',
        name: 'sandbox_create_community_alert',
      );

  String get you_are_on_enterprise_plan => Intl.message(
        'You are on Enterprise Plan',
        name: 'you_are_on_enterprise_plan',
      );

  String get sandbox_dialog_subtitle => Intl.message(
        'Sandbox Seva communities are created for instructional purposes only. Any credits earned or debited will not count towards your account.',
        name: 'sandbox_dialog_subtitle',
      );

  String get info => Intl.message(
        'Info',
        name: 'info',
      );

  String get Login => Intl.message(
        'Login',
        name: 'Login',
      );

  String get Register => Intl.message(
        'Register',
        name: 'Register',
      );

  String get explore_search_hint => Intl.message(
        'Ex: ZIP/ Postal Code or city, state, country',
        name: 'explore_search_hint',
      );

  String get onetomany_createoffer_note => Intl.message(
        'Note: Upon completing the one to many offer, the combined prep time and session hours will be credited to you.',
        name: 'onetomany_createoffer_note',
      );

  String get add_event_to_calender => Intl.message(
        'Add event to calender',
        name: 'add_event_to_calender',
      );

  String get add_to_calender => Intl.message(
        'Add to calender',
        name: 'add_to_calender',
      );

  String get do_you_want_addto_calender => Intl.message(
        'Do you want to add this event to your calendar?',
        name: 'do_you_want_addto_calender',
      );

  String get add_to_google_calender => Intl.message(
        'Add to Google Calendar',
        name: 'add_to_google_calender',
      );

  String get add_to_outlook => Intl.message(
        'Add to Outlook',
        name: 'add_to_outlook',
      );

  String get add_to_ical => Intl.message(
        'Add to ical',
        name: 'add_to_ical',
      );

  String get calender_sync => Intl.message(
        'calendar_sync',
        name: 'calender_sync',
      );

  String get something_went_wrong => Intl.message(
        'Something went wrong',
        name: 'something_went_wrong',
      );

  String get featured_communities => Intl.message(
        'Featured communities',
        name: 'featured_communities',
      );

  String get browse_by_category => Intl.message(
        'Browse community by category',
        name: 'browse_by_category',
      );

  String get find => Intl.message(
        'Find',
        name: 'find',
      );

  String get any_category => Intl.message(
        'any category',
        name: 'any_category',
      );

  String get new_york => Intl.message(
        'New york | USA',
        name: 'new_york',
      );

  String get join_webinar => Intl.message(
        'join webinar',
        name: 'join_webinar',
      );

  String get pledge_goods_supplies => Intl.message(
        ' has pledge to donate good/supplies',
        name: 'pledge_goods_supplies',
      );

  String get credits_debited => Intl.message(
        'Seva Credits Debited',
        name: 'credits_debited',
      );

  String get credits_credited => Intl.message(
        'Seva Credits Credited',
        name: 'credits_credited',
      );

  String get credits_debited_msg => Intl.message(
        'Seva Credits have been debited from your account',
        name: 'credits_debited_msg',
      );

  String get accepted_offer_msg => Intl.message(
        'You have accepted this offer.',
        name: 'accepted_offer_msg',
      );

  String get completed_the_request => Intl.message(
        ' Completed the request',
        name: 'completed_the_request',
      );

  String get deletion_request => Intl.message(
        'Deletion Request',
        name: 'deletion_request',
      );

  String get create_virtual_offer => Intl.message(
        'create virtual offer',
        name: 'create_virtual_offer',
      );

  String get create_public_offer => Intl.message(
        'create public offer',
        name: 'create_public_offer',
      );

  String get amount_lessthan_donation_amount => Intl.message(
        'Entered amount is less than minimum donation amount.',
        name: 'amount_lessthan_donation_amount',
      );

  String get user_name_not_availble => Intl.message(
        'User name not available',
        name: 'user_name_not_availble',
      );

  String get document => Intl.message(
        'Document',
        name: 'document',
      );

  String get users => Intl.message(
        'Users',
        name: 'users',
      );

  String get cash_request_title_hint => Intl.message(
        'Ex: Fundraiser for women’s shelter...',
        name: 'cash_request_title_hint',
      );

  String get error_loading_data => Intl.message(
        'Error Loading Data',
        name: 'error_loading_data',
      );

  String get likes => Intl.message(
        'likes',
        name: 'likes',
      );

  String get anonymous_user => Intl.message(
        'Anonymous user',
        name: 'anonymous_user',
      );

  String get filtering_blocked_content => Intl.message(
        'Filtering blocked content',
        name: 'filtering_blocked_content',
      );

  String get filtering_past_requests_content => Intl.message(
        'Filtering past requests content',
        name: 'filtering_past_requests_content',
      );

  String get approved_member => Intl.message(
        'Approved Members',
        name: 'approved_member',
      );

  String get send_csv_file => Intl.message(
        'Send CSV File',
        name: 'send_csv_file',
      );

  String get success => Intl.message(
        'success',
        name: 'success',
      );

  String get failure => Intl.message(
        'Failure',
        name: 'failure',
      );

  String get current => Intl.message(
        'Current',
        name: 'current',
      );

  String get hours_not_updated => Intl.message(
        'hours not updated',
        name: 'hours_not_updated',
      );

  String get request_approved => Intl.message(
        'Request Approved',
        name: 'request_approved',
      );

  String get request_has_been_assigned_to_a_member => Intl.message(
        'Request has been assigned to a member',
        name: 'request_has_been_assigned_to_a_member',
      );

  String get borrow_request_for_item => Intl.message(
        'Borrow Request for item',
        name: 'borrow_request_for_item',
      );

  String get clear_all => Intl.message(
        'Clear All',
        name: 'clear_all',
      );

  String get message_room_join => Intl.message(
        'Message room join',
        name: 'message_room_join',
      );

  String get message_room_remove => Intl.message(
        'Message room remove',
        name: 'message_room_remove',
      );

  String get item_received_alert_dialouge => Intl.message(
        'If you have you received your item/place back click the button below to complete this.',
        name: 'item_received_alert_dialouge',
      );

  String get request_ended => Intl.message(
        'This request has now ended. Tap to complete the request',
        name: 'request_ended',
      );

  String get request_ended_emailsent_msg => Intl.message(
        'The request has completed and an email has been sent to you. Tap to leave a feedback.',
        name: 'request_ended_emailsent_msg',
      );

  String get lender_acknowledged_request_completion => Intl.message(
        'The Lender has acknowledged completion of this request. Tap to leave a feedback.',
        name: 'lender_acknowledged_request_completion',
      );

  String get borrow_request_for_place => Intl.message(
        'Borrow request for place',
        name: 'borrow_request_for_place',
      );

  String get card_holder => Intl.message(
        'Card Holder',
        name: 'card_holder',
      );

  String get offering_amount => Intl.message(
        'Offering Amount',
        name: 'offering_amount',
      );

  String get offering_goods => Intl.message(
        'Offering Goods',
        name: 'offering_goods',
      );

  String get images_help_convey_theme_of_request => Intl.message(
        'Images helps to convey the theme of your request',
        name: 'images_help_convey_theme_of_request',
      );

  String get max_image_size => Intl.message(
        'Maximum size: 5MB',
        name: 'max_image_size',
      );

  String get exp_date => Intl.message(
        'Exp. Date',
        name: 'exp_date',
      );

  String get camera_not_available => Intl.message(
        'Camera not available',
        name: 'camera_not_available',
      );

  String get loading_camera => Intl.message(
        'Loading Camera...',
        name: 'loading_camera ',
      );

  String get internet_connection_lost => Intl.message(
        'Internet connection lost',
        name: 'internet_connection_lost',
      );

  String get update_available => Intl.message(
        'Update Available',
        name: 'update_available',
      );

  String get update_app => Intl.message(
        'Update App',
        name: 'update_app',
      );

  String get update_msg => Intl.message(
        'There is an update available with the app, Please tap on update to use the latest version of the app',
        name: 'update_msg',
      );

  String get member_permission => Intl.message(
        'Member Permission',
        name: 'member_permission ',
      );

  String get copy_and_share_code => Intl.message(
        'Code Generated: Copy the code and share to your friends',
        name: 'copy_and_share_code',
      );

  String get copy_community_code => Intl.message(
        'Copy Community Code',
        name: 'copy_community_code',
      );

  String get copy_code => Intl.message(
        'Copy Code',
        name: 'copy_code',
      );

  String get share_code_msg => Intl.message(
        'You can share the code to invite them to your seva community',
        name: 'share_code_msg',
      );

  String get no_pending_join_request => Intl.message(
        'No pending join requests',
        name: 'no_pending_join_request',
      );

  String get attend => Intl.message(
        'Attend',
        name: 'attend',
      );

  String get requested_by => Intl.message(
        'Requested By',
        name: 'requested_by',
      );

  String get location_not_provided => Intl.message(
        'Location not provided',
        name: 'location_not_provided',
      );

  String get request_approved_by_msg => Intl.message(
        'Your request has been approved by',
        name: 'request_approved_by_msg',
      );

  String get request_agreement_not_available => Intl.message(
        'Request agreement not available',
        name: 'request_agreement_not_available',
      );

  String get click_to_view_request_agreement => Intl.message(
        'Click to view request agreement',
        name: 'click_to_view_request_agreement',
      );

  String get enter_prep_time => Intl.message(
        'Enter Prep Time',
        name: 'enter_prep_time ',
      );

  String get choose_document => Intl.message(
        ' Choose Document',
        name: 'choose_document',
      );

  String get pets_allowed => Intl.message(
        'Pets Allowed',
        name: 'pets_allowed',
      );

  String get attending => Intl.message(
        'Attending',
        name: 'attending',
      );

  String get invited_speaker => Intl.message(
        'Invited Speaker',
        name: 'invited_speaker',
      );

  String get description_not_updated => Intl.message(
        'Description not yet updated',
        name: 'description_not_updated',
      );

  String get add_manual_time => Intl.message(
        'Add Manual Time',
        name: 'add_manual_time',
      );

  String get reliabilitysocre => Intl.message(
        'Reliability score',
        name: 'reliabilitysocre',
      );

  String get cv_not_available => Intl.message(
        'CV not available',
        name: 'cv_not_available ',
      );

  String get change_document => Intl.message(
        'Change document',
        name: 'change_document',
      );

  String get add_document => Intl.message(
        'Add document',
        name: 'add_document',
      );

  String get sign_up_with_apple => Intl.message(
        'Sign up with Apple',
        name: 'sign_up_with_apple',
      );

  String get sign_up_with_google => Intl.message(
        'Sign up with Google',
        name: 'sign_up_with_google',
      );

  String get browse_requests_by_category => Intl.message(
        'Browse requests by category',
        name: 'browse_requests_by_category',
      );

  String get do_you_want_to_add => Intl.message(
        'Do you want to add this',
        name: 'do_you_want_to_add',
      );

  String get event_to_calender => Intl.message(
        'event to calender',
        name: 'event_to_calender',
      );

  String get seva_community_name_not_updated => Intl.message(
        'Seva Community name not updated',
        name: 'seva_community_name_not_updated',
      );

  String get create_new => Intl.message(
        'Create New',
        name: 'create_new',
      );

  String get choose_previous_agreement => Intl.message(
        'Choose Previous Agreement',
        name: 'choose_previous_agreement',
      );

  String get no_agrreement => Intl.message(
        'No Agreement',
        name: 'no_agrreement',
      );

  String get fixed => Intl.message(
        'Fixed',
        name: 'fixed',
      );

  String get long_term_month_to_month => Intl.message(
        'Long-term (Month to Month)',
        name: 'long_term_month_to_month',
      );

  String get request_offer_agreement_hint_text => Intl.message(
        'Ex :3',
        name: 'request_offer_agreement_hint_text',
      );

  String get request_offer_agreement_hint_text2 => Intl.message(
        'Ex: \$300',
        name: 'request_offer_agreement_hint_text2',
      );

  String get request_offer_agreement_hint_text3 => Intl.message(
        'Ex: Gas-powered lawnmower in mint condition with full tank of gas.',
        name: 'request_offer_agreement_hint_text3',
      );

  String get request_offer_agreement_tool_widget_text => Intl.message(
        'Stipulations regarding returned item in unsatisfactory condition.',
        name: 'request_offer_agreement_tool_widget_text',
      );

  String get request_offer_agreement_hint_text4 => Intl.message(
        'Ex: Lawnmower must be cleaned and operable with a full tank of gas.',
        name: 'request_offer_agreement_hint_text4',
      );

  String get document_name => Intl.message(
        'Document Name*',
        name: 'document_name',
      );

  String get please_enter_doc_name => Intl.message(
        'Please enter document name',
        name: 'please_enter_doc_name',
      );

  String get other_details => Intl.message(
        'Other Details',
        name: 'other_details',
      );

  String get request_offer_agreement_hint_text5 => Intl.message(
        'Ex: LANDLORD\'S LIABILITY. The Guest and any of their guests hereby indemnify and hold harmless the Landlord against any and all claims of personal injury or property damage or loss arising from the use of the Premises regardless of the nature of the accident, injury or loss. The Guest expressly recognizes that any insurance for property damage or loss which the Landlord may maintain on the property does not cover the personal property of Tenant and that Tenant should purchase their own insurance for their guests if such coverage is desired.',
        name: 'request_offer_agreement_hint_text5',
      );

  String get use => Intl.message(
        'use',
        name: 'use',
      );

  String get approve_borrow_request => Intl.message(
        'Approve Room Borrow Request',
        name: 'approve_borrow_request',
      );

  String get approve_item_borrow => Intl.message(
        'Approve Item Borrow request',
        name: 'approve_item_borrow',
      );

  String get approve_borrow_hint_text1 => Intl.message(
        'Tell your borrower do and donts',
        name: 'approve_borrow_hint_text1',
      );

  String get approve_borrow_alert_msg1 => Intl.message(
        'Please enter the dos and donts',
        name: 'approve_borrow_alert_msg1',
      );

  String get approve_borrow_no_agreement_selected => Intl.message(
        'No Agreement Selected',
        name: 'approve_borrow_no_agreement_selected',
      );

  String get request_agreement_form_component_text => Intl.message(
        'Create the proposed agreement between you and the borrower regarding the property. Use previous agreements if appropriate.',
        name: 'request_agreement_form_component_text',
      );

  String get approve_borrow_terms_acknowledgement_text1 => Intl.message(
        'I acknowledge that this Borrower can use the place on the mentioned dates',
        name: 'approve_borrow_terms_acknowledgement_text1',
      );

  String get approve_borrow_terms_acknowledgement_text2 => Intl.message(
        'I acknowledge that this Borrower can use the item(s) on the mentioned dates',
        name: 'approve_borrow_terms_acknowledgement_text2',
      );

  String get approve_borrow_terms_acknowledgement_text3 => Intl.message(
        'Note: Please instruct on how to reach the location and do and dont accordingly.',
        name: 'approve_borrow_terms_acknowledgement_text3',
      );

  String get approve_borrow_terms_acknowledgement_text4 => Intl.message(
        'Note: Please create an agreement if you have specific instructions and/or requirements.',
        name: 'approve_borrow_terms_acknowledgement_text4',
      );

  String get error_was_thrown => Intl.message(
        'Error was Thrown',
        name: 'error_was_thrown',
      );

  String get max_250_characters => Intl.message(
        '* max 250 characters',
        name: 'max_250_characters',
      );

  String get doc_pdf => Intl.message(
        'Document.pdf',
        name: 'doc_pdf',
      );

  String get credits => Intl.message(
        'Credits:',
        name: 'credits',
      );

  String get could_not_launch => Intl.message(
        'Could not launch',
        name: 'could_not_launch',
      );

  String get need_a_place => Intl.message(
        'Need a place',
        name: 'need_a_place',
      );

  String get item => Intl.message(
        'Item',
        name: 'item',
      );

  String get borrow => Intl.message(
        'Borrow',
        name: 'borrow',
      );

  String get choose_skills_for_request => Intl.message(
        'Choose skills for request',
        name: 'choose_skills_for_request',
      );

  String get creating_request_with_underscore_not_allowed => Intl.message(
        'Creating request with \'_\' is not allowed ',
        name: 'creating_request_with_underscore_not_allowed',
      );

  String get selected_skills => Intl.message(
        'Selected Skills',
        name: 'selected_skills',
      );

  String get request_tools_description => Intl.message(
        'Request tools description*',
        name: 'request_tools_description',
      );

  String get seva => Intl.message(
        'Seva',
        name: 'seva',
      );

  String get test_community => Intl.message(
        'Test Community',
        name: 'test_community',
      );

  String get you_already_created_test_community => Intl.message(
        'You already created a test community.',
        name: 'you_already_created_test_community',
      );

  String get selected_value => Intl.message(
        'Selected value :',
        name: 'selected_value',
      );

  String get upgrade_plan_msg1 => Intl.message(
        'Sorry Couldn\'t fetch data',
        name: 'upgrade_plan_msg1',
      );

  String get upgrade_plan_disable_msg1 => Intl.message(
        'This feature is disabled for your community',
        name: 'upgrade_plan_disable_msg1',
      );

  String get upgrade_plan_disable_msg2 => Intl.message(
        'This is currently not permitted. Please see the following link for more information: http://web.sevaxapp.com/',
        name: 'upgrade_plan_disable_msg2',
      );

  String get upgrade_plan_disable_msg3 => Intl.message(
        'This is currently not permitted. Please contact the Community Creator for more information',
        name: 'upgrade_plan_disable_msg3',
      );

  String get edit_name => Intl.message(
        'Edit Name',
        name: 'edit_name',
      );

  String get sponsored_by => Intl.message(
        'Sponsored By',
        name: 'sponsored_by',
      );

  String get sponsor_name => Intl.message(
        'Sponsor name',
        name: 'sponsor_name',
      );

  String get join_seva_community => Intl.message(
        'Join Seva Community',
        name: 'join_seva_community',
      );

  String get please_switch_to_access => Intl.message(
        'Please switch seva community to access ',
        name: 'please_switch_to_access',
      );

  String get please_join_seva_to_access => Intl.message(
        'Please join seva community to access ',
        name: 'please_join_seva_to_access',
      );

  String get no_events_available => Intl.message(
        'No Events Available',
        name: 'no_events_available',
      );

  String get ack => Intl.message(
        'Ack',
        name: 'ack',
      );

  String get enter_the_amount_received => Intl.message(
        'Enter the amount recieved',
        name: 'enter_the_amount_received',
      );

  String get virtual_requests => Intl.message(
        'Virtual requests',
        name: 'virtual_requests',
      );

  String get attended_by => Intl.message(
        'Attended by',
        name: 'attended_by',
      );

  String get reset_list => Intl.message(
        'Reset list',
        name: 'reset_list',
      );

  String get join_community_to_view_updates => Intl.message(
        'To view and receive updates join the community',
        name: 'join_community_to_view_updates',
      );

  String get join_chat => Intl.message(
        'Join Chat',
        name: 'join_chat',
      );

  String get person_of_contact_details => Intl.message(
        'Person of contact details',
        name: 'person_of_contact_details',
      );

  String get review_agreement => Intl.message(
        'Review Agreement',
        name: 'review_agreement',
      );

  String get any_specific_conditions => Intl.message(
        'Any specific condition(s)',
        name: 'any_specific_conditions',
      );

  String get review_before_proceding_text => Intl.message(
        'Please review the agreement below before proceeding.',
        name: 'review_before_proceding_text',
      );

  String get lender_not_accepted_request_msg => Intl.message(
        'Lender has not created an agreement for this request',
        name: 'lender_not_accepted_request_msg',
      );

  String get agreement => Intl.message(
        'Agreement',
        name: 'agreement',
      );

  String get terms_acknowledgement_text => Intl.message(
        'I accept the terms of use as per the agreement',
        name: 'terms_acknowledgement_text',
      );

  String get description_of_item => Intl.message(
        'Description of item(s)',
        name: 'description_of_item',
      );

  String get item_returned_hint_text => Intl.message(
        'Ex: item(s) must be returned in the same condition.',
        name: 'item_returned_hint_text',
      );

  String get sandbox_community_description => Intl.message(
        'Sandbox communities are created for testing purposes?',
        name: 'sandbox_community_description',
      );

  String get select_categories_community_headding => Intl.message(
        'Select categories for your community',
        name: 'select_categories_community_headding',
      );

  String get snackbar_select_agreement_type => Intl.message(
        'Select an agreement type',
        name: 'snackbar_select_agreement_type',
      );

  String get guests_can_do_and_dont => Intl.message(
        'Guests can do and don\'t*',
        name: 'guests_can_do_and_dont',
      );

  String get security_deposits => Intl.message(
        'Security Deposit',
        name: 'security_deposits',
      );

  String get max_occupants => Intl.message(
        'Maximum occupants',
        name: 'max_occupants',
      );

  String get quite_hours_allowed => Intl.message(
        'Quiet hours allowed',
        name: 'quite_hours_allowed',
      );

  String get usage_term => Intl.message(
        'Usage term*',
        name: 'usage_term',
      );

  String get instruction_for_stay => Intl.message(
        'Instruction for the stay',
        name: 'instruction_for_stay',
      );

  String get enter_delivery_time => Intl.message(
        'Enter Delivery Time',
        name: 'enter_delivery_time',
      );

  String get you_created_sandbox_community => Intl.message(
        'You already created a sandbox community.',
        name: 'you_created_sandbox_community',
      );

  String get anywhere => Intl.message(
        'Anywhere',
        name: 'anywhere',
      );

  String get request_description_hint_text_borrow => Intl.message(
        'Please describe what you require',
        name: 'request_description_hint_text_borrow',
      );

  String get goods_request_data_hint_text => Intl.message(
        'Ex: Local Food Bank has a shortage...',
        name: 'goods_request_data_hint_text',
      );

  String get cash_request_data_hint_text => Intl.message(
        'Ex: Fundraiser to expand women’s shelter...',
        name: 'cash_request_data_hint_text',
      );

  String get request_descrip_hint_text => Intl.message(
        'Your Request and any #hashtags',
        name: 'request_descrip_hint_text',
      );

  String get invite_members_group_dots => Intl.message(
        '...',
        name: 'invite_members_group_dots',
      );

  String get view => Intl.message(
        'view',
        name: 'view',
      );

  String get coming_soon => Intl.message(
        'Coming Soon',
        name: 'coming_soon',
      );

  String get public => Intl.message(
        'Public',
        name: 'public',
      );

  String get document_csv => Intl.message(
        'Document.CSV',
        name: 'document_csv',
      );

  String get select_time => Intl.message(
        'Select time',
        name: 'select_time',
      );

  String get claimed_successfully => Intl.message(
        'Claimed Successfully',
        name: 'claimed_successfully',
      );

  String get no_result_found => Intl.message(
        'No result found',
        name: 'no_result_found',
      );

  String get try_text => Intl.message(
        'Try',
        name: 'try_text',
      );

  String get seva_community_groups => Intl.message(
        'Seva Community Groups',
        name: 'seva_community_groups',
      );

  String get projects_text => Intl.message(
        'Projects',
        name: 'projects_text',
      );

  String get select_all => Intl.message(
        'Select All',
        name: 'select_all',
      );

  String get click_button_below_to_review => Intl.message(
        'Click button below to review',
        name: 'click_button_below_to_review',
      );

  String get and_complete_task => Intl.message(
        'and complete the task',
        name: 'and_complete_task',
      );

  String get remove_from_bookmark => Intl.message(
        'Remove from bookmarks',
        name: 'remove_from_bookmark ',
      );

  String get invitations => Intl.message(
        'Invitations',
        name: 'invitations',
      );

  String get attachment => Intl.message(
        'Attachment',
        name: 'attachment',
      );

  String get zero_one => Intl.message(
        '0/1',
        name: 'zero_one',
      );

  String get report_of => Intl.message(
        'Report of',
        name: 'report_of',
      );

  String get waiting_acknowledgement => Intl.message(
        'Waiting acknowledgement',
        name: 'waiting_acknowledgement',
      );

  String get add_sponsor_image => Intl.message(
        'Add Sponsor image',
        name: 'add_sponsor_image',
      );

  String get hint_text_number => Intl.message(
        '123456789',
        name: 'hint_text_number',
      );

  String get accept_modified_amount_finalized => Intl.message(
        'By Accepting this amount will be finalized',
        name: 'accept_modified_amount_finalized',
      );

  String get please_enter_valid_amount => Intl.message(
        'Please enter a valid amount',
        name: 'please_enter_valid_amount',
      );

  String get request_amount_cannot_be_greater => Intl.message(
        'Requested amount cannot be greater than offered amount!',
        name: 'request_amount_cannot_be_greater',
      );

  String get name_not_updated => Intl.message(
        ' name not updated',
        name: 'name_not_updated',
      );

  String get timebank_not_updated => Intl.message(
        'Timebank name not updated',
        name: 'timebank_not_updated',
      );

  String get manage_permissions => Intl.message(
        'Manage Permissions',
        name: 'manage_permissions',
      );

  String get csv_file_sent_successfully_to => Intl.message(
        'CSV file sent successfully to',
        name: 'csv_file_sent_successfully_to',
      );

  String get you_will_go_ahead_with_them_for_request => Intl.message(
        ' you will go ahead with them for the request.',
        name: 'you_will_go_ahead_with_them_for_request',
      );

  String get back => Intl.message(
        'Back',
        name: 'back',
      );

  String get by_selecting_this_you_will_be_creating_a_Sandbox_Community =>
      Intl.message(
        'By selecting this you will be creating a Sandbox Community',
        name: 'by_selecting_this_you_will_be_creating_a_Sandbox_Community',
      );

  String get community_name_unavailable => Intl.message(
        'COMMUNITY NAME UNAVAILABLE',
        name: 'community_name_unavailable',
      );

  String get new_posts => Intl.message(
        'new posts',
        name: 'new_posts',
      );

  String get what_would_you_like_to_share => Intl.message(
        'What would you like to share',
        name: 'what_would_you_like_to_share',
      );

  String get role => Intl.message(
        'Role',
        name: 'role',
      );

  String get event_permissions => Intl.message(
        'Event Permissions',
        name: 'event_permissions',
      );

  String get general_permissions => Intl.message(
        'General Permissions',
        name: 'general_permissions',
      );

  String get request_permissions => Intl.message(
        'Request Permissions',
        name: 'request_permissions',
      );

  String get offer_permissions => Intl.message(
        'Offer Permissions',
        name: 'offer_permissions',
      );

  String get group_permissions => Intl.message(
        'Group Permissions',
        name: 'group_permissions',
      );

  String get careers => Intl.message(
        'Careers',
        name: 'careers',
      );

  String get communities => Intl.message(
        'Communities',
        name: 'communities',
      );

  String get discover => Intl.message(
        'Discover',
        name: 'discover',
      );

  String get diversity_and_belonging => Intl.message(
        'Diversity & Belonging',
        name: 'diversity_and_belonging',
      );

  String get guidebooks => Intl.message(
        'Guidebooks',
        name: 'guidebooks',
      );

  String get hosting => Intl.message(
        'Hosting',
        name: 'hosting',
      );

  String get host_a_community => Intl.message(
        'Host a community',
        name: 'host_a_community',
      );

  String get organize_an_event => Intl.message(
        'Organize an event',
        name: 'organize_an_event',
      );

  String get policies => Intl.message(
        'Policies',
        name: 'policies',
      );

  String get trust_and_safety => Intl.message(
        'Trust & Safety',
        name: 'trust_and_safety',
      );

  String get sevax => Intl.message(
        'SevaX',
        name: 'sevax',
      );

  String get news_text => Intl.message(
        'News',
        name: 'news_text',
      );

  String get seva_exchange_corporation => Intl.message(
        '© Seva Exchange Corporation',
        name: 'seva_exchange_corporation',
      );

  String get url => Intl.message(
        'Url',
        name: 'url',
      );

  String get error => Intl.message(
        'error',
        name: 'error',
      );

  String get external_url => Intl.message(
        'External Url',
        name: 'external_url',
      );

  String get credits_have_been_credited_to_your_account => Intl.message(
        'Seva Credit(s) have been credited to your account.',
        name: 'credits_have_been_credited_to_your_account',
      );

  String get credits_have_been_debited_from_your_account => Intl.message(
        'Seva Credit(s) have been debited from your account.',
        name: 'credits_have_been_debited_from_your_account',
      );

  String get choose_bundle_pricing => Intl.message(
        'Choose bundle pricing',
        name: 'choose_bundle_pricing',
      );

  String get unknown => Intl.message(
        'Unknown',
        name: 'unknown',
      );

  String get creating_offer_with_underscore_error => Intl.message(
        'Creating offer with \'_\' is not allowed',
        name: 'creating_offer_with_underscore_error',
      );

  String get plans => Intl.message(
        'Plans',
        name: 'plans',
      );

  String get invoice_history => Intl.message(
        'Invoice History',
        name: 'invoice_history',
      );

  String get subscription_period => Intl.message(
        'Subscription Period',
        name: 'subscription_period',
      );

  String get effective_date => Intl.message(
        'Effective Date',
        name: 'effective_date',
      );

  String get invoice_amount => Intl.message(
        'Invoice Amount',
        name: 'invoice_amount',
      );

  String get next_invoice_date => Intl.message(
        'Next Invoice Date',
        name: 'next_invoice_date',
      );

  String get monthly => Intl.message(
        'Monthly',
        name: 'monthly',
      );

  String get download => Intl.message(
        'Download',
        name: 'download',
      );

  String get annual => Intl.message(
        'Annual',
        name: 'annual',
      );

  String get inactive => Intl.message(
        'Inactive',
        name: 'inactive',
      );

  String get date_not_available => Intl.message(
        'Date not available',
        name: 'date_not_available',
      );

  String get not_available => Intl.message(
        'not available',
        name: 'not_available',
      );

  String get edit_current_plan => Intl.message(
        'Edit Current Plan',
        name: 'edit_current_plan',
      );

  String get cancel_plan => Intl.message(
        'Cancel Plan',
        name: 'cancel_plan',
      );

  String get card_ending_with => Intl.message(
        'Card ending with',
        name: 'card_ending_with',
      );

  String get show_previous_invoices => Intl.message(
        'show previous invoices',
        name: 'show_previous_invoices',
      );

  String get show_less_invoices => Intl.message(
        'show less invoices',
        name: 'show_less_invoices',
      );

  String get my_cards => Intl.message(
        'My Cards',
        name: 'my_cards',
      );

  String get payment_method => Intl.message(
        'Payment Method',
        name: 'payment_method',
      );

  String get pay_by => Intl.message(
        'Pay by',
        name: 'pay_by',
      );

  String get company => Intl.message(
        'Company',
        name: 'company',
      );

  String get additional => Intl.message(
        'Additional',
        name: 'additional',
      );

  String get to_do => Intl.message(
        'To Do',
        name: 'to_do',
      );

  String get one_to_many_offer_attende => Intl.message(
        'One to Many Offer Attendee',
        name: 'one_to_many_offer_attende',
      );

  String get one_to_many_offer_speaker => Intl.message(
        'One to Many Offer Speaker',
        name: 'one_to_many_offer_speaker',
      );

  String get time_request_volunteer => Intl.message(
        'Time Request Volunteer',
        name: 'time_request_volunteer',
      );

  String get time_offer_volunteer => Intl.message(
        'Accepted Time Offer',
        name: 'time_offer_volunteer',
      );

  String get one_to_many_request_speaker => Intl.message(
        'One to Many Request Speaker',
        name: 'one_to_many_request_speaker',
      );

  String get one_to_many_request_attende => Intl.message(
        'One to Many Request attendee',
        name: 'one_to_many_request_attende',
      );

  String get completed_one_to_many_offer_attende_title => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_offer_attende_title',
      );

  String get completed_one_to_many_offer_attende_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_offer_attende_subtitle',
      );

  String get completed_one_to_many_offer_speaker_title => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_offer_speaker_title',
      );

  String get completed_one_to_many_offer_speaker_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_offer_speaker_subtitle',
      );

  String get completed_one_to_many_request_attende_title => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_request_attende_title',
      );

  String get completed_one_to_many_request_attende_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_request_attende_subtitle',
      );

  String get completed_one_to_many_request_speaker_title => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_request_speaker_title',
      );

  String get completed_one_to_many_request_speaker_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'completed_one_to_many_request_speaker_subtitle',
      );

  String get to_do_one_to_many_offer_attende_title => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_offer_attende_title',
      );

  String get to_do_one_to_many_offer_attende_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_offer_attende_subtitle',
      );

  String get to_do_one_to_many_reuqest_speaker_title => Intl.message(
        'This one to many reuqest has completed.',
        name: 'to_do_one_to_many_reuqest_speaker_title',
      );

  String get to_do_one_to_many_reuqest_speaker_subtitle => Intl.message(
        'This one to many request has completed.',
        name: 'to_do_one_to_many_reuqest_speaker_subtitle',
      );

  String get to_do_one_to_many_request_attende_title => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_request_attende_title',
      );

  String get to_do_one_to_many_request_attende_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_request_attende_subtitle',
      );

  String get to_do_one_to_many_request_speaker_title => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_request_speaker_title',
      );

  String get to_do_one_to_many_request_speaker_subtitle => Intl.message(
        'This one to many offer has completed.',
        name: 'to_do_one_to_many_request_speaker_subtitle',
      );

  String get one_to_many_attendee_offer => Intl.message(
        'One to Many Offer Attendee',
        name: 'one_to_many_attendee_offer',
      );

  String get one_to_many_speaker_offer => Intl.message(
        'One to Many Offer Speaker',
        name: 'one_to_many_speaker_offer',
      );

  String get one_to_many_attendee_request => Intl.message(
        'One to Many Request Attendee',
        name: 'one_to_many_attendee_request',
      );

  String get one_to_many_speaker_request => Intl.message(
        'One to Many Offer Speaker',
        name: 'one_to_many_speaker_request',
      );

  String get do_not_copy => Intl.message(
        'Do not copy',
        name: 'do_not_copy',
      );

  String get proceed_with_copying => Intl.message(
        'Proceed with copying.',
        name: 'proceed_with_copying',
      );

  String get copy_requests_in_events => Intl.message(
        'You have requested to make this a recurring event. Would you like to include all the requests within this event over to all the remaining events?',
        name: 'copy_requests_in_events',
      );

  String get create_community_upload_image_text => Intl.message(
        'Upload an image to represent your community',
        name: 'create_community_upload_image_text',
      );

  String get create_community_select_categories_text => Intl.message(
        'Select categories for your community',
        name: 'create_community_select_categories_text',
      );

  String get create_community_negative_threshold_text => Intl.message(
        'Negative credits threshold',
        name: 'create_community_negative_threshold_text',
      );

  String get choose_plan => Intl.message(
        'Choose Plan',
        name: 'choose_plan',
      );

  String get new_comminity_message => Intl.message(
        'New Community Message',
        name: 'new_comminity_message',
      );

  String get go_to_community_chat => Intl.message(
        'Go To Community Chats',
        name: 'go_to_community_chat',
      );

  String get no_child_communities => Intl.message(
        'No child existing communities',
        name: 'no_child_communities',
      );

  String get community_chat => Intl.message(
        'Child Messaging Rooms',
        name: 'community_chat',
      );

  String get add_cover_picture => Intl.message(
        'Add Cover Picture',
        name: 'add_cover_picture',
      );

  String get or_drag_and_drop => Intl.message(
        'or drag and drop',
        name: 'or_drag_and_drop',
      );

  String get cover_picture_label => Intl.message(
        'Seva Community Cover Picture',
        name: 'cover_picture_label',
      );

  String get cover_picture_label_group => Intl.message(
        'Group Cover Picture',
        name: 'cover_picture_label_group',
      );

  String get cover_picture_label_event => Intl.message(
        'Event Cover Picture',
        name: 'cover_picture_label_event',
      );

  String get crop_photo => Intl.message(
        'Crop Photo',
        name: 'crop_photo',
      );

  String get my_request_categories => Intl.message(
        'My Request Subcategories',
        name: 'my_request_categories',
      );

  String get add_new_request_category => Intl.message(
        'Add new request subcategory',
        name: 'add_new_request_category',
      );

  String get edit_request_category => Intl.message(
        'Edit subcategory',
        name: 'edit_request_category',
      );

  String get add_new_subcategory => Intl.message(
        'Add new subcategory',
        name: 'add_new_subcategory',
      );

  String get add_new_subcategory_hint => Intl.message(
        'Subcategory title',
        name: 'add_new_subcategory_hint',
      );

  String get select_photo => Intl.message(
        'Select Photo',
        name: 'select_photo',
      );

  String get photo_selected => Intl.message(
        'Photo Selected',
        name: 'photo_selected',
      );

  String get please_enter_title => Intl.message(
        'Please enter title',
        name: 'please_enter_title',
      );

  String get request_category_exists => Intl.message(
        'Request subcategory exists',
        name: 'request_category_exists',
      );

  String get no_subcategories_created => Intl.message(
        'No Request Subcategories Created',
        name: 'no_subcategories_created',
      );

  String get change_pricing_options => Intl.message(
        'Change Pricing Options',
        name: 'change_pricing_options',
      );

  String get occurrences => Intl.message(
        'Occurrences',
        name: 'occurrences',
      );

  String get share_post_new => Intl.message(
        'Share Post',
        name: 'share_post_new',
      );

  String get this_is_a_repeating_request => Intl.message(
        'This is a repeating request',
        name: 'this_is_a_repeating_request',
      );

  String get careers_explore => Intl.message(
        'Careers',
        name: 'careers_explore',
      );

  String get communities_explore => Intl.message(
        'Communities',
        name: 'communities_explore',
      );

  String get discover_explore => Intl.message(
        'Discover',
        name: 'discover_explore',
      );

  String get diversity_belonging_explore => Intl.message(
        'Diversity Belonging',
        name: 'diversity_belonging_explore',
      );

  String get guidebooks_explore => Intl.message(
        'Guidebooks',
        name: 'guidebooks_explore',
      );

  String get hosting_explore => Intl.message(
        'Hosting',
        name: 'hosting_explore',
      );

  String get host_a_community_explore => Intl.message(
        'Host a community',
        name: 'host_a_community_explore',
      );

  String get organize_an_event_explore => Intl.message(
        'Organize an event',
        name: 'organize_an_event_explore',
      );

  String get policies_explore => Intl.message(
        'Policies',
        name: 'policies_explore',
      );

  String get news_explore => Intl.message(
        'News',
        name: 'news_explore',
      );

  String get trust_and_safety_explore => Intl.message(
        'Trust & Safety',
        name: 'trust_and_safety_explore',
      );

  String get other_payment_title_hint => Intl.message(
        'Ex: IndieGoGo or Revolut',
        name: 'other_payment_title_hint',
      );

  String get other_payment_details_hint => Intl.message(
        'Ex: Email, Phone Number, ID',
        name: 'other_payment_details_hint',
      );

  String get other_payment_details => Intl.message(
        'Payment Method Details',
        name: 'other_payment_details',
      );

  String get deleted_events_create_request_message => Intl.message(
        'This event is going to be deleted. As a result, requests cannot be created.',
        name: 'deleted_events_create_request_message',
      );

  String get other_payment_name => Intl.message(
        'Payment Method Name',
        name: 'other_payment_name',
      );

  String get accept_offer_invitation_confirmation_to_do_tasks => Intl.message(
        'This task will be added to your To Do list, after you approve it.',
        name: 'accept_offer_invitation_confirmation_to_do_tasks',
      );

  String get are_you_sure_you_want_to_cancel_the_subscription => Intl.message(
        'Are you sure you want to cancel the subscription?',
        name: 'are_you_sure_you_want_to_cancel_the_subscription',
      );

  String get subscription_reactivated => Intl.message(
        'Subscription re-activated',
        name: 'subscription_reactivated',
      );

  String get your_subscription_has_been_reactivated => Intl.message(
        'Your subscription has been re-activated.',
        name: 'your_subscription_has_been_reactivated',
      );

  String get trial_added => Intl.message(
        'Your free 7 day trial starts now',
        name: 'trial_added',
      );

  String get we_have_added_seven_days_free_trial_to_your_subscription =>
      Intl.message(
        'Note: If you do nothing after the 7 day free trial, your paid subscription will continue.',
        name: 'we_have_added_seven_days_free_trial_to_your_subscription',
      );

  String get we_will_miss_you => Intl.message(
        'We will miss you!',
        name: 'we_will_miss_you',
      );

  String get your_subscription_will_be_cancelled_on_the => Intl.message(
        'Your subscription will be cancelled on the',
        name: 'your_subscription_will_be_cancelled_on_the',
      );

  String get add_in_critical_features => Intl.message(
        'Add in critical features.',
        name: 'add_in_critical_features',
      );

  String get add_a_free_trial => Intl.message(
        'Add a free trial.',
        name: 'add_a_free_trial',
      );

  String get add_in_more_comprehensive_training => Intl.message(
        'Add in more comprehensive training.',
        name: 'add_in_more_comprehensive_training',
      );

  String get not_the_right_product_fit_features_workflow_etc => Intl.message(
        'Not the right product fit (ie. features, workflow, etc.)',
        name: 'not_the_right_product_fit_features_workflow_etc',
      );

  String get technical_issues_such_as_glitches_crashes_or_bugs => Intl.message(
        'Technical issues such as glitches, crashes, or bugs.',
        name: 'technical_issues_such_as_glitches_crashes_or_bugs',
      );

  String get the_price_was_too_expensive => Intl.message(
        'The price was too expensive.',
        name: 'the_price_was_too_expensive',
      );

  String get product_was_too_complex_to_use => Intl.message(
        'Product was too complex to use.',
        name: 'product_was_too_complex_to_use',
      );

  String get not_integrating_with_existing_tools => Intl.message(
        'Not integrating with existing tools.',
        name: 'not_integrating_with_existing_tools',
      );

  String get just_not_the_right_time_to_implement => Intl.message(
        'Just not the right time to implement.',
        name: 'just_not_the_right_time_to_implement',
      );

  String get we_are_sorry_to_see_you_go => Intl.message(
        'We are sorry to see you go!',
        name: 'we_are_sorry_to_see_you_go',
      );

  String
      get does_your_cancellation_have_anything_to_do_with_the_following_Select_all_that_apply =>
          Intl.message(
            'Does your cancellation have anything to do with the following? (Select all that apply.)',
            name:
                'does_your_cancellation_have_anything_to_do_with_the_following_Select_all_that_apply',
          );

  String get the_app_did_not_meet_our_requirements_or_expectations_because =>
      Intl.message(
        'The app did not meet our requirements or expectations, because:',
        name: 'the_app_did_not_meet_our_requirements_or_expectations_because',
      );

  String
      get please_let_us_know_if_we_can_do_anything_to_change_your_mind_select_all_that_apply =>
          Intl.message(
            'Please let us know if we can do anything to change your mind? (Select all that apply.)',
            name:
                'please_let_us_know_if_we_can_do_anything_to_change_your_mind_select_all_that_apply',
          );

  String
      get would_you_like_a_bit_more_time_to_evaluvate_our_app_for_free_full_seven_day_trial =>
          Intl.message(
            'Would you like a bit more time to evaluate our app for a free full 7 day trial?',
            name:
                'would_you_like_a_bit_more_time_to_evaluvate_our_app_for_free_full_seven_day_trial',
          );

  String get explore_full_feature_for_next_seven_days => Intl.message(
        'Explore full feature for next 7 days',
        name: 'explore_full_feature_for_next_seven_days',
      );

  String get yes_please_i_know_this_in_a_one_time_free_trial => Intl.message(
        'Yes, please. I know this is a one time free trial.',
        name: 'yes_please_i_know_this_in_a_one_time_free_trial',
      );

  String get no_thank_you => Intl.message(
        'No, thank you.',
        name: 'no_thank_you',
      );

  String get user_remove_from_timebank_failed => Intl.message(
        'User cannot be removed from this Seva Community',
        name: 'user_remove_from_timebank_failed',
      );

  String get completed_events => Intl.message(
        'Completed Events',
        name: 'completed_events',
      );

  String get goods_text => Intl.message(
        'Goods',
        name: 'goods_text',
      );

  String get request_paymenttype_swift => Intl.message(
        'Swift - Bank Account transfers between countries',
        name: 'request_paymenttype_swift',
      );

  String get approve_lending_offer => Intl.message(
        'Approve Lending Offer',
        name: 'approve_lending_offer',
      );

  String get date_to_borrow_and_return => Intl.message(
        'Date to Pick-up and Return item(s)',
        name: 'date_to_borrow_and_return',
      );

  String get date_to_check_in_out => Intl.message(
        'Date of Check In and expected Check Out',
        name: 'date_to_check_in_out',
      );

  String get addditional_instructions => Intl.message(
        'Additional Instructions',
        name: 'addditional_instructions',
      );

  String get addditional_instructions_error_text => Intl.message(
        'Please enter additional instructions',
        name: 'addditional_instructions_error_text',
      );

  String get additional_instructions_hint_item => Intl.message(
        'Ex: Lawnmower is available next door',
        name: 'additional_instructions_hint_item',
      );

  String get additional_instructions_hint_place => Intl.message(
        'Ex: Keys are available in the lockbox\'',
        name: 'additional_instructions_hint_place',
      );

  String get lending_approve_terms_item => Intl.message(
        'I acknowledge that you can lend the item(s) on the mentioned dates.',
        name: 'lending_approve_terms_item',
      );

  String get lending_approve_terms_place => Intl.message(
        'I acknowledge that you can lend the place on the mentioned dates.',
        name: 'lending_approve_terms_place',
      );

  String get lending_text => Intl.message(
        'Lending',
        name: 'lending_text',
      );

  String get cannot_approve_multiple_borrowers_item => Intl.message(
        'You cannot approve multiple borrowers at once. Currently the item(s) are with **name. Once returned you can approve this request.',
        name: 'cannot_approve_multiple_borrowers_item',
      );

  String get cannot_approve_multiple_borrowers_place => Intl.message(
        'You cannot approve multiple borrowers at once. Currently  **name is checked in. Once  **name has checked out you can approve this request.',
        name: 'cannot_approve_multiple_borrowers_place',
      );

  String get borrower_responsibilities => Intl.message(
        'Borrower Responsibilities',
        name: 'borrower_responsibilities',
      );

  String get borrower_responsibilities_subtext => Intl.message(
        'Please check applicable sections to be added in the agreement.',
        name: 'borrower_responsibilities_subtext',
      );

  String get liability_damage => Intl.message(
        'Liability for damage',
        name: 'liability_damage',
      );

  String get use_disclaimer => Intl.message(
        'Use/Disclaimer',
        name: 'use_disclaimer',
      );

  String get delivery_return_equipment => Intl.message(
        'Delivery and Return of Equipment',
        name: 'delivery_return_equipment',
      );

  String get maintain_repair => Intl.message(
        'Maintenance and Repair',
        name: 'maintain_repair',
      );

  String get place_agreement_name_hint => Intl.message(
        'Ex: House for the weekend..',
        name: 'place_agreement_name_hint',
      );

  String get add_new_place_text => Intl.message(
        'Add New Place',
        name: 'add_new_place_text',
      );

  String get update_place_text => Intl.message(
        'Update Place',
        name: 'update_place_text',
      );

  String get add_images_to_place => Intl.message(
        'Add One or more Images of the place',
        name: 'add_images_to_place',
      );

  String get name_of_place => Intl.message(
        'Name of your place',
        name: 'name_of_place',
      );

  String get name_place_text => Intl.message(
        'Name of Place',
        name: 'name_place_text',
      );

  String get name_item_text => Intl.message(
        'Name of Item',
        name: 'name_item_text',
      );

  String get name_of_place_hint => Intl.message(
        'Ex: Room near downtown',
        name: 'name_of_place_hint',
      );

  String get amenities_text => Intl.message(
        'Amenities',
        name: 'amenities_text',
      );

  String get amenities_hint => Intl.message(
        'Please select Amenities guests can utilize',
        name: 'amenities_hint',
      );

  String get no_of_guests => Intl.message(
        'Number of guests',
        name: 'no_of_guests',
      );

  String get bed_roooms_text => Intl.message(
        'Bed Rooms for guests',
        name: 'bed_roooms_text',
      );

  String get bath_rooms_text => Intl.message(
        'Bath Room(s)',
        name: 'bath_rooms_text',
      );

  String get common_spaces => Intl.message(
        'Common Space',
        name: 'common_spaces',
      );

  String get house_rules => Intl.message(
        'House Rules',
        name: 'house_rules',
      );

  String get estimated_value => Intl.message(
        'Estimated Value*',
        name: 'estimated_value',
      );

  String get estimated_value_items => Intl.message(
        'Estimated value of Item(s)',
        name: 'estimated_value_items',
      );

  String get contact_information => Intl.message(
        'Contact Information',
        name: 'contact_information',
      );

  String get add_place_text => Intl.message(
        'Add Place',
        name: 'add_place_text',
      );

  String get lending_offer => Intl.message(
        'Lending Offer',
        name: 'lending_offer',
      );

  String get lending_offer_title_hint => Intl.message(
        'Ex:Lawnmower',
        name: 'lending_offer_title_hint',
      );

  String get lending_offer_desc_hint => Intl.message(
        'Describe your lending',
        name: 'lending_offer_desc_hint',
      );

  String get validation_error_place_name => Intl.message(
        'Please enter name of your place',
        name: 'validation_error_place_name',
      );

  String get validation_error_no_of_guests => Intl.message(
        'Please enter no of guests can stay',
        name: 'validation_error_no_of_guests',
      );

  String get validation_error_no_of_rooms => Intl.message(
        'Please enter no of rooms available',
        name: 'validation_error_no_of_rooms',
      );

  String get validation_error_no_estimated_value_room => Intl.message(
        'Please enter an estimated value for the place',
        name: 'validation_error_no_estimated_value_room',
      );

  String get validation_error_no_estimated_value_item => Intl.message(
        'Please enter an estimated value for the item',
        name: 'validation_error_no_estimated_value_item',
      );

  String get validation_error_no_of_bathrooms => Intl.message(
        'Please enter no of bathrooms available',
        name: 'validation_error_no_of_bathrooms',
      );

  String get validation_error_common_spaces => Intl.message(
        'Please specify common spaces',
        name: 'validation_error_common_spaces',
      );

  String get validation_error_house_rules => Intl.message(
        'Please specify house rules',
        name: 'validation_error_house_rules',
      );

  String get validation_error_amenities => Intl.message(
        'Please select amenities',
        name: 'validation_error_amenities',
      );

  String get validation_error_house_images => Intl.message(
        'Please add place images',
        name: 'validation_error_house_images',
      );

  String get common_spaces_hint => Intl.message(
        'Ex: Sofa bed 1, Couch 1, Floor Mattress 1',
        name: 'common_spaces_hint',
      );

  String get house_rules_hint => Intl.message(
        'Ex: No Smoking',
        name: 'house_rules_hint',
      );

  String get place_text => Intl.message(
        'Place',
        name: 'place_text',
      );

  String get items_text => Intl.message(
        'Item(s)',
        name: 'items_text',
      );

  String get updating_place => Intl.message(
        'Updating place',
        name: 'updating_place',
      );

  String get creating_place => Intl.message(
        'Creating Place',
        name: 'creating_place',
      );

  String get bed_rooms => Intl.message(
        'Bedroom(s)',
        name: 'bed_rooms',
      );

  String get guests_text => Intl.message(
        'Guest(s)',
        name: 'guests_text',
      );

  String get creating_place_error => Intl.message(
        'There was error creating your place, Please try again.',
        name: 'creating_place_error',
      );

  String get updating_place_error => Intl.message(
        'There was error updating your place, Please try again.',
        name: 'updating_place_error',
      );

  String get borrow_request_title => Intl.message(
        'Borrow Request',
        name: 'borrow_request_title',
      );

  String get your_location => Intl.message(
        'Your location',
        name: 'your_location',
      );

  String get your_location_subtext => Intl.message(
        'location will help members to connect easily.',
        name: 'your_location_subtext',
      );

  String get refund_deposit => Intl.message(
        'Refundable Deposit Needed?',
        name: 'refund_deposit',
      );

  String get maintain_clean => Intl.message(
        'Maintenance and Cleanliness',
        name: 'maintain_clean',
      );

  String get provide_address => Intl.message(
        'Please provide particular area or zipcode',
        name: 'provide_address',
      );

  String get borrow_request_lender => Intl.message(
        'Borrow Request Lender',
        name: 'borrow_request_lender',
      );

  String get borrow_request_lender_pending_return_check => Intl.message(
        'Borrow Request Lender - Return Acknowledgment Pending (tap to complete request)',
        name: 'borrow_request_lender_pending_return_check',
      );

  String get borrow_request_creator_awaiting_confirmation => Intl.message(
        'Borrow Request - Awaiting Lender Confirmation',
        name: 'borrow_request_creator_awaiting_confirmation',
      );

  String get details_of_the_request => Intl.message(
        'Details of the Request',
        name: 'details_of_the_request',
      );

  String get details_of_the_request_subtext_item => Intl.message(
        'Please provide details of the item(s), agreement and location',
        name: 'details_of_the_request_subtext_item',
      );

  String get details_of_the_request_subtext_place => Intl.message(
        'Please provide details of the place, agreement and location',
        name: 'details_of_the_request_subtext_place',
      );

  String get accept_borrow_request => Intl.message(
        'Accept Borrower Request',
        name: 'accept_borrow_request',
      );

  String get address_text => Intl.message(
        'Address',
        name: 'address_text',
      );

  String get address_of_location => Intl.message(
        'Address of location',
        name: 'address_of_location',
      );

  String get send_text => Intl.message(
        'Send',
        name: 'send_text',
      );

  String get select_a_item_lending => Intl.message(
        'Select list of related item(s) for Borrow*',
        name: 'select_a_item_lending',
      );

  String get select_item_for_lending => Intl.message(
        'Select an item to lend*',
        name: 'select_item_for_lending',
      );

  String get items_validation => Intl.message(
        'You have not selected any Item(s). Please select one or more before creating the Borrow request.',
        name: 'items_validation',
      );

  String get accept_borrow_agreement_page_hint => Intl.message(
        'To help the borrower. Please provide information about the item available; the lending agreement and the location of property.',
        name: 'accept_borrow_agreement_page_hint',
      );

  String get accept_borrow_agreement_place_hint => Intl.message(
        'Please provide details about your place, the proposed agreement and location of the property.',
        name: 'accept_borrow_agreement_place_hint',
      );

  String get accept_borrow_agreement_item_title => Intl.message(
        'You are about to give item(s) to the borrower',
        name: 'accept_borrow_agreement_item_title',
      );

  String get select_a_place_lending => Intl.message(
        'Select a place to lend*',
        name: 'select_a_place_lending',
      );

  String get add_new_item => Intl.message(
        'Add New Item',
        name: 'add_new_item',
      );

  String get update_item => Intl.message(
        'Update Item',
        name: 'update_item',
      );

  String get name_of_item => Intl.message(
        'Name of your item',
        name: 'name_of_item',
      );

  String get name_of_item_hint => Intl.message(
        'Ex: Lawnmower',
        name: 'name_of_item_hint',
      );

  String get add_item_text => Intl.message(
        'Add Item',
        name: 'add_item_text',
      );

  String get validation_error_item_name => Intl.message(
        'Please enter name of your item',
        name: 'validation_error_item_name',
      );

  String get updating_item => Intl.message(
        'Updating item',
        name: 'updating_item',
      );

  String get creating_item => Intl.message(
        'Creating item',
        name: 'creating_item',
      );

  String get creating_item_error => Intl.message(
        'There was error creating your item, Please try again.',
        name: 'creating_item_error',
      );

  String get updating_item_error => Intl.message(
        'There was error updating your item, Please try again.',
        name: 'updating_item_error',
      );

  String get agree_to_signature_legal_text => Intl.message(
        'By accepting the conditions, your electronic signature is assumed and you are responsible for all terms within this agreement.',
        name: 'agree_to_signature_legal_text',
      );

  String get agreement_to_be_signed => Intl.message(
        'Agreement to be signed',
        name: 'agreement_to_be_signed',
      );

  String get agreement_signed => Intl.message(
        'You have signed the agreement',
        name: 'agreement_signed',
      );

  String get responses_text => Intl.message(
        'Responses',
        name: 'responses_text',
      );

  String get you_have_received_responses => Intl.message(
        'You have received ** response***.',
        name: 'you_have_received_responses',
      );

  String get lenders_text => Intl.message(
        'Lenders',
        name: 'lenders_text',
      );

  String get already_accepted_lender => Intl.message(
        'You have already accepted a lender for this request.',
        name: 'already_accepted_lender',
      );

  String get borrow_request_agreement => Intl.message(
        'Borrow Request Agreement',
        name: 'borrow_request_agreement',
      );

  String get lending_offer_agreement => Intl.message(
        'Lending Offer Agreement',
        name: 'lending_offer_agreement',
      );

  String get lease_duration => Intl.message(
        'Lease Duration: ',
        name: 'lease_duration',
      );

  String get agreement_id => Intl.message(
        'Agreement ID: ',
        name: 'agreement_id',
      );

  String get agreement_details => Intl.message(
        'Agreement Details: ',
        name: 'agreement_details',
      );

  String get lenders_specific_conditions => Intl.message(
        'Lender\'s Specific Conditions: ',
        name: 'lenders_specific_conditions',
      );

  String get agreement_damage_liability => Intl.message(
        'The Borrower is responsible for the full cost of repair or replacement of any or all of the item(s) or properties that are damaged, lost, or stolen from the time the Borrower assumes custody until it is returned to the Lender, unless otherwise agreed at the time the agreement is finalized. If the item(s) or property(s) is lost, stolen or damaged, Borrower agrees to promptly notify the Lender Representative designated above.',
        name: 'agreement_damage_liability',
      );

  String get agreement_user_disclaimer => Intl.message(
        'The Borrower shall be responsible for the proper use and deployment of the item(s) or property. The Borrower shall be responsible for training anyone using the item(s) on the proper use of the item(s) in accordance with any item(s) use procedures.',
        name: 'agreement_user_disclaimer',
      );

  String get agreement_refund_deposit => Intl.message(
        'The Borrower will provide a refundable deposit as defined within the agreement with the Lender. The criteria established regarding the condition of the item(s) or property upon return will also be defined in the agreement.',
        name: 'agreement_refund_deposit',
      );

  String get agreement_maintain_and_clean => Intl.message(
        'All item(s) or property borrowed must be returned in a condition similar to the condition it is received by the Borrower, unless otherwise noted in the agreement. Specific details related to the item(s) or property and the Lender\'s requirements upon return should be noted in the contract and agreed upon prior to the Borrower\'s receipt.',
        name: 'agreement_maintain_and_clean',
      );

  String get agreement_delivery_return => Intl.message(
        'The item(s) subject to this Agreement shall remain with Lender. The Borrower shall be responsible for the safe packaging, proper import, export, shipping and receiving of the item(s). The item(s) shall be returned within a reasonable amount of time after the loan duration end date identified.',
        name: 'agreement_delivery_return',
      );

  String get agreement_maintain_and_repair => Intl.message(
        'Except for reasonable wear and tear, Item(s) shall be returned to Lender in as good condition as when received by the Borrower. During the loan duration and prior to return, the Borrower agrees to assume all responsibility for maintenance and repair.',
        name: 'agreement_maintain_and_repair',
      );

  String get terms_of_service => Intl.message(
        'Terms of Service: ',
        name: 'terms_of_service',
      );

  String get please_note_text => Intl.message(
        'Please Note:',
        name: 'please_note_text',
      );

  String get borrow_lender_dispute => Intl.message(
        'In the real world and online, communities and community members sometimes disagree. If you have a dispute with another Community member, we hope that you will be able to work it out amicably.\" ',
        name: 'borrow_lender_dispute',
      );

  String get borrow_request_seva_disclaimer => Intl.message(
        'However, if you cannot, please understand that Seva Exchange is not responsible for the actions of its members, each member is responsible for their own actions and behavior, whether using Seva Exchange or chatting over the back fence. Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: \"A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party.\" ',
        name: 'borrow_request_seva_disclaimer',
      );

  String get agreement_amending_disclaimer => Intl.message(
        'If the lender and borrower adjust the return date of the item as defined in the agreement, it is the responsibility of the parties involved to maintain the agreement extension and it is not included in this process or the responsibility of Seva Exchange.',
        name: 'agreement_amending_disclaimer',
      );

  String get agreement_final_acknowledgement => Intl.message(
        'It is hereby acknowledged that while Seva Exchange is furnishing this agreement and securely managing in their digital vault, Seva Exchange is only providing this as a convenience to the two parties in this agreement. Seva Exchange is indemnified from any loss or damage that occurs as a result of this transaction. Neither party will hold Seva Exchange accountable and agree to completely absolve Seva Exchange should there be any litigation arising from this transaction.',
        name: 'agreement_final_acknowledgement',
      );

  String get agreement_prior_to_signing_disclaimer => Intl.message(
        'The Borrower should inspect the item or property being taken to ensure the description and operability of the borrowed item or property is represented properly in the agreement and request modifications as necessary prior to executing the agreement. Any adjustments to the defined provisions need to be made prior to signing the agreement. Any actions taken to resolve the issues outside the agreement will be the responsibility of the lender and/or borrower, example is Small Claims Court. Seva Exchange will have no responsibility in the negotiation, management or collection related to the violations of the agreement.',
        name: 'agreement_prior_to_signing_disclaimer',
      );

  String get lender_text => Intl.message(
        'Lender',
        name: 'lender_text',
      );

  String get borrower_text => Intl.message(
        'Borrower',
        name: 'borrower_text',
      );

  String get agreement_date => Intl.message(
        'Agreement Date and Time',
        name: 'agreement_date',
      );

  String get lender_acknowledged_feedback => Intl.message(
        'The Lender has acknowledged completion of this request. Tap to leave a feedback.',
        name: 'lender_acknowledged_feedback',
      );

  String get offering_place_to => Intl.message(
        'You are offering a place to ',
        name: 'offering_place_to',
      );

  String get offering_items_to => Intl.message(
        'You are offering item(s) to ',
        name: 'offering_items_to',
      );

  String get length_of_stay => Intl.message(
        'Length of stay between:  ',
        name: 'length_of_stay',
      );

  String get collect_and_return_items => Intl.message(
        'Pick-up and Return item(s):  ',
        name: 'collect_and_return_items',
      );

  String get items_returned => Intl.message(
        'Item(s) Returned',
        name: 'items_returned',
      );

  String get checked_in_text => Intl.message(
        'Checked In',
        name: 'checked_in_text',
      );

  String get checked_out_text => Intl.message(
        'Checked Out',
        name: 'checked_out_text',
      );

  String get check_out_text => Intl.message(
        'Check Out',
        name: 'check_out_text',
      );

  String get check_in_text => Intl.message(
        'Check In',
        name: 'check_in_text',
      );

  String get check_in_pending => Intl.message(
        'Check in pending',
        name: 'check_in_pending',
      );

  String get borrow_request_collect_items_tag => Intl.message(
        'Borrow Request - Pick-up Item(s)',
        name: 'borrow_request_collect_items_tag',
      );

  String get borrow_request_return_items_tag => Intl.message(
        'Borrow Request - Return Item(s)',
        name: 'borrow_request_return_items_tag',
      );

  String get collect_items => Intl.message(
        'Pick-up Item(s)',
        name: 'collect_items',
      );

  String get return_items => Intl.message(
        'Return Item(s)',
        name: 'return_items',
      );

  String get collected_items => Intl.message(
        'Picked-up Item(s)',
        name: 'collected_items',
      );

  String get returned_items => Intl.message(
        'Returned Item(s)',
        name: 'returned_items',
      );

  String get lent_to_text => Intl.message(
        'Lent to: ',
        name: 'lent_to_text',
      );

  String get place_not_added => Intl.message(
        'Place not added',
        name: 'place_not_added',
      );

  String get items_not_added => Intl.message(
        'Item(s) not added',
        name: 'items_not_added',
      );

  String get lending_offer_location_hint => Intl.message(
        'Provide the information regarding the location you would like to lend',
        name: 'lending_offer_location_hint',
      );

  String get offer_agreement_not_available => Intl.message(
        'Request agreement not available',
        name: 'offer_agreement_not_available',
      );

  String get click_to_view_offer_agreement => Intl.message(
        'Click to view offer agreement',
        name: 'click_to_view_offer_agreement',
      );

  String get join_borrow_request => Intl.message(
        'Invited to accept request',
        name: 'join_borrow_request',
      );

  String get withdraw_lending_offer => Intl.message(
        'Click here if you want to withdraw your request',
        name: 'withdraw_lending_offer',
      );

  String get lender_not_created_agreement => Intl.message(
        'Lender has not created an agreement for this offer',
        name: 'lender_not_created_agreement',
      );

  String get admin_borrow_request_received_back_check => Intl.message(
        'If you have received your item/place back from the borrower, click the button below to complete this transaction.',
        name: 'admin_borrow_request_received_back_check',
      );

  String get please_add_amenities => Intl.message(
        'Please add Amenities.',
        name: 'please_add_amenities',
      );

  String get has_reviewed_you_for_request => Intl.message(
        'has reviewed you for this request. Click button below to review and complete the task',
        name: 'has_reviewed_you_for_request',
      );

  String get view_text => Intl.message(
        'view',
        name: 'view_text',
      );

  String get request_has_been_approved => Intl.message(
        'Request has been approved',
        name: 'request_has_been_approved',
      );

  String get items_taken => Intl.message(
        'Item(s) taken',
        name: 'items_taken',
      );

  String get arrived_text => Intl.message(
        'Arrived',
        name: 'arrived_text',
      );

  String get departed_text => Intl.message(
        'Departed',
        name: 'departed_text',
      );

  String get items_collected_alert => Intl.message(
        'Item(s) to be picked-up and returned on:  ',
        name: 'items_collected_alert',
      );

  String get items_collected_alert_two => Intl.message(
        'You have picked-up item(s) from',
        name: 'items_collected_alert_two',
      );

  String get please_return_by => Intl.message(
        'Please return by: ',
        name: 'please_return_by',
      );

  String get items_returned_to_lender => Intl.message(
        'You have returned the item(s) to the lender, ',
        name: 'items_returned_to_lender',
      );

  String get exchanged_completed => Intl.message(
        'Exchange completed',
        name: 'exchanged_completed',
      );

  String get your_departure_date_is => Intl.message(
        'Your departure date is:',
        name: 'your_departure_date_is',
      );

  String get you_departed_on => Intl.message(
        'You departed on:',
        name: 'you_departed_on',
      );

  String get arrival_text => Intl.message(
        'Arrival',
        name: 'arrival_text',
      );

  String get arrive_text => Intl.message(
        'Arrival',
        name: 'arrive_text',
      );

  String get departure_text => Intl.message(
        'Departure',
        name: 'departure_text',
      );

  String get notes_text => Intl.message(
        'Notes',
        name: 'notes_text',
      );

  String get share_feedback_place => Intl.message(
        'You can leave an appreciation review for your host.',
        name: 'share_feedback_place',
      );

  String get time_offer_accepted_tag => Intl.message(
        'Time offer accepted',
        name: 'time_offer_accepted_tag',
      );

  String get idle_borrow_request_first_warning => Intl.message(
        '*** weeks have passed without any interest. Please re-evaluate this request or withdraw.',
        name: 'idle_borrow_request_first_warning',
      );

  String get idle_borrow_request_second_warning => Intl.message(
        '*** weeks have passed without any interest. Please note that this request will be deleted if there is still no activity after 14 more days',
        name: 'idle_borrow_request_second_warning',
      );

  String get idle_borrow_request_third_warning_deleted => Intl.message(
        'This request has now been deleted due to inactivity for the past 6 weeks.',
        name: 'idle_borrow_request_third_warning_deleted',
      );

  String get idle_lending_offer_first_warning => Intl.message(
        '*** weeks have passed without any interest. Please re-evaluate this offer or withdraw.',
        name: 'idle_lending_offer_first_warning',
      );

  String get idle_lending_offer_second_warning => Intl.message(
        '*** weeks have passed without any interest. Please note that this offer will be deleted if there is still no activity after 14 more days',
        name: 'idle_lending_offer_second_warning',
      );

  String get idle_lending_offer_third_warning_deleted => Intl.message(
        'This offer has now been deleted due to inactivity for the past 6 weeks.',
        name: 'idle_lending_offer_third_warning_deleted',
      );

  String get idle_for_4_weeks => Intl.message(
        ' has been idle for 4 weeks',
        name: 'idle_for_4_weeks',
      );

  String get idle_for_2_weeks => Intl.message(
        ' has been idle for 2 weeks',
        name: 'idle_for_2_weeks',
      );

  String get lending_offer_collect_items_tag => Intl.message(
        'Lending Offer - Pick-up Item(s)',
        name: 'lending_offer_collect_items_tag',
      );

  String get lending_offer_return_items_tag => Intl.message(
        'Lending Offer - Return Item(s)',
        name: 'lending_offer_return_items_tag',
      );

  String get lending_offer_check_in_tag => Intl.message(
        'Lending Offer - Check In',
        name: 'lending_offer_check_in_tag',
      );

  String get lending_offer_check_out_tag => Intl.message(
        'Lending Offer - Check Out',
        name: 'lending_offer_check_out_tag',
      );

  String get change_departure_date => Intl.message(
        'Change departure date?',
        name: 'change_departure_date',
      );

  String get tab_to_leave_feedback => Intl.message(
        'Tap to leave a feedback.',
        name: 'tab_to_leave_feedback',
      );

  String get lending_offer_return_items_hint => Intl.message(
        'Click here if you have returned the item(s).',
        name: 'lending_offer_return_items_hint',
      );

  String get lending_offer_return_place_hint => Intl.message(
        'Click here if you have checked out of the place',
        name: 'lending_offer_return_place_hint',
      );

  String get borrower_returned_items_feedback => Intl.message(
        'You returned item(s). Tap to leave a feedback.',
        name: 'borrower_returned_items_feedback',
      );

  String get borrower_departed_provide_feedback => Intl.message(
        'You checked out as noted above. Tap to leave a feedback.',
        name: 'borrower_departed_provide_feedback',
      );

  String get check_out_alert => Intl.message(
        'Are you sure you want to check out?',
        name: 'check_out_alert',
      );

  String get return_items_alert => Intl.message(
        'Are you sure you want to return item(s)?',
        name: 'return_items_alert',
      );

  String get add_new_text => Intl.message(
        'Add new',
        name: 'add_new_text',
      );

  String get completed_lending_offer => Intl.message(
        'Completed Lending Offer',
        name: 'completed_lending_offer',
      );

  String get end_date_after_offer_end_date_place => Intl.message(
        'The check out date is after the offer end date. Please edit your offer end date or select a date before the offer end date to approve this request.',
        name: 'end_date_after_offer_end_date_place',
      );

  String get end_date_after_offer_end_date_item => Intl.message(
        'The return date is after the offer end date. Please edit your offer end date or select a date before the offer end date to approve this request.',
        name: 'end_date_after_offer_end_date_item',
      );

  String get error_loading_status => Intl.message(
        'error loading status',
        name: 'error_loading_status',
      );

  String get download_pdf => Intl.message(
        'Download PDF',
        name: 'download_pdf',
      );

  String get time_applied_request_tag => Intl.message(
        'applied for request',
        name: 'time_applied_request_tag',
      );

  String get time_withdrawn_request_tag => Intl.message(
        'withdrew from request',
        name: 'time_withdrawn_request_tag',
      );

  String get time_request_approved_tag => Intl.message(
        'request was approved',
        name: 'time_request_approved_tag',
      );

  String get time_request_rejected_tag => Intl.message(
        'request was rejected',
        name: 'time_request_rejected_tag',
      );

  String get time_claim_credits_tag => Intl.message(
        'claimed credits',
        name: 'time_claim_credits_tag',
      );

  String get time_claim_accepted_tag => Intl.message(
        'claim accepted',
        name: 'time_claim_accepted_tag',
      );

  String get time_claim_declined_tag => Intl.message(
        'claim declined',
        name: 'time_claim_declined_tag',
      );

  String get goods_pledged_by_donor_tag => Intl.message(
        'goods pledged by donor',
        name: 'goods_pledged_by_donor_tag',
      );

  String get goods_acknowledged_donation_tag => Intl.message(
        'goods donation acknowledged',
        name: 'goods_acknowledged_donation_tag',
      );

  String get goods_donation_modified_by_creator_tag => Intl.message(
        'goods donation modified by creator',
        name: 'goods_donation_modified_by_creator_tag',
      );

  String get goods_donation_modified_by_donor_tag => Intl.message(
        'goods donation modified by donor',
        name: 'goods_donation_modified_by_donor_tag',
      );

  String get goods_donation_creator_rejected_tag => Intl.message(
        'goods donation rejected',
        name: 'goods_donation_creator_rejected_tag',
      );

  String get money_acknowledged_donation_tag => Intl.message(
        'money donation acknowledged',
        name: 'money_acknowledged_donation_tag',
      );

  String get money_donation_modified_by_creator_tag => Intl.message(
        'money donation modified by creator',
        name: 'money_donation_modified_by_creator_tag',
      );

  String get money_donation_modified_by_donor_tag => Intl.message(
        'money donation modified by donor',
        name: 'money_donation_modified_by_donor_tag',
      );

  String get money_donation_creator_rejected_tag => Intl.message(
        'money donation rejected',
        name: 'money_donation_creator_rejected_tag',
      );

  String get time_signed_up_for_offer_tag => Intl.message(
        'signed up for offer',
        name: 'time_signed_up_for_offer_tag',
      );

  String get time_debited_for_one_to_many_offer_tag => Intl.message(
        'credits debited',
        name: 'time_debited_for_one_to_many_offer_tag',
      );

  String get time_offer_creator_credited_for_one_to_many_offer_tag =>
      Intl.message(
        'creator credited',
        name: 'time_offer_creator_credited_for_one_to_many_offer_tag',
      );

  String get timebank_debited_for_one_to_many_offer_tag => Intl.message(
        'credits paid to creator',
        name: 'timebank_debited_for_one_to_many_offer_tag',
      );

  String get timebank_credited_for_one_to_many_offer_tag => Intl.message(
        'received credits for offer',
        name: 'timebank_credited_for_one_to_many_offer_tag',
      );

  String get requested_by_admin_tag => Intl.message(
        'requested by admin',
        name: 'requested_by_admin_tag',
      );

  String get account_balance => Intl.message(
        'Account Balance\n',
        name: 'account_balance',
      );

  String get item_s_text => Intl.message(
        'item(s)',
        name: 'item_s_text',
      );

  String get sent_text => Intl.message(
        'Sent',
        name: 'sent_text',
      );

  String get donated_by => Intl.message(
        'Donated By:',
        name: 'donated_by',
      );

  String get donated_to => Intl.message(
        'Donated To:',
        name: 'donated_to',
      );

  String get transations => Intl.message(
        'Transactions',
        name: 'transations',
      );

  String get donation_amount => Intl.message(
        'DONATION AMOUNT',
        name: 'donation_amount',
      );

  String get receipt_statement => Intl.message(
        'RECEIPT  STATEMENT:',
        name: 'receipt_statement',
      );

  String get receipt_number => Intl.message(
        'Receipt Number:',
        name: 'receipt_number',
      );

  String get receipt_date => Intl.message(
        'Receipt Date:',
        name: 'receipt_date',
      );

  String get donation_information => Intl.message(
        'DONATION INFORMATION',
        name: 'donation_information',
      );

  String get total_text => Intl.message(
        ' TOTAL',
        name: 'total_text',
      );

  String get goods_donated => Intl.message(
        'GOODS DONATED',
        name: 'goods_donated',
      );

  String get total_items => Intl.message(
        'TOTAL  ITEMS',
        name: 'total_items',
      );

  String get from_text => Intl.message(
        'From:',
        name: 'from_text',
      );

  String get to_text => Intl.message(
        ' To:',
        name: 'to_text',
      );

  String get name_text => Intl.message(
        'Name',
        name: 'name_text',
      );

  String get trasaction_amount => Intl.message(
        'Transaction amount',
        name: 'trasaction_amount',
      );

  String get trasaction_details => Intl.message(
        'Transaction details',
        name: 'trasaction_details',
      );

  String get agreement_accepted => Intl.message(
        'Accepted without agreement',
        name: 'agreement_accepted',
      );

  String get usd_text => Intl.message(
        'USD',
        name: 'usd_text',
      );

  String get sandbox_community_lable => Intl.message(
        'Sandbox Community',
        name: 'sandbox_community_lable',
      );

  String get choose_place_agreement => Intl.message(
        'Select Place Agreement',
        name: 'choose_place_agreement',
      );

  String get choose_item_agreement => Intl.message(
        'Select Item(s) Agreement',
        name: 'choose_item_agreement',
      );

  String get place_returned_hint_text => Intl.message(
        'Ex: place must be returned in the same condition.',
        name: 'place_returned_hint_text',
      );

  String get pricing_text => Intl.message(
        'Pricing',
        name: 'pricing_text',
      );

  String get planPageNote1 => Intl.message(
        'Signup in less than a minute. Try out all our features with our sandbox community for 7 days, then choose a plan that\'s right for you.',
        name: 'planPageNote1',
      );

  String get chooseBundlePricing => Intl.message(
        'Choose bundle pricing',
        name: 'chooseBundlePricing',
      );

  String get other_text => Intl.message(
        'Other',
        name: 'other_text',
      );

  String get current_text => Intl.message(
        'Current',
        name: 'current_text',
      );

  String get test_text => Intl.message(
        'test',
        name: 'test_text',
      );

  String get claimed_for_manual_time_tag => Intl.message(
        'Claimed manual time',
        name: 'claimed_for_manual_time_tag',
      );

  String get accepted_manual_time_request_tag => Intl.message(
        'Manual time claim was accepted',
        name: 'accepted_manual_time_request_tag',
      );

  String get rejected_manual_time_request_tag => Intl.message(
        'Manual time claim was rejected',
        name: 'rejected_manual_time_request_tag',
      );

  String get ADMIN_DONATE_TOUSER_tag => Intl.message(
        'Admin donated credits',
        name: 'ADMIN_DONATE_TOUSER_tag',
      );

  String get MANNUAL_TIME_tag => Intl.message(
        'Manual time claim',
        name: 'MANNUAL_TIME_tag',
      );

  String get OFFER_CREDIT_FROM_TIMEBANK_tag => Intl.message(
        'Credits for Offer',
        name: 'OFFER_CREDIT_FROM_TIMEBANK_tag',
      );

  String get OFFER_CREDIT_TO_TIMEBANK => Intl.message(
        'Credits for Offer',
        name: 'OFFER_CREDIT_TO_TIMEBANK',
      );

  String get REQUEST_CREATION_TIMEBANK_FILL_CREDITS => Intl.message(
        'Credited by SevaX Global',
        name: 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS',
      );

  String get SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE => Intl.message(
        'SevaX Global - Completion of One To Many Request',
        name: 'SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE',
      );

  String get TAX_tag => Intl.message(
        'Tax',
        name: 'TAX_tag',
      );

  String get TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE_tag => Intl.message(
        'One to many request Attendee transaction',
        name: 'TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE_tag',
      );

  String get TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE_tag => Intl.message(
        'One to many request Speaker transaction',
        name: 'TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE_tag',
      );

  String get TIME_REQUEST_tag => Intl.message(
        'Time request completion',
        name: 'TIME_REQUEST_tag',
      );

  String get USER_DONATE_TOTIMEBANK_tag => Intl.message(
        'Donation',
        name: 'USER_DONATE_TOTIMEBANK_tag',
      );

  String get USER_PAYLOAN_TOTIMEBANK_tag => Intl.message(
        'Loan payment',
        name: 'USER_PAYLOAN_TOTIMEBANK_tag',
      );

  String get annually => Intl.message(
        'ANNUALLY',
        name: 'annually',
      );

  String get goods_donation => Intl.message(
        'Goods Donation',
        name: 'goods_donation',
      );

  String get cash_donation => Intl.message(
        'Cash Donation',
        name: 'cash_donation',
      );

  String get any_distance => Intl.message(
        'Any Distance',
        name: 'any_distance',
      );

  String get sponsor_details => Intl.message(
        'Sponsor Details',
        name: 'sponsor_details',
      );

  String get add_sponsor => Intl.message(
        'Add Sponsor',
        name: 'add_sponsor',
      );

  String get donate_text => Intl.message(
        'Donate',
        name: 'donate_text',
      );

  String get try_oska_postal_code => Intl.message(
        'Try \"Oska\" \"Postal Code\"',
        name: 'try_oska_postal_code',
      );

  String get new_message_text => Intl.message(
        'new message',
        name: 'new_message_text',
      );

  String get new_messages_text => Intl.message(
        'new messages',
        name: 'new_messages_text',
      );

  String get external_url_text => Intl.message(
        'External Url',
        name: 'external_url_text',
      );

  String get deletion_request_text => Intl.message(
        'Deletion Request',
        name: 'deletion_request_text',
      );

  String get has_worked_for_text => Intl.message(
        'has worked for',
        name: 'has_worked_for_text',
      );

  String get hours_text => Intl.message(
        'hours',
        name: 'hours_text',
      );

  String get has_reviewed_this_request_text => Intl.message(
        'has reviewed this request',
        name: 'has_reviewed_this_request_text',
      );

  String get tap_to_share_feedback_text => Intl.message(
        'Tap to share feedback',
        name: 'tap_to_share_feedback_text',
      );

  String get people_signed_up_text => Intl.message(
        'people signed up',
        name: 'people_signed_up_text',
      );

  String get has_invited_you_to_join_their => Intl.message(
        'has invited you to join their',
        name: 'has_invited_you_to_join_their',
      );

  String get seva_community_seva_means_selfless_service_in_Sanskrit =>
      Intl.message(
        'Seva Community. Seva means \"selfless service\" in Sanskrit',
        name: 'seva_community_seva_means_selfless_service_in_Sanskrit',
      );

  String get seva_ommunities_are_based_on_a_mutual_reciprocity_system =>
      Intl.message(
        'Seva Communities are based on a mutual-reciprocity system',
        name: 'seva_ommunities_are_based_on_a_mutual_reciprocity_system',
      );

  String
      get where_community_members_help_each_other_out_in_exchange_for_seva_credits_that_can_be_redeemed_for_services_they_need =>
          Intl.message(
            'where community members help each other out in exchange for Seva Credits that can be redeemed for services they need',
            name:
                'where_community_members_help_each_other_out_in_exchange_for_seva_credits_that_can_be_redeemed_for_services_they_need',
          );

  String
      get to_learn_more_about_being_a_part_of_a_Seva_Community_here_s_a_short_explainer_video =>
          Intl.message(
            'To learn more about being a part of a Seva Community, here\"s a short explainer video',
            name:
                'to_learn_more_about_being_a_part_of_a_Seva_Community_here_s_a_short_explainer_video',
          );

  String get here_is_what_you_ll_need_to_know => Intl.message(
        'Here is what you\'ll need to know',
        name: 'here_is_what_you_ll_need_to_know',
      );

  String get first_text => Intl.message(
        'First',
        name: 'first_text',
      );

  String
      get depending_on_where_you_click_the_link_from_whether_it_s_your_web_browser_or_mobile_phone =>
          Intl.message(
            'depending on where you click the link from, whether it\"s your web browser or mobile phone',
            name:
                'depending_on_where_you_click_the_link_from_whether_it_s_your_web_browser_or_mobile_phone',
          );

  String get the_link_will_either_take_you_to_our_main => Intl.message(
        'the link will either take you to our main',
        name: 'the_link_will_either_take_you_to_our_main',
      );

  String
      get web_page_where_you_can_register_on_the_web_directly_or_it_will_take_you_from_your_mobile_phone_to_the_App_or_google_play_stores =>
          Intl.message(
            'web page where you can register on the web directly or it will take you from your mobile phone to the App or Google Play Stores',
            name:
                'web_page_where_you_can_register_on_the_web_directly_or_it_will_take_you_from_your_mobile_phone_to_the_App_or_google_play_stores',
          );

  String
      get where_you_can_download_our_SevaX_App_Once_you_have_registered_on_the_SevaX_mobile_app_or_the_website =>
          Intl.message(
            'where you can download our SevaX App. Once you have registered on the SevaX mobile app or the website',
            name:
                'where_you_can_download_our_SevaX_App_Once_you_have_registered_on_the_SevaX_mobile_app_or_the_website',
          );

  String get you_can_explore_Seva_Communities_near_you_Type_in_the =>
      Intl.message(
        'you can explore Seva Communities near you. Type in the',
        name: 'you_can_explore_Seva_Communities_near_you_Type_in_the',
      );

  String get and_enter_code_text => Intl.message(
        'and enter code',
        name: 'and_enter_code_text',
      );

  String get when_prompted_text => Intl.message(
        'when prompted',
        name: 'when_prompted_text',
      );

  String get click_to_Join_text => Intl.message(
        'Click to Join',
        name: 'click_to_Join_text',
      );

  String get and_their_Seva_Community_via_this_dynamic_link_at => Intl.message(
        'and their Seva Community via this dynamic link at',
        name: 'and_their_Seva_Community_via_this_dynamic_link_at',
      );

  String
      get thank_you_for_being_a_part_of_our_Seva_Exchange_movement_the_Seva_Exchange_team_Please_email_us_at =>
          Intl.message(
            'Thank you for being a part of our Seva Exchange movement!\n-the Seva Exchange team\n\nPlease email us at support@sevaexchange.com',
            name:
                'thank_you_for_being_a_part_of_our_Seva_Exchange_movement_the_Seva_Exchange_team_Please_email_us_at',
          );

  String get if_you_have_any_questions_or_issues_joining_with_the_link_given =>
      Intl.message(
        'if you have any questions or issues joining with the link given',
        name: 'if_you_have_any_questions_or_issues_joining_with_the_link_given',
      );

  String get you_are_signing_up_for_this_test => Intl.message(
        'You are signing up for this',
        name: 'you_are_signing_up_for_this_test',
      );

  String get doing_so_will_debit_a_total_of => Intl.message(
        'Doing so will debit a total of',
        name: 'doing_so_will_debit_a_total_of',
      );

  String get credits_from_you_after_you_say_ok => Intl.message(
        'credits from you after you say OK',
        name: 'credits_from_you_after_you_say_ok',
      );

  String get you_don_t_have_enough_credit_to_signup_for_this_class =>
      Intl.message(
        'You don\"t have enough credit to signup for this class',
        name: 'you_don_t_have_enough_credit_to_signup_for_this_class',
      );

  String get name_not_updated_text => Intl.message(
        'name not updated',
        name: 'name_not_updated_text',
      );

  String get notification_for_new_messages => Intl.message(
        'Notification for new messages',
        name: 'notification_for_new_messages',
      );

  String get feeds_notification_text => Intl.message(
        'Feeds notification',
        name: 'feeds_notification_text',
      );

  String get posting_to_text => Intl.message(
        'Posting to',
        name: 'posting_to_text',
      );

  String get edit_subsequent_requests => Intl.message(
        'Edit subsequent requests',
        name: 'edit_subsequent_requests',
      );

  String get edit_this_request_only => Intl.message(
        'Edit this request only',
        name: 'edit_this_request_only',
      );

  String get this_action_is_restricted_for_you_by_the_owner_of_this =>
      Intl.message(
        'This action is restricted for you by the owner of this',
        name: 'this_action_is_restricted_for_you_by_the_owner_of_this',
      );

  String get lending_offer_title_hint_item => Intl.message(
        'Ex: Offering to lend a lawnmower.',
        name: 'lending_offer_title_hint_item',
      );

  String get lending_offer_title_hint_place => Intl.message(
        'Ex: Offering to lend a room.',
        name: 'lending_offer_title_hint_place',
      );

  String get lending_offer_description_hint_item => Intl.message(
        'Provide a detailed description of the item you would like to lend.',
        name: 'lending_offer_description_hint_item',
      );

  String get lending_offer_description_hint_place => Intl.message(
        'Provide a detailed description of the place you would like to lend including number of rooms, number of beds, etc.',
        name: 'lending_offer_description_hint_place',
      );

  String get bath_rooms => Intl.message(
        'Bathroom(s)',
        name: 'bath_rooms',
      );

  String get borrow_request_title_hint_item => Intl.message(
        'Ex: Lawnmower',
        name: 'borrow_request_title_hint_item',
      );

  String get borrow_request_title_hint_place => Intl.message(
        'Ex: Room',
        name: 'borrow_request_title_hint_place',
      );

  String get borrow_request_description_hint_item => Intl.message(
        'Provide a detailed description of the item you would like to borrow.',
        name: 'borrow_request_description_hint_item',
      );

  String get borrow_request_description_hint_place => Intl.message(
        'Provide a detailed description of the place you would like to borrow including number of rooms, number of beds, etc.',
        name: 'borrow_request_description_hint_place',
      );

  String get search_agreement_hint_place => Intl.message(
        'Enter name of a property agreement template',
        name: 'search_agreement_hint_place',
      );

  String get search_agreement_hint_item => Intl.message(
        'Enter name of an item agreement template',
        name: 'search_agreement_hint_item',
      );

  String get accept_place_borrow_request => Intl.message(
        'Accept Place Borrow Request',
        name: 'accept_place_borrow_request',
      );

  String get accept_item_borrow_request => Intl.message(
        'Accept Item Borrow request',
        name: 'accept_item_borrow_request',
      );

  String get accept_place_lending_offer => Intl.message(
        'Accept Place Lending Offer',
        name: 'accept_place_lending_offer',
      );

  String get accept_item_lending_offer => Intl.message(
        'Accept Item Lending Offer',
        name: 'accept_item_lending_offer',
      );

  String get lender_not_accepted_request_msg_place => Intl.message(
        'Lender is providing the property request with no agreement required',
        name: 'lender_not_accepted_request_msg_place',
      );

  String get lender_not_accepted_request_msg_item => Intl.message(
        'Lender is providing the item(s) request with no agreement required',
        name: 'lender_not_accepted_request_msg_item',
      );

  String get already_accepted_lender_place => Intl.message(
        'You have already accepted a property for this request',
        name: 'already_accepted_lender_place',
      );

  String get already_accepted_lender_item => Intl.message(
        'You have already accepted an item for this request',
        name: 'already_accepted_lender_item',
      );

  String get admin_borrow_request_received_back_check_place => Intl.message(
        'If you have received your place back from the borrower, please click the button below to complete this transaction',
        name: 'admin_borrow_request_received_back_check_place',
      );

  String get admin_borrow_request_received_back_check_item => Intl.message(
        'If you have received your item(s) back from the borrower, please click the button below to complete this transaction',
        name: 'admin_borrow_request_received_back_check_item',
      );

  String get place_agreement_name_hint_place => Intl.message(
        'Ex: Room in New York',
        name: 'place_agreement_name_hint_place',
      );

  String get place_agreement_name_hint_item => Intl.message(
        'Ex: Lawnmower for the weekend',
        name: 'place_agreement_name_hint_item',
      );

  String get lend_text => Intl.message(
        'Lend',
        name: 'lend_text',
      );

  String get estimated_value_hint_place => Intl.message(
        ' (This is the amount based on the property\'s rental value, including amenities)',
        name: 'estimated_value_hint_place',
      );

  String get estimated_value_hint_item => Intl.message(
        ' (This is the amount based on the item\'s current value)',
        name: 'estimated_value_hint_item',
      );

  String get end_date_after_offer_end_date => Intl.message(
        'The dates selected are outside the scope of this offer. Please review and edit your requested dates to approve this request.',
        name: 'end_date_after_offer_end_date',
      );

  String get offer_start_date_validation => Intl.message(
        'Please enter start date',
        name: 'offer_start_date_validation',
      );

  String get lease_start_date => Intl.message(
        'Lease Start Date: ',
        name: 'lease_start_date',
      );

  String get canceled_text => Intl.message(
        'Canceled',
        name: 'canceled_text',
      );

  String get enter_minimum_three_characters => Intl.message(
        'Enter minimum 3 characters',
        name: 'enter_minimum_three_characters',
      );

  String get selected_date_should_be_less_then_current_date => Intl.message(
        'Selected date should be less than current date.',
        name: 'selected_date_should_be_less_then_current_date',
      );

  String get organization_text => Intl.message(
        'Organization',
        name: 'organization_text',
      );

  String get abc_cafe_text => Intl.message(
        'Ex. ABC Cafe.',
        name: 'abc_cafe_text',
      );

  String get sponsor_details_text => Intl.message(
        'Sponsor Details',
        name: 'sponsor_details_text',
      );

  String get add_event_sponsors_text => Intl.message(
        'Add Event Sponsors',
        name: 'add_event_sponsors_text',
      );

  String get sponsored_by_text => Intl.message(
        'Sponsored by',
        name: 'sponsored_by_text',
      );

  String get add_sponsor_text => Intl.message(
        'Add Sponsor',
        name: 'add_sponsor_text',
      );

  String get edit_name_text => Intl.message(
        'Edit Name',
        name: 'edit_name_text',
      );

  String get no_timeline_found => Intl.message(
        'No timeline found',
        name: 'no_timeline_found',
      );

  String get civil_code_dispute => Intl.message(
        'Accordingly, to the maximum extent permitted by applicable law, you release us (and our officers, directors, agents, subsidiaries, joint ventures and employees) from claims, demands and damages (actual and consequential) of every kind and nature, known and unknown, arising out of or in any way connected with such disputes. If you are a California resident, you hereby waive California Civil Code §1542, which says: \"A general release does not extend to claims that the creditor or releasing party does not know or suspect to exist in his or her favor at the time of executing the release, and that, if known by him or her, would have materially affected his or her settlement with the debtor or releasing party.\" ',
        name: 'civil_code_dispute',
      );

  String get total_caps_text => Intl.message(
        ' TOTAL',
        name: 'total_caps_text',
      );

  String get total_items_text => Intl.message(
        'TOTAL ITEMS',
        name: 'total_items_text',
      );

  String get money_pledged_by_donor_tag => Intl.message(
        'Money pledged by donor',
        name: 'money_pledged_by_donor_tag',
      );

  String get estimated_value_item_hint => Intl.message(
        'Ex: \$100',
        name: 'estimated_value_item_hint',
      );

  String get estimated_value_place_hint => Intl.message(
        'Ex: \$2000',
        name: 'estimated_value_place_hint',
      );

  String get seva_exchange_text_new => Intl.message(
        'By continuing, you agree to Seva Exchange\'s',
        name: 'seva_exchange_text_new',
      );

  String get lending_offer_location_hint_item => Intl.message(
        'Provide general vicinity of pick-up location',
        name: 'lending_offer_location_hint_item',
      );

  String get lending_offer_location_hint_place => Intl.message(
        'Provide general vicinity of where the accommodation is',
        name: 'lending_offer_location_hint_place',
      );

  String get location_safety_disclaimer => Intl.message(
        'Note: For safety precautions, do not list the exact location.',
        name: 'location_safety_disclaimer',
      );

  String get customise_community => Intl.message(
        'Customise your Community',
        name: 'customise_community',
      );

  String get community_logo => Intl.message(
        'Commumity Logo',
        name: 'community_logo',
      );

  String get replace_logo => Intl.message(
        'This logo will replace the SevaX Logo on the top left side of the page',
        name: 'replace_logo',
      );

  String get choose_theme_color => Intl.message(
        'Choose theme color',
        name: 'choose_theme_color',
      );

  String get long_press_to_reset => Intl.message(
        'Long press to reset',
        name: 'long_press_to_reset',
      );

  String get tap_to_add_colors => Intl.message(
        'Tap to add colors',
        name: 'tap_to_add_colors',
      );

  String get you_have_recieved => Intl.message(
        'You have received ',
        name: 'you_have_recieved',
      );

  String get seva_credits_donated_text => Intl.message(
        'Seva Credits Donated',
        name: 'seva_credits_donated_text',
      );

  String get seva_credits_from_text => Intl.message(
        'Seva Credit(s) from',
        name: 'seva_credits_from_text',
      );

  String get change_ownership_successful => Intl.message(
        'You have successfully transferred ownership of **groupName to **newOwnerName.',
        name: 'change_ownership_successful',
      );

  String get changed_ownership_of_text => Intl.message(
        'changed ownership of',
        name: 'changed_ownership_of_text',
      );

  String get transfer_ownership_text => Intl.message(
        'Transfer Ownership',
        name: 'transfer_ownership_text',
      );

  String get you_have_been_made_the_new_owner_of_group_name_subtitle =>
      Intl.message(
        'You have been made the new owner of',
        name: 'you_have_been_made_the_new_owner_of_group_name_subtitle',
      );

  String get direction_for_manage_transfer_ownership => Intl.message(
        'Go to your group Manage tab and then select a new group member to transfer ownership.',
        name: 'direction_for_manage_transfer_ownership',
      );

  String get be_sure_message_text => Intl.message(
        'Be sure to check with the member first by messaging them.',
        name: 'be_sure_message_text',
      );

  String get removed_you_from_text => Intl.message(
        'removed you from',
        name: 'removed_you_from_text',
      );

  String get note_for_transfer_ownership_notification => Intl.message(
        'Note: If you cannot fulfil this role or if you believe this was done in error please click here.',
        name: 'note_for_transfer_ownership_notification',
      );

  String get transfer_of_group_ownership_update => Intl.message(
        'Transfer of group ownership update.',
        name: 'transfer_of_group_ownership_update',
      );

  String get directions_text => Intl.message(
        'Directions',
        name: 'directions_text',
      );

  String get link_for_demo_video_text => Intl.message(
        'Link for demo video:',
        name: 'link_for_demo_video_text',
      );

  String get within_text => Intl.message(
        'Within',
        name: 'within_text',
      );

  String get share_text => Intl.message(
        'Share',
        name: 'share_text',
      );

  String get edit_post => Intl.message(
        'Edit Post',
        name: 'edit_post',
      );

  String get create_post => Intl.message(
        'Create a Post',
        name: 'create_post',
      );

  String get add_to_post => Intl.message(
        'Add to post',
        name: 'add_to_post',
      );

  String get save_changes => Intl.message(
        'Save Changes',
        name: 'save_changes',
      );

  String get accept_this_offer => Intl.message(
        'Would you like to accept this offer?',
        name: 'accept_this_offer',
      );

  String get have_accepted_offer => Intl.message(
        'You have accepted this offer.',
        name: 'have_accepted_offer',
      );

  String get chat_text => Intl.message(
        'Chat',
        name: 'chat_text',
      );

  String get share_post_to => Intl.message(
        'Whom do you want to share this Post?',
        name: 'share_post_to',
      );

  String get remove_bookmark => Intl.message(
        'Remove from bookmark',
        name: 'remove_bookmark',
      );

  String get add_images => Intl.message(
        'Add images',
        name: 'add_images',
      );

  String get choose_images => Intl.message(
        'Choose Images',
        name: 'choose_images',
      );

  String get money_request_minimum_donation_error_text => Intl.message(
        'Please enter the number of minimum donation needed',
        name: 'money_request_minimum_donation_error_text',
      );

  String get latest => Intl.message(
        'LATEST',
        name: 'latest',
      );

  String get why_do_you_want_to_join => Intl.message(
        'Why do you want to join this community?',
        name: 'why_do_you_want_to_join',
      );

  String get recommended_image_ratio => Intl.message(
        'Recommended ratio 3:1, no larger than 2 MB',
        name: 'recommended_image_ratio',
      );

  String get short_review => Intl.message(
        'Write a short review',
        name: 'short_review',
      );

  String get invite_members_copy_code => Intl.message(
        'To invite members, copy and paste this either into the message portion of your email or into a text message.',
        name: 'invite_members_copy_code',
      );

  String get failed_text => Intl.message(
        'FAILED',
        name: 'failed_text',
      );

  String get not_attended => Intl.message(
        'NOT ATTENDED',
        name: 'not_attended',
      );

  String get copy_to_clipboard => Intl.message(
        'Copy to clipboard',
        name: 'copy_to_clipboard',
      );

  String get create_feeds => Intl.message(
        'Create Feeds',
        name: 'create_feeds',
      );

  String get billing_access => Intl.message(
        'Billing Access',
        name: 'billing_access',
      );

  String get customise_community_title => Intl.message(
        'Customise Community',
        name: 'customise_community_title',
      );

  String get create_borrow_request => Intl.message(
        'Create Borrow Request',
        name: 'create_borrow_request',
      );

  String get create_events => Intl.message(
        'Create Events',
        name: 'create_events',
      );

  String get create_goods_offers => Intl.message(
        'Create Goods Offers',
        name: 'create_goods_offers',
      );

  String get create_goods_request => Intl.message(
        'Create Goods Requests',
        name: 'create_goods_request',
      );

  String get create_money_offers => Intl.message(
        'Create Money Offers',
        name: 'create_money_offers',
      );

  String get create_money_request => Intl.message(
        'Create Money Requests',
        name: 'create_money_request',
      );

  String get create_time_offers => Intl.message(
        'Create Time Offers',
        name: 'create_time_offers',
      );

  String get create_time_request => Intl.message(
        'Create Time Requests',
        name: 'create_time_request',
      );

  String get invite_bulk_members => Intl.message(
        'Invite / Invite bulk members',
        name: 'invite_bulk_members',
      );

  String get promote_user => Intl.message(
        'Promote User',
        name: 'promote_user',
      );

  String get demote_user => Intl.message(
        'Demote user',
        name: 'demote_user',
      );

  String get create_onetomany_request => Intl.message(
        'Create One To Many Requests',
        name: 'create_onetomany_request',
      );

  String get create_virtual_request => Intl.message(
        'Create virtual Request',
        name: 'create_virtual_request',
      );

  String get create_public_request => Intl.message(
        'Create public request',
        name: 'create_public_request',
      );

  String get create_virtual_event => Intl.message(
        'Create virtual event',
        name: 'create_virtual_event',
      );

  String get create_public_event => Intl.message(
        'Create public event',
        name: 'create_public_event',
      );

  String get create_endorsed_group => Intl.message(
        'Create endorsed group',
        name: 'create_endorsed_group',
      );

  String get create_private_group => Intl.message(
        'Create private group',
        name: 'create_private_group',
      );

  String get one_to_many_offer => Intl.message(
        'Create One To Many Offer',
        name: 'one_to_many_offer',
      );

  String get accept_time_offer => Intl.message(
        'Accept Time Offer',
        name: 'accept_time_offer',
      );

  String get accept_money_offer => Intl.message(
        'Accept Money Offer',
        name: 'accept_money_offer',
      );

  String get accept_goods_offer => Intl.message(
        'Accept Goods Offer',
        name: 'accept_goods_offer',
      );

  String get accept_one_to_many_offer => Intl.message(
        'Accept One To Many Offer',
        name: 'accept_one_to_many_offer',
      );

  String get create_lending_offers => Intl.message(
        'Create Lending Offers',
        name: 'create_lending_offers',
      );

  String get accept_lending_offers => Intl.message(
        'Accept Lending Offers',
        name: 'accept_lending_offers',
      );

  String get as_a_donation_text => Intl.message(
        'as a donation.',
        name: 'as_a_donation_text',
      );

  String get name_should_contain_three_characters => Intl.message(
        'Name should atleast contain 3 characters',
        name: 'name_should_contain_three_characters',
      );

  String get password_cannot_be_empty => Intl.message(
        'Password cannot be empty',
        name: 'password_cannot_be_empty',
      );

  String get password_length => Intl.message(
        'Password must be at least 6 character long',
        name: 'password_length',
      );

  String get confirm_password_length => Intl.message(
        'Confirm Password must be at least 6 character long',
        name: 'confirm_password_length',
      );

  String get confirm_password_empty => Intl.message(
        'Confirm Password cannot be empty',
        name: 'confirm_password_empty',
      );

  String get paypal_hint_text => Intl.message(
        'Ex: Paypal ID (phone or email)',
        name: 'paypal_hint_text',
      );

  String get swift_hint_text => Intl.message(
        'Ex: Swift ID',
        name: 'swift_hint_text',
      );

  String get id_cannot_be_empty => Intl.message(
        'ID cannot be empty',
        name: 'id_cannot_be_empty',
      );

  String get enter_valid_swift_id => Intl.message(
        'Enter valid Swift ID',
        name: 'enter_valid_swift_id',
      );

  String get creating_offer_with_underscore => Intl.message(
        'Creating offer with \"_\" is not allowed',
        name: 'creating_offer_with_underscore',
      );

  String get change_trasaction_bundle_pricing => Intl.message(
        'Are you sure you want to change the transaction pricing to bundle pricing',
        name: 'change_trasaction_bundle_pricing',
      );

  String get pricing_method_changed => Intl.message(
        'Pricing method changed successfully',
        name: 'pricing_method_changed',
      );

  String get change_trasaction_pricing => Intl.message(
        'Change transaction pricing',
        name: 'change_trasaction_pricing',
      );

  String get seva_credit_s => Intl.message(
        'Seva Credit(s)',
        name: 'seva_credit_s',
      );

  String get link_not_provided => Intl.message(
        'Link not provided!',
        name: 'link_not_provided',
      );

  String get customize_community => Intl.message(
        'Customize Your Community',
        name: 'customize_community',
      );

  String get amount_cannot_be_greater => Intl.message(
        'Requested amount cannot be greater than offered amount!',
        name: 'amount_cannot_be_greater',
      );

  String get glossaries_text => Intl.message(
        'Glossaries',
        name: 'glossaries_text',
      );

  String get faq_text => Intl.message(
        'FAQ',
        name: 'faq_text',
      );

  String get requires_permission_to_access_your_location => Intl.message(
        'requires permission to access your location.',
        name: 'requires_permission_to_access_your_location',
      );

  String get would_you_like_to_add_this_event_to_your_calendar => Intl.message(
        'Would you like to add this event to your calendar?',
        name: 'would_you_like_to_add_this_event_to_your_calendar',
      );

  String get choose_category_text => Intl.message(
        'Choose Category',
        name: 'choose_category_text',
      );

  String get reported_within_seva_community => Intl.message(
        'Reported within Seva Community',
        name: 'reported_within_seva_community',
      );

  String get reported_within_group => Intl.message(
        'Reported within Group',
        name: 'reported_within_group',
      );

  String get cropped_image => Intl.message(
        'Cropped image',
        name: 'cropped_image',
      );

  String get relative_text => Intl.message(
        'relative',
        name: 'relative_text',
      );

  String get seva_community_name_already_exists => Intl.message(
        'Seva Community name already exists',
        name: 'seva_community_name_already_exists',
      );
}

class ArbifyLocalizationsDelegate extends LocalizationsDelegate<S> {
  const ArbifyLocalizationsDelegate();

  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: 'es'),
        Locale.fromSubtags(languageCode: 'pt'),
        Locale.fromSubtags(languageCode: 'sn'),
        Locale.fromSubtags(languageCode: 'de'),
        Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
        Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
        Locale.fromSubtags(languageCode: 'af'),
        Locale.fromSubtags(languageCode: 'sw'),
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'fr'),
      ];

  @override
  bool isSupported(Locale locale) => [
        'es',
        'pt',
        'sn',
        'de',
        'zh',
        'zh',
        'af',
        'sw',
        'en',
        'fr',
      ].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) => S.load(locale);

  @override
  bool shouldReload(ArbifyLocalizationsDelegate old) => false;
}
