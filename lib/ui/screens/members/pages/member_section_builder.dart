import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/members/widgets/short_profile_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/timebanks/member_level.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';

class MemberSectionBuilder extends StatelessWidget {
  const MemberSectionBuilder({
    Key key,
    this.members,
    this.type,
    this.section,
    this.creatorId,
    this.isTimebankSection = false,
    this.timebank,
    this.progress,
  }) : super(key: key);

  final List<UserModel> members;
  final MemberType type;
  final UsersSection section;
  final String creatorId;
  final isTimebankSection;
  final TimebankModel timebank;
  final ProgressDialog progress;

  @override
  Widget build(BuildContext context) {
    log('role ${type.toString()}');
    log('section ${section.toString()}');
    final user = SevaCore.of(context).loggedInUser;
    final bloc = Provider.of<MembersBloc>(
      context,
      listen: false,
    );
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: members.length > 100 ? 200 : members.length,
      itemBuilder: (context, index) {
        UserModel member = members[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userModel: member,
                ),
              ),
            );
          },
          child: Row(
            children: [
              ShortProfileCard(
                model: member,
              ),
              Spacer(),
              //hide actions for creator
              creatorId != member.sevaUserID
                  ? Container(
                      child: section == UsersSection.OWNERS
                          ? Row(
                              children: [
                                type == MemberType.OWNER ||
                                        type == MemberType.CREATOR
                                    ? demote(
                                        context: context,
                                        user: user,
                                        bloc: bloc,
                                        member: member,
                                        timebankModel: timebank)
                                    : Container(),
                                donate(
                                    context: context,
                                    user: user,
                                    timebankModel: timebank,
                                    member: member),
                                type == MemberType.OWNER ||
                                        type == MemberType.CREATOR
                                    ? remove(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member)
                                    : Container(),
                              ],
                            )
                          : section == UsersSection.ADMINS
                              ? Row(
                                  children: [
                                    type == MemberType.OWNER ||
                                            type == MemberType.CREATOR
                                        ? promote(
                                            context: context,
                                            user: user,
                                            bloc: bloc,
                                            member: member,
                                            timebankModel: timebank)
                                        : Container(),
                                    demote(
                                        context: context,
                                        user: user,
                                        bloc: bloc,
                                        member: member,
                                        timebankModel: timebank),
                                    donate(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member),
                                    remove(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member),
                                  ],
                                )
                              : Row(
                                  children: [
                                    promote(
                                        context: context,
                                        user: user,
                                        bloc: bloc,
                                        member: member,
                                        timebankModel: timebank),
                                    donate(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member),
                                    remove(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member),
                                    exit(
                                        context: context,
                                        user: user,
                                        timebankModel: timebank,
                                        member: member),
                                  ],
                                ),
                    )

//              Row(
//                      children: [
//                        section == UsersSection.OWNERS ||
//                                section == UsersSection.ADMINS
//                            ?demote(context: context,user: user,bloc: bloc,member: member)
//                            : section == UsersSection.ADMINS ||
//                                    section == UsersSection.MEMBERS
//                                ? promote(context: context,user: user,bloc: bloc,member: member)
//                                : Container(),
//                        donate(context: context,user: user,timebankModel: timebank,member: member),
//                        remove(context: context,user: user,timebankModel: timebank,member: member),
//                        exit(context: context,user: user,timebankModel: timebank,member: member),
//                        //only a member can exit timebank
//                      ],
//                    )
                  : Container(),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) {
        return Divider(
          thickness: 0.5,
        );
      },
    );
  }

  Widget demote({
    BuildContext context,
    UserModel member,
    UserModel user,
    MembersBloc bloc,
    TimebankModel timebankModel,
  }) {
    return _hideUnAuthorizedWidgetFromUser(
      child: FlatButton.icon(
        textColor: Colors.black,
        icon: customImageAsset(
          '',
          // SevaWebAssetIcons.userIcon,
          color: Color(0xFFFE86C60),
        ),
        label: Text(S.of(context).demote),
        onPressed: () async {
          if (section == UsersSection.ADMINS) {
            bloc.demoteMember(
              member.sevaUserID,
              user.currentCommunity,
              timebank.id,
            );
          } else if (section == UsersSection.OWNERS) {
            await MembershipManager.updateOrganizerStatus(
              associatedName: SevaCore.of(context).loggedInUser.fullname,
              communityId: SevaCore.of(context).loggedInUser.currentCommunity,
              timebankId: timebankModel.id,
              notificationType: NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER,
              parentTimebankId: timebankModel.parentTimebankId,
              targetUserId: member.sevaUserID,
              timebankName: timebankModel.name,
              userEmail: member.email,
            );
          }
        },
      ),
      actionType: ActionType.DEMOTE,
      additionalCondition: member.sevaUserID != user.sevaUserID,
    );
  }

  Widget promote({
    BuildContext context,
    UserModel member,
    UserModel user,
    MembersBloc bloc,
    TimebankModel timebankModel,
  }) {
    return _hideUnAuthorizedWidgetFromUser(
      child: FlatButton.icon(
        textColor: Colors.black,
        icon: customImageAsset('SevaWebAssetIcons.userIcon',
            color: Theme.of(context).primaryColor),
        label: Text(section == UsersSection.MEMBERS
            ? S.of(context).promote
            : S.of(context).make_owner),
        onPressed: () async {
          if (section == UsersSection.MEMBERS) {
            bloc.promoteMember(
              member.sevaUserID,
              user.currentCommunity,
              timebank.id,
            );
          } else if (section == UsersSection.ADMINS) {
            await MembershipManager.updateOrganizerStatus(
              associatedName: SevaCore.of(context).loggedInUser.fullname,
              communityId: SevaCore.of(context).loggedInUser.currentCommunity,
              timebankId: timebank.id,
              notificationType: NotificationType.ADMIN_PROMOTED_AS_ORGANIZER,
              parentTimebankId: timebankModel.parentTimebankId,
              targetUserId: member.sevaUserID,
              timebankName: timebankModel.name,
              userEmail: member.email,
            );
          }
        },
      ),
      actionType: ActionType.PROMOTE,
      //can't promote or demote ourself
      additionalCondition: member.sevaUserID != user.sevaUserID,
    );
  }

  Widget donate({
    BuildContext context,
    UserModel member,
    UserModel user,
    TimebankModel timebankModel,
  }) {
    return _hideUnAuthorizedWidgetFromUser(
      child: FlatButton.icon(
        textColor: Colors.black,
        icon: customImageAsset('SevaWebAssetIcons.donate',
            color: Theme.of(context).primaryColor),
        label: Text(S.of(context).donate),
        onPressed: () async {
          await showFontSizePickerDialog(context, timebankModel, member);
        },
      ),
      actionType: ActionType.DONATE,
      //donation can't be made to self
      additionalCondition: member.sevaUserID != user.sevaUserID,
    );
  }

  Widget remove({
    BuildContext context,
    UserModel member,
    UserModel user,
    TimebankModel timebankModel,
  }) {
    return _hideUnAuthorizedWidgetFromUser(
      child: FlatButton.icon(
        textColor: Colors.black,
        icon: customImageAsset('SevaWebAssetIcons.delete'),
        label: Text(S.of(context).remove),
        onPressed: () async {
          if (await CustomDialogs.generalConfirmationDialogWithMessage(
            context,
            "${S.of(context).member_removal_confirmation} ${member.fullname}?",
          )) {
            progress.show();
            await removeMember(
              context: context,
              isFromExit: false,
              model: timebankModel,
              member: member,
            );
          }
        },
      ),
      actionType: ActionType.REMOVE,
      additionalCondition: member.sevaUserID != user.sevaUserID,
    );
  }

  Widget exit({
    BuildContext context,
    UserModel member,
    UserModel user,
    TimebankModel timebankModel,
  }) {
    return _hideUnAuthorizedWidgetFromUser(
      child: FlatButton.icon(
        textColor: Colors.black,
        icon: Icon(Icons.exit_to_app, color: Color(0xFFE86C60)),
        label: Text(S.of(context).exit),
        onPressed: () async {
          await exitFromTimebank(
            context: context,
            model: timebankModel,
            member: member,
          );
        },
      ),
      actionType: ActionType.EXIT,
      additionalCondition: member.sevaUserID == user.sevaUserID,
    );
  }

  void showFontSizePickerDialog(
      BuildContext context, TimebankModel timebankModel, UserModel user) async {
    ProgressDialog progressDialog = ProgressDialog(
      context,
      customBody: Container(
        height: 100,
        width: 100,
        child: LoadingIndicator(),
      ),
      isDismissible: false,
    );

    if (timebankModel.balance <= 0) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).insufficient_credits_to_donate),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
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
        donateAmount: donateAmount,
        maxAmount: timebankModel.balance.toDouble(),
      ),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      progressDialog.show();
      donateAmount = donateAmount_Received;
      timebankModel.balance = timebankModel.balance - donateAmount_Received;

      //from, to, timestamp, credits, isApproved, type, typeid, timebankid
      await TransactionBloc().createNewTransaction(
        timebankModel.id,
        user.sevaUserID,
        DateTime.now().millisecondsSinceEpoch,
        donateAmount,
        true,
        "ADMIN_DONATE_TOUSER",
        null,
        timebankModel.id,
        associatedCommunity: timebankModel.communityId,
      );
      progressDialog.hide();
      await showDialog<double>(
        context: context,
        builder: (context) => InputDonateSuccessDialog(
            onComplete: () => {Navigator.pop(context)}),
      );
    }
  }

  Future<void> exitFromTimebank({
    BuildContext context,
    TimebankModel model,
    UserModel member,
  }) async {
    bool isTimebank = model.parentTimebankId == FlavorConfig.values.timebankId;

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
    bool isTimebank = model.parentTimebankId == FlavorConfig.values.timebankId;
    Map<String, dynamic> responseData =
        await Provider.of<MembersBloc>(context, listen: false).removeMember(
      member.sevaUserID,
      model.id,
      isTimebank,
    );

    progress.hide();

    if (timebank.parentTimebankId == FlavorConfig.values.timebankId) {
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

  Widget customImageAsset(String image, {Color color}) {
    return Image.asset(image, color: color, height: 22, width: 22);
  }

  Widget _hideUnAuthorizedWidgetFromUser({
    bool additionalCondition = true,
    ActionType actionType,
    Widget child,
  }) {
    return actionPermission[type].contains(actionType) && additionalCondition
        ? child
        : Container();
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
                  "${responseData['PendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n"
                  "${S.of(context).clear_transaction}"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
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
        ExtendedNavigator.ofRouter<MembersRouter>().pushTransferOwnerShipView(
          timebankId: timebankModel.id,
          responseData: responseData,
          isComingFromExit: isFromExit ? true : false,
          memberSevaUserId: userModel.sevaUserID,
          memberName: userModel.fullname,
          memberPhotUrl: userModel.photoURL,
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

        ExtendedNavigator.ofRouter<HomePageRouter>().pop();
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
                FlatButton(
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
                FlatButton(
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
}
