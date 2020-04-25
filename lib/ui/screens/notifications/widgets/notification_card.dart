import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/utils.dart';

class NotificationCard extends StatelessWidget {
  final Function onPressed;
  final Function onDismissed;
  final String photoUrl;
  final String title;
  final String subTitle;
  final bool isDissmissible;

  const NotificationCard({
    Key key,
    this.onPressed,
    this.photoUrl,
    this.title,
    this.subTitle,
    this.onDismissed,
    this.isDissmissible = true,
  })  : assert(title != null),
        assert(subTitle != null),
        assert(photoUrl != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isDissmissible,
      child: Dismissible(
        background: Container(
          margin: EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: Colors.red.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadows: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                spreadRadius: 2,
                blurRadius: 3,
              )
            ],
          ),
          child: ListTile(),
        ),
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          onDismissed();
        },
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
            leading: CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
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
