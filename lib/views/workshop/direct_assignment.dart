import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

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
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context);

    print("Color ${color.primaryColor}");

    return Scaffold(
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
              margin: EdgeInsets.all(10),
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
        timebankId: widget.timebankId,
      ),
    );
  }

  TimebankModel timebankModel;
  Widget getList({String timebankId}) {
    if (timebankModel != null) {
      return Container(
        child: getDataScrollView(
          context,
          timebankModel,
        ),
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        timebankModel = snapshot.data;
        return Container(
          child: getDataScrollView(
            context,
            timebankModel,
          ),
        );
      },
    );
  }

  Widget getDataScrollView(
    BuildContext context,
    TimebankModel timebankModel,
  ) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            getContent(context, timebankModel),
          ),
        ),
      ],
    );
  }

  List<Widget> getContent(BuildContext context, TimebankModel model) {
    return [
      getMembersList(context, model),
      SizedBox(height: 48),
    ];
  }

  Widget getMembersList(BuildContext context, TimebankModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...model.members.map((member) {
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            print("From cache");
            return getUserWidget(widget.listOfMembers[member], context);
          }

          print("from database");

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
        }).toList(),
      ],
    );
  }

  Widget getUserWidget(UserModel user, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print(user.email +
            " User selected" +
            SevaCore.of(context).loggedInUser.email);

        if (!widget.userSelected.containsKey(user.email))
          widget.userSelected[user.email] = user;
        else
          widget.userSelected.remove(user.email);

        print(
            "${widget.userSelected.length} Users selected ${widget.userSelected.containsKey(user.email)} ");

        setState(() {});
      },
      child: Card(
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
                color: widget.userSelected.containsKey(user.email)
                    ? Colors.white
                    : Colors.blue),
          ),
          subtitle: Text(
            user.email,
            style: TextStyle(
                color: widget.userSelected.containsKey(user.email)
                    ? Colors.white
                    : Colors.blue),
          ),
        ),
      ),
    );
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
