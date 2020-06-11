import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/chat_model.dart';

AppBar chatAppBar(
    BuildContext context, ParticipantInfo info, List<Widget> actions) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Theme.of(context).primaryColor,
    titleSpacing: 0,
    title: Row(
      children: <Widget>[
        Container(
          height: 36,
          width: 36,
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                info.photoUrl ?? defaultUserImageURL,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            info.name,
            style: TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    actions: actions,
  );
}
