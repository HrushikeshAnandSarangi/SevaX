import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/attachment_page.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ReportInfoCard extends StatelessWidget {
  final Report? report;
  final double? radius = 8;
  final bool? isFromTimebank;

  const ReportInfoCard({Key? key, this.report, this.isFromTimebank})
      : assert(report != null),
        assert(isFromTimebank != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                report!.reporterImage != null
                    ? CustomNetworkImage(
                        report!.reporterImage!,
                        fit: BoxFit.fitWidth,
                        size: 60,
                      )
                    : CustomAvatar(name: report!.reporterName),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 6),
                      Text(
                        report!.reporterName!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        report!.timestamp == null
                            ? "" //error message when timestamp is null
                            : timeAgo.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  report!.timestamp!,
                                ),
                                locale: Locale(AppConfig.prefs!
                                        .getString('language_code')!)
                                    .toLanguageTag()),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Offstage(
                        offstage: !isFromTimebank!,
                        child: Text(
                          'Reported within ${report!.isTimebankReport! ? "Seva Community" : "Group : ${report!.entityName}"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("${report!.message}"),
                      SizedBox(height: 20),
                      report!.attachment == null
                          ? Container()
                          : LayoutBuilder(
                              builder: (context, constraints) =>
                                  GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    Attachment.route(
                                      attachment: report!.attachment!,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: constraints.maxWidth / 2,
                                  child: CachedNetworkImage(
                                    imageUrl: report!.attachment!,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
