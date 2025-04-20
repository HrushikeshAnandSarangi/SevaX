// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final String userImageUrl;
  final String address;
  final String documentUrl;
  final String documentName;
  final String userName;
  final int timestamp;
  final bool isFavorite;
  final bool isAdmin;
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
    this.address,
    this.documentUrl,
    this.documentName,
    this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String loggedinemail = SevaCore.of(context).loggedInUser.email;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(address),
                  Spacer(),
                  Text(
                    timeago.format(
                        DateTime.fromMillisecondsSinceEpoch(timestamp),
                        locale: Locale(getLangTag()).toLanguageTag()),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 16),
            //Pinning ui
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Linkify(
                              text: title != null && title != "NoData"
                                  ? title.trim()
                                  : S.of(context).title,
                              onOpen: (url) async {
                                // if (await canLaunch(url)) {
                                //   launch(url);
                                // }
                              }
                              // overflow: TextOverflow.ellipsis,
                              // maxLines: 7,
                              // style: TextStyle(
                              //     fontSize: 15.0,
                              //     fontWeight: FontWeight.bold,
                              //     fontFamily: "Europa"),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage:
                        NetworkImage(userImageUrl ?? defaultUserImageURL),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          userName != null
                              ? userName.trim()
                              : S.of(context).user_name_not_availble,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 7,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        document(context),
                        //  SizedBox(height: 10),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            //feed image
            imageUrl == null || imageUrl == "NoData"
                ? Offstage()
                : getImageView(id, imageUrl),
            SizedBox(
              height: 8,
            ),
            //feed options
            cardButtons(),
            SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );

    /* return Card(
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
                          imageUrl ?? defaultUserImageURL,
                        ),
                      )
                    : CustomNetworkImage(
                        imageUrl ?? defaultUserImageURL,
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
    );*/
  }

  Widget getOptionButtons(Widget child, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
          onTap: onPressed),
    );
  }

  Widget cardButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          onTap: onBookMark,
          child: Icon(
            isBookMarked ? Icons.flag : Icons.outlined_flag,
            // color: isBookMarked ? Colors.red : null,
          ),
        ),
        SizedBox(width: 10),

        InkWell(
          onTap: onFavorite,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
        SizedBox(width: 10),
        InkWell(
          onTap: onShare,
          child: Icon(Icons.share),
        ),
        SizedBox(width: 15),
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

  Widget getImageView(String newsId, String urlToLoad) {
    return Container(
      height: 200,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          child: Hero(
            tag: newsId,
            child: FadeInImage(
              fit: BoxFit.fitWidth,
              placeholder: AssetImage('lib/assets/images/noimagefound.png'),
              image: NetworkImage(urlToLoad),
            ),
          ),
        ),
      ),
    );
  }

  Widget document(BuildContext context) {
    return documentUrl == null
        ? Offstage()
        : Container(
            height: 30,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.7),
              color: Colors.grey[200],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.attach_file,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    documentName ?? S.of(context).document,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
  }
}

// import 'dart:collection';

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
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
