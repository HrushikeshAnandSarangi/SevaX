import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

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
  String primaryTimebankId,
}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: FlavorConfig.values.dynamicLinkUriPrefix,
    link: Uri.parse(
        'https://www.sevaexchange.com?invitedMemberEmail=$inviteeEmail&communityId=$communityId&primaryTimebankId=$primaryTimebankId'),
    androidParameters: AndroidParameters(
      packageName: FlavorConfig.values.packageName,
      minimumVersion: 0,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    iosParameters: IosParameters(
      bundleId: FlavorConfig.values.bundleId,
      minimumVersion: '0',
    ),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();
  return shortLink.shortUrl.toString();
}
