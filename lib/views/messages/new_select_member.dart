import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:shimmer/shimmer.dart';

import 'chatview.dart';

class SelectMember extends StatefulWidget {
  final String timebankId;
  NewsModel newsModel;
  bool isFromShare = false;

  SelectMember({@required this.timebankId});

  SelectMember.shareFeed(
      {this.timebankId, this.newsModel, this.isFromShare = true});

  @override
  State<StatefulWidget> createState() {
    return _SelectMemberState();
  }
}

class _SelectMemberState extends State<SelectMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFromShare ? "Share with" : "Select member",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[],
      ),
      body: _SelectMembersView(
        timebankId: widget.timebankId,
        isFromShare: widget.isFromShare,
        newsModel: widget.newsModel,
      ),
    );
  }
}

class _SelectMembersView extends StatelessWidget {
  final String timebankId;
  final bool isFromShare;
  final NewsModel newsModel;

  _SelectMembersView(
      {@required this.timebankId, this.isFromShare, this.newsModel});

  @override
  Widget build(BuildContext context) {
    print("SelectMembers ---->");

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
        TimebankModel timebankModel = snapshot.data;
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
    ];
  }

  TimebankModel filterBlockedContent(
    TimebankModel timebank,
    BuildContext context,
  ) {
    List<String> filteredMembers = [];

    timebank.members.forEach((member) {
      if (SevaCore.of(context).loggedInUser.blockedMembers.contains(member) ||
          SevaCore.of(context).loggedInUser.blockedBy.contains(member)) {
      } else {
        filteredMembers.add(member);
      }
    });
    timebank.members = filteredMembers;
    return timebank;
  }

  Widget getMembersList(BuildContext context, TimebankModel model) {
    model = filterBlockedContent(model, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...model.members.map((member) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (user.email == SevaCore.of(context).loggedInUser.email) {
                print("Removed my item");
                return Offstage();
              } else {
                return getUserWidget(user, context);
              }
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
            " Tapped on new chat for " +
            SevaCore.of(context).loggedInUser.email);

        if (user.email == SevaCore.of(context).loggedInUser.email) {
          return null;
        } else {
          UserModel loggedInUser = SevaCore.of(context).loggedInUser;
          ParticipantInfo sender = ParticipantInfo(
            id: loggedInUser.sevaUserID,
            name: loggedInUser.fullname,
            photoUrl: loggedInUser.photoURL,
            type: MessageType.TYPE_PERSONAL,
          );

          ParticipantInfo reciever = ParticipantInfo(
            id: user.sevaUserID,
            name: user.fullname,
            photoUrl: user.photoURL,
            type: MessageType.TYPE_PERSONAL,
          );

          createAndOpenChat(
            context: context,
            timebankId: timebankId,
            communityId: loggedInUser.currentCommunity,
            sender: sender,
            reciever: reciever,
            isFromRejectCompletion: false,
            isFromShare: isFromShare,
            news: isFromShare ? newsModel : NewsModel(),
            isFromNewChat: fromNewChat,
            onChatCreate: () {
              Navigator.of(context).pop();
            },
          );
        }
        return user.email == SevaCore.of(context).loggedInUser.email
            ? null
            : () {};
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              user.photoURL ?? defaultUserImageURL,
            ),
          ),
          title: Text(user.fullname),
        ),
      ),
    );
  }

  var fromNewChat = IsFromNewChat(true, DateTime.now().millisecondsSinceEpoch);

  Widget getSectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle2,
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

  Future updateTimebank(
    TimebankModel model, {
    List<String> admins,
    List<String> coordinators,
    List<String> members,
  }) async {
    if (admins != null) {
      model.admins = admins;
    }
    if (coordinators != null) {
      model.coordinators = coordinators;
    }
    if (members != null) {
      model.members = members;
    }
    await FirestoreManager.updateTimebank(timebankModel: model);
  }
}
