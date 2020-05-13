import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsCard extends StatelessWidget {
  final String id;
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
    this.id,
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
                child: id != null
                    ? Hero(
                        tag: id + "*",
                        child: CustomNetworkImage(
                          imageUrl,
                        ),
                      )
                    : CustomNetworkImage(
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
        SizedBox(width: 10),
        // InkWell(
        //   onTap: onFavorite,
        //   child: Icon(
        //     isFavorite ? Icons.favorite : Icons.favorite_border,
        //   ),
        // ),
        // SizedBox(width: 10),
      ],
    );
  }
}

// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/models/news_model.dart';
// import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
// import 'package:sevaexchange/utils/members_of_timebank.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NewsCard extends StatefulWidget {
//   final NewsModel news;
//   final String email;
//   final double radius;

//   const NewsCard({
//     Key key,
//     this.news,
//     this.radius = 4,
//     this.email,
//   }) : super(key: key);

//   @override
//   _NewsCardState createState() => _NewsCardState();
// }

// class _NewsCardState extends State<NewsCard> {
//   NewsModel news;
//   bool isLiked = false;

//   @override
//   void initState() {
//     news = widget.news;

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(widget.radius),
//       ),
//       elevation: 10,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Offstage(
//             offstage: (news.newsImageUrl ?? news.imageScraped) == null ||
//                 (news.newsImageUrl ?? news.imageScraped) == "NoData",
//             child: ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(widget.radius),
//                 topRight: Radius.circular(widget.radius),
//               ),
//               child: AspectRatio(
//                   aspectRatio: 3 / 2,
//                   child: Hero(
//                     tag: news.id + "*",
//                     child: CustomNetworkImage(
//                       news.newsImageUrl ?? news.imageScraped,
//                     ),
//                   )),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Text(
//               news.title != null && news.title != "NoData"
//                   ? news.title.trim()
//                   : news.subheading.trim(),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 7,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             children: <Widget>[
//               SizedBox(width: 10),
//               CircleAvatar(
//                 radius: 25,
//                 child: CustomNetworkImage(
//                   news.userPhotoURL ?? defaultUserImageURL,
//                 ),
//               ),
//               SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     news.fullName,
//                     style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
//                   ),
//                   Text(
//                     timeago.format(
//                       DateTime.fromMillisecondsSinceEpoch(news.postTimestamp),
//                     ),
//                     style: TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ],
//               ),
//               // Spacer(),

//               Spacer(),
//               cardButtons(),
//             ],
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget cardButtons() {
//     return Row(
//       children: <Widget>[
//         // InkWell(
//         //   onTap: onBookMark,
//         //   child: Icon(
//         //     widget.isBookMarked ? Icons.flag : Icons.outlined_flag,
//         //   ),
//         // ),
//         SizedBox(width: 5),
//         InkWell(
//           onTap: onShare,
//           child: Icon(Icons.share),
//         ),
//         SizedBox(width: 5),
//         InkWell(
//           onTap: onFavorite,
//           child: Icon(
//             news.likes.contains(widget.email)
//                 ? Icons.favorite
//                 : Icons.favorite_border,
//             color: Colors.red,
//           ),
//         ),
//         SizedBox(width: 10),
//       ],
//     );
//   }

//   void onBookMark() {}

//   void onShare() {
//     if (SevaCore.of(context).loggedInUser.associatedWithTimebanks > 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SelectTimeBankNewsShare(
//             news,
//           ),
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SelectMembersFromTimebank(
//             timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
//             newsModel: NewsModel(),
//             isFromShare: false,
//             selectionMode: MEMBER_SELECTION_MODE.NEW_CHAT,
//             userSelected: HashMap(),
//           ),
//         ),
//       );
//     }
//   }

//   void onFavorite() {}
// }
