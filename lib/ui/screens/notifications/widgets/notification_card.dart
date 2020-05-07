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
                  builder: (BuildContext dialoContext) {
                    return AlertDialog(
                      title: Text("Delete notification"),
                      content: Text(
                        "Are you sure you want to remove this notificaition.",
                      ),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => {Navigator.of(dialoContext).pop()},
                          child: Text(
                            "Cancel",
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            Navigator.of(dialoContext).pop();
                            onDismissed();
                          },
                          child: Text(
                            "Delete",
                          ),
                        ),
                      ],
                    );
                  });
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
//       new Slidable(
//   delegate: new SlidableDrawerDelegate(),
//   actionExtentRatio: 0.25,
//   child: new Container(
//     color: Colors.white,
//     child: new ListTile(
//       leading: new CircleAvatar(
//         backgroundColor: Colors.indigoAccent,
//         child: new Text('$3'),
//         foregroundColor: Colors.white,
//       ),
//       title: new Text('Tile n°$3'),
//       subtitle: new Text('SlidableDrawerDelegate'),
//     ),
//   ),
//   actions: <Widget>[
//     new IconSlideAction(
//       caption: 'Archive',
//       color: Colors.blue,
//       icon: Icons.archive,
//       onTap: () => _showSnackBar('Archive'),
//     ),
//     new IconSlideAction(
//       caption: 'Share',
//       color: Colors.indigo,
//       icon: Icons.share,
//       onTap: () => _showSnackBar('Share'),
//     ),
//   ],
//   secondaryActions: <Widget>[
//     new IconSlideAction(
//       caption: 'More',
//       color: Colors.black45,
//       icon: Icons.more_horiz,
//       onTap: () => _showSnackBar('More'),
//     ),
//     new IconSlideAction(
//       caption: 'Delete',
//       color: Colors.red,
//       icon: Icons.delete,
//       onTap: () => _showSnackBar('Delete'),
//     ),
//   ],
// );

//     return AbsorbPointer(
//       absorbing: !isDissmissible,
//       child: Dismissible(
//         background: Container(
//           margin: EdgeInsets.all(8),
//           decoration: ShapeDecoration(
//             color: Colors.red.withAlpha(80),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             shadows: [
//               BoxShadow(
//                 color: Colors.black.withAlpha(10),
//                 spreadRadius: 2,
//                 blurRadius: 3,
//               )
//             ],
//           ),
//           child: ListTile(),
//         ),
//         key: Key(Utils.getUuid()),
//         onDismissed: (direction) {
//           onDismissed();
//         },
//         child: Container(
//           margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
//           decoration: ShapeDecoration(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//             ),
//             color: Colors.white,
//             shadows: [
//               BoxShadow(
//                 color: Colors.black.withAlpha(10),
//                 spreadRadius: 2,
//                 blurRadius: 3,
//               )
//             ],
//           ),
//           child: ListTile(
//             title: Text(title),
//             leading: photoUrl != null
//                 ? CircleAvatar(
//                     radius: 22,
//                     backgroundImage: CachedNetworkImageProvider(photoUrl),
//                   )
//                 : CustomAvatar(
//                     radius: 22,
//                     name: entityName ?? " ",
//                   ),
//             subtitle: Text(
//               subTitle,
//             ),
//             onTap: () => onPressed != null ? onPressed() : null,
//           ),
//         ),
//       ),
//     );
  }
}
