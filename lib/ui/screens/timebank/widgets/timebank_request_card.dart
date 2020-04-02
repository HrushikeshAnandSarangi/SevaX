import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';

class TimebankRequestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String photoUrl;
  final int startTime;
  final int endTime;
  final bool isApplied;

  const TimebankRequestCard({
    Key key,
    this.title,
    this.subtitle,
    this.photoUrl,
    this.isApplied = false,
    this.startTime,
    this.endTime,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: ClipOval(
                child: SizedBox(
                  height: 45,
                  width: 45,
                  child: FadeInImage.assetNetwork(
                    placeholder: defaultUserImageURL,
                    image: photoUrl ?? defaultUserImageURL,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          getTimeFormattedString(startTime),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward, size: 14),
                        SizedBox(width: 4),
                        Text(
                          getTimeFormattedString(endTime),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        isApplied
                            ? Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                width: 100,
                                height: 32,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.all(0),
                                  color: Colors.green,
                                  child: Text(
                                    'Applied',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Offstage(
            //   offstage: !isApplied,
            //   child: RotatedBox(
            //     quarterTurns: 3,
            //     child: Container(
            //       color: Colors.green,
            //       child: Text("Applied"),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
