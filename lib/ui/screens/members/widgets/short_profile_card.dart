import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';

class ShortProfileCard extends StatelessWidget {
  final UserModel model;
  final UserRole role;
  final PopupMenuButton actionButton;

  const ShortProfileCard({Key key, this.model, this.role, this.actionButton})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        model.photoURL != null
            ? CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(model.photoURL),
                radius: 30,
              )
            : CustomAvatar(
                name: model.fullname,
                radius: 30,
              ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            model.fullname ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actionButton,
      ],
    );
  }
}
