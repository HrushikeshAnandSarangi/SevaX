import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/widgets/tag_view.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProjectsCard extends StatelessWidget {
  final String location;
  final int timestamp;
  final String photoUrl;
  final String title;
  final String description;
  final int startTime;
  final int endTime;
  final int tasks;
  final int pendingTask;
  final Function onTap;
  final bool isRecurring;
  const ProjectsCard({
    Key key,
    this.isRecurring,
    this.location,
    this.timestamp,
    this.photoUrl,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.tasks,
    this.pendingTask,
    this.onTap,
  })  : assert(timestamp != null),
        assert(startTime != null),
        assert(endTime != null),
        assert(title != null),
        assert(description != null),
        assert(tasks != null),
        assert(pendingTask != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var projectLocation = getLocation(location);
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  projectLocation != null
                      ? Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                        )
                      : Container(),
                  projectLocation != null ? Text(projectLocation) : Container(),
                  Spacer(),
                  Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(timestamp),
                      locale: S.of(context).localeName == 'sn'
                          ? 'en'
                          : S.of(context).localeName,
                    ),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage:
                        NetworkImage(photoUrl ?? defaultProjectImageURL),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Visibility(
                          visible: isRecurring ?? false,
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: TagView(
                              tagTitle: 'Recurring',
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              getTimeFormattedString(
                                startTime,
                                S.of(context).localeName,
                              ),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.remove,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 2),
                            Text(
                              getTimeFormattedString(
                                endTime,
                                S.of(context).localeName,
                              ),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Text(
                          description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            children: [
                              TextSpan(
                                text: "$tasks ${S.of(context).tasks}",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextSpan(text: "     "),
                              TextSpan(
                                text: "$pendingTask ${S.of(context).pending}",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getLocation(String location) {
    if (location != null && location.length > 1) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}
