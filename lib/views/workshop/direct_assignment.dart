import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebank_congratsView.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

import '../../flavor_config.dart';

class SelectMembersInGroup extends StatefulWidget {
  String timebankId;
  HashMap<String, UserModel> userSelected;
  HashMap<String, UserModel> listOfMembers = HashMap();

  SelectMembersInGroup(
      String timebankId, HashMap<String, UserModel> userSelected) {
    this.timebankId = timebankId;
    this.userSelected = userSelected;
  }

  @override
  State<StatefulWidget> createState() {
    return _SelectMembersInGroupState();
  }
}

class _SelectMembersInGroupState extends State<SelectMembersInGroup> {
  String _timebankId;
  ScrollController _controller;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var _hasMoreItems = true;
  var _showMoreItems = true;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  List<Widget> _avtars = [];
  List<UserModel> userModels = [];
  HashMap<String, int> emailIndexMap = HashMap();

  _SelectMembersInGroupState(){
    _timebankId = FlavorConfig.values.timebankName == "Yang 2020" ? FlavorConfig.values.timebankId : widget.timebankId;
  }

  @override
  void initState(){
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
        !_controller.position.outOfRange && _hasMoreItems) {
      setState(() {
        _showMoreItems = true;
//        loadNextBatchItems();
      });
    } else {
      _showMoreItems = false;

    }
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context);
    print("Color ${color.primaryColor}");
    var finalWidget =  Scaffold(
      appBar: AppBar(
        title: Text(
          "Select volunteers",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pop({'membersSelected': widget.userSelected});
            },
            child: Container(
              margin: EdgeInsets.all(0),
              alignment: Alignment.center,
              height: double.infinity,
              child: Text(
                "Save",
                style: prefix0.TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: getList(
        timebankId: FlavorConfig.values.timebankName == "Yang 2020" ? FlavorConfig.values.timebankId : widget.timebankId,
      ),
    );

    if(_showMoreItems) {
      loadNextBatchItems().then((onValue){
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

  Widget getContent(BuildContext context,TimebankModel model) {
    if(_avtars.length == 0 && _hasMoreItems && _showMoreItems) {
      return circularBar;
    }else{
      if(selectedUserModelIndex!=-1){
        updateModelIndex(selectedUserModelIndex);
        selectedUserModelIndex = -1;
      }
      return ListView.builder(
        controller: _controller,
        itemCount: fetchItemsCount(),
        itemBuilder: (BuildContext ctxt, int index) =>
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: index < _avtars.length ?
                _avtars[index]
                : Container(
                width: double.infinity,
                height: 80,
                child: circularBar,
              ),
            ),
      );
    }
  }

  Widget get circularBar {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  int fetchItemsCount() {
    if(_hasMoreItems && _showMoreItems) {
      return _avtars.length + 1;
    }
    return _avtars.length;
  }

  Future updateModelIndex(int index) async {
    var member = userModels[index].sevaUserID;
    if (widget.listOfMembers != null &&
        widget.listOfMembers.containsKey(member)) {
      userModels.add(widget.listOfMembers[member]);
      _avtars[index] = getUserWidget(widget.listOfMembers[member], context);
    }else{
      _avtars[index] = FutureBuilder<UserModel>(
        future: FirestoreManager.getUserForId(sevaUserId: member),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerWidget;
          }
          UserModel user = snapshot.data;
          userModels.add(user);
          widget.listOfMembers[user.sevaUserID] = user;
          return getUserWidget(user, context);
        },
      );
    }
  }


  Future loadNextBatchItems() async {
    if(_hasMoreItems) {
      FirestoreManager.getUsersForTimebankId(_timebankId, _pageIndex).then((onValue){
        int index = _indexSoFar;
        var addItems = onValue.map((memberObject) {
          var member = memberObject.sevaUserID;
          index++;
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            userModels.add(widget.listOfMembers[member]);
            emailIndexMap[widget.listOfMembers[member].email] = index;
            return getUserWidget(widget.listOfMembers[member], context);
          }
          var items = FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              userModels.add(user);
              emailIndexMap[user.email] = index;
              widget.listOfMembers[user.sevaUserID] = user;
              return getUserWidget(user, context);
            },
          );
          return items;
        }
        ).toList();
        if(addItems.length>0) {
          setState(() {
//            var prevIndex = _indexSoFar;
            _avtars.addAll(addItems);
            _indexSoFar = _indexSoFar + addItems.length;
//            for(var i=prevIndex;i<_indexSoFar;i++){
//              emailIndexMap[userModels[i].email] = i;
//            }
            _pageIndex = _pageIndex + 1;
          });
        }else{
          _hasMoreItems = addItems.length == 20;
        }
      });
    }
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    var card = getUserModelCard(user);
    return GestureDetector(
      onTap: () async {
        print(user.email +
            " User selected" +
            SevaCore.of(context).loggedInUser.email);


        if (!widget.userSelected.containsKey(user.email)){
          widget.userSelected[user.email] = user;
          currSelectedState = true;
        }
        else{
          widget.userSelected.remove(user.email);
          currSelectedState = false;
        }

        print(
            "${widget.userSelected.length} Users selected ${widget.userSelected.containsKey(user.email)} ");

        setState(() {
        });
      },
      child: card,
    );
  }

  Card getUserModelCard(UserModel user) {
    return Card(
      color: widget.userSelected.containsKey(user.email)
          ? Colors.green
          : Colors.white,
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
    );
  }

  Color getTextColorForSelectedItem(String email) {
    if(widget.userSelected.containsKey(email)) {
      return Colors.white;
    }
    return Colors.black;
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
