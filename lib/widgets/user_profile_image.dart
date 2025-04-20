import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';

class UserProfileImage extends StatelessWidget {
  final TimebankModel timebankModel;
  final double height;
  final double width;
  final String email;
  final String photoUrl;
  final String userId;

  UserProfileImage(
      {required this.timebankModel,
      required this.height,
      required this.width,
      required this.email,
      required this.photoUrl,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ProfileViewer(
            timebankId: timebankModel.id,
            entityName: timebankModel.name,
            isFromTimebank: isPrimaryTimebank(
                parentTimebankId: timebankModel.parentTimebankId),
            userEmail: email,
          );
        }));
      },
      child: photoUrl != null
          ? Container(
              height: height != null ? height : 50,
              width: width != null ? width : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(photoUrl ??
                        'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png')),
              ),
            )
          : Container(
              height: height != null ? height : 50,
              width: width != null ? width : 50,
              child: CircleAvatar(
                  backgroundImage: NetworkImage(defaultUserImageURL),
                  minRadius: 25.0),
            ),
    );
  }
}
