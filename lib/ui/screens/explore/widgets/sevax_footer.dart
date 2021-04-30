import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/language.dart';

class SevaExploreFooter extends StatelessWidget {
  final List<List<String>> footerData = [
    ["SevaX", "Discover", "Hosting"],
    ["About Us", "Trust & Safety", "Host a community"],
    ["Careers", "Requests", "Create a offer"],
    ["Press", "Communities", "Organize an event"],
    ["Policies", "Offers", "Create a request"],
    ["Help", "Events", ""],
    ["", "Guidebooks", ""],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 40,
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
                SizedBox(height: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      onChanged: (value) {},
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
                                      data,
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
                                onTap: () {
                                  logger.i(data);
                                },
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
                button('Terms', () {}),
                button('Privacy', () {}),
                button('Site Map', () {}),
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Ftwitter.png?alt=media&token=4246c0d2-6971-474a-9096-3ccb2a7649a3',
                    width: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Finstagram-symbol.png?alt=media&token=7e08d6c7-00a6-4187-a2ff-a0883c13f1ac',
                    width: 15,
                    color: Colors.white,
                  ),
                  onPressed: () {},
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
}
