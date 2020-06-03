import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/news_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';

import '../../../../flavor_config.dart';

class FeedsTabView extends StatefulWidget {
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
            return Center(
                child: Text(AppLocalizations.of(context)
                    .translate('search', 'search_something')));
          }
          return StreamBuilder<List<NewsModel>>(
            stream: Searches.searchFeeds(
              queryString: search.data,
              loggedInUser: _bloc.user,
              currentCommunityOfUser: _bloc.community,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == null || snapshot.data.isEmpty) {
                print("===>> ${snapshot.data}");
                return Center(
                  child: Text(AppLocalizations.of(context)
                      .translate('search', 'search_something')),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final news = snapshot.data[index];
                  print("address ${news.newsImageUrl}");
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NewsCardView(
                              newsModel: news,
                            );
                          },
                        ),
                      );
                    },
                    child: NewsCard(
                      id: news.id,
                      imageUrl: news.newsImageUrl ?? news.imageScraped,
                      title: news.title != null && news.title != "NoData"
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
                      isAdmin: _bloc.timebank.admins.contains(
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
        print("elasticsearch pjs location result is");
        return "Unknown";
      }
    } else {
      print("elasticsearch pjs location result isggggg");
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
    print("===>> ${news.likes}");
    Set<String> likesList = Set.from(news.likes);
    news.likes != null && news.likes.contains(email)
        ? likesList.remove(email)
        : likesList.add(email);
    news.likes = likesList.toList();
    await FirestoreManager.updateNews(newsObject: news);
//    await Firestore.instance.collection('news').document(news.id).updateData({
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
            title: Text('Already reported!'),
            content: Text('You already reported this feed'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
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
            title: Text(AppLocalizations.of(context).translate('homepage', 'report')),
            content: Text(AppLocalizations.of(context).translate('homepage', 'want_report')),
            actions: <Widget>[
              FlatButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(mContext).accentColor,
                textColor: FlavorConfig.values.buttonTextColor,
                child: Text(
                  AppLocalizations.of(context).translate('homepage', 'report_feed'),
                  style: TextStyle(
                    fontSize: dialogButtonSize,
                  ),
                ),
                onPressed: () {
                  if (news.reports.contains(
                      SevaCore.of(mContext).loggedInUser.sevaUserID)) {
                    print('already in reports');
                  } else {
                    if (news.reports.isEmpty) {
                      news.reports = List<String>();
                    }
                    news.reports
                        .add(SevaCore.of(mContext).loggedInUser.sevaUserID);
                    Firestore.instance
                        .collection('news')
                        .document(news.id)
                        .updateData({'reports': news.reports});
                  }
                  Navigator.of(viewContext).pop();
                  setState(() {});
                },
              ),
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate('shared', 'cancel'),
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

// import 'dart:collection';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sevaexchange/models/news_model.dart';
// import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
// import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
// import 'package:sevaexchange/ui/screens/search/widgets/news_card.dart';
// import 'package:sevaexchange/utils/bloc_provider.dart';
// import 'package:sevaexchange/utils/members_of_timebank.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/messages/select_timebank_for_news_share.dart';
// import 'package:sevaexchange/views/news/news_card_view.dart';

// class FeedsTabView extends StatefulWidget {
//   @override
//   _FeedsTabViewState createState() => _FeedsTabViewState();
// }

// class _FeedsTabViewState extends State<FeedsTabView>
//     with AutomaticKeepAliveClientMixin {
//   List<NewsModel> news = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final _bloc = BlocProvider.of<SearchBloc>(context);
//     return Container(
//       child: StreamBuilder<String>(
//         stream: _bloc.searchText,
//         builder: (context, search) {
//           if (search.data == null || search.data == "") {
//             return Center(child: Text("Search Something"));
//           }
//           return StreamBuilder<List<NewsModel>>(
//             stream: Searches.searchFeeds(
//                 queryString: search.data,
//                 loggedInUser: SevaCore.of(context).loggedInUser),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//               return ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 shrinkWrap: true,
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (context, index) {
//                   final news = snapshot.data[index];
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return NewsCardView(
//                               newsModel: news,
//                               timebankId: SevaCore.of(context)
//                                   .loggedInUser
//                                   .currentCommunity,
//                             );
//                           },
//                         ),
//                       );
//                     },
//                     child: NewsCard(
//                       news: news,
//                       email: SevaCore.of(context).loggedInUser.email,
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _share(BuildContext context, NewsModel news) {
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

//   void _like(NewsModel news, String email) {
//     print("===>> ${news.likes}");
//     Set<String> likesList = Set.from(news.likes);
//     news.likes != null && news.likes.contains(email)
//         ? likesList.remove(email)
//         : likesList.add(email);
//     news.likes = likesList.toList();
//     print(news.likes.toList());
//     Firestore.instance.collection('news').document(news.id).updateData({
//       "likes": likesList.toList(),
//     });
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
