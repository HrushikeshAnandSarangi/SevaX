import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class HideBlockedContent extends StatelessWidget {
  const HideBlockedContent({
    Key? key,
    required this.creatorId,
    required this.child,
    this.additionalConditions = true,
  }) : super(key: key);

  final String creatorId;
  final bool additionalConditions;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return HideWidget(
      hide: checkIfBlocked(
            creatorId,
            SevaCore.of(context).loggedInUser,
          ) &&
          additionalConditions,
      child: child,
      secondChild: const SizedBox.shrink(),
    );
  }

  static bool checkIfBlocked(final String creatorId, final UserModel user) {
    try {
      return user.blockedBy?.contains(creatorId) == true ||
          user.blockedMembers?.contains(creatorId) == true;
    } catch (_) {
      return false;
    }
  }
}
