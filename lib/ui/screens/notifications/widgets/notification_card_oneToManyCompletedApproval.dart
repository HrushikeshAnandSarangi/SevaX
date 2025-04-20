import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NotificationCardOneToManyCompletedApproval extends StatelessWidget {
  final VoidCallback onPressedApprove;
  final VoidCallback onPressedReject;
  final Function onDismissed;
  final String? photoUrl;
  final String title;
  final String subTitle;
  final bool isDissmissible;
  final String? entityName;
  final int timestamp;

  const NotificationCardOneToManyCompletedApproval({
    Key? key,
    required this.onPressedApprove,
    required this.onPressedReject,
    required this.onDismissed,
    this.photoUrl,
    required this.title,
    required this.subTitle,
    this.entityName,
    this.isDissmissible = true,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isDissmissible &&
          onPressedApprove == null &&
          onPressedReject == null,
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
          child: Column(
            children: [
              ListTile(
                title: Text(title),
                leading: photoUrl != null
                    ? CircleAvatar(
                        radius: 22,
                        backgroundImage: CachedNetworkImageProvider(photoUrl!),
                      )
                    : CustomAvatar(
                        radius: 22,
                        name: entityName ?? " ",
                      ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTitle != null ? subTitle.trim() : '',
                    ),
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
                  ],
                ),
                //onTap: () => onPressed != null ? onPressed() : null,
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.19),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.07,
                    child: CustomElevatedButton(
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).approve,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Europa',
                            fontSize: 12),
                      ),
                      onPressed: () =>
                          onPressedApprove != null ? onPressedApprove() : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.07,
                    child: CustomElevatedButton(
                      padding: EdgeInsets.zero,
                      color: FlavorConfig.values.theme?.colorScheme.secondary ??
                          Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).reject,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Europa',
                            fontSize: 12),
                      ),
                      onPressed: () =>
                          onPressedReject != null ? onPressedReject() : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
