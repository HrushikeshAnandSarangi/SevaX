import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';

class NotificationCard extends StatelessWidget {
  final Function onPressed;
  final Function onDismissed;
  final String photoUrl;
  final String title;
  final String subTitle;
  final bool isDissmissible;
  final String entityName;

  const NotificationCard({
    Key key,
    this.onPressed,
    this.photoUrl,
    this.title,
    this.subTitle,
    this.onDismissed,
    this.entityName,
    this.isDissmissible = true,
  })  : assert(title != null),
        assert(subTitle != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isDissmissible,
      child: Slidable(
        actionExtentRatio: 0.25,
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text("Delete notification"),
                    content: Text(
                      "Are you sure you want to remove this notificaition.",
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => {Navigator.of(dialogContext).pop()},
                        child: Text(
                          "Cancel",
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          onDismissed();
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          "Delete",
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        delegate: new SlidableDrawerDelegate(),
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
            title: Text(title),
            leading: photoUrl != null
                ? CircleAvatar(
                    radius: 22,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  )
                : CustomAvatar(
                    radius: 22,
                    name: entityName ?? " ",
                  ),
            subtitle: Text(
              subTitle,
            ),
            onTap: () => onPressed != null ? onPressed() : null,
          ),
        ),
      ),
    );
  }
}
