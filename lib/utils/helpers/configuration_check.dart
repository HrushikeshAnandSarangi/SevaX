import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/utils/app_config.dart';

class ConfigurationCheck extends StatelessWidget {
  final MemberType role;
  final String actionType;
  final Widget child;

  ConfigurationCheck({this.role, this.actionType, this.child});

  @override
  Widget build(BuildContext context) {
    return checkAllowedConfiguartions(role, actionType)
        ? child
        : InkWell(
            onTap: () {
              actionNotAllowedDialog(context);
            },
            child: AbsorbPointer(absorbing: true, child: child),
          );
  }

  static bool checkAllowedConfiguartions(MemberType role, String actionType) {
    TimebankConfigurations configurations = AppConfig.timebankConfigurations;
    switch (role) {
      case MemberType.MEMBER:
        return configurations.member != null &&
            configurations.member.contains(actionType);
      case MemberType.ADMIN:
        return configurations.admin != null &&
            configurations.admin.contains(actionType);
      case MemberType.SUPER_ADMIN:
        return configurations.superAdmin != null &&
            configurations.superAdmin.contains(actionType);

      case MemberType.CREATOR:
        return true;
    }
  }
}

MemberType memberType(TimebankModel model, String userId) {
  if (model.creatorId == userId) {
    return MemberType.CREATOR;
  } else if (model.admins.contains(userId)) {
    return MemberType.ADMIN;
  } else if (model.organizers.contains(userId)) {
    return MemberType.SUPER_ADMIN;
  } else {
    return MemberType.MEMBER;
  }
}

void actionNotAllowedDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(S.of(context).alert),
          content: Text(
              'This action is Restricted for you by owner the of the seva Community.'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                S.of(context).ok,
              ),
              textColor: Colors.deepOrange,
            )
          ],
        );
      });
}
