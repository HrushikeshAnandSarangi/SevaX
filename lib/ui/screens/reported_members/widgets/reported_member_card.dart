import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_info.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/transfer_ownership_view.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ReportedMemberCard extends StatelessWidget {
  final ReportedMembersModel? model;
  final TimebankModel? timebankModel;
  final bool? isFromTimebank;
  const ReportedMemberCard(
      {Key? key, this.model, this.isFromTimebank, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool canRemove = !(isPrimaryTimebank(
            parentTimebankId: timebankModel!.parentTimebankId) &&
        timebankModel!.creatorId == model!.reportedId);
    int userCount = reportedByCount(model!, isFromTimebank!);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          ReportedMemberInfo.route(
            model: model!,
            isFromTimebank: isFromTimebank!,
            removeMember: () => isFromTimebank!
                ? removeMemberTimebankFn(
                    context,
                    SevaCore.of(context).loggedInUser.email!,
                    SevaCore.of(context).loggedInUser.sevaUserID!,
                    SevaCore.of(context).loggedInUser.fullname!,
                    SevaCore.of(context).loggedInUser.photoURL!,
                    timebankModel!.name,
                    timebankModel!.id)
                : removeMemberGroupFn(context),
            canRemove: canRemove,
            messageMember: () => messageMember(
              context: context,
              timebankModel: timebankModel!,
              communityId: model!.communityId!,
              model: model!,
            ),
          ),
        );
      },
      child: Card(
        color: Color(0xFF0FAFAFA),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (timebankModel != null) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ProfileViewer(
                        timebankId: timebankModel!.id,
                        entityName: timebankModel!.name,
                        isFromTimebank: isPrimaryTimebank(
                            parentTimebankId: timebankModel!.parentTimebankId),
                        userEmail: model!.reportedUserEmail,
                      );
                    }));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    child: Offstage(
                      offstage: model!.reportedUserImage != null,
                      child: CustomAvatar(
                          radius: 30,
                          name: model!.reportedUserName,
                          onTap: () {}),
                    ),
                    backgroundImage: CachedNetworkImageProvider(
                        model!.reportedUserImage ?? ''),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model!.reportedUserName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${S.of(context).reported_by} $userCount ${S.of(context).user(userCount)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        // color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                  ),
                  child: Image.asset(
                    messageIcon,
                    width: 22,
                    height: 22,
                  ),
                ),
                onTap: () => messageMember(
                  context: context,
                  timebankModel: timebankModel!,
                  communityId: model!.communityId!,
                  model: model!,
                ),
              ),
              SizedBox(width: 16),
              Visibility(
                visible: canRemove,
                child: GestureDetector(
                  child: Image.asset(
                    removeUserIcon,
                    width: 22,
                    height: 22,
                  ),
                  onTap: () {
                    progressDialog = ProgressDialog(
                      context,
                      type: ProgressDialogType.normal,
                      isDismissible: false,
                    );
                    progressDialog!.show();

                    isFromTimebank!
                        ? removeMemberTimebankFn(
                            context,
                            SevaCore.of(context).loggedInUser.email!,
                            SevaCore.of(context).loggedInUser.sevaUserID!,
                            SevaCore.of(context).loggedInUser.fullname!,
                            SevaCore.of(context).loggedInUser.photoURL!,
                            timebankModel!.name,
                            timebankModel!.id)
                        : removeMemberGroupFn(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int reportedByCount(ReportedMembersModel model, bool isFromTimebank) {
    if (isFromTimebank) {
      return model.reporterIds!.length;
    } else {
      int count = 0;
      model.reports!.forEach((Report report) {
        if (report.isTimebankReport == isFromTimebank) {
          count++;
        }
      });
      return count;
    }
  }

  void messageMember({
    required BuildContext context,
    required TimebankModel timebankModel,
    required String communityId,
    required ReportedMembersModel model,
  }) {
    ParticipantInfo reciever = ParticipantInfo(
      id: model.reportedId,
      name: model.reportedUserName,
      photoUrl: model.reportedUserImage,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo sender = ParticipantInfo(
      id: timebankModel.id,
      name: timebankModel.name,
      photoUrl: timebankModel.photoUrl,
      type: ChatType.TYPE_TIMEBANK,
    );
    createAndOpenChat(
      context: context,
      timebankId: timebankModel.id,
      sender: sender,
      reciever: reciever,
      communityId: model.communityId!,
      isTimebankMessage: true,
      feedId: '',
      onChatCreate: () {},
      showToCommunities: [],
      entityId: timebankModel.id,
    );
  }

  void removeMemberGroupFn(BuildContext context) async {
    log(S.of(context).remove_member);
    Map<String, dynamic> responseData = await removeMemberFromGroup(
        sevauserid: model!.reportedId, groupId: timebankModel!.id);
    progressDialog!.hide();

    if (responseData['deletable'] == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: Text(S.of(context).user_removed_from_group),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              CustomTextButton(
                child: Text(S.of(context).close),
                textColor: Colors.red,
                onPressed: () async {
                  await CollectionRef.reportedUsersList
                      .doc(model!.reportedId! + "*" + model!.communityId!)
                      .delete();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(S.of(context).user_removed_from_group_failed),
              content: Text("${S.of(context).user_has} \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n "
                  "${S.of(context).clear_transaction} "),
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

  void removeMemberTimebankFn(
      BuildContext context,
      String adminEmail,
      String adminId,
      String adminName,
      String adminPhoto,
      String timebankTitle,
      String timebankId) async {
    Map<String, dynamic> responseData = await removeMemberFromTimebank(
        sevauserid: model!.reportedId, timebankId: timebankModel!.id);
    progressDialog?.hide();

    if (responseData['deletable'] == true) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: Text(S.of(context).user_removed_from_timebank),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              CustomTextButton(
                child: Text(S.of(context).close),
                onPressed: () async {
                  await CollectionRef.reportedUsersList
                      .doc(model!.reportedId! + "*" + model!.communityId!)
                      .delete();

                  await CollectionRef.timebank
                      .doc(timebankId)
                      .collection('entryExitLogs')
                      .doc()
                      .set({
                    'mode': ExitJoinType.EXIT.readable,
                    'modeType': ExitMode.REPORTED_IN_COMMUNITY.readable,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                    'communityId': model!.communityId,
                    'isGroup': timebankModel!.parentTimebankId ==
                            FlavorConfig.values.timebankId
                        ? false
                        : true,
                    'memberDetails': {
                      'email': model!.reportedUserEmail!,
                      'id': model!.reportedId,
                      'fullName': model!.reportedUserName,
                      'photoUrl': model!.reportedUserImage,
                    },
                    'adminDetails': {
                      'email': adminEmail,
                      'id': adminId,
                      'fullName': adminName,
                      'photoUrl': adminPhoto,
                    },
                    'associatedTimebankDetails': {
                      'timebankId': timebankId,
                      'timebankTitle': timebankTitle,
                    },
                  });

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(S.of(context).user_removed_from_timebank_failed),
              content: Text("${S.of(context).user_has} \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n "
                  "${S.of(context).clear_transaction} "),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferOwnerShipView(
              timebankId: timebankModel!.id,
              responseData: responseData,
              memberName: model!.reportedUserName!,
              memberSevaUserId: model!.reportedId!,
              memberPhotUrl: model!.reportedUserImage!,
              memberEmail: model!.reportedUserEmail!,
              isComingFromExit: false,
            ),
          ),
        );
      }
    }
  }
}
