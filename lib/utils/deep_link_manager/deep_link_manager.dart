import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

void initDynamicLinks(BuildContext context) async {
  final PendingDynamicLinkData? data =
      await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data!.link;

  if (deepLink != null) {
    Navigator.pushNamed(context, deepLink.path);
  }

  FirebaseDynamicLinks.instance.onLink
      .listen((PendingDynamicLinkData dynamicLink) async {
    final Uri deepLink = dynamicLink.link;
    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }).onError((error) async {});
}

Future<String> createDynamicLinkFor({
  String? inviteeEmail,
  String? communityId,
  String? primaryTimebankId,
}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: FlavorConfig.values.dynamicLinkUriPrefix,
    link: Uri.parse(
        'http://web.sevaxapp.com?invitedMemberEmail=$inviteeEmail&communityId=$communityId&primaryTimebankId=$primaryTimebankId'),
    androidParameters: AndroidParameters(
      packageName: FlavorConfig.values.packageName!,
      minimumVersion: 0,
    ),
    iosParameters: IOSParameters(
      bundleId: FlavorConfig.values.bundleId!,
      minimumVersion: '0',
    ),
  );

  final ShortDynamicLink shortLink =
      await FirebaseDynamicLinks.instance.buildShortLink(parameters);

  return shortLink.shortUrl.toString();
}
