import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/message_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/decorations.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class FeedBubble extends StatelessWidget {
  final NewsModel news;
  final bool isSent;
  final String senderId;
  final MessageModel messageModel;

  const FeedBubble({
    required this.news,
    required this.isSent,
    required this.senderId,
    required this.messageModel,
    Key? key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isSent
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 5, 0, 5)
          : EdgeInsets.fromLTRB(
              0, 5, MediaQuery.of(context).size.width / 10, 5),
      alignment: isSent ? Alignment.topRight : Alignment.topLeft,
      child: Wrap(
        children: <Widget>[
          Container(
            decoration: isSent
                ? MessageDecoration.sendDecoration()
                : MessageDecoration.receiveDecoration(),
            padding: isSent && news != null
                ? EdgeInsets.fromLTRB(0, 0, 5, 2)
                : messageModel.fromId != senderId && news != null
                    ? EdgeInsets.fromLTRB(0, 0, 0, 2)
                    : EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                getFeedCard(context),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 5,
                    bottom: 3,
                  ),
                  child: Text(
                    formatChatDate(
                      messageModel.timestamp ?? 0,
                      SevaCore.of(context).loggedInUser.timezone ?? 'UTC',
                      S.of(context).localeName,
                    ),
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getFeedCard(context) {
    if (news == null) {
      return Container();
    }
    var imageBanner = news.newsImageUrl == null
        ? (news.imageScraped == null ? "NoData" : news.imageScraped)
        : news.newsImageUrl;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_context) {
              return BlocProvider(
                  bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                  child: NewsCardView(newsModel: news, isFocused: false));
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  offset: Offset(0, 0),
                  spreadRadius: 8,
                  blurRadius: 10),
            ]),
        child: Column(
          children: <Widget>[
            Container(
              height: imageBanner != "NoData" ? 250 : 0,
              child: SizedBox.expand(
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: imageBanner != "NoData"
                        ? FadeInImage(
                            fit: BoxFit.fitWidth,
                            placeholder:
                                AssetImage('lib/assets/images/waiting.jpg'),
                            image: NetworkImage(
                              imageBanner ?? defaultUserImageURL,
                            ),
                          )
                        : Offstage()),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(
                                (news.title ?? news.subheading) ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          timeAgo.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                news.postTimestamp ?? 0,
                              ),
                              locale: Locale(
                                getLangTag(),
                              ).toLanguageTag()),
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
