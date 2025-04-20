import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart' as prefix;
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';

import 'search_timebank_manager_page.dart';

enum MEMBER_SELECTION_MODE { SHARE_FEED, NEW_CHAT }

class SelectMembersFromTimebank extends StatefulWidget {
  late String timebankId;
  late HashMap<String, UserModel> userSelected;
  HashMap<String, UserModel> listOfMembers = HashMap();

  bool isFromShare = false;
  late NewsModel newsModel;
  late MEMBER_SELECTION_MODE selectionMode;

  SelectMembersFromTimebank({
    String? timebankId,
    HashMap<String, UserModel>? userSelected,
    bool? isFromShare,
    NewsModel? newsModel,
    MEMBER_SELECTION_MODE? selectionMode,
  }) {
    this.timebankId = timebankId!;
    this.userSelected = userSelected!;
    this.isFromShare = isFromShare!;
    this.newsModel = newsModel!;
    this.selectionMode = selectionMode!;
  }

  @override
  State<StatefulWidget> createState() {
    return _SelectMembersInGroupState();
  }
}

class _SelectMembersInGroupState extends State<SelectMembersFromTimebank> {
  ScrollController? _controller;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var _showMoreItems = true;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  var _isLoading = false;
  var nullcount = 0;

  var _lastReached = false;

  List<Widget> _avtars = [];
  HashMap<String, int> emailIndexMap = HashMap();
  HashMap<int, UserModel> indexToModelMap = HashMap();

  @override
  void initState() {
    _showMoreItems = true;
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange &&
        !_isLoading) {
      if (!_lastReached) {
        loadNextBatchItems().then((onValue) {
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_avtars.length == 0 && !_isLoading) {
      loadNextBatchItems();
    }
    var color = Theme.of(context);
    var finalWidget = Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).select_volunteer,
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              // Icons.arrow_back,
              // color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchTimebankMemberElastic(
                    widget.timebankId,
                    widget.isFromShare,
                    widget.newsModel,
                    widget.selectionMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: getList(
        timebankId: widget.timebankId,
      ),
    );
    return finalWidget;
  }

  TimebankModel? timebankModel;
  Widget getList({String? timebankId}) {
    if (timebankModel != null) {
      return getContent(
        context,
        timebankModel!,
      );
    }

    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
        timebankId: timebankId!,
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
          timebankModel!,
        );
      },
    );
  }

  Widget getContent(BuildContext context, TimebankModel model) {
    if (_avtars.length == 0 && _lastReached) {
      return Center(
          child: Text(
        S.of(context).no_volunteers_available,
      ));
    } else if (_avtars.length == 0 && _showMoreItems && !_isLoading) {
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
    return LoadingIndicator();
  }

  int fetchItemsCount() {
    if (!_lastReached) {
      return _avtars.length + 1;
    }
    return _avtars.length;
  }

  Future<Widget> updateModelIndex(int index) async {
    UserModel user = indexToModelMap[index]!;

    return getUserWidget(user, context);
  }

  void checkAndStopLoading() {
    nullcount++;
    _isLoading = false;
    _pageIndex = _pageIndex + 1;
    if (nullcount >= 3) {
      setState(() {
        _lastReached = true;
      });
      return;
    }
    loadNextBatchItems();
  }

  Future loadNextBatchItems() async {
    if (!_isLoading && !_lastReached) {
      _isLoading = true;
      FirestoreManager.getUsersForTimebankId(widget.timebankId, _pageIndex,
              SevaCore.of(context).loggedInUser.email!)
          .then((onValue) {
        if (onValue == null) {
          checkAndStopLoading();
          return;
        }
        var userModelList = onValue.userModelList;
        if (userModelList == null || userModelList.length == 0) {
          checkAndStopLoading();
          return;
        }
        nullcount = 0;
        var addItems = userModelList.map((memberObject) {
          var member = memberObject.sevaUserID;
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            return getUserWidget(widget.listOfMembers[member]!, context);
          }
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data!;
              widget.listOfMembers[user.sevaUserID!] = user;
              return getUserWidget(user, context);
            },
          );
        }).toList();
        if (addItems.length > 0) {
          var lastIndex = _avtars.length;
          setState(() {
            var iterationCount = 0;
            for (int i = 0; i < addItems.length; i++) {
              if (emailIndexMap[userModelList[i].email] == null) {
                // Filtering duplicates
                _avtars.add(addItems[i]);
                indexToModelMap[lastIndex] = userModelList[i];
                emailIndexMap[userModelList[i].email] = lastIndex++;
                iterationCount++;
              }
            }
            _indexSoFar = _indexSoFar + iterationCount;
            _pageIndex = _pageIndex + 1;
          });
        } else {
          checkAndStopLoading();
          return;
        }
        _isLoading = false;
        setState(() {
          _lastReached = onValue.lastPage;
        });
      });
    }
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        switch (widget.selectionMode) {
          case MEMBER_SELECTION_MODE.NEW_CHAT:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;
              prefix.ParticipantInfo sender = prefix.ParticipantInfo(
                id: loggedInUser.sevaUserID,
                name: loggedInUser.fullname,
                photoUrl: loggedInUser.photoURL,
                type: prefix.ChatType.TYPE_PERSONAL,
              );

              prefix.ParticipantInfo reciever = prefix.ParticipantInfo(
                id: user.sevaUserID,
                name: user.fullname,
                photoUrl: user.photoURL,
                type: prefix.ChatType.TYPE_PERSONAL,
              );
              showProgressDialog();
              createAndOpenChat(
                context: context,
                timebankId: widget.timebankId,
                communityId: loggedInUser.currentCommunity!,
                sender: sender,
                reciever: reciever,
                isFromRejectCompletion: false,
                feedId: '',
                showToCommunities: <String>[],
                entityId: '',
                onChatCreate: () {
                  Navigator.of(dialogLoadingContext!).pop();
                  Navigator.of(context).pop();
                },
              );
            }
            return;

            break;

          case MEMBER_SELECTION_MODE.SHARE_FEED:
            if (user.email == SevaCore.of(context).loggedInUser.email) {
              return null;
            } else {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;
              prefix.ParticipantInfo sender = prefix.ParticipantInfo(
                id: loggedInUser.sevaUserID,
                name: loggedInUser.fullname,
                photoUrl: loggedInUser.photoURL,
                type: prefix.ChatType.TYPE_PERSONAL,
              );

              prefix.ParticipantInfo reciever = prefix.ParticipantInfo(
                id: user.sevaUserID!,
                name: user.fullname,
                photoUrl: user.photoURL,
                type: prefix.ChatType.TYPE_PERSONAL,
              );
              showProgressDialog();
              createAndOpenChat(
                context: context,
                timebankId: widget.timebankId,
                communityId: loggedInUser.currentCommunity ?? '',
                sender: sender,
                reciever: reciever,
                isFromRejectCompletion: false,
                isFromShare: true,
                feedId: widget.newsModel.id ?? '',
                showToCommunities: <String>[],
                entityId: '',
                onChatCreate: () {
                  Navigator.of(dialogLoadingContext!).pop();
                  Navigator.of(context).pop();
                },
              );
            }
            return;

            break;
        }
      },
      child: user.email == SevaCore.of(context).loggedInUser.email
          ? Container()
          : Card(
              color: isSelected(user.email!) ? Colors.green : Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user.photoURL ?? defaultUserImageURL),
                ),
                title: Text(
                  user.fullname!,
                  style: TextStyle(
                    color: getTextColorForSelectedItem(user.email!),
                  ),
                ),
                // subtitle: Text(
                //   user.email,
                //   style: TextStyle(
                //     color: getTextColorForSelectedItem(user.email),
                //   ),
                // ),
              ),
            ),
    );
  }

  BuildContext? dialogLoadingContext;

  void showProgressDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          dialogLoadingContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
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
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget getDataCard({
    required String title,
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
