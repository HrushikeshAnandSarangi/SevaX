import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/configuration_model.dart';
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

TimebankConfigurations getConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getFriendAndPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getNeighbourhoodPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getNonProfitConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getEnterpriseConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getCommunityPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getCommunityPlusPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}

TimebankConfigurations getGroupConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
    member: [
      "create_feeds",
      "accept_offers",
      "accept_requests",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_endorsed_group",
      "create_private_group"
    ],
    superAdmin: [
      "billing_access",
      "create_feeds",
      "accept_offers",
      "accept_requests",
      //"create_borrow_request",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      //"create_borrow_request",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group"
    ],
  );
}
