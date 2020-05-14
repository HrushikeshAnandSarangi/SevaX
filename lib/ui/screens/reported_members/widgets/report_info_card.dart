import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/attachment_page.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';

class ReportInfoCard extends StatelessWidget {
  final Report report;
  final double radius = 8;

  const ReportInfoCard({Key key, this.report}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  report.reporterImage != null
                      ? CustomNetworkImage(
                          report.reporterImage,
                          fit: BoxFit.fitWidth,
                        )
                      : CustomAvatar(name: report.reporterName),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 6),
                        Text(
                          report.reporterName,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        Text("Reason: ${report.message}"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Offstage(
              offstage: report.attachment == null,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    Attachment.route(attachment: report.attachment),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      "View attachment",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
