import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

extension ConfigurationCheckExtension on ConfigurationCheck {
  static String getIndividualOffertype(RequestType individualOfferType) {
    switch (individualOfferType) {
      case RequestType.CASH:
        return 'accept_money_offer';
      case RequestType.GOODS:
        return 'accept_goods_offer';
      case RequestType.TIME:
        return 'accept_time_offer';

      default:
        return 'accept_time_offer';
    }
  }

  static String getOfferAcceptanceKey(OfferModel offerModel) {
    if (offerModel.offerType == OfferType.INDIVIDUAL_OFFER)
      return getIndividualOffertype(offerModel.type);
    else
      return 'accept_one_to_many_offer';
  }
}

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
              log('role ${role}');
              logger.i("y22k" +
                  actionType +
                  " <<<<<<<<<<<<<< " +
                  AppConfig.timebankConfigurations.admin.toString());
              actionNotAllowedDialog(context);
            },
            child: AbsorbPointer(absorbing: true, child: child),
          );
  }

  static bool checkAllowedConfiguartions(MemberType role, String actionType) {
    TimebankConfigurations configurations =
        AppConfig.timebankConfigurations ?? getConfigurationModel();

    logger.d("y2k : " + configurations.admin.toString());

    switch (role) {
      case MemberType.CREATOR:
        return true;
      case MemberType.MEMBER:
        return configurations.member != null &&
            configurations.member.contains(actionType);
      case MemberType.ADMIN:
        logger.d(
          ">> | Admin Configuration : " + configurations.admin.toString(),
        );
        return configurations.admin != null &&
            configurations.admin.contains(actionType);
      case MemberType.SUPER_ADMIN:
        return configurations.superAdmin != null &&
            configurations.superAdmin.contains(actionType);
      default:
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
  } else if (model.members.contains(userId)) {
    return MemberType.MEMBER;
  }
}

void actionNotAllowedDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (dialogContext) {
        return permissionsAlertDialog(dialogContext);
      });
}

Widget permissionsAlertDialog(BuildContext context) {
  return AlertDialog(
    title: Text(S.of(context).alert),
    content: Text(
        "This action is restricted for you by the owner of this Seva Community."),
    actions: [
      CustomTextButton(
        shape: StadiumBorder(),
        color: Theme.of(context).accentColor,
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          S.of(context).ok,
          style: TextStyle(
            fontFamily: 'Europa',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        textColor: Colors.deepOrange,
      )
    ],
  );
}

TimebankConfigurations getConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
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
      "create_private_group",
      "one_to_many_offer",

      //offer
      "one_to_many_offer",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",
      //offer
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getFriendAndPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",

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
      "create_private_group",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",

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
      "create_private_group",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getNeighbourhoodPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_requests",
      "create_events",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "promote_user",
      "demote_user",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
      "accept_requests",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "create_virtual_request",
      "create_virtual_offer",
      "create_public_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_requests",
      "create_events",
      "create_time_offers",
      "create_time_request",
      "create_group",
      "promote_user",
      "demote_user",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getGroupConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_requests",
      "create_events",
      "create_goods_offers",
      "create_goods_request",
      "create_money_offers",
      "create_money_request",
      "create_time_offers",
      "create_time_request",
      "promote_user",
      "demote_user",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_endorsed_group",
      "create_private_group",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "billing_access",
      "create_feeds",
      "billing_access",

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
      "create_private_group",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getNonProfitConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getEnterpriseConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getCommunityPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getCommunityPlusPlanConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",

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
      "create_private_group",
      "one_to_many_offer",

      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}

TimebankConfigurations getPrivateConfigurationModel() {
  return TimebankConfigurations(
    admin: [
      "create_feeds",
      "billing_access",
      "accept_requests",
      "create_events",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
    member: [
      "create_feeds",
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
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
    ],
    superAdmin: [
      "create_feeds",
      "billing_access",
      "accept_requests",
      "create_events",
      "create_goods_offers",
      "create_money_offers",
      "create_time_offers",
      "create_time_request",
      "invite_bulk_members",
      "create_group",
      "promote_user",
      "demote_user",
      "create_onetomany_request",
      "create_virtual_request",
      "create_public_request",
      "create_virtual_offer",
      "create_public_offer",
      "create_virtual_event",
      "create_public_event",
      "create_private_group",
      "one_to_many_offer",
      "accept_one_to_many_offer",
      "accept_time_offer",
      "accept_goods_offer",
      "accept_money_offer"
    ],
  );
}
