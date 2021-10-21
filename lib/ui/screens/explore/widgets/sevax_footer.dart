import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/localization/app_timezone.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/language.dart';
import 'package:sevaexchange/views/profile/timezone.dart';

class SevaExploreFooter extends StatefulWidget {
  final bool footerColor;
  SevaExploreFooter({this.footerColor});
  @override
  _SevaExploreFooterState createState() => _SevaExploreFooterState();
}

class _SevaExploreFooterState extends State<SevaExploreFooter> {
  String timezoneName;
  final List<List<FooterData>> footerData = [
    [FooterData.SevaX, FooterData.Discover, FooterData.Hosting],
    [FooterData.About_Us, FooterData.Trust_Safety, FooterData.Host_community],
    [FooterData.Careers, FooterData.Requests, FooterData.Create_offer],
    [FooterData.Press, FooterData.Communities, FooterData.Organize_event],
    [FooterData.Policies, FooterData.Offers, FooterData.Create_request],
    [FooterData.Help, FooterData.Events, FooterData.EMPTY],
    [FooterData.Diversity_Belonging, FooterData.Guidebooks, FooterData.EMPTY],
  ];

  @override
  void initState() {
    // TODO: implement initState
    timezoneName = DateTime.now().timeZoneName.toLowerCase();
    var exists = TimezoneListData().timezonelist.firstWhere(
          (element) =>
              element.timezoneName.toLowerCase() == timezoneName.toLowerCase(),
          orElse: () => null,
        );
    if (exists == null) {
      timezoneName = 'PACIFIC TIME'.toLowerCase();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timezoneName = Provider.of<AppTimeZone>(context).appTimeZone.toString();

    return Container(
      width: MediaQuery.of(context).size.width,
      color: widget.footerColor == true
          ? Theme.of(context).primaryColor
          : Color(0xFFF454684),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2 - 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      onChanged: (value) async {
                        Provider.of<AppLanguage>(context, listen: false)
                            .changeLanguage(
                          getLocaleFromCode(value),
                        );
                        if (SevaCore.of(context).loggedInUser != null) {
                          await updateUserLanguage(
                            user: SevaCore.of(context).loggedInUser
                              ..language = value,
                          );
                        }
                        Phoenix.rebirth(context);
                      },
                      value: S.of(context).localeName,
                      items: languageNames.keys
                          .map(
                            (key) => DropdownMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  languageNames[key],
                                ),
                              ),
                              value: key,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2 - 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      onChanged: (value) {
                        setState(() {
                          timezoneName = value;
                        });
                        Provider.of<AppTimeZone>(context, listen: false)
                            .changeTimeZone(value);
                      },
                      value: timezoneName,
                      isExpanded: true,
                      items: TimezoneListData()
                          .timezonelist
                          .map(
                            (model) => DropdownMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  model.timezoneName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value: model.timezoneName.toLowerCase(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Table(
              children: [
                ...footerData
                    .map(
                      (row) => TableRow(
                        children: row
                            .map(
                              (data) => TableRowInkWell(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        footerData[0].contains(data) ? 16 : 4,
                                  ),
                                  child: Center(
                                    child: Text(
                                      getFooterDataTitle(
                                          data: data, context: context),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: footerData[0].contains(data)
                                            ? 16
                                            : 14,
                                        fontWeight: footerData[0].contains(data)
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: openUrl(
                                  context: context,
                                  data: data,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ],
            ),
            Divider(
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button(
                  'Terms',
                  getOnTap(
                    context,
                    S.of(context).login_agreement_terms_link,
                    'termsAndConditionsLink',
                  ),
                ),
                button(
                  'Privacy',
                  getOnTap(
                    context,
                    S.of(context).login_agreement_privacy_link,
                    'privacyPolicyLink',
                  ),
                ),
                button(
                  'Site Map',
                  getOnTap(context, 'Site Map', 'aboutSeva'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Ffacebook.png?alt=media&token=2a2ee259-0c97-4fee-bda8-aecd56a857aa',
                    width: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    navigateToWebView(
                      aboutMode: AboutMode(
                          title: 'Facebook',
                          urlToHit: 'https://www.facebook.com/sevaexchange/'),
                      context: context,
                    );
                  },
                ),
                IconButton(
                  icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Ftwitter.png?alt=media&token=4246c0d2-6971-474a-9096-3ccb2a7649a3',
                    width: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    navigateToWebView(
                      aboutMode: AboutMode(
                          title: 'Twitter',
                          urlToHit: 'https://twitter.com/exchangeseva'),
                      context: context,
                    );
                  },
                ),
                IconButton(
                  icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Finstagram-symbol.png?alt=media&token=7e08d6c7-00a6-4187-a2ff-a0883c13f1ac',
                    width: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    navigateToWebView(
                      aboutMode: AboutMode(
                          title: 'Instagram',
                          urlToHit: 'https://www.instagram.com/sevaexchange/'),
                      context: context,
                    );
                  },
                ),
              ],
            ),
            Text(
              '© Seva Exchange Corporation',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextButton button(
    String text,
    VoidCallback onTap,
  ) {
    return TextButton(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: onTap,
    );
  }

  Function getOnTap(BuildContext context, String title, String dynamicKey) {
    return () async {
      var dynamicLinks;
      dynamicLinks = json.decode(
        AppConfig.remoteConfig.getString(
          'links_${S.of(context).localeName ?? 'en'}',
        ),
      );
      log(dynamicLinks[dynamicKey]);
      navigateToWebView(
        aboutMode: AboutMode(title: title, urlToHit: dynamicLinks[dynamicKey]),
        context: context,
      );
    };
  }

  String getFooterDataTitle(
      {@required FooterData data, @required BuildContext context}) {
    switch (data) {
      case FooterData.About_Us:
        return S.of(context).help_about_us;
      case FooterData.Careers:
        return S.of(context).careers_explore;
      case FooterData.Communities:
        return S.of(context).communities_explore;
      case FooterData.Create_offer:
        return S.of(context).create_offer;
      case FooterData.Create_request:
        return S.of(context).create_request;
      case FooterData.Discover:
        return S.of(context).discover_explore;
      case FooterData.Diversity_Belonging:
        return S.of(context).diversity_belonging_explore;
      case FooterData.Events:
        return S.of(context).projects;
      case FooterData.Guidebooks:
        return S.of(context).guidebooks_explore;
      case FooterData.Help:
        return S.of(context).help;
      case FooterData.Hosting:
        return S.of(context).hosting_explore;
      case FooterData.Host_community:
        return S.of(context).host_a_community_explore;
      case FooterData.Organize_event:
        return S.of(context).organize_an_event_explore;
      case FooterData.Policies:
        return S.of(context).policies_explore;
      case FooterData.Press:
        return S.of(context).news_explore;
      case FooterData.Offers:
        return S.of(context).offers;
      case FooterData.Trust_Safety:
        return S.of(context).trust_and_safety_explore;
      case FooterData.SevaX:
        return 'SevaX';
      case FooterData.Requests:
        return S.of(context).requests;
      case FooterData.EMPTY:
        return '';
      default:
        return '';
    }
  }

  Function openUrl(
      {@required FooterData data, @required BuildContext context}) {
    switch (data) {
      case FooterData.About_Us:
        return getOnTap(context, S.of(context).help_about_us, 'aboutUsLink');

      case FooterData.Careers:
        return getOnTap(context, S.of(context).careers_explore, 'careersLink');
      case FooterData.Communities:
        return getOnTap(
            context, S.of(context).communities_explore, 'aboutSeva');

      case FooterData.Diversity_Belonging:
        return getOnTap(context, S.of(context).diversity_belonging_explore,
            'diversityLink');

      case FooterData.Events:
        return getOnTap(context, S.of(context).projects, 'projectsInfoLink');

      case FooterData.Create_offer:
        return getOnTap(context, S.of(context).create_offer, 'offersInfoLink');

      case FooterData.Create_request:
        return getOnTap(
            context, S.of(context).create_request, 'requestsInfoLink');

      case FooterData.Discover:
        return getOnTap(
            context, S.of(context).discover_explore, 'trainingVideo');

      case FooterData.Guidebooks:
        return getOnTap(
            context, S.of(context).guidebooks_explore, 'trainingVideo');

      case FooterData.Help:
        return getOnTap(
          context,
          S.of(context).help,
          "trainingVideo",
        );

      case FooterData.Hosting:
        return getOnTap(
            context, S.of(context).hosting_explore, 'hostingCommunity');

      case FooterData.Host_community:
        return getOnTap(context, S.of(context).host_a_community_explore,
            'hostingCommunity');

      case FooterData.Organize_event:
        return getOnTap(context, S.of(context).organize_an_event_explore,
            'projectsInfoLink');

      case FooterData.Policies:
        return getOnTap(
            context, S.of(context).policies_explore, 'privacyPolicyLink');

      case FooterData.Press:
        return getOnTap(context, S.of(context).news_explore, 'pressLink');

      case FooterData.Offers:
        return getOnTap(context, S.of(context).offers, 'offersInfoLink');

      case FooterData.Trust_Safety:
        return getOnTap(context, S.of(context).trust_and_safety_explore,
            'trustAndSafetyLink');

      case FooterData.SevaX:
        return getOnTap(context, 'SevaX', 'aboutSeva');

      case FooterData.Requests:
        return getOnTap(context, S.of(context).requests, 'requestsInfoLink');

      case FooterData.EMPTY:
        return () {};

      default:
        return () {};
    }
  }
}

enum FooterData {
  SevaX,
  Discover,
  Hosting,
  About_Us,
  Trust_Safety,
  Host_community,
  Careers,
  Requests,
  Create_offer,
  Press,
  Communities,
  Organize_event,
  Policies,
  Offers,
  Create_request,
  Help,
  Events,
  Diversity_Belonging,
  Guidebooks,
  EMPTY
}
