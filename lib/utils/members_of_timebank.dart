import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

import '../flavor_config.dart';
import 'data_managers/chat_data_manager.dart';

enum MEMBER_SELECTION_MODE { SHARE_FEED, NEW_CHAT }

class SelectMembersFromTimebank extends StatefulWidget {
  String timebankId;
  HashMap<String, UserModel> userSelected;
  HashMap<String, UserModel> listOfMembers = HashMap();

  bool isFromShare = false;
  NewsModel newsModel;
  MEMBER_SELECTION_MODE selectionMode;

  SelectMembersFromTimebank({
    String timebankId,
    HashMap<String, UserModel> userSelected,
    bool isFromShare,
    NewsModel newsModel,
    MEMBER_SELECTION_MODE selectionMode,
  }) {
    this.timebankId = timebankId;
    this.userSelected = userSelected;
    this.isFromShare = isFromShare;
    this.newsModel = newsModel;
    this.selectionMode = selectionMode;
  }

  @override
  State<StatefulWidget> createState() {
    return _SelectMembersInGroupState();
  }
}

class _SelectMembersInGroupState extends State<SelectMembersFromTimebank> {
  ScrollController _controller;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var _hasMoreItems = true;
  var _showMoreItems = true;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  var isLoading = false;

  var fromNewChat = IsFromNewChat(true, DateTime.now().millisecondsSinceEpoch);

  List<Widget> _avtars = [];
  HashMap<String, int> emailIndexMap = HashMap();
  HashMap<int, UserModel> indexToModelMap = HashMap();

  @override
  void initState() {
//    loadNextBatchItems();
    _showMoreItems = true;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange &&
        _hasMoreItems) {
      setState(() {
        _showMoreItems = true;
      });
    } else {
      _showMoreItems = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context);
    print("Color ${color.primaryColor}");
    var finalWidget = Scaffold(
      appBar: AppBar(
        title: Text(
          "Select volunteer",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[],
      ),
      body: getList(
        timebankId: widget.timebankId,
      ),
    );

    if (_showMoreItems && !isLoading) {
      loadNextBatchItems(
        SevaCore.of(context).loggedInUser.email,
      ).then((onValue) {
        return finalWidget;
      });
    }
    return finalWidget;
  }

  TimebankModel timebankModel;
  Widget getList({String timebankId}) {
    if (timebankModel != null) {
      return getContent(
        context,
        timebankModel,
      );
    }

    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularBar;
        }
        timebankModel = snapshot.data;
        return getContent(
          context,
          timebankModel,
        );
      },
    );
  }

  Widget getContent(BuildContext context, TimebankModel model) {
    if (_avtars.length == 0 && _hasMoreItems && _showMoreItems) {
      return circularBar;
    } else {
      return listViewWidget;
    }
  }

  Widget get listViewWidget {
    return ListView.builder(
      controller: _controller,
      itemCount: fetchItemsCount(),
      itemBuilder: (BuildContext ctxt, int index) => Padding(
        padding: const EdgeInsets.all(0.0),
        child: index < _avtars.length
            ? _avtars[index]
            : Container(
                width: double.infinity,
                height: 80,
                child: circularBar,
              ),
      ),
    );
  }

  Widget get circularBar {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  int fetchItemsCount() {
    if (_hasMoreItems && _showMoreItems) {
      return _avtars.length + 1;
    }
    return _avtars.length;
  }

  Future<Widget> updateModelIndex(int index) async {
    UserModel user = indexToModelMap[index];

    return getUserWidget(user, context);
  }

  Future loadNextBatchItems(String userEmail) async {
    if (_hasMoreItems) {
      isLoading = true;
      FirestoreManager.getUsersForTimebankId(
        userEmail: userEmail,
        index: _pageIndex,
        timebankId: widget.timebankId,
      ).then((onValue) {
        var addItems = onValue.map((memberObject) {
          var member = memberObject.sevaUserID;
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            return getUserWidget(widget.listOfMembers[member], context);
          }
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              widget.listOfMembers[user.sevaUserID] = user;
              return getUserWidget(user, context);
            },
          );
        }).toList();

        if (addItems.length > 0) {
          var lastIndex = _avtars.length;
          setState(() {
            var iterationCount = 0;
            for (int i = 0; i < addItems.length; i++) {
              if (emailIndexMap[onValue[i].email] == null) {
                // Filtering duplicates
                _avtars.add(addItems[i]);
                indexToModelMap[lastIndex] = onValue[i];
                emailIndexMap[onValue[i].email] = lastIndex++;
                iterationCount++;
              }
            }
            _indexSoFar = _indexSoFar + iterationCount;
            _pageIndex = _pageIndex + 1;
          });
        } else {
          _hasMoreItems = addItems.length == 20;
        }

        isLoading = false;
      });
    }
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print(user.email + " User selected" + user.email);
        // Navigator.of(context).pop();

        //create chat when tapped :

        switch (widget.selectionMode) {
          case MEMBER_SELECTION_MODE.NEW_CHAT:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              List users = [
                user.email,
                SevaCore.of(context).loggedInUser.email
              ];
              print("Listing users");
              users.sort();
              ChatModel model = ChatModel();
              model.user1 = users[0];
              model.user2 = users[1];
              print("Model1" + model.user1);
              print("Model2" + model.user2);

              await createChat(chat: model).then(
                (_) {
                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatView(
                        useremail: user.email,
                        chatModel: model,
                        isFromShare: false,
                        news: NewsModel(),
                        isFromNewChat: fromNewChat,
                      ),
                    ),
                  );
                },
              );
            }
            return user.email == SevaCore.of(context).loggedInUser.email
                ? null
                : () {};

            break;

          case MEMBER_SELECTION_MODE.SHARE_FEED:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              List users = [
                user.email,
                SevaCore.of(context).loggedInUser.email
              ];
              print("Listing users");
              users.sort();
              ChatModel model = ChatModel();
              model.user1 = users[0];
              model.user2 = users[1];
              print("Model1" + model.user1);
              print("Model2" + model.user2);

              await createChat(chat: model).then(
                (_) {
                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatView(
                        useremail: user.email,
                        chatModel: model,
                        isFromShare: true,
                        news: widget.newsModel,
                        isFromNewChat: IsFromNewChat(
                            false, DateTime.now().millisecondsSinceEpoch),
                      ),
                    ),
                  );
                },
              );
            }
            return user.email == SevaCore.of(context).loggedInUser.email
                ? null
                : () {};

            break;
        }
      },
      child: Card(
        color: isSelected(user.email) ? Colors.green : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL),
          ),
          title: Text(
            user.fullname,
            style: TextStyle(
              color: getTextColorForSelectedItem(user.email),
            ),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
              color: getTextColorForSelectedItem(user.email),
            ),
          ),
        ),
      ),
    );
  }

  bool isSelected(String email) {
    return widget.userSelected.containsKey(email) ||
        (currSelectedState && selectedUserModelIndex == emailIndexMap[email]);
  }

  Color getTextColorForSelectedItem(String email) {
    return isSelected(email) ? Colors.white : Colors.black;
  }

  Widget getSectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget getDataCard({
    @required String title,
  }) {
    return Container(
      child: Column(
        children: <Widget>[Text('')],
      ),
    );
  }

  Widget get shimmerWidget {
    return Shimmer.fromColors(
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey.withAlpha(40),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
            title: Container(
              color: Colors.grey.withAlpha(90),
              height: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(90),
            ),
            subtitle: Container(
              color: Colors.grey.withAlpha(90),
              height: 8,
            )),
      ),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
    );
  }
}
