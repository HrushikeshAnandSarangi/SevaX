import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart'
    as prefix0;
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/group_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

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
            return Center(child: Text(S.of(context).search_something));
          }
          return StreamBuilder<GroupData>(
            stream: CombineLatestStream.combine2(
              Searches.searchGroups(
                queryString: search.data,
                loggedInUser: _bloc.user,
                currentCommunityOfUser: _bloc.community,
              ),
              CollectionRef.joinRequests
                  .where("user_id", isEqualTo: _bloc.user.sevaUserID)
                  .snapshots(),
              (x, y) => GroupData(x, y),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data.timebanks == null ||
                  snapshot.data.timebanks.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(S.of(context).no_search_result_found),
                  ],
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10),
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.timebanks.length,
                itemBuilder: (context, index) {
                  final group = snapshot.data.timebanks[index];
                  JoinStatus joinStatus = status(
                    group,
                    _bloc.user.sevaUserID,
                    snapshot.data.requests,
                  );
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_context) => BlocProvider(
                              bloc: BlocProvider.of<UserDataBloc>(context),
                              child: BlocProvider(
                                bloc:
                                    BlocProvider.of<HomeDashBoardBloc>(context),
                                child: TabarView(
                                  userModel: SevaCore.of(context).loggedInUser,
                                  timebankModel: group,
                                ),
                              ),
                            ),
                          ));
                    },
                    child: GroupCard(
                      image: group.photoUrl ?? defaultGroupImageURL,
                      title: group.name,
                      subtitle: group.missionStatement,
                      status: joinStatus,
                      onPressed: joinStatus == JoinStatus.JOIN
                          ? () {
                              joinTimebank(_bloc.user, group);
                            }
                          : null,
                    ),
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
    if (isAccessAvailable(timebank, userId)) {
      return JoinStatus.JOINED;
    }
    if (timebank.coordinators.contains(userId)) {
      return JoinStatus.JOINED;
    }

    if (querySnapshot != null) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot snap = querySnapshot.docs[i];
        if (timebank.id == snap.data()['entity_id']) {
          if (snap.data()["accepted"] == false &&
              snap.data()["operation_taken"] == false) {
            return JoinStatus.REQUESTED;
          }
          if (snap.data()["accepted"] == false &&
              snap.data()["operation_taken"] == true) {
            return JoinStatus.REJECTED;
          }
          if (snap.data()["accepted"] == true) {
            return JoinStatus.JOINED;
          }
        }
      }
    }
    return JoinStatus.JOIN;
  }

  Future<void> joinTimebank(UserModel user, TimebankModel timebank) async {
    await _assembleAndSendRequest(
      subTimebankId: timebank.id,
      subTimebankLabel: timebank.name,
      userIdForNewMember: user.sevaUserID,
    );

    setState(() {
      // getData();
    });
    return;
  }

  Future _assembleAndSendRequest({
    String userIdForNewMember,
    String subTimebankLabel,
    String subTimebankId,
  }) async {
    var joinRequestModel = _assembleJoinRequestModel(
      userIdForNewMember: userIdForNewMember,
      subTimebankLabel: subTimebankLabel,
      subtimebankId: subTimebankId,
    );

    var notification = _assembleNotificationForJoinRequest(
      joinRequestModel: joinRequestModel,
      userIdForNewMember: userIdForNewMember,
      creatorId: userIdForNewMember,
      subTimebankId: subTimebankId,
    );

    await createAndSendJoinJoinRequest(
      joinRequestModel: joinRequestModel,
      notification: notification,
      subtimebankId: subTimebankId,
    ).commit();
  }

  WriteBatch createAndSendJoinJoinRequest({
    String subtimebankId,
    NotificationsModel notification,
    JoinRequestModel joinRequestModel,
  }) {
    WriteBatch batchWrite = CollectionRef.batch;
    batchWrite.set(
        CollectionRef.timebank
            .doc(
              subtimebankId,
            )
            .collection("notifications")
            .doc(notification.id),
        notification.toMap());

    batchWrite.set(CollectionRef.joinRequests.doc(joinRequestModel.id),
        joinRequestModel.toMap());
    return batchWrite;
  }

  JoinRequestModel _assembleJoinRequestModel({
    String userIdForNewMember,
    String subTimebankLabel,
    String subtimebankId,
  }) {
    return JoinRequestModel(
      timebankTitle: subTimebankLabel,
      accepted: false,
      entityId: subtimebankId,
      entityType: prefix0.EntityType.Timebank,
      operationTaken: false,
      reason: S.of(context).i_want_to_volunteer,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: userIdForNewMember,
      isFromGroup: true,
      notificationId: utils.Utils.getUuid(),
    );
  }

  NotificationsModel _assembleNotificationForJoinRequest({
    String userIdForNewMember,
    JoinRequestModel joinRequestModel,
    String subTimebankId,
    String creatorId,
  }) {
    return NotificationsModel(
      timebankId: subTimebankId,
      id: joinRequestModel.notificationId,
      targetUserId: creatorId,
      senderUserId: userIdForNewMember,
      type: NotificationType.JoinRequest,
      isTimebankNotification: true,
      isRead: false,
      data: joinRequestModel.toMap(),
      communityId: "NOT_REQUIRED",
    );
  }
}

class GroupData {
  final List<TimebankModel> timebanks;
  final QuerySnapshot requests;

  GroupData(this.timebanks, this.requests);
}
