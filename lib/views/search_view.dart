// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
// import 'package:sevaexchange/ui/screens/offers/offers_ui.dart';
// import 'package:sevaexchange/utils/bloc_provider.dart';
// import 'package:sevaexchange/utils/search_manager.dart';
// import 'package:sevaexchange/views/news/news_card_view.dart';
// import 'package:sevaexchange/views/profile/profile.dart';
// import 'package:sevaexchange/views/profile/profileviewer.dart';
// import 'package:sevaexchange/views/timebank_modules/request_card_view.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
//
// import 'core.dart';
//
// class SearchView extends StatefulWidget {
//   final TabController controller;
//   SearchView(this.controller);
//   @override
//   SearchViewState createState() => SearchViewState();
// }
//
// class SearchViewState extends State<SearchView> with TickerProviderStateMixin {
//   TabController controller;
//   final TextEditingController searchTextController = TextEditingController();
//   final searchOnChange = BehaviorSubject<String>();
//   @override
//   void initState() {
//     super.initState();
//     controller = widget.controller;
//     searchOnChange
//         .debounceTime(Duration(milliseconds: 500))
//         .listen((queryString) {
//       controller.addListener(() {
//         setState(() {});
//       });
//       searchTextController.addListener(() {
//         setState(() {});
//       });
//     });
//   }
//
//   void _search(String queryString) {
//     if (queryString.length == 1) {
//       setState(() {
//         searchOnChange.add(queryString);
//       });
//     } else {
//       searchOnChange.add(queryString);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.white),
//           backgroundColor: Theme.of(context).primaryColor,
//           leading: Container(
//             margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
//             child: IconButton(
//               icon: Hero(
//                 tag: 'profilehero',
//                 child: Container(
//                   height: 36,
//                   width: 36,
//                   decoration: ShapeDecoration(
//                     shape: CircleBorder(
//                       side: BorderSide(
//                         color: Colors.white,
//                         width: 1,
//                       ),
//                     ),
//                     image: DecorationImage(
//                       image: NetworkImage(
//                           SevaCore.of(context).loggedInUser.photoURL ??
//                               defaultUserImageURL),
//                     ),
//                   ),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProfileView(),
//                   ),
//                 );
//               },
//             ),
//           ),
//           title: Container(
//             padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
//             child: TextField(
//               onChanged: _search,
//               style: TextStyle(color: Colors.white),
//               controller: searchTextController,
//               decoration: InputDecoration(
//                   hasFloatingPlaceholder: false,
//                   alignLabelWithHint: true,
//                   isDense: true,
//                   enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.white)),
//                   hintText: 'Search',
//                   hintStyle: TextStyle(color: Colors.white)),
//             ),
//           ),
//           bottom: TabBar(
//             labelColor: Colors.white,
//             isScrollable: true,
//             controller: controller,
//             tabs: [
//               Tab(child: Text('Users')),
//               Tab(child: Text('Feeds')),
//               Tab(child: Text('Requests')),
//               Tab(child: Text('Offers')),
//             ],
//           ),
//         ),
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           children: <Widget>[
//             Expanded(
//               child: ResultView(() {
//                 switch (controller.index) {
//                   case 0:
//                     return SearchType.USER;
//                   case 1:
//                     return SearchType.NEWS;
//                   case 2:
//                     return SearchType.REQUEST;
//                   case 3:
//                     return SearchType.OFFER;
//                   default:
//                     return SearchType.USER;
//                 }
//               }(), searchTextController),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ResultView extends StatefulWidget {
//   final SearchType type;
//   final TextEditingController controller;
//   ResultView(this.type, this.controller);
//   @override
//   _ResultViewState createState() => _ResultViewState();
// }
//
// class _ResultViewState extends State<ResultView> {
//   bool checkValidSting(String str) {
//     return str != null && str.trim().length != 0;
//   }
//
//   Widget getTitleForCard(String str, String fullName) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         str == null || str == "No content"
//             ? Offstage()
//             : Text(
//                 fullName == null ? defaultUsername : fullName.trim(),
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//         Text(
//           str.trim(),
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.left,
//         ),
//       ],
//     );
//   }
//
//   Widget fetchHeadingFromNewsModel(NewsModel newsModel) {
//     if (checkValidSting(newsModel.title)) {
//       return getTitleForCard(newsModel.title, newsModel.fullName);
//     }
//     if (checkValidSting(newsModel.subheading)) {
//       return getTitleForCard(newsModel.subheading, newsModel.fullName);
//     }
//     if (checkValidSting(newsModel.description)) {
//       return getTitleForCard(newsModel.description, newsModel.fullName);
//     }
//     return getTitleForCard('No content', newsModel.fullName);
//   }
//
//   Widget build(BuildContext context) {
//     if (widget == null ||
//         widget.controller == null ||
//         widget.controller.text == null) {
//       return Container();
//     }
//     if (widget.controller.text.trim().isEmpty) {
//       return Center(
//           child: ClipOval(
//         child: ClipOval(
//           child: Image.asset('lib/assets/images/search.png'),
//         ),
//       ));
//     } else if (widget.controller.text.trim().length < 3) {
//       return getEmptyWidget('Users', 'Search requires minimum 3 characters');
//     }
//     switch (widget.type) {
//       case SearchType.USER:
//         return StreamBuilder<List<UserModel>>(
//           stream:
//               SearchManager.searchForUser(queryString: widget.controller.text),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: SizedBox(
//                   height: 48,
//                   width: 48,
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//             List<UserModel> userList = snapshot.data;
//             if (userList.length == 0) {
//               return getEmptyWidget('Users', 'No search result found');
//             }
//             return ListView.builder(
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Container(
//                     padding: EdgeInsets.only(left: 8, top: 16),
//                     child: Text('Users', style: sectionTextStyle),
//                   );
//                 }
//                 UserModel user = userList.elementAt(index - 1);
//                 return Card(
//                   child: ListTile(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return ProfileViewer(userEmail: user.email);
//                           },
//                         ),
//                       );
//                     },
//                     leading: user.photoURL != null
//                         ? ClipOval(
//                             child: FadeInImage.assetNetwork(
//                               fadeInCurve: Curves.easeIn,
//                               fadeInDuration: Duration(milliseconds: 400),
//                               fadeOutDuration: Duration(milliseconds: 200),
//                               width: 50,
//                               height: 50,
//                               placeholder: 'lib/assets/images/noimagefound.png',
//                               image: user.photoURL,
//                             ),
//                           )
//                         : CircleAvatar(),
//                     title: Text(user.fullname),
//                     subtitle: Text(user.email),
//                   ),
//                 );
//               },
//               itemCount: userList.length + 1,
//             );
//           },
//         );
//         break;
//       case SearchType.NEWS:
//         return StreamBuilder<List<NewsModel>>(
//           stream:
//               SearchManager.searchForNews(queryString: widget.controller.text),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: SizedBox(
//                   height: 48,
//                   width: 48,
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//             List<NewsModel> newsList = snapshot.data;
//             if (newsList.length == 0) {
//               return getEmptyWidget('News', 'No news feed found');
//             }
//             return ListView.builder(
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Container(
//                     padding: EdgeInsets.only(left: 8, top: 16),
//                     child: Text('News', style: sectionTextStyle),
//                   );
//                 }
//                 NewsModel news = newsList.elementAt(index - 1);
//                 return InkWell(
//                   onTap: () async {
//                     showDialog(
//                         barrierDismissible: false,
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text('Loading'),
//                             content: LinearProgressIndicator(),
//                           );
//                         });
//                     Navigator.of(context, rootNavigator: true).pop();
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_context) {
//                           return BlocProvider(
//                             bloc: BlocProvider.of<HomeDashBoardBloc>(context),
//                             child: NewsCardView(
//                               newsModel: news,
//                               isFocused: false,
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                     return;
//                   },
//                   child: ListTile(
//                     title: fetchHeadingFromNewsModel(news),
//                     leading: Hero(
//                       tag: news.id,
//                       child: CircleAvatar(
//                         child: ClipOval(
//                           child: FadeInImage.assetNetwork(
//                             height: 140,
//                             width: 140,
//                             placeholder: 'lib/assets/images/noimagefound.png',
//                             image: news.newsImageUrl == null
//                                 ? defaultUserImageURL
//                                 : news.newsImageUrl,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               itemCount: newsList.length + 1,
//             );
//           },
//         );
//         break;
//       case SearchType.OFFER:
//         return StreamBuilder<List<OfferModel>>(
//           stream:
//               SearchManager.searchForOffer(queryString: widget.controller.text),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: SizedBox(
//                   height: 48,
//                   width: 48,
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//             List<OfferModel> offerList = snapshot.data;
//             if (offerList.length == 0) {
//               return getEmptyWidget('Offers', 'No offer found');
//             }
//             return ListView.builder(
//               itemCount: offerList.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Container(
//                     padding: EdgeInsets.only(left: 8, top: 16),
//                     child: Text('Offers', style: sectionTextStyle),
//                   );
//                 }
//                 OfferModel model = offerList.elementAt(index - 1);
//                 return Card(
//                   child: ListTile(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return OfferCardView(offerModel: model,timebankModel: ,);
//                           },
//                         ),
//                       );
//                     },
//                     title: Text(model.offerType == OfferType.INDIVIDUAL_OFFER
//                         ? model.individualOfferDataModel.title
//                         : model.individualOfferDataModel.title),
//                     subtitle: Text(
//                       model.offerType == OfferType.INDIVIDUAL_OFFER
//                           ? model.individualOfferDataModel.description
//                           : model.groupOfferDataModel.classDescription,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//         break;
//       case SearchType.REQUEST:
//         return StreamBuilder<List<RequestModel>>(
//           stream: SearchManager.searchForRequest(
//               queryString: widget.controller.text),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: SizedBox(
//                   height: 48,
//                   width: 48,
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//             List<RequestModel> requestList = snapshot.data;
//             if (requestList.length == 0) {
//               return getEmptyWidget('Requests', 'No request found');
//             }
//             return ListView.builder(
//               itemCount: requestList.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Container(
//                     padding: EdgeInsets.only(left: 8, top: 16),
//                     child: Text('Requests', style: sectionTextStyle),
//                   );
//                 }
//                 RequestModel model = requestList.elementAt(index - 1);
//                 return Card(
//                   child: ListTile(
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return RequestCardView(requestItem: model);
//                           },
//                         ),
//                       );
//                     },
//                     title: Text(model.title),
//                     subtitle: Text(model.description),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//         break;
//       default:
//         return StreamBuilder<List<UserModel>>(
//           stream:
//               SearchManager.searchForUser(queryString: widget.controller.text),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text(snapshot.error.toString());
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return LoadingIndicator();
//             }
//             List<UserModel> userList = snapshot.data;
//             if (userList.length == 0) {
//               return getEmptyWidget('Users', 'No user found');
//             }
//             return ListView.builder(
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Container(
//                     padding: EdgeInsets.only(left: 8, top: 16),
//                     child: Text('Users', style: sectionTextStyle),
//                   );
//                 }
//                 UserModel user = userList.elementAt(index - 1);
//                 return Card(
//                   child: ListTile(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return ProfileViewer(userEmail: user.email);
//                           },
//                         ),
//                       );
//                     },
//                     leading: user.photoURL != null
//                         ? ClipOval(
//                             child: FadeInImage.assetNetwork(
//                               fadeInCurve: Curves.easeIn,
//                               fadeInDuration: Duration(milliseconds: 400),
//                               fadeOutDuration: Duration(milliseconds: 200),
//                               width: 50,
//                               height: 50,
//                               placeholder: 'lib/assets/images/noimagefound.png',
//                               image: user.photoURL,
//                             ),
//                           )
//                         : CircleAvatar(),
//                     title: Text(user.fullname),
//                     subtitle: Text(user.email),
//                   ),
//                 );
//               },
//               itemCount: userList.length + 1,
//             );
//           },
//         );
//     }
//   }
//
//   Widget getEmptyWidget(String title, String notFoundValue) {
//     return Center(
//       child: Text(
//         notFoundValue,
//         overflow: TextOverflow.ellipsis,
//         style: sectionHeadingStyle,
//       ),
//     );
//   }
//
//   TextStyle get sectionHeadingStyle {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 12.5,
//       color: Colors.black,
//     );
//   }
//
//   TextStyle get sectionTextStyle {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 11,
//       color: Colors.grey,
//     );
//   }
// }
//
//
enum SearchType {
  USER,
  NEWS,
  OFFER,
  REQUEST,
}
