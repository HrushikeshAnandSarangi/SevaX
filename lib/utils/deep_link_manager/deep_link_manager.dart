import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      appStoreId: '1451705907',
    ),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();

  return shortLink.shortUrl.toString();
}

Future<String> createDynamicLinkFromAPI({
  String inviteeEmail,
  String communityId,
  String primaryTimebankId,
}) async {
  var body = {
    "dynamicLinkInfo": {
      "domainUriPrefix": FlavorConfig.values.dynamicLinkUriPrefix,
      "link":
          'https://www.sevaexchange.com?invitedMemberEmail=$inviteeEmail&communityId=$communityId&primaryTimebankId=$primaryTimebankId',
      "androidInfo": {"androidPackageName": FlavorConfig.values.packageName},
      "iosInfo": {
        "iosBundleId": FlavorConfig.values.bundleId,
        'iosAppStoreId': '1451705907',
      }
    }
  };

  var url =
      "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyA1uAGsq35nEARPexmT5c1AFL29wfOuv5Y";
  var result = await http.post(Uri.encodeFull(url),
      body: jsonEncode(body), headers: {"Content-Type": "application/json"});

  var dynamicLinkResponse = dynamicShortLinkUrlFromJson(result.body);

  return dynamicLinkResponse.shortLink;
}

DynamicShortLinkUrl dynamicShortLinkUrlFromJson(String str) =>
    DynamicShortLinkUrl.fromJson(json.decode(str));

String dynamicShortLinkUrlToJson(DynamicShortLinkUrl data) =>
    json.encode(data.toJson());

class DynamicShortLinkUrl {
  DynamicShortLinkUrl({
    this.shortLink,
    this.warning,
    this.previewLink,
  });

  String shortLink;
  List<Warning> warning;
  String previewLink;

  factory DynamicShortLinkUrl.fromJson(Map<String, dynamic> json) =>
      DynamicShortLinkUrl(
        shortLink: json["shortLink"],
        warning:
            List<Warning>.from(json["warning"].map((x) => Warning.fromJson(x))),
        previewLink: json["previewLink"],
      );

  Map<String, dynamic> toJson() => {
        "shortLink": shortLink,
        "warning": List<dynamic>.from(warning.map((x) => x.toJson())),
        "previewLink": previewLink,
      };
}

class Warning {
  Warning({
    this.warningCode,
    this.warningMessage,
  });

  String warningCode;
  String warningMessage;

  factory Warning.fromJson(Map<String, dynamic> json) => Warning(
        warningCode: json["warningCode"],
        warningMessage: json["warningMessage"],
      );

  Map<String, dynamic> toJson() => {
        "warningCode": warningCode,
        "warningMessage": warningMessage,
      };
}
