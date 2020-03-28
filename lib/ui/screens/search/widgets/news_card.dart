import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String userImageUrl;
  final String userName;
  final int timestamp;
  final bool isFavorite;
  final bool isBookMarked;
  final double radius;
  final Function onShare;
  final Function onFavorite;
  final Function onBookMark;

  const NewsCard({
    Key key,
    this.imageUrl,
    this.title,
    this.userImageUrl,
    this.userName,
    this.timestamp,
    this.isFavorite = false,
    this.isBookMarked = false,
    this.onShare,
    this.onFavorite,
    this.onBookMark,
    this.radius = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imageUrl);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Offstage(
            offstage: imageUrl == null || imageUrl == "NoData",
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: CustomNetworkImage(
                  imageUrl,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 7,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              CircleAvatar(
                radius: 25,
                child: CustomNetworkImage(userImageUrl ?? defaultUserImageURL),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                  Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(timestamp),
                    ),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              // Spacer(),

              Spacer(),
              cardButtons(),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget cardButtons() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: onBookMark,
          child: Icon(
            isBookMarked ? Icons.flag : Icons.outlined_flag,
          ),
        ),
        SizedBox(width: 5),
        InkWell(
          onTap: onShare,
          child: Icon(Icons.share),
        ),
        SizedBox(width: 5),
        InkWell(
          onTap: onFavorite,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
