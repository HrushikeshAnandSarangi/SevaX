import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';
import 'package:sevaexchange/views/exchange/help.dart';
import 'package:sevaexchange/views/news/news_card_view.dart';
import 'package:sevaexchange/views/news/newslistview.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/time_bank_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';

import 'core.dart';

class SearchView extends StatefulWidget {
  final TabController controller;

  SearchView(this.controller);

  @override
  SearchViewState createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  TabController controller;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.addListener(() {
      setState(() {});
    });
    searchTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          leading: Container(
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              icon: Hero(
                tag: 'profilehero',
                child: Container(
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
                      image: NetworkImage(
                          SevaCore.of(context).loggedInUser.photoURL),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(),
                  ),
                );
              },
            ),
          ),
          title: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: searchTextController,
              decoration: InputDecoration(
                  hasFloatingPlaceholder: false,
                  alignLabelWithHint: true,
                  isDense: true,
                  // suffix: GestureDetector(
                  //   //onTap: () => search(),
                  //   child: Icon(Icons.search),
                  // ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white)),
              // controller: searchTextController,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            isScrollable: true,
            controller: controller,
            tabs: [
              Tab(child: Text('Users')),
              Tab(child: Text('News')),
              Tab(child: Text('Requests')),
              Tab(child: Text('Offers')),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            Expanded(
              child: ResultView(() {
                switch (controller.index) {
                  case 0:
                    return SearchType.USER;
                  case 1:
                    return SearchType.NEWS;
                  case 2:
                    return SearchType.REQUEST;
                  case 3:
                    return SearchType.OFFER;
                  default:
                    return SearchType.USER;
                }
              }(), searchTextController),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultView extends StatefulWidget {
  final SearchType type;
  final TextEditingController controller;

  ResultView(this.type, this.controller);

  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  Widget build(BuildContext context) {
    if (widget.controller.text.trim().isEmpty) {
      return Center(child: Text('Enter a Search String'));
    }
    switch (widget.type) {
      case SearchType.USER:
        return StreamBuilder<List<UserModel>>(
          stream:
              SearchManager.searchForUser(queryString: widget.controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            List<UserModel> userList = snapshot.data;

            return ListView.builder(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(left: 8, top: 16),
                    child: Text('Users', style: sectionTextStyle),
                  );
                }
                UserModel user = userList.elementAt(index - 1);
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfileViewer(userEmail: user.email);
                          },
                        ),
                      );
                    },
                    leading: user.photoURL != null
                        ? ClipOval(
                            child: FadeInImage.assetNetwork(
                              fadeInCurve: Curves.easeIn,
                              fadeInDuration: Duration(milliseconds: 400),
                              fadeOutDuration: Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              placeholder: 'lib/assets/images/noimagefound.png',
                              image: user.photoURL,
                            ),
                          )
                        : CircleAvatar(),
                    title: Text(user.fullname),
                    subtitle: Text(user.email),
                  ),
                );
              },
              itemCount: userList.length + 1,
            );
          },
        );
        break;

      case SearchType.NEWS:
        return StreamBuilder<List<NewsModel>>(
          stream:
              SearchManager.searchForNews(queryString: widget.controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            List<NewsModel> newsList = snapshot.data;
            return ListView.builder(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(left: 8, top: 16),
                    child: Text('News', style: sectionTextStyle),
                  );
                }
                NewsModel news = newsList.elementAt(index - 1);
                return Card(
                  child: ListTile(
                    onTap: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Loading'),
                              content: LinearProgressIndicator(),
                            );
                          });
                      NewsModel newsModel = await FirestoreManager.getNewsForId(
                        news.id,
                      );
                      Navigator.of(context, rootNavigator: true).pop();
                      if (newsModel == null) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return NewsCardView(
                              newsModel: newsModel,
                            );
                          },
                        ),
                      );
                    },
                    title: Text(news.title),
                    subtitle: Text(news.description),
                    leading: Hero(
                      tag: news.id,
                      child: CircleAvatar(
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            height: 70,
                            width: 70,
                            placeholder: 'lib/assets/images/noimagefound.png',
                            image: news.newsImageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: newsList.length + 1,
            );
          },
        );
        break;

      case SearchType.OFFER:
        return StreamBuilder<List<OfferModel>>(
          stream:
              SearchManager.searchForOffer(queryString: widget.controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            List<OfferModel> offerList = snapshot.data;

            return ListView.builder(
              itemCount: offerList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(left: 8, top: 16),
                    child: Text('Offers', style: sectionTextStyle),
                  );
                }
                OfferModel model = offerList.elementAt(index - 1);
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return OfferCardView(offerModel: model);
                          },
                        ),
                      );
                    },
                    title: Text(model.title),
                    subtitle: Text(model.description),
                  ),
                );
              },
            );
          },
        );
        break;

      case SearchType.REQUEST:
        return StreamBuilder<List<RequestModel>>(
          stream: SearchManager.searchForRequest(
              queryString: widget.controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            List<RequestModel> requestList = snapshot.data;

            return ListView.builder(
              itemCount: requestList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(left: 8, top: 16),
                    child: Text('Requests', style: sectionTextStyle),
                  );
                }
                RequestModel model = requestList.elementAt(index - 1);
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return RequestCardView(requestItem: model);
                          },
                        ),
                      );
                    },
                    title: Text(model.title),
                    subtitle: Text(model.description),
                  ),
                );
              },
            );
          },
        );
        break;
      default:
        return StreamBuilder<List<UserModel>>(
          stream:
              SearchManager.searchForUser(queryString: widget.controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            List<UserModel> userList = snapshot.data;

            return ListView.builder(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: EdgeInsets.only(left: 8, top: 16),
                    child: Text('Users', style: sectionTextStyle),
                  );
                }
                UserModel user = userList.elementAt(index - 1);
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfileViewer(userEmail: user.email);
                          },
                        ),
                      );
                    },
                    leading: user.photoURL != null
                        ? ClipOval(
                            child: FadeInImage.assetNetwork(
                              fadeInCurve: Curves.easeIn,
                              fadeInDuration: Duration(milliseconds: 400),
                              fadeOutDuration: Duration(milliseconds: 200),
                              width: 50,
                              height: 50,
                              placeholder: 'lib/assets/images/noimagefound.png',
                              image: user.photoURL,
                            ),
                          )
                        : CircleAvatar(),
                    title: Text(user.fullname),
                    subtitle: Text(user.email),
                  ),
                );
              },
              itemCount: userList.length + 1,
            );
          },
        );
    }
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }
}

enum SearchType {
  USER,
//  TIMEBANK,
//  CAMPAIGN,
  NEWS,
  OFFER,
  REQUEST,
}
