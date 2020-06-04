import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_info.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/views/timebanks/transfer_ownership_view.dart';

class ReportedMemberCard extends StatelessWidget {
  final ReportedMembersModel model;
  final TimebankModel timebankModel;
  final bool isFromTimebank;
  const ReportedMemberCard(
      {Key key, this.model, this.isFromTimebank, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    int userCount = reportedByCount(model, isFromTimebank);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          ReportedMemberInfo.route(
            model: model,
            isFromTimebank: isFromTimebank,
            removeMember: () => isFromTimebank
                ? removeMemberTimebankFn(context)
                : removeMemberGroupFn(context),
            messageMember: () => messageMember(
              context: context,
              timebankModel: timebankModel,
              communityId: model.communityId,
              model: model,
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  child: Offstage(
                    offstage: model.reportedUserImage != null,
                    child: CustomAvatar(
                      radius: 30,
                      name: model.reportedUserName,
                    ),
                  ),
                  backgroundImage:
                      CachedNetworkImageProvider(model.reportedUserImage ?? ''),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.reportedUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Reported by $userCount ${userCount == 1 ? "user" : "users"}",
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
                  timebankModel: timebankModel,
                  communityId: model.communityId,
                  model: model,
                ),
              ),
              SizedBox(width: 16),
              GestureDetector(
                child: Image.asset(
                  removeUserIcon,
                  width: 22,
                  height: 22,
                ),
                onTap: () => isFromTimebank
                    ? removeMemberTimebankFn(context)
                    : removeMemberGroupFn(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int reportedByCount(ReportedMembersModel model, bool isFromTimebank) {
    if (isFromTimebank) {
      return model.reporterIds.length;
    } else {
      int count = 0;
      model.reports.forEach((Report report) {
        if (report.isTimebankReport == isFromTimebank) {
          count++;
        }
      });
      return count;
    }
  }

  void messageMember({
    @required BuildContext context,
    @required TimebankModel timebankModel,
    @required String communityId,
    @required ReportedMembersModel model,
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
      communityId: model.communityId,
      isTimebankMessage: true,
    );
  }

  void removeMemberGroupFn(BuildContext context) async {
    log("remove member");
    Map<String, dynamic> responseData = await removeMemberFromGroup(
        sevauserid: model.reportedId, groupId: timebankModel.id);
    if (responseData['deletable'] == true) {
      await Firestore.instance
          .collection('reported_users_list').document(model.reportedId+"*"+model.communityId).delete();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: new Text("User is successfully removed from the group"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                textColor: Colors.red,
                onPressed: () {
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
              title: new Text("User cannot be deleted from this group"),
              content: new Text("User has \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} pending projects,\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} pending requests,\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} pending offers.\n "
                  "Please clear the transactions and try again. "),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
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
              content: new Text(
                  "Cannot remove yourself from the group. Instead, please try deleting the group."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
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

  void removeMemberTimebankFn(BuildContext context) async {
    print(model.reportedId + " removing member ongoing " + timebankModel.id);
    Map<String, dynamic> responseData = await removeMemberFromTimebank(
        sevauserid: model.reportedId, timebankId: timebankModel.id);
    print("reported members removal response is --- " +
        responseData['ownerGroupsArr'].toString());
    if (responseData['deletable'] == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: new Text("User is successfully removed from the timebank"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
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
              title: new Text("User cannot be deleted from this timebank"),
              content: new Text("User has \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} pending projects,\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} pending requests,\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} pending offers.\n "
                  "Please clear the transactions and try again. "),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
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
              timebankId: timebankModel.id,
              responseData: responseData,
              memberName: model.reportedUserName,
              memberSevaUserId: model.reportedId,
              memberPhotUrl: model.reportedUserImage,
              isComingFromExit: false,
            ),
          ),
        );
      }
    }
  }
}
