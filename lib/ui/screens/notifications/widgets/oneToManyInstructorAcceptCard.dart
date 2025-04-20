import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class OneToManyInstructorAcceptCard extends StatelessWidget {
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

  const OneToManyInstructorAcceptCard({
    Key? key,
    required this.onPressedAccept,
    required this.onPressedReject,
    required this.photoUrl,
    required this.creatorName,
    required this.title,
    //this.subTitle,
    required this.onDismissed,
    required this.entityName,
    this.isDissmissible = true,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing:
          !isDissmissible && onPressedAccept == null && onPressedReject == null,
      child: Slidable(
        startActionPane: isDissmissible
            ? ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
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
                              CustomTextButton(
                                onPressed: () =>
                                    {Navigator.of(dialogContext).pop()},
                                child: Text(
                                  S.of(context).cancel,
                                ),
                              ),
                              CustomTextButton(
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: S.of(context).delete,
                  ),
                ],
              )
            : null,
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
                      child: CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: onPressedAccept,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).accept,
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      height: 32,
                      child: CustomElevatedButton(
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: onPressedReject,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
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
