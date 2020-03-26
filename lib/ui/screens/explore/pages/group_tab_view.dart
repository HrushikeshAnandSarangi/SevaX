import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/group_card.dart';
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
                      "https://lh3.googleusercontent.com/proxy/QW6EdU3ubrUmfTHkcnX4yuuPusr9UYzHxrUJnWG6XnLidEKem-pqE4TGIJLywfFZI2Vt-t7mRrn74A_c0hLCoHwmCuNwAHe-NF453nOl4UERFFPkWagvZsiaiAEpCygPcgY",
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
