import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_app_bar.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/sevax_footer.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExplorePageViewHolder extends StatelessWidget {
  final Widget child;
  final bool hideHeader;
  final bool hideFooter;
  final bool hideSearchBar;
  final ValueChanged<String> onSearchChanged;
  final EdgeInsets childPadding;
  final TextEditingController controller;

  const ExplorePageViewHolder({
    Key key,
    this.child,
    this.hideSearchBar = false,
    this.hideHeader = false,
    this.hideFooter = false,
    this.onSearchChanged,
    this.childPadding,
    this.controller,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
            ),
            Padding(
              padding:
                  childPadding ?? const EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
            HideWidget(
              hide: hideFooter,
              child: SevaExploreFooter(),
            ),
          ],
        ),
      ),
    );
  }
}
