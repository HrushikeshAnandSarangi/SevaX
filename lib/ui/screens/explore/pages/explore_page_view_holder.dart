import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_app_bar.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/sevax_footer.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExplorePageViewHolder extends StatelessWidget {
  final Widget child;
  final bool hideHeader;
  final bool hideFooter;
  final bool hideSearchBar;
  final String? appBarTitle;
  final ValueChanged<String>? onSearchChanged;
  final EdgeInsets? childPadding;
  final TextEditingController? controller;
  final ScrollController? scrollController;

  const ExplorePageViewHolder({
    Key? key,
    required this.child,
    this.hideSearchBar = false,
    this.hideHeader = false,
    this.hideFooter = false,
    this.onSearchChanged,
    this.childPadding,
    this.controller,
    this.appBarTitle,
    this.scrollController,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideHeader && appBarTitle != null
          ? AppBar(
              title: Text(
                appBarTitle!,
                style: const TextStyle(fontSize: 18),
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
              secondChild: Container(height: 30),
            ),
            HideWidget(
              hide: !hideHeader,
              child: SizedBox(height: 12),
              secondChild: const SizedBox.shrink(),
            ),
            Padding(
              padding:
                  childPadding ?? const EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
            SizedBox(
              height: 30,
            ),
            SevaExploreFooter(
              footerColor: hideFooter,
            ),
          ],
        ),
      ),
    );
  }
}
