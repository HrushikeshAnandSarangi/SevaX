import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
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
      case RequestType.LENDING_OFFER:
        return 'accept_lending_offers';

      default:
        return 'accept_time_offer';
    }
  }

  static String getOfferAcceptanceKey(OfferModel offerModel) {
    if (offerModel.offerType == OfferType.INDIVIDUAL_OFFER)
      return getIndividualOffertype(offerModel.type!);
    else
      return 'accept_one_to_many_offer';
  }
}

class ConfigurationCheck extends StatelessWidget {
  final MemberType? role;
  final String? actionType;
  final Widget? child;

  ConfigurationCheck({this.role, this.actionType, this.child});

  @override
  Widget build(BuildContext context) {
    // Provide default values if role or actionType is null
    final MemberType safeRole = role ?? MemberType.MEMBER;
    final String safeActionType = actionType ?? '';
    final Widget safeChild = child ?? SizedBox.shrink();

    return checkAllowedConfiguartions(safeRole, safeActionType)
        ? safeChild
        : InkWell(
            onTap: () {
              log('role $role');
              log('type $actionType');
              actionNotAllowedDialog(context);
            },
            child: AbsorbPointer(absorbing: true, child: safeChild),
          );
  }

  static bool checkAllowedConfiguartions(MemberType role, String actionType) {
    TimebankConfigurations configurations =
        AppConfig.timebankConfigurations ?? getConfigurationModel();
    switch (role) {
      case MemberType.CREATOR:
        return true;
      case MemberType.MEMBER:
        return configurations.member != null &&
            configurations.member!.contains(actionType);
      case MemberType.ADMIN:
        return configurations.admin != null &&
            configurations.admin!.contains(actionType);
      case MemberType.SUPER_ADMIN:
        return configurations.superAdmin != null &&
            configurations.superAdmin!.contains(actionType);
      default:
        return false;
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
          "${S.of(context).this_action_is_restricted_for_you_by_the_owner_of_this} Seva Community."),
      actions: [
        CustomTextButton(
          shape: StadiumBorder(),
          color: Theme.of(context).colorScheme.secondary,
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

  static TimebankConfigurations getConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",

        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_goods_offers",
        "create_borrow_request",
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
        "accept_lending_offers"
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",

        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getFriendAndPlanConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers",
      ],
      superAdmin: [
        "create_feeds",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getNeighbourhoodPlanConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_time_offers",
        "create_time_request",
        "create_group",
        "create_virtual_request",
        "create_virtual_offer",
        "create_public_offer",
        "accept_one_to_many_offer",
        "accept_lending_offers"
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getGroupConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers"
      ],
      superAdmin: [
        "billing_access",
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getNonProfitConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers"
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getEnterpriseConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers"
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers"
      ],
    );
  }

  TimebankConfigurations getCommunityPlanConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers",
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
    );
  }

  TimebankConfigurations getCommunityPlusPlanConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers",
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "create_borrow_request",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
    );
  }

  TimebankConfigurations getPrivateConfigurationModel() {
    return TimebankConfigurations(
      admin: [
        "create_feeds",
        "billing_access",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
      member: [
        "create_feeds",
        "create_borrow_request",
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
        "accept_lending_offers",
      ],
      superAdmin: [
        "create_feeds",
        "billing_access",
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
        "accept_money_offer",
        "accept_lending_offers",
      ],
    );
  }
}
