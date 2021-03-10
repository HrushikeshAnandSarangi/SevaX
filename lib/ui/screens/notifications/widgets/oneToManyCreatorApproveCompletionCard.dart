import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class OneToManyCreatorApproveCompletionCard extends StatelessWidget {
  final VoidCallback onPressedAccept;
  final VoidCallback onPressedReject;
  final Function onDismissed;
  final String photoUrl;
  final String creatorName;
  final String title;
  //final String subTitle;
  final bool isDissmissible;
  final String entityName;
  final int timestamp;

  const OneToManyCreatorApproveCompletionCard({
    Key key,
    this.onPressedAccept,
    this.onPressedReject,
    this.photoUrl,
    this.creatorName,
    this.title,
    //this.subTitle,
    this.onDismissed,
    this.entityName,
    this.isDissmissible = true,
    @required this.timestamp,
  })  : assert(title != null),
        assert(creatorName != null),
        assert(timestamp != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing:
          !isDissmissible && onPressedAccept == null && onPressedReject == null,
      child: Slidable(
        actionExtentRatio: 0.25,
        actions: isDissmissible
            ? <Widget>[
                IconSlideAction(
                  caption: S.of(context).delete,
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(
                            S.of(context).delete_notification,
                          ),
                          content: Text(
                            S.of(context).delete_notification_confirmation,
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () =>
                                  {Navigator.of(dialogContext).pop()},
                              child: Text(
                                S.of(context).cancel,
                              ),
                            ),
                            FlatButton(
                              onPressed: () async {
                                onDismissed();
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(
                                S.of(context).delete,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ]
            : [],
        delegate: SlidableDrawerDelegate(),
        child: Container(
          margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                spreadRadius: 2,
                blurRadius: 3,
              )
            ],
          ),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: creatorName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        TextSpan(text: title),
                      ],
                    ),
                  ),
                )
              ],
            ),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green[300],
                  size: 50,
                ),
                Icon(Icons.done, color: Colors.white, size: 30),
              ],
            ),
            //photoUrl != null
            //     ? CircleAvatar(
            //         radius: 22,
            //         backgroundImage: CachedNetworkImageProvider(photoUrl),
            //       )
            //     : CustomAvatar(
            //         radius: 22,
            //         name: entityName ?? " ",
            //       ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text(
                //   subTitle != null ? subTitle.trim() : '',
                //),
                SizedBox(height: 4),
                Text(
                  timeAgo.format(
                    DateTime.fromMillisecondsSinceEpoch(
                      timestamp,
                    ),
                    locale: S.of(context).localeName == 'sn'
                        ? 'en'
                        : S.of(context).localeName,
                  ),
                ),

                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    Container(
                      height: 32,
                      child: RaisedButton(
                        onPressed: onPressedAccept,
                        child: Text(
                          S.of(context).approve,
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    Container(
                      height: 32,
                      child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: onPressedReject,
                        child: Text(
                          S.of(context).reject,
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

              ],
            ),
            //onTap: () => onPressed != null ? onPressed() : null,
          ),
        ),
      ),
    );
  }
}
