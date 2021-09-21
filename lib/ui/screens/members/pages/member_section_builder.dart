import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/members/dialogs/exit_confirmation_dialog.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/members/widgets/short_profile_card.dart';
import 'package:sevaexchange/ui/screens/upgrade_plan_banners/pages/upgrade_plan_banner.dart';
import 'package:sevaexchange/ui/utils/editDeleteIconWidget.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebanks/member_level.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/transfer_ownership_view.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';

class MemberSectionBuilder extends StatelessWidget {
  const MemberSectionBuilder(
      {Key key,
      this.members,
      this.type,
      this.section,
      this.creatorId,
      this.isTimebankSection = false,
      this.timebank,
      this.progress,
      this.onMemberExit})
      : super(key: key);

  final List<UserModel> members;
  final MemberType type;
  final UsersSection section;
  final String creatorId;
  final isTimebankSection;
  final TimebankModel timebank;
  final ProgressDialog progress;
  final VoidCallback onMemberExit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: members.length > 100 ? 200 : members.length,
      itemBuilder: (_context, index) {
        UserModel member = members[index];
        return member != null
            ? InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileViewer(
                        userEmail: member.email,
                        timebankId: timebank.id,
                        isFromTimebank: isPrimaryTimebank(
                            parentTimebankId: timebank.parentTimebankId),
                        entityName: timebank.name,
                      ),
                    ),
                  );
                },
                child: ShortProfileCard(
                  model: member,
                  actionButton: member.sevaUserID == creatorId
                      ? null // no actions on creator
                      : actionBuilder(context, member, section, type),
                ),
              )
            : Container();
      },
      separatorBuilder: (context, index) {
        UserModel member = members[index];
        return Offstage(
          offstage: member != null ? false : true,
          child: Divider(
            thickness: 0.5,
          ),
        );
      },
    );
  }

  Widget actionBuilder(BuildContext context, UserModel member,
      UsersSection section, MemberType type) {
    logger.i(type, section);
    List<PopupMenuItem<ActionType>> items = [];

    if (member.sevaUserID != SevaCore.of(context).loggedInUser.sevaUserID &&
        [MemberType.ADMIN, MemberType.SUPER_ADMIN, MemberType.CREATOR]
            .contains(type)) {
      items.add(
        PopupMenuItem(
          child: textAndImageIconWidget(
              "images/donate.png", S.of(context).donate, context),
          value: ActionType.DONATE,
        ),
      );
    }
    if (member.sevaUserID != SevaCore.of(context).loggedInUser.sevaUserID) {
      switch (section) {
        case UsersSection.OWNERS:
          if ([MemberType.CREATOR].contains(type)) {
            items.add(
              PopupMenuItem(
                child: textAndImageIconWidgetDemote("images/user_icon.png",
                    0xFFFE86C60, S.of(context).demote, context),
                //0xFFFE86C60 (red)
                value: ActionType.DEMOTE,
              ),
            );
          }
          break;
        case UsersSection.ADMINS:
          if ([MemberType.SUPER_ADMIN, MemberType.CREATOR].contains(type)) {
            items.add(
              PopupMenuItem(
                child: textAndImageIconWidget(
                    "images/user_icon.png", S.of(context).promote, context),
                value: ActionType.PROMOTE,
              ),
            );
          }
          if ([MemberType.SUPER_ADMIN, MemberType.CREATOR].contains(type)) {
            items.add(
              PopupMenuItem(
                child: textAndImageIconWidgetDemote("images/user_icon.png",
                    0xFFFE86C60, S.of(context).demote, context),
                value: ActionType.DEMOTE,
              ),
            );
          }

          break;
        case UsersSection.MEMBERS:
          if ([MemberType.ADMIN, MemberType.SUPER_ADMIN, MemberType.CREATOR]
              .contains(type)) {
            items.add(
              PopupMenuItem(
                child: textAndImageIconWidget(
                    "images/user_icon.png", S.of(context).promote, context),
                value: ActionType.PROMOTE,
              ),
            );
            items.add(
              PopupMenuItem(
                child: textAndImageIconWidget(
                    "images/delete.png", S.of(context).remove, context),
                value: ActionType.REMOVE,
              ),
            );
            break;
          }
      }
    } else {
      if (section == UsersSection.MEMBERS) {
        items.add(
          PopupMenuItem(
            child: textAndIconWidget(
                Icons.exit_to_app, S.of(context).exit, context),
            value: ActionType.EXIT,
          ),
        );
      }
    }

    return items.isNotEmpty
        ? PopupMenuButton<ActionType>(
            itemBuilder: (_) => items,
            onSelected: (value) async {
              switch (value) {
                case ActionType.PROMOTE:
                  if (section == UsersSection.ADMINS) {
                    if (TransactionsMatrixCheck.checkAllowedTransaction(
                        'multiple_super_admins')) {
                      if (ConfigurationCheck.checkAllowedConfiguartions(
                          type, 'promote_user')) {
                        await MembershipManager.updateOrganizerStatus(
                          associatedName:
                              SevaCore.of(context).loggedInUser.fullname,
                          communityId: SevaCore.of(context)
                              .loggedInUser
                              .currentCommunity,
                          timebankId: timebank.id,
                          notificationType:
                              NotificationType.ADMIN_PROMOTED_AS_ORGANIZER,
                          parentTimebankId: timebank.parentTimebankId,
                          targetUserId: member.sevaUserID,
                          timebankName: timebank.name,
                          userEmail: member.email,
                        );
                      } else {
                        actionNotAllowedDialog(context);
                      }
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => UpgradePlanBanner(
                            activePlanName:
                                AppConfig.paymentStatusMap['planId'],
                            details: AppConfig
                                .upgradePlanBannerModel.multiple_super_admins,
                          ),
                        ),
                      );
                    }
                  } else {
                    if (ConfigurationCheck.checkAllowedConfiguartions(
                        type, 'promote_user')) {
                      await MembershipManager.updateMembershipStatus(
                        associatedName:
                            SevaCore.of(context).loggedInUser.fullname,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity,
                        timebankId: timebank.id,
                        notificationType:
                            NotificationType.MEMBER_PROMOTED_AS_ADMIN,
                        parentTimebankId: timebank.parentTimebankId,
                        targetUserId: member.sevaUserID,
                        timebankName: timebank.name,
                        userEmail: member.email,
                      );
                    } else {
                      actionNotAllowedDialog(context);
                    }
                  }
                  break;
                case ActionType.DEMOTE:
                  if (ConfigurationCheck.checkAllowedConfiguartions(
                      type, 'demote_user')) {
                    if (section == UsersSection.OWNERS) {
                      await MembershipManager.updateOrganizerStatus(
                        associatedName:
                            SevaCore.of(context).loggedInUser.fullname,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity,
                        timebankId: timebank.id,
                        notificationType:
                            NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER,
                        parentTimebankId: timebank.parentTimebankId,
                        targetUserId: member.sevaUserID,
                        timebankName: timebank.name,
                        userEmail: member.email,
                      );
                    } else {
                      await MembershipManager.updateMembershipStatus(
                        associatedName:
                            SevaCore.of(context).loggedInUser.fullname,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity,
                        timebankId: timebank.id,
                        notificationType:
                            NotificationType.MEMBER_DEMOTED_FROM_ADMIN,
                        parentTimebankId: timebank.parentTimebankId,
                        targetUserId: member.sevaUserID,
                        timebankName: timebank.name,
                        userEmail: member.email,
                      );
                    }
                  } else {
                    actionNotAllowedDialog(context);
                  }
                  break;
                case ActionType.DONATE:
                  _showFontSizePickerDialog(context, member, timebank);
                  break;
                case ActionType.REMOVE:
                  if (await CustomDialogs.generalConfirmationDialogWithMessage(
                    context,
                    "${S.of(context).member_removal_confirmation} ${member.fullname}?",
                  )) {
                    progress.show();
                    await removeMember(
                      context: context,
                      isFromExit: false,
                      model: timebank,
                      member: member,
                    );
                  }

                  break;
                case ActionType.EXIT:
                  await exitFromTimebank(
                    context: context,
                    model: timebank,
                    member: member,
                  );

                  break;
              }
            },
          )
        : null;
  }

  Future<void> exitFromTimebank({
    BuildContext context,
    TimebankModel model,
    UserModel member,
  }) async {
    bool isTimebank =
        isPrimaryTimebank(parentTimebankId: model.parentTimebankId);

    String reason = await exitTimebankOrGroup(
      context: context,
      title:
          '${S.of(context).exit} ${isTimebank ? S.of(context).timebank : S.of(context).group}',
    );

    if (reason != null) {
      progress.show();
      await removeMember(
        context: context,
        model: model,
        member: member,
        isFromExit: true,
        reason: reason,
      );
    }
  }

  void removeMember({
    BuildContext context,
    TimebankModel model,
    UserModel member,
    String reason,
    bool isFromExit,
  }) async {
    bool isTimebank =
        isPrimaryTimebank(parentTimebankId: model.parentTimebankId);
    Map<String, dynamic> responseData =
        await Provider.of<MembersBloc>(context, listen: false).removeMember(
      member.sevaUserID,
      model.id,
      isTimebank,
    );

    if (isFromExit) {
      await CollectionRef.timebank
          .doc(model.id)
          .collection('entryExitLogs')
          .doc()
          .set({
        'mode': ExitJoinType.EXIT.readable,
        'modeType': ExitMode.LEFT_THE_COMMUNITY.readable,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'communityId': member.currentCommunity,
        'isGroup': model.parentTimebankId == FlavorConfig.values.timebankId
            ? false
            : true,
        'memberDetails': {
          'email': member.email,
          'id': member.sevaUserID,
          'fullName': member.fullname,
          'photoUrl': member.photoURL,
        },
        'adminDetails': {
          'email': SevaCore.of(context).loggedInUser.email,
          'id': SevaCore.of(context).loggedInUser.sevaUserID,
          'fullName': SevaCore.of(context).loggedInUser.fullname,
          'photoUrl': SevaCore.of(context).loggedInUser.photoURL,
        },
        'associatedTimebankDetails': {
          'timebankId': model.id,
          'timebankTitle': model.name,
        },
      });
    }

    if (!isFromExit && responseData['deletable'] == true) {
      await CollectionRef.timebank
          .doc(timebank.id)
          .collection('entryExitLogs')
          .doc()
          .set({
        'mode': ExitJoinType.EXIT.readable,
        'modeType': ExitMode.REMOVED_BY_ADMIN.readable,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'communityId': member.currentCommunity,
        'isGroup': model.parentTimebankId == FlavorConfig.values.timebankId
            ? false
            : true,
        'memberDetails': {
          'email': member.email,
          'id': member.sevaUserID,
          'fullName': member.fullname,
          'photoUrl': member.photoURL,
        },
        'adminDetails': {
          'email': SevaCore.of(context).loggedInUser.email,
          'id': SevaCore.of(context).loggedInUser.sevaUserID,
          'fullName': SevaCore.of(context).loggedInUser.fullname,
          'photoUrl': SevaCore.of(context).loggedInUser.photoURL,
        },
        'associatedTimebankDetails': {
          'timebankId': model.id,
          'timebankTitle': model.name,
        },
      });
    }
    progress.hide();

    if (isTimebank) {
      await removeMemberTimebankFn(
        context: context,
        responseData: responseData,
        userModel: member,
        isFromExit: isFromExit,
        timebankModel: model,
        reason: reason,
      );
    } else {
      await removeMemberGroupFn(
        context: context,
        responseData: responseData,
        userModel: member,
        isFromExit: isFromExit,
        timebankModel: model,
        reason: reason,
      );
    }
  }

  void removeMemberTimebankFn({
    BuildContext context,
    UserModel userModel,
    TimebankModel timebankModel,
    bool isFromExit,
    String reason,
    Map<String, dynamic> responseData,
  }) async {
    if (responseData['deletable'] == true) {
      if (isFromExit) {
        await NotificationsRepository.sendUserExitNotificationToAdmin(
          user: userModel,
          timebank: timebankModel,
          communityId: userModel.currentCommunity,
          reason: reason,
        );

        onMemberExit();

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SwitchTimebank(),
        //   ),
        // );
      }
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(
                  "${isFromExit ? "You" : "User"} ${isFromExit ? S.of(context).cant_exit_timebank : "cannot be removed from this seva community"}"),
              content: Text("${isFromExit ? "You" : "User"} have \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n"
                  "${S.of(context).clear_transaction}"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                CustomTextButton(
                  child: Text(S.of(context).close),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (responseData['softDeleteCheck'] == true &&
          responseData['groupOwnershipCheck'] == false) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransferOwnerShipView(
              timebankId: timebankModel.id,
              responseData: responseData,
              isComingFromExit: isFromExit ? true : false,
              memberSevaUserId: userModel.sevaUserID,
              memberName: userModel.fullname,
              memberPhotUrl: userModel.photoURL,
              memberEmail: userModel.email,
            ),
          ),
        );
      }
    }
  }

  void removeMemberGroupFn(
      {BuildContext context,
      UserModel userModel,
      TimebankModel timebankModel,
      bool isFromExit,
      String reason,
      Map<String, dynamic> responseData}) async {
    if (responseData['deletable'] == true) {
      if (isFromExit) {
        await NotificationsRepository.sendUserExitNotificationToAdmin(
          user: userModel,
          timebank: timebankModel,
          communityId: userModel.currentCommunity,
          reason: reason,
        );
        onMemberExit();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SwitchTimebank(),
        //   ),
        // );
      }
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(S.of(context).cant_exit_group),
              content: Text("${S.of(context).you_have} \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n "
                  "${S.of(context).clear_transaction} "),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                CustomTextButton(
                  child: Text(S.of(context).cancel),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (responseData['softDeleteCheck'] == true &&
          responseData['groupOwnershipCheck'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: Text(S.of(context).remove_self_from_group_error),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                CustomTextButton(
                  child: Text(S.of(context).close),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showFontSizePickerDialog(
      BuildContext context, UserModel user, TimebankModel model) async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (timebank.balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).insufficient_credits_to_donate),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    // <-- note the async keyword here
    double donateAmount = 0;
//     this will contain the result from Navigator.pop(context, result)
    final donateAmount_Received = await showDialog<double>(
      context: context,
      builder: (context) => InputDonateDialog(
          donateAmount: donateAmount, maxAmount: timebank.balance.toDouble()),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      donateAmount = donateAmount_Received;
      timebank.balance = timebank.balance - donateAmount_Received;

      //from, to, timestamp, credits, isApproved, type, typeid, timebankid
      await TransactionBloc().createNewTransaction(
          model.id,
          user.sevaUserID,
          DateTime.now().millisecondsSinceEpoch,
          donateAmount,
          true,
          "ADMIN_DONATE_TOUSER",
          null,
          model.id,
          communityId: model.communityId,
          fromEmailORId: model.id,
          toEmailORId: user.email);
      await showDialog<double>(
        context: context,
        builder: (context) => InputDonateSuccessDialog(
            onComplete: () => {Navigator.pop(context)}),
      );
    }
  }
}
