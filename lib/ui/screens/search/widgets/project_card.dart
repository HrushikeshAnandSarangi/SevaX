import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'network_image.dart';

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
  const ProjectsCard({
    Key key,
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
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(getLocation(location)),
                  Spacer(),
                  Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(timestamp),
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
                    child: CustomNetworkImage(photoUrl ?? defaultUserImageURL,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
//                          getInitials(title),
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              getTimeFormattedString(startTime),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              getTimeFormattedString(endTime),
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
                                text: "$tasks Tasks",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextSpan(text: "     "),
                              TextSpan(text: "$pendingTask Pending"),
                            ],
                          ),
                        )
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
    if (location != null) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        return "Unknown";
      }
    } else {
      return "Unknown";
    }
  }
}
