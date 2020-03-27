import 'package:flutter/material.dart';

import 'package:sevaexchange/ui/screens/search/widgets/group_card.dart';
import 'package:sevaexchange/ui/utils/strings.dart';

class GroupTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: <Widget>[
            Text(
              ExplorePageLabels.groupInfo,
              style: TextStyle(fontSize: 16),
            ),
            ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return GroupCard(
                  image:
                      "https://www.pandotrip.com/wp-content/uploads/2017/03/Hintersee-lake-2-740x485.jpg",
                  title: "Class Standard 6 Technology",
                  subtitle: "Chicago, Illionis 6700 members",
                  onPressed: () {},
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 2,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
