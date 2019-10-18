import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

import '../../flavor_config.dart';
import 'chatview.dart';

class SelectMember extends StatefulWidget {
  final String timebankId;

  SelectMember({@required this.timebankId});

  @override
  State<StatefulWidget> createState() {
    return _SelectMemberState();
  }
}

class _SelectMemberState extends State<SelectMember> {
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context);

    print("Color ${color.primaryColor}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        backgroundColor: getAppBarBackgroundColor(),
        title: Text(
          "Select member",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[],
      ),
      body: _SelectMembersView(
        timebankId: widget.timebankId,
      ),
    );
  }

  Color getAppBarBackgroundColor() {
    switch (FlavorConfig.appFlavor) {
      case Flavor.HUMANITY_FIRST:
        return Colors.indigo;

      case Flavor.TOM:
        return Color.fromARGB(255, 11, 40, 161);

      case Flavor.TULSI:
        return Color.fromARGB(255, 26, 50, 102);

      case Flavor.APP:
        return Color.fromARGB(255, 109, 110, 172);

      default:
      return Color.fromARGB(255, 109, 110, 172);
    }
  }
}

class _SelectMembersView extends StatelessWidget {
  final String timebankId;

  _SelectMembersView({
    @required this.timebankId,
  });

  @override
  Widget build(BuildContext context) {
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
      // getAdminList(context, model),
      getCoordinationList(context, model),
      getMembersList(context, model),
      SizedBox(height: 48),
    ];
  }

  Widget getAdminList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
        //SevaCore.of(context).loggedInUser.sevaUserID,
        "rmybIeNJHycTx64sU2wHUo5tQNa2");

    if (model.admins.length == 0) return Container();
    print(model.admins);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Admins'),
        ...model.admins.map((admin) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: admin),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        admins.remove(user.sevaUserID);
                        updateTimebank(model, admins: admins);
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      icon: Icons.arrow_downward,
                      color: Colors.orange,
                      caption: 'Coordinator',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        coordinators.add(user.sevaUserID);
                        admins.remove(user.sevaUserID);
                        updateTimebank(
                          model,
                          coordinators: coordinators,
                          admins: admins,
                        );
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return getUserWidget(user, context);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget getCoordinationList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
        // SevaCore.of(context).loggedInUser.sevaUserID,
        "rmybIeNJHycTx64sU2wHUo5tQNa2");
    if (model.coordinators == null || model.coordinators.isEmpty)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Coordinators'),
        ...model.coordinators.map((coordinator) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: coordinator),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        coordinators.remove(user.sevaUserID);
                        updateTimebank(model, coordinators: coordinators);
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return getUserWidget(user, context);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget getMembersList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
        // SevaCore.of(context).loggedInUser.sevaUserID,
        "rmybIeNJHycTx64sU2wHUo5tQNa2");
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
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    if (!model.admins.contains(user.sevaUserID))
                      IconSlideAction(
                        icon: Icons.supervisor_account,
                        color: Colors.green,
                        caption: 'Admin',
                        onTap: () {
                          List<String> admins =
                              model.admins.map((s) => s).toList();
                          List<String> coordinators =
                              model.coordinators.map((s) => s).toList();
                          admins.add(user.sevaUserID);
                          coordinators.remove(user.sevaUserID);
                          updateTimebank(
                            model,
                            admins: admins,
                            coordinators: coordinators,
                          );
                        },
                      ),
                    if (!model.coordinators.contains(user.sevaUserID) &&
                        !model.admins.contains(user.sevaUserID))
                      IconSlideAction(
                        icon: Icons.supervised_user_circle,
                        color: Colors.orange,
                        caption: 'Coordinator',
                        onTap: () {
                          List<String> coordinators =
                              model.coordinators.map((s) => s).toList();
                          coordinators.add(user.sevaUserID);
                          updateTimebank(model, coordinators: coordinators);
                        },
                      ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        List<String> members =
                            model.members.map((s) => s).toList();
                        admins.remove(user.sevaUserID);
                        coordinators.remove(user.sevaUserID);
                        members.remove(user.sevaUserID);
                        updateTimebank(
                          model,
                          members: members,
                          admins: admins,
                          coordinators: coordinators,
                        );
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
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
            " Tapped on new chat for " +
            SevaCore.of(context).loggedInUser.email);

        if (user.email == SevaCore.of(context).loggedInUser.email) {
          return null;
        } else {
          List users = [user.email, SevaCore.of(context).loggedInUser.email];
          print("Listing users");
          users.sort();
          ChatModel model = ChatModel();
          model.user1 = users[0];
          model.user2 = users[1];
          print("Model1" + model.user1);
          print("Model2" + model.user2);

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => ChatView(
          //             useremail: user.email,
          //             chatModel: model,
          //             isFromShare: false,
          //             news: NewsModel(),
          //           )),
          // );
          await createChat(chat: model).then(
            (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatView(
                          useremail: user.email,
                          chatModel: model,
                          isFromShare: false,
                          news: NewsModel(),
                        )),
              );
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
            backgroundImage: NetworkImage(user.photoURL),
          ),
          title: Text(user.fullname),
          subtitle: Text(user.email),
        ),
      ),
    );
  }

  /// Create a [chat]
  Future<void> createChat({
    @required ChatModel chat,
  }) async {
    // log.i('createChat: MessageModel: ${chat.toMap()}');
    chat.rootTimebank = FlavorConfig.values.timebankId;
    return Firestore.instance
        .collection('chatsnew')
        .document(chat.user1 +
            '*' +
            chat.user2 +
            '*' +
            FlavorConfig.values.timebankId)
        .setData(chat.toMap(), merge: true);
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
