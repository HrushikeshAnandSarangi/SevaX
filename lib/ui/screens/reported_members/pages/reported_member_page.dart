import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/bloc/reported_member_bloc.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_card.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ReportedMembersPage extends StatefulWidget {
  final TimebankModel? timebankModel;
  final String? communityId;
  final bool? isFromTimebank;

  const ReportedMembersPage(
      {Key? key, this.timebankModel, this.communityId, this.isFromTimebank})
      : super(key: key);

  static Route<dynamic> route(
      {TimebankModel? timebankModel,
      String? communityId,
      bool? isFromTimebank}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ReportedMembersPage(
        timebankModel: timebankModel,
        communityId: communityId,
        isFromTimebank: isFromTimebank,
      ),
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
      widget.timebankModel!.id,
      widget.communityId!,
      widget.isFromTimebank!,
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
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).reported_members,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        child: StreamBuilder<List<ReportedMembersModel>>(
          stream: _bloc.reportedMembers,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Text(S.of(context).no_data));
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return ReportedMemberCard(
                  model: snapshot.data![index],
                  isFromTimebank: widget.isFromTimebank,
                  timebankModel: widget.timebankModel,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
