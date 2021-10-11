import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_app_bar.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/sevax_footer.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExplorePageViewHolder extends StatelessWidget {
  final Widget child;
  final bool hideHeader;
  final bool hideFooter;
  final bool hideSearchBar;
  final String appBarTitle;
  final ValueChanged<String> onSearchChanged;
  final EdgeInsets childPadding;
  final TextEditingController controller;
  final ScrollController scrollController;

  const ExplorePageViewHolder({
    Key key,
    this.child,
    this.hideSearchBar = false,
    this.hideHeader = false,
    this.hideFooter = false,
    this.onSearchChanged,
    this.childPadding,
    this.controller,
    this.appBarTitle,
    this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle != null && hideHeader
          ? AppBar(
              title: Text(
                appBarTitle,
                style: TextStyle(fontSize: 18),
              ),
            )
          : null,
      body: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            HideWidget(
              hide: hideHeader,
              child: ExplorePageAppBar(
                onSearchChanged: onSearchChanged,
                hideSearchBar: hideSearchBar,
                controller: controller,
              ),
              secondChild:
                  appBarTitle == null ? Container(height: 30) : Container(),
            ),
            HideWidget(
              hide: !hideHeader,
              child: SizedBox(height: 12),
            ),
            Padding(
              padding:
                  childPadding ?? const EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
            SizedBox(
              height: 30,
            ),
            SevaExploreFooter(footerColor: hideFooter,),
          ],
        ),
      ),
    );
  }
}
