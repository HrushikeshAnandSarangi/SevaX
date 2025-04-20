import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';

class SelectMembersInGroup extends StatefulWidget {
  final String timebankId;
  final String userEmail;
  final List<String> listOfAlreadyExistingMembers;
  final HashMap<String, UserModel> userSelected;
  final HashMap<String, UserModel> listOfMembers;

  SelectMembersInGroup({
    required this.timebankId,
    required this.userSelected,
    required this.userEmail,
    List<String>? listOfalreadyExistingMembers,
  })  : listOfAlreadyExistingMembers = listOfalreadyExistingMembers ?? [],
        listOfMembers = HashMap<String, UserModel>();

  @override
  State<StatefulWidget> createState() => _SelectMembersInGroupState();
}

class _SelectMembersInGroupState extends State<SelectMembersInGroup> {
  String? _timebankId;
  ScrollController? _controller;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  var _isLoading = false;
  var _lastReached = false;
  var nullcount = 0;

  List<Widget> _avtars = [];
  HashMap<String, int> emailIndexMap = HashMap();
  HashMap<int, UserModel> indexToModelMap = HashMap();

  @override
  void initState() {
    _timebankId = widget.timebankId;
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_controller != null &&
        _controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange &&
        !_isLoading &&
        nullcount < 3) {
      loadNextBatchItems().then((onValue) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_avtars.length == 0 && nullcount < 3) {
      loadNextBatchItems();
    }
    var finalWidget = Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).select_volunteer,
          style: TextStyle(fontSize: 20),
        ),
        elevation: 0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
//              widget.onTap();
              Navigator.of(context)
                  .pop({'membersSelected': widget.userSelected});
            },
            child: Container(
              margin: EdgeInsets.all(0),
              alignment: Alignment.center,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  S.of(context).save,
                  style: prefix0.TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
      body: getList(
        timebankId: FlavorConfig.values.timebankName == "Yang 2020"
            ? FlavorConfig.values.timebankId
            : widget.timebankId,
      ),
    );

    return finalWidget;
  }

  late TimebankModel timebankModel;
  Widget getList({required String timebankId}) {
    if (timebankModel != null) {
      return listViewWidget;
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
        if (snapshot.data == null) {
          return listViewWidget;
        }
        timebankModel = snapshot.data!;
        return listViewWidget;
      },
    );
  }

  Widget get listViewWidget {
    if (nullcount < 3) {
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
    if (_avtars.length == 0) {
      return Center(
        child: Text(S.of(context).no_volunteers_available),
      );
    }
    return Center(
      child: Text(S.of(context).no_volunteers_available),
    );
  }

  Widget get circularBar {
    return LoadingIndicator();
  }

  int fetchItemsCount() {
    return _lastReached ? _avtars.length : _avtars.length + 1;
  }

  Future<Widget> updateModelIndex(int index) async {
    UserModel? user = indexToModelMap[index];
    if (user == null) {
      throw Exception('User not found for index: $index');
    }

    return getUserWidget(user, context);
  }

  bool checkAlreadyExistingMembersContains(String sevaId) {
    if (FlavorConfig.values.timebankName != "Yang 2020") {
      for (var i = 0; i < widget.listOfAlreadyExistingMembers.length; i++) {
        if (sevaId.trim() == widget.listOfAlreadyExistingMembers[i].trim()) {
          return false;
        }
      }
    }
    return true;
  }

  Future loadNextBatchItems() async {
    if (!_isLoading && !_lastReached && nullcount < 3) {
      _isLoading = true;
      var onValue = await FirestoreManager.getUsersForTimebankId(
          _timebankId ?? '', _pageIndex, widget.userEmail);
      var userModelList = onValue.userModelList;
      if (userModelList == null || userModelList.length == 0) {
        nullcount++;
        _isLoading = false;
        _pageIndex = _pageIndex + 1;
        loadNextBatchItems();
      } else {
        nullcount = 0;
        var addItems = userModelList.map((memberObject) {
          var member = memberObject.sevaUserID;
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            final userModel = widget.listOfMembers[member];
            if (userModel != null) {
              return getUserWidget(userModel, context);
            }
          }
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data!;

              if (user == null) {
                return Offstage();
              }
              if (userModelList.length == 1 && user.email == widget.userEmail) {
                return Center(
                  child: Text(S.of(context).no_volunteers_available),
                );
              }
              if (user.email == widget.userEmail) {
                return Offstage();
              }
              widget.listOfMembers[user.sevaUserID ?? ''] = user;
              return getUserWidget(user, context);
            },
          );
        }).toList();
        if (addItems.length > 0) {
          var lastIndex = _avtars.length;
          setState(() {
            var iterationCount = 0;
            for (int i = 0; i < addItems.length; i++) {
              if (emailIndexMap[userModelList[i].email] == null &&
                  checkAlreadyExistingMembersContains(
                      userModelList[i].sevaUserID.trim())) {
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
        }
        _isLoading = false;
      }
      if (onValue.lastPage) {
        setState(() {
          _lastReached = onValue.lastPage;
        });
      } else if (_avtars.length < 20) {
        loadNextBatchItems();
      }
    } else {
      setState(() {
        _lastReached = true;
      });
    }
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.userSelected.containsKey(user.email)) {
          widget.userSelected[user.email ?? ''] = user;
          currSelectedState = true;
        } else {
          widget.userSelected.remove(user.email);
          currSelectedState = false;
        }
        selectedUserModelIndex = emailIndexMap[user.email] ?? -1;
        setState(() {
          if (selectedUserModelIndex != -1) {
            updateModelIndex(selectedUserModelIndex).then((onValue) {
              _avtars[selectedUserModelIndex] = onValue;
              selectedUserModelIndex = -1;
            });
          }
        });
      },
      child: Card(
        color: isSelected(user.email ?? '') ? Colors.green : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL ?? defaultUserImageURL),
          ),
          title: Text(
            user.fullname ?? '',
            style: TextStyle(
              color: getTextColorForSelectedItem(user.email ?? ''),
            ),
          ),
          subtitle: Container(),
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
        style: Theme.of(context).textTheme.titleMedium,
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
