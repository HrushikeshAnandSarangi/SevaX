import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/report_info_card.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_chip.dart';

enum ACTIONS { REMOVE, MESSAGE }

class ReportedMemberInfo extends StatelessWidget {
  final ReportedMembersModel model;
  final bool isFromTimebank;
  final VoidCallback removeMember;
  final VoidCallback messageMember;

  const ReportedMemberInfo(
      {Key key,
      this.model,
      this.isFromTimebank,
      this.removeMember,
      this.messageMember})
      : assert(isFromTimebank != null),
        assert(model != null),
        super(key: key);

  static Route<dynamic> route({
    ReportedMembersModel model,
    bool isFromTimebank,
    VoidCallback removeMember,
    VoidCallback messageMember,
  }) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ReportedMemberInfo(
          model: model,
          isFromTimebank: isFromTimebank,
          removeMember: removeMember,
          messageMember: messageMember),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> reportCountsMap = countReports(model);
    List<String> keys = List.from(reportCountsMap.keys);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report of ${model.reportedUserName}",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              if (value == ACTIONS.MESSAGE) {
                messageMember();
              } else {
                removeMember();
                Navigator.of(context).pop();
              }
            },
            itemBuilder: (context) => <PopupMenuItem>[
              PopupMenuItem(
                child: Text("Message"),
                value: ACTIONS.MESSAGE,
              ),
              PopupMenuItem(
                child: Text("Remove"),
                value: ACTIONS.REMOVE,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            SizedBox(
              height: 35,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                itemCount: reportCountsMap.length,
                itemBuilder: (_, index) {
                  return ReportedMemberChip(
                    title: keys[index],
                    count: reportCountsMap[keys[index]],
                  );
                },
              ),
            ),
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: model.reports.length,
              itemBuilder: (context, index) {
                Report report = model.reports[index];
                return (isFromTimebank
                        ? true
                        : report.isTimebankReport == isFromTimebank)
                    ? ReportInfoCard(
                        report: report,
                        isFromTimebank: isFromTimebank,
                      )
                    : Container();
              },
              separatorBuilder: (_, index) {
                Report report = model.reports[index];
                return (isFromTimebank
                        ? true
                        : report.isTimebankReport == isFromTimebank)
                    ? Divider(
                        thickness: 1,
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, int> countReports(ReportedMembersModel model) {
  Map<String, int> map = {};
  model.reports.forEach((Report report) {
    if (map.containsKey(report.entityName)) {
      map[report.isTimebankReport ? "Timebank" : report.entityName] += 1;
    } else {
      map[report.isTimebankReport ? "Timebank" : report.entityName] = 1;
    }
  });
  return map;
}
