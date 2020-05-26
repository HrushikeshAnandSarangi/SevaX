import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_info.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/views/messages/chatview.dart';

class ReportedMemberCard extends StatelessWidget {
  final ReportedMembersModel model;
  final String timebankId;
  final bool isFromTimebank;
  const ReportedMemberCard(
      {Key key, this.model, this.isFromTimebank, this.timebankId})
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
            removeMember: () => removeMember(),
            messageMember: () => messageMember(
              context: context,
              userEmail: model.reportedUserEmail,
              timebankId: timebankId,
              communityId: model.communityId,
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
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Image.asset(
                    messageIcon,
                    width: 22,
                    height: 22,
                  ),
                ),
                onTap: () => messageMember(
                  context: context,
                  userEmail: model.reportedUserEmail,
                  timebankId: timebankId,
                  communityId: model.communityId,
                ),
              ),
              SizedBox(width: 16),
              GestureDetector(
                child: Image.asset(
                  removeUserIcon,
                  width: 22,
                  height: 22,
                ),
                onTap: removeMember,
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
    @required String userEmail,
    @required String timebankId,
    @required String communityId,
  }) {
    log("message member");
    List users = [userEmail, timebankId];
    users.sort();
    ChatModel chatModel = ChatModel();
    chatModel.communityId = communityId;
    chatModel.user1 = users[0];
    chatModel.user2 = users[1];
    chatModel.timebankId = timebankId;
    createChat(chat: chatModel);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          useremail: userEmail,
          chatModel: chatModel,
        ),
      ),
    );
  }

  void removeMember() async {
    log("remove member");


  }
}
