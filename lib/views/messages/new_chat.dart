// import 'package:flutter/material.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/models/new_chat_model.dart';
// import 'package:sevaexchange/ui/utils/message_utils.dart';
// import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/utils/search_manager.dart';
// import 'package:sevaexchange/views/messages/allmembers.dart';
// import 'package:shimmer/shimmer.dart';

// import '../core.dart';
// import 'chatview.dart';

// class NewChat extends StatefulWidget {
//   bool isShare;
//   NewsModel news;
//   final String timebankId;

//   NewChat(this.isShare, this.news, this.timebankId);

//   @override
//   NewChatState createState() => NewChatState();
// }

// class NewChatState extends State<NewChat> with TickerProviderStateMixin {
//   //TabController controller;
//   final TextEditingController searchTextController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     searchTextController.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Theme.of(context).primaryColor,
//         // leading: Container(
//         //     padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
//         //     child: Icon(Icons.search)),
//         title: Container(
//           padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
//           child: TextField(
//             style: TextStyle(color: Colors.white),
//             controller: searchTextController,
//             decoration: InputDecoration(
//               hasFloatingPlaceholder: false,
//               alignLabelWithHint: true,
//               isDense: true,
//               // suffix: GestureDetector(
//               //   //onTap: () => search(),
//               //   child: Icon(Icons.search),
//               // ),
//               enabledBorder: UnderlineInputBorder(
//                   borderSide: new BorderSide(color: Colors.white)),
//               hintText: 'Search',
//               hintStyle: TextStyle(color: Colors.white),
//             ),
//             // controller: searchTextController,
//           ),
//         ),
//         // bottom: TabBar(
//         //   isScrollable: true,
//         //   controller: controller,
//         //   tabs: [
//         //     Tab(child: Text('Users')),
//         //     Tab(child: Text('News')),
//         //     Tab(child: Text('Requests')),
//         //     Tab(child: Text('Offers')),
//         //   ],
//         // ),
//       ),
//       resizeToAvoidBottomInset: false,
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ResultView(
//               () {}(),
//               searchTextController,
//               widget.isShare,
//               widget.news,
//               widget.timebankId,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ResultView extends StatefulWidget {
//   final SearchType type;
//   final TextEditingController controller;
//   bool isShare;
//   NewsModel news;
//   String timebankId;

//   ResultView(
//       this.type, this.controller, this.isShare, this.news, this.timebankId);

//   @override
//   _ResultViewState createState() => _ResultViewState();
// }

// class _ResultViewState extends State<ResultView> {
//   @override
//   void initState() {
//     if (widget.isShare == null) widget.isShare = false;
//     super.initState();
//   }

//   Widget build(BuildContext context) {
//     String loggedInEmail = SevaCore.of(context).loggedInUser.email;
//     var blockedMembers =
//         List<String>.from(SevaCore.of(context).loggedInUser.blockedMembers);
//     var blockedByMembers =
//         List<String>.from(SevaCore.of(context).loggedInUser.blockedBy);
//     if (widget.controller.text.trim().isEmpty) {
//       return StreamBuilder<List<ChatModel>>(
//         stream: getChatsforUser(
//           email: SevaCore.of(context).loggedInUser.email,
//           blockedBy: blockedByMembers,
//           blockedMembers: blockedMembers,
//           communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//         ),
//         builder:
//             (BuildContext context, AsyncSnapshot<List<ChatModel>> snapshot) {
//           if (snapshot.hasError) {
//             return new Text('Error: ${snapshot.error}');
//           }
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             default:
//               List<ChatModel> chatModelList = snapshot.data;
//               if (chatModelList.length == 0) {
//                 return Center(child: Text('No chats'));
//               }
//               return Container(
//                 padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                 child: ListView(
//                   children: [
//                     ...chatModelList.map(
//                       (ChatModel chatModel) {
//                         return getMessageListView(chatModel, context);
//                       },
//                     ).toList(),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     Center(
//                       child: InkWell(
//                         onTap: () {
//                           NewsModel news = NewsModel();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => AllMembersChat(
//                                 isShare: widget.isShare,
//                                 news: widget.news,
//                                 timebankId: widget.timebankId,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           'Show all members',
//                           style: TextStyle(
//                               color: Theme.of(context).accentColor,
//                               fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//           }
//         },
//       );
//     }

//     return StreamBuilder<List<UserModel>>(
//       stream: SearchManager.searchForUser(queryString: widget.controller.text),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text(snapshot.error.toString());
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: SizedBox(
//               height: 48,
//               width: 48,
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//         List<UserModel> userList = snapshot.data;

//         return ListView.builder(
//           itemBuilder: (context, index) {
//             if (index == 0) {
//               return Container(
//                 padding: EdgeInsets.only(left: 8, top: 16),
//                 child: Text('Users', style: sectionTextStyle),
//               );
//             }
//             UserModel user = userList.elementAt(index - 1);
//             return Card(
//               child: ListTile(
//                 onTap: user.email == loggedInEmail
//                     ? null
//                     : () {
//                         UserModel loggedInUser =
//                             SevaCore.of(context).loggedInUser;
//                         ParticipantInfo sender = ParticipantInfo(
//                           id: loggedInUser.sevaUserID,
//                           photoUrl: loggedInUser.photoURL,
//                           name: loggedInUser.fullname,
//                           type: MessageType.TYPE_PERSONAL,
//                         );

//                         ParticipantInfo reciever = ParticipantInfo(
//                           id: user.sevaUserID,
//                           photoUrl: user.photoURL,
//                           name: user.fullname,
//                           type: MessageType.TYPE_PERSONAL,
//                         );

//                         createAndOpenChat(
//                           context: context,
//                           timebankId: widget.timebankId,
//                           communityId: loggedInUser.currentCommunity,
//                           sender: sender,
//                           reciever: reciever,
//                           isFromShare: widget.isShare,
//                           news: widget.news,
//                         );
//                       },
//                 leading: user.photoURL != null
//                     ? ClipOval(
//                         child: FadeInImage.assetNetwork(
//                           fadeInCurve: Curves.easeIn,
//                           fadeInDuration: Duration(milliseconds: 400),
//                           fadeOutDuration: Duration(milliseconds: 200),
//                           width: 50,
//                           height: 50,
//                           placeholder: 'lib/assets/images/noimagefound.png',
//                           image: user.photoURL,
//                         ),
//                       )
//                     : CircleAvatar(),
//                 title: Text(user.fullname),
//                 subtitle: Text(user.email),
//               ),
//             );
//           },
//           itemCount: userList.length + 1,
//         );
//       },
//     );
//   }

//   Widget get taskShimmer {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Shimmer.fromColors(
//         child: Container(
//           decoration: ShapeDecoration(
//             color: Colors.white.withAlpha(80),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//             ),
//           ),
//           child: ListTile(
//             title: Container(height: 10, color: Colors.white),
//             subtitle: Container(height: 10, color: Colors.white),
//             leading: CircleAvatar(
//               backgroundColor: Colors.white,
//             ),
//           ),
//         ),
//         baseColor: Colors.black.withAlpha(50),
//         highlightColor: Colors.white.withAlpha(50),
//       ),
//     );
//   }

//   Widget getMessageListView(ChatModel chatModel, BuildContext parentContext) {
//     String lastmessage;
//     if (chatModel.lastMessage == null) {
//       lastmessage = '';
//     } else
//       lastmessage = chatModel.lastMessage;
//     if (chatModel.user1 == SevaCore.of(context).loggedInUser.email) {
//       return StreamBuilder<Object>(
//           stream: FirestoreManager.getUserForEmailStream(chatModel.user2),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return taskShimmer;
//             }
//             UserModel user = snapshot.data;
//             return Container(
//               child: Card(
//                 elevation: 0,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       parentContext,
//                       MaterialPageRoute(
//                         builder: (context) => ChatView(
//                           useremail: user.email,
//                           // chatModel: chatModel,
//                           isFromShare: widget.isShare,
//                           news: widget.news,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         ClipOval(
//                           child: SizedBox(
//                             height: 45,
//                             width: 45,
//                             child: FadeInImage.assetNetwork(
//                                 placeholder: 'lib/assets/images/profile.png',
//                                 image: user.photoURL),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 user.fullname,
//                                 style:
//                                     Theme.of(parentContext).textTheme.subhead,
//                               ),
//                               Text(
//                                 lastmessage,
//                                 style: TextStyle(color: Colors.grey),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//     } else if (chatModel.user2 == SevaCore.of(context).loggedInUser.email) {
//       return StreamBuilder<Object>(
//           stream: FirestoreManager.getUserForEmailStream(chatModel.user1),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return taskShimmer;
//             }
//             UserModel user = snapshot.data;
//             return Container(
//               child: Card(
//                 elevation: 0,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       parentContext,
//                       MaterialPageRoute(
//                         builder: (context) => ChatView(
//                           useremail: user.email,
//                           // chatModel: chatModel,
//                           isFromShare: widget.isShare,
//                           news: widget.news,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         ClipOval(
//                           child: SizedBox(
//                             height: 45,
//                             width: 45,
//                             child: FadeInImage.assetNetwork(
//                                 placeholder: 'lib/assets/images/profile.png',
//                                 image: user.photoURL),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 user.fullname,
//                                 style:
//                                     Theme.of(parentContext).textTheme.subhead,
//                               ),
//                               Text(
//                                 lastmessage,
//                                 style: TextStyle(color: Colors.grey),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           });
//     }
//   }

//   TextStyle get sectionTextStyle {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 11,
//       color: Colors.grey,
//     );
//   }
// }

// enum SearchType {
//   USER,
// //  TIMEBANK,
// //  CAMPAIGN,
//   NEWS,
//   OFFER,
//   REQUEST,
// }
