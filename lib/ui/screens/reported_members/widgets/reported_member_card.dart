import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_info.dart';

class ReportedMemberCard extends StatelessWidget {
  final ReportedMembersModel model;
  const ReportedMemberCard({Key key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(model.reportedUserImage),
        ),
        title: Text(
          model.reportedUserName,
        ),
        trailing: Text(
          model.reporterId.length.toString(),
          style: TextStyle(color: Colors.red),
        ),
        onTap: () {
          Navigator.of(context).push(ReportedMemberInfo.route(
            model: model,
          ));
        },
      ),
    );
  }
}
