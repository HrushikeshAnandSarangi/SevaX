import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/user_model.dart';

import '../../flavor_config.dart';

void initDynamicLinks(BuildContext context) async {
  final PendingDynamicLinkData data =
      await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data?.link;

  if (deepLink != null) {
    Navigator.pushNamed(context, deepLink.path);
  }

  FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
    final Uri deepLink = dynamicLink?.link;
    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }, onError: (OnLinkErrorException e) async {
    print('onLinkError');
    print(e.message);
  });
}

Future<String> createDynamicLinkFor({
  String inviteeEmail,
  String communityId,
}) async {
  print(
      "________________________________________createDynamicLinkFor _ started");
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://sevadev.page.link',
    link: Uri.parse(
        'https://sevadev.page.link/timebankInvite?invitedMemberEmail=$inviteeEmail&communityId=$communityId'),
    androidParameters: AndroidParameters(
      packageName: 'com.sevaexchange.dev',
      minimumVersion: 0,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.sevaexchange.dev',
      minimumVersion: '0',
    ),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();
  Uri url = shortLink.shortUrl;
  print(
      "________________________________________createDynamicLinkFor _ completed with link - > ${shortLink.shortUrl.toString()}");
  return shortLink.shortUrl.toString();
}

Future<void> fetchLinkData({UserModel loggedInUser}) async {
  // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
  var link = await FirebaseDynamicLinks.instance.getInitialLink();

  // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
  await handleLinkData(loggedInUser: loggedInUser, data: link);
  FirebaseDynamicLinks.instance.onLink(onError: (_) {
    HandleJoinFromLink();
  }, onSuccess: (PendingDynamicLinkData dynamicLink) async {
    return handleLinkData(loggedInUser: loggedInUser, data: dynamicLink);
  });

  // This will handle incoming links if the application is already opened
}

Future<bool> handleLinkData(
    {PendingDynamicLinkData data, UserModel loggedInUser}) async {
  print("==================================================================");

  final Uri uri = data?.link;
  if (uri != null) {
    final queryParams = uri.queryParameters;
    if (queryParams.length > 0) {
      String invitedMemberEmail = queryParams["invitedMemberEmail"];
      String communityId = queryParams["communityId"];
      // verify the username is parsed correctly
      print(
          "$invitedMemberEmail ---   $communityId -------------- ${loggedInUser.toMap()}");

      await registerloggedInUserToCommunity(
        communityId: communityId,
        userrModel: loggedInUser,
        invitedMemberEmail: invitedMemberEmail,
      );
      return true;
    }
  }
  return false;
}

Future<bool> registerloggedInUserToCommunity(
    {UserModel userrModel,
    String communityId,
    String invitedMemberEmail}) async {
  return true;
}

Future<bool> mailCodeToInvitedMember({
  String mailSender,
  String mailReciever,
  String mailSubject,
  String mailContent,
}) async {
  print(
      "________________________________________mailCodeToInvitedMember _ started with content -> " +
          mailContent);
  try {
    await http.post(
      "${FlavorConfig.values.cloudFunctionBaseURL}/mailForSoftDelete",
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "mailSender": mailSender,
          "mailSubject": mailSubject,
          "mailBody": mailContent
        },
      ),
    );
    print(
        "________________________________________mailCodeToInvitedMember _ successfully");
    return true;
  } catch (_) {
    print(
        "________________________________________mailCodeToInvitedMember _ failed");
    return false;
  }
}

class HandleJoinFromLink {
  String communityId;
  bool isFromLink;
  String invitedMemberEmail;

  HandleJoinFromLink() {
    isFromLink = false;
    communityId = null;
    invitedMemberEmail = null;
  }

  HandleJoinFromLink.from({
    String communityId,
    String invitedMemberEmail,
  }) {
    isFromLink = true;
    this.communityId = communityId;
    this.invitedMemberEmail = invitedMemberEmail;
  }
}
