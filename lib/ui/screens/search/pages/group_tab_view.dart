import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart'
    as prefix0;
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/group_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';

import '../../../../flavor_config.dart';

class GroupTabView extends StatefulWidget {
  @override
  _GroupTabViewState createState() => _GroupTabViewState();
}

class _GroupTabViewState extends State<GroupTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<GroupData>(
            stream: CombineLatestStream.combine2(
              Searches.searchGroups(
                queryString: search.data,
                loggedInUser: _bloc.user,
                currentCommunityOfUser: _bloc.community,
              ),
              Firestore.instance
                  .collection("join_requests")
                  .where("user_id", isEqualTo: _bloc.user.sevaUserID)
                  .snapshots(),
              (x, y) => GroupData(x, y),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data.timebanks == null ||
                  snapshot.data.timebanks.isEmpty) {
                print("===>> ${snapshot.data.timebanks}");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text("No data found !"),
                  ],
                );
              }

              print("snapshot ==> ${snapshot.data.timebanks.length}");

              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.timebanks.length,
                itemBuilder: (context, index) {
                  final group = snapshot.data.timebanks[index];
                  JoinStatus joinStatus = status(
                    group,
                    _bloc.user.sevaUserID,
                    snapshot.data.requests,
                  );
                  return GroupCard(
                    image: group.photoUrl ?? "",
                    title: group.name,
                    subtitle: group.missionStatement,
                    status: joinStatus,
                    onPressed: joinStatus == JoinStatus.JOIN
                        ? () {
                            joinTimebank(_bloc.user, group);
                          }
                        : null,
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 2,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  JoinStatus status(
      TimebankModel timebank, String userId, QuerySnapshot querySnapshot) {
    if (timebank.members.contains(userId)) {
      return JoinStatus.JOINED;
    }
    if (timebank.admins.contains(userId)) {
      return JoinStatus.JOINED;
    }
    if (timebank.coordinators.contains(userId)) {
      return JoinStatus.JOINED;
    }

    if (querySnapshot != null) {
      for (int i = 0; i < querySnapshot.documents.length; i++) {
        DocumentSnapshot snap = querySnapshot.documents[i];
        if (timebank.id == snap.data['entity_id']) {
          if (snap.data["accepted"] == false &&
              snap.data["operation_taken"] == false) {
            return JoinStatus.REQUESTED;
          }
          if (snap.data["accepted"] == false &&
              snap.data["operation_taken"] == true) {
            return JoinStatus.REJECTED;
          }
          if (snap.data["accepted"] == true) {
            return JoinStatus.JOINED;
          }
        }
      }
    }
    return JoinStatus.JOIN;
  }

  Future<void> joinTimebank(UserModel user, TimebankModel timebank) async {
    prefix0.JoinRequestModel joinRequestModel = prefix0.JoinRequestModel();
    joinRequestModel.reason = "i want to join";
    joinRequestModel.userId = user.sevaUserID;
    joinRequestModel.timestamp = DateTime.now().millisecondsSinceEpoch;

    joinRequestModel.entityId = timebank.id;
    joinRequestModel.entityType = prefix0.EntityType.Timebank;
    joinRequestModel.accepted = false;

    await updateJoinRequest(model: joinRequestModel);

    JoinRequestNotificationModel joinReqModel = JoinRequestNotificationModel(
        timebankId: timebank.id,
        timebankTitle: timebank.name,
        reasonToJoin: joinRequestModel.reason);

    NotificationsModel notification = NotificationsModel(
      id: Utils.getUuid(),
      targetUserId: timebank.creatorId,
      senderUserId: user.sevaUserID,
      type: NotificationType.JoinRequest,
      data: joinReqModel.toMap(),
    );

    notification.timebankId = FlavorConfig.values.timebankId;
    //  print('creator id ${notification.timebankId}');

    UserModel timebankCreator =
        await FirestoreManager.getUserForId(sevaUserId: timebank.creatorId);
    //print('time creator email ${timebankCreator.email}');

    await Firestore.instance
        .collection('users')
        .document(timebankCreator.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());

    setState(() {
      // getData();
    });
    return;
  }
}

class GroupData {
  final List<TimebankModel> timebanks;
  final QuerySnapshot requests;

  GroupData(this.timebanks, this.requests);
}
