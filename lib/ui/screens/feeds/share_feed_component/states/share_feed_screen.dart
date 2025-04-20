import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/bloc/share_feed_bloc_component.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_dashboard.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_loading_state.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_search_component.dart';
import 'package:sevaexchange/views/core.dart';

class ShareFeedsComponent extends StatefulWidget {
  final NewsModel? feedToShare;
  final String? timebankId;
  final SearchSegmentBloc? searchSegmentBloc;
  final UserModel? loggedInUser;

  const ShareFeedsComponent({
    Key? key,
    this.feedToShare,
    this.timebankId,
    this.searchSegmentBloc,
    this.loggedInUser,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ShareFeedsComponentState();
}

class ShareFeedsComponentState extends State<ShareFeedsComponent> {
  PageController pageController = PageController(
    initialPage: 1,
  );

  @override
  void initState() {
    super.initState();

    clearData();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.share_sharp,
        color: Colors.black,
      ),
      onPressed: () {
        clearData();

        showDialog(
          context: context,
          builder: (dialogContextReference) => Dialog(
            child: Container(
              width: 583,
              height: 639,
              child: PageView(
                controller: pageController,
                physics: new NeverScrollableScrollPhysics(),
                children: [
                  LoadingComponent(),
                  SearchComponent(
                    // timebankModel:
                    //     _homePageBaseBloc.getTimebankModelFromCurrentCommunity(
                    //   widget.timebankId,
                    // ),
                    loggedInUser: widget.loggedInUser!,
                    pageController: pageController,
                    searchSegmentBloc: widget.searchSegmentBloc!,
                  ),
                  ShareDashboard(
                    dialogContextReference: dialogContextReference,
                    feedToShare: widget.feedToShare,
                    pageController: pageController,
                    searchSegmentBloc: widget.searchSegmentBloc,
                    loggedInUser: widget.loggedInUser,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void clearData() {
    widget.searchSegmentBloc?.disposeSelectionsMade();
    widget.searchSegmentBloc?.selectedMembersForShare.clear();
  }
}
