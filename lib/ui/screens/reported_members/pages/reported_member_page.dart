import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/bloc/reported_member_bloc.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_card.dart';

class ReportedMembersPage extends StatefulWidget {
  final String timebankId;
  final String communityId;
  final bool isFromTimebank;

  const ReportedMembersPage(
      {Key key, this.timebankId, this.communityId, this.isFromTimebank})
      : super(key: key);

  static Route<dynamic> route(
      {String timebankId, String communityId, bool isFromTimebank}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ReportedMembersPage(
          timebankId: timebankId,
          communityId: communityId,
          isFromTimebank: isFromTimebank),
    );
  }

  @override
  _ReportedMembersPageState createState() => _ReportedMembersPageState();
}

class _ReportedMembersPageState extends State<ReportedMembersPage> {
  final ReportedMembersBloc _bloc = ReportedMembersBloc();

  @override
  void initState() {
    _bloc.fetchReportedMembers(
      widget.timebankId,
      widget.communityId,
      widget.isFromTimebank,
    );
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reported Members',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        child: StreamBuilder<List<ReportedMembersModel>>(
          stream: _bloc.reportedMembers,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.data == null || snapshot.data.isEmpty) {
              return Text("No data");
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
                return ReportedMemberCard(
                  model: snapshot.data[index],
                  isFromTimebank: widget.isFromTimebank,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
