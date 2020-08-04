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
