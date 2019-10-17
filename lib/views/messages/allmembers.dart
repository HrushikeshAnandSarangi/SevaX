import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart'
    as prefix0;
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/views/messages/new_chat.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';

import '../core.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'chatview.dart';

class AllMembersChat extends StatefulWidget {
  bool isShare;
  NewsModel news;

  AllMembersChat(this.isShare, this.news);

  @override
  AllMembersChatState createState() => AllMembersChatState();
}

class AllMembersChatState extends State<AllMembersChat>
    with TickerProviderStateMixin {
  //TabController controller;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //controller = widget.controller;
    // controller.addListener(() {
    //   setState(() {});
    // });

    searchTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        // leading: Container(
        //     padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
        //     child: Icon(Icons.search)),
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
                  borderSide: new BorderSide(color: Colors.white)),
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.white),
            ),
            // controller: searchTextController,
          ),
        ),
        // bottom: TabBar(
        //   isScrollable: true,
        //   controller: controller,
        //   tabs: [
        //     Tab(child: Text('Users')),
        //     Tab(child: Text('News')),
        //     Tab(child: Text('Requests')),
        //     Tab(child: Text('Offers')),
        //   ],
        // ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ResultView(
                () {}(), searchTextController, widget.isShare, widget.news),
          ),
        ],
      ),
    );
  }
}

class ResultView extends StatefulWidget {
  final SearchType type;
  final TextEditingController controller;
  bool isShare;
  NewsModel news;

  ResultView(this.type, this.controller, this.isShare, this.news);

  @override
  _ResultViewState createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  @override
  void initState() {
    if (widget.isShare == null) widget.isShare = false;
    super.initState();
  }

  Widget build(BuildContext context) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;

    if (widget.controller.text.trim().isEmpty) {
      return StreamBuilder<prefix0.TimebankModel>(
        stream:
            getTimebankModelStream(timebankId: FlavorConfig.values.timebankId),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              prefix0.TimebankModel timebankModel = snapshot.data;
              List<String> memberList = timebankModel.members;
              if (memberList.length == 0) {
                return Center(child: Text('No members'));
              }
              return Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: ListView(
                  children: [
                    ...memberList.map(
                      (String member) {
                        return getMemberListView(member, context);
                      },
                    ).toList(),
                  ],
                ),
              );
          }
        },
      );
    }

    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUser(queryString: widget.controller.text),
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
                onTap: user.email == loggedInEmail
                    ? null
                    : () {
                        List users = [user.email, loggedInEmail];
                        users.sort();
                        ChatModel model = ChatModel();
                        model.user1 = users[0];
                        model.user2 = users[1];
                        createChat(chat: model).then(
                          (_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatView(
                                        useremail: user.email,
                                        chatModel: model,
                                        isFromShare: widget.isShare,
                                        news: widget.news,
                                      )),
                            );
                          },
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

  Widget get taskShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }

  Widget getMemberListView(String userId, BuildContext parentContext) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    return StreamBuilder<Object>(
        stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return taskShimmer;
          }
          UserModel user = snapshot.data;
          return user.email == loggedInEmail
              ? Offstage()
              : Card(
                  child: ListTile(
                    onTap: () {
                      List users = [user.email, loggedInEmail];
                      users.sort();
                      ChatModel model = ChatModel();
                      model.user1 = users[0];
                      model.user2 = users[1];
                      createChat(chat: model).then(
                        (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatView(
                                      useremail: user.email,
                                      chatModel: model,
                                      isFromShare: widget.isShare,
                                      news: widget.news,
                                    )),
                          );
                        },
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
        });
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
