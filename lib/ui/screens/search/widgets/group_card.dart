import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class GroupCard extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;
  final VoidCallback? onPressed;
  final JoinStatus status;

  const GroupCard({
    Key? key,
    this.image,
    this.title,
    this.subtitle,
    this.onPressed,
    this.status = JoinStatus.JOIN,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 3 / 2,
            child: CachedNetworkImage(
              imageUrl: image != null
                  ? image ?? defaultGroupImageURL
                  : defaultGroupImageURL,
              fit: BoxFit.fitWidth,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  child: CustomTextButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    shape: StadiumBorder(),
                    color: Colors.grey[300],
                    textColor: Theme.of(context).primaryColor,
                    child: Text(status.toString().split('.')[1]),
                    onPressed: onPressed!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum JoinStatus {
  JOIN,
  JOINED,
  REQUESTED,
  REJECTED,
}
