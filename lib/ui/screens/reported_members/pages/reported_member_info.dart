import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/report_info_card.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_chip.dart';
import 'package:sevaexchange/ui/utils/editDeleteIconWidget.dart';

enum ACTIONS { REMOVE, MESSAGE }

class ReportedMemberInfo extends StatelessWidget {
  final ReportedMembersModel model;
  final bool isFromTimebank;
  final VoidCallback removeMember;
  final VoidCallback messageMember;
  final bool canRemove;

  const ReportedMemberInfo({
    Key? key,
    required this.model,
    required this.isFromTimebank,
    required this.removeMember,
    required this.messageMember,
    required this.canRemove,
  })  : assert(isFromTimebank != null),
        assert(model != null),
        assert(canRemove != null),
        super(key: key);

  static Route<dynamic> route({
    ReportedMembersModel? model,
    bool? isFromTimebank,
    VoidCallback? removeMember,
    VoidCallback? messageMember,
    bool? canRemove,
  }) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ReportedMemberInfo(
        model: model!,
        isFromTimebank: isFromTimebank!,
        removeMember: removeMember!,
        messageMember: messageMember!,
        canRemove: canRemove!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> reportCountsMap = countReports(model);
    List<String> keys = List.from(reportCountsMap.keys);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).report_of + "${model.reportedUserName}",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(onSelected: (value) {
            if (value == ACTIONS.MESSAGE) {
              messageMember();
            } else {
              removeMember();
              Navigator.of(context).pop();
            }
          }, itemBuilder: (context) {
            List<PopupMenuItem> items = [
              PopupMenuItem(
                child: messageIconTextWidget(
                    "images/icons/message.png", S.of(context).message, context),
                value: ACTIONS.MESSAGE,
              )
            ];

            if (canRemove) {
              items.add(
                PopupMenuItem(
                  child: textAndImageIconWidgetWithSize(
                      "images/icons/remove_user.png",
                      20,
                      S.of(context).remove,
                      context),
                  value: ACTIONS.REMOVE,
                ),
              );
            }
            return items;
          }),
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
              itemCount: model.reports!.length,
              itemBuilder: (context, index) {
                Report report = model.reports![index];
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
                Report report = model.reports![index];
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
  model.reports!.forEach((Report report) {
    String key =
        report.isTimebankReport! ? "Seva Community" : report.entityName!;
    map[key] = (map[key] ?? 0) + 1;
  });
  return map;
}
