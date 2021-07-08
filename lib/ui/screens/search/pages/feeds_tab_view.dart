import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/news_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../flavor_config.dart';

class FeedsTabView extends StatefulWidget {
  CommunityModel communityModel;
  FeedsTabView({this.communityModel});

  @override
  _FeedsTabViewState createState() => _FeedsTabViewState();
}

class _FeedsTabViewState extends State<FeedsTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text(S.of(context).search_something));
          }
          return StreamBuilder<List<NewsModel>>(
            stream: Searches.searchFeeds(
              queryString: search.data,
              loggedInUser: _bloc.user,
              currentCommunityOfUser: _bloc.community,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data == null || snapshot.data.isEmpty) {
                return Center(
                  child: Text(S.of(context).search_something),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final news = snapshot.data[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_context) {
                            return BlocProvider(
                              bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                              child: NewsCardView(
                                newsModel: news,
                                isFocused: false,
                                timebankModel: _bloc.timebank,
                                communityModel: widget.communityModel,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: NewsCard(
                      id: news.id,
                      imageUrl: news.newsImageUrl ?? news.imageScraped,
                      title: news.title != null &&
                              news.title != "NoData"
                          ? news.title.trim()
                          : news.subheading.trim(),
                      userImageUrl: news.userPhotoURL ?? defaultUserImageURL,
                      userName: news.fullName,
                      timestamp: news.postTimestamp,
                      onShare: () => _share(context, news),
                      isFavorite: news.likes
                          .contains(SevaCore.of(context).loggedInUser.email),
                      onFavorite: () =>
                          _like(news, SevaCore.of(context).loggedInUser.email),
                      isAdmin: isAccessAvailable(_bloc.timebank,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      address: getLocation(news.placeAddress) ??
                          "location not updated",
                      documentName: news.newsDocumentName,
                      documentUrl: news.newsDocumentUrl,
                      isBookMarked: news.reports.contains(
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      onBookMark: () => _report(news: news, mContext: context),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String getLocation(String location) {
    if (location != null) {
      List<String> l = location.split(',');
      l = l.reversed.toList();
      if (l.length >= 2) {
        return "${l[1]},${l[0]}";
      } else if (l.length >= 1) {
        return "${l[0]}";
      } else {
        return "Unknown";
      }
    } else {
      return "Unknown";
    }
  }

  void _share(BuildContext context, NewsModel news) {
    if (SevaCore.of(context).loggedInUser.associatedWithTimebanks > 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectTimeBankNewsShare(
                  news,
                )),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectMembersFromTimebank(
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
            newsModel: NewsModel(),
            isFromShare: false,
            selectionMode: MEMBER_SELECTION_MODE.NEW_CHAT,
            userSelected: HashMap(),
          ),
        ),
      );
    }
  }

  void _like(NewsModel news, String email) async {
    Set<String> likesList = Set.from(news.likes);
    news.likes != null && news.likes.contains(email)
        ? likesList.remove(email)
        : likesList.add(email);
    news.likes = likesList.toList();
    await FirestoreManager.updateNews(newsObject: news);
//    await CollectionRef.feeds.doc(news.id).update({
//      "likes": likesList,
//    });
    setState(() {});
  }

  void _report({NewsModel news, BuildContext mContext}) {
    if (news.reports.contains(SevaCore.of(mContext).loggedInUser.sevaUserID)) {
      showDialog(
        context: mContext,
        builder: (BuildContext viewContextS) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(S.of(context).already_reported),
            content: Text(S.of(context).feed_reported),
            actions: <Widget>[
              CustomTextButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: dialogButtonSize,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContextS).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: mContext,
        builder: (BuildContext viewContext) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(
              S.of(context).report_feed,
            ),
            content: Text(S.of(context).report_feed_confirmation_message),
            actions: <Widget>[
              CustomTextButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(mContext).accentColor,
                textColor: FlavorConfig.values.buttonTextColor,
                child: Text(
                  S.of(context).report_feed,
                  style: TextStyle(
                    fontSize: dialogButtonSize,
                  ),
                ),
                onPressed: () {
                  if (news.reports.contains(
                      SevaCore.of(mContext).loggedInUser.sevaUserID)) {
                  } else {
                    if (news.reports.isEmpty) {
                      news.reports = [];
                    }
                    news.reports
                        .add(SevaCore.of(mContext).loggedInUser.sevaUserID);
                    CollectionRef.feeds
                        .doc(news.id)
                        .update({'reports': news.reports});
                  }
                  Navigator.of(viewContext).pop();
                  setState(() {});
                },
              ),
              CustomTextButton(
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
