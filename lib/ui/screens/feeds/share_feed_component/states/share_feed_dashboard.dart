import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/bloc/share_feed_bloc_component.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_search_component.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/utils/share_feeds_component.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ShareDashboard extends StatelessWidget {
  final NewsModel? feedToShare;
  final PageController? pageController;
  final SearchSegmentBloc? searchSegmentBloc;
  final BuildContext? dialogContextReference;
  final UserModel? loggedInUser;

  const ShareDashboard({
    Key? key,
    this.pageController,
    this.feedToShare,
    this.searchSegmentBloc,
    this.dialogContextReference,
    this.loggedInUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var associatedImage = feedToShare?.imageScraped != null &&
            feedToShare?.imageScraped != 'NoData'
        ? feedToShare?.imageScraped
        : feedToShare?.newsImageUrl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  pageController?.animateToPage(
                    1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                  size: 24.0,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 12,
                  bottom: 12,
                ),
                child: Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomCloseButton(
                onCleared: () {
                  if (dialogContextReference != null) {
                    Navigator.pop(dialogContextReference!);
                  }
                },
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  height: 1,
                  color: HexColor('#ECEDF1'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        height: 45,
                        width: 45,
                        child: ProfileImage(
                          image: feedToShare?.userPhotoURL ?? '',
                          tag: feedToShare?.fullName ?? 'Unknown',
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        margin: EdgeInsets.only(left: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feedToShare?.fullName ?? '',
                              style: TextStyle(
                                color: HexColor('#4A4A4A'),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: HexColor('#4A4A4A'),
                                  size: 15.0,
                                ),
                                Flexible(
                                  child: Text(
                                    feedToShare?.placeAddress ?? '',
                                    // 'California',
                                    style: TextStyle(
                                      color: HexColor('#9B9B9B'),
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  feedToShare?.title ?? feedToShare?.subheading ?? '',
                  style: TextStyle(
                    color: HexColor('#9B9B9B'),
                    fontSize: 14,
                  ),
                ),
                associatedImage != null
                    ? Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Image.network(
                          associatedImage,
                        ),
                      )
                    : Center(
                        child: Container(
                          height: 180,
                        ),
                      ),
              ]),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            width: double.infinity,
            child: CustomTextButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                if (searchSegmentBloc == null) return;
                var listOfSelectedMembers =
                    searchSegmentBloc!.getSelectedUsersForShare();
                if (listOfSelectedMembers.length > 0) {
                  pageController?.animateToPage(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                  if (loggedInUser?.currentCommunity != null &&
                      feedToShare?.id != null) {
                    await ShareMessageManager()
                        .assembleMembersDataForSharingFeed(
                      communityId: loggedInUser!.currentCommunity!,
                      sender: loggedInUser!,
                      selectedMembers: listOfSelectedMembers,
                      messageContent: feedToShare!.id!,
                    );

                    Future.delayed(const Duration(milliseconds: 1000), () {
                      if (dialogContextReference != null) {
                        Navigator.pop(dialogContextReference!);
                      }
                    });
                  }
                } else {
                  pageController?.animateToPage(
                    1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                }
              },
              child: Text(
                S.of(context).share_post_new,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
