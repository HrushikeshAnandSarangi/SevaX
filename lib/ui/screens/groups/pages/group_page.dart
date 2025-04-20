import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class GroupPage extends StatefulWidget {
  final String communityId;

  const GroupPage({Key? key, required this.communityId}) : super(key: key);
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    var user = SevaCore.of(context).loggedInUser;
    final bloc = Provider.of<HomePageBaseBloc>(context, listen: false);
    return Padding(
      // padding: const EdgeInsets.all(12.0),
      padding: EdgeInsets.only(
        left: 12,
        top: 12,
      ),
      // ,
      child: StreamBuilder<ExploreGroupDataHolder>(
        stream: Provider.of<HomePageBaseBloc>(context, listen: false)
            .exploreGroupsOutputStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          logger.i(snapshot.data?.listOfSubTimebanks?.length ?? 0);
          if (snapshot.data == null ||
              snapshot.data?.listOfSubTimebanks?.isEmpty == true) {
            return EmptyWidget(
              title: S.of(context).no_groups_found,
              sub_title: S.of(context).try_text + S.of(context).creating_one,
              titleFontSize: 16,
            );
          }
          List<TimebankModel> myGroups = [];
          List<TimebankModel> otherGroups = [];

          snapshot.data?.listOfSubTimebanks?.forEach((group) {
            if (!isPrimaryTimebank(parentTimebankId: group.parentTimebankId)) {
              if (group.members.contains(user.sevaUserID)) {
                myGroups.add(group);
              } else {
                if (group.private) {
                  if (group.managedCreatorIds.contains(user.sevaUserID)) {
                    otherGroups.add(group);
                  }
                } else {
                  otherGroups.add(group);
                }
              }
            }
          });
          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          (S.of(context).groups.toString()[0].toUpperCase() +
                              S
                                  .of(context)
                                  .groups
                                  .toString()
                                  .substring(1)
                                  .toLowerCase()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        infoButton(
                          context: context,
                          key: GlobalKey(),
                          type: InfoType.GROUPS,
                        ),
                        TransactionLimitCheck(
                          isSoftDeleteRequested:
                              bloc.primaryTimebankModel().requestedSoftDelete ??
                                  false,
                          timebankId: bloc.primaryTimebankModel().id ?? '',
                          comingFrom: ComingFrom.Groups,
                          child: ConfigurationCheck(
                            actionType: 'create_group',
                            role: MemberType.CREATOR,
                            child: InkWell(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.add_circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                bloc.primaryTimebankModel().protected
                                    ? isAccessAvailable(
                                        bloc.primaryTimebankModel(),
                                        user.sevaUserID ?? '',
                                      )
                                        ? navigateToCreateGroup(
                                            primaryTimebankModel:
                                                bloc.primaryTimebankModel(),
                                          )
                                        : showProtctedTImebankDialog(context)
                                    : navigateToCreateGroup(
                                        primaryTimebankModel:
                                            bloc.primaryTimebankModel(),
                                      );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 7),
                HideWidget(
                  hide: myGroups.isNotEmpty || otherGroups.isNotEmpty,
                  child: EmptyWidget(
                    title: S.of(context).no_groups_found,
                    sub_title:
                        S.of(context).try_text + S.of(context).creating_one,
                    titleFontSize: 16,
                  ),
                  secondChild: Container(),
                ),
                myGroups.isNotEmpty
                    ? Text(
                        S.of(context).my_groups,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      )
                    : Container(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: myGroups.length,
                  itemBuilder: (context, index) {
                    var timebank = myGroups[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: _GroupCard(
                        hideCard: timebank.softDelete,
                        hideButton: true,
                        buttonText: S.of(context).joined,
                        onButtonPressed: () {},
                        timebank: timebank,
                        onTap: () {
                          navigateToGroup(timebank);
                        },
                      ),
                    );
                  },
                ),
                ...otherGroups.isNotEmpty
                    ? [
                        SizedBox(height: 15),
                        Text(
                          S.of(context).seva_community_groups,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 7),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: otherGroups.length,
                          itemBuilder: (context, index) {
                            var timebank = otherGroups[index];
                            var status = getMembershipStatusStatus(
                              timebankId: timebank.id,
                              joinRequestModels:
                                  snapshot.data?.joinRequestsMade,
                            );
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: _GroupCard(
                                hideCard: timebank.softDelete,
                                buttonText: getLabelFromMembershipStatus(
                                    context: context, membshipStatus: status),
                                onButtonPressed: status == MembershipStatus.JOIN
                                    ? () {
                                        CreateJoinRequestManager
                                            .assembleAndSendRequest(
                                          subTimebankId: timebank.id,
                                          subTimebankLabel: timebank.name,
                                          userIdForNewMember: user.sevaUserID!,
                                          reasonForJoining:
                                              S.of(context).i_want_to_volunteer,
                                          communityId: timebank.communityId,
                                        );
                                      }
                                    : () {},
                                timebank: timebank,
                                onTap: () {
                                  navigateToGroup(timebank);
                                },
                              ),
                            );
                          },
                        ),
                      ]
                    : [],
              ],
            ),
          );
        },
      ),
    );
  }

  void navigateToCreateGroup({
    required TimebankModel primaryTimebankModel,
  }) {
    if (isPrimaryTimebank(parentTimebankId: primaryTimebankModel.id) &&
        !isAccessAvailable(primaryTimebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID ?? '')) {
      showAdminAccessMessage(context: context);
    } else {
      createEditCommunityBloc
          .updateUserDetails(SevaCore.of(context).loggedInUser);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimebankCreate(
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank ?? '',
            communityCreatorId: Provider.of<HomePageBaseBloc>(context,
                    listen: false)
                .communtiyModel(
                    SevaCore.of(context).loggedInUser.currentCommunity ?? '')
                .created_by,
          ),
        ),
      );
    }
  }

  void navigateToGroup(TimebankModel timebank) {
    try {
      Provider.of<HomePageBaseBloc>(context, listen: false)
          .changeTimebank(timebank);
    } on Exception catch (e) {
      logger.e(e);
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_context) => BlocProvider(
            bloc: BlocProvider.of<UserDataBloc>(context),
            child: BlocProvider(
              bloc: BlocProvider.of<HomeDashBoardBloc>(context),
              child: TabarView(
                userModel: SevaCore.of(context).loggedInUser,
                timebankModel: timebank,
              ),
            ),
          ),
        )).then((_) {
      try {
        Provider.of<HomePageBaseBloc>(context, listen: false)
            .switchToPreviousTimebank();
      } on Exception catch (e) {
        logger.e(e);
      }
    });
  }

  void showProtctedTImebankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).protected_timebank),
          content: Text(S.of(context).protected_timebank_group_creation_error),
          actionsPadding: EdgeInsets.only(right: 20),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              color: Theme.of(context).colorScheme.secondary,
              child: Text(S.of(context).close),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final bool hideCard;
  final VoidCallback onTap;
  final VoidCallback onButtonPressed;
  final String buttonText;
  final bool hideButton;
  const _GroupCard({
    Key? key,
    required this.timebank,
    required this.onTap,
    required this.onButtonPressed,
    required this.buttonText,
    this.hideButton = false,
    this.hideCard = false,
  }) : super(key: key);

  final TimebankModel timebank;

  @override
  Widget build(BuildContext context) {
    return HideWidget(
      hide: hideCard,
      child: InkWell(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      NetworkImage(timebank.photoUrl ?? defaultGroupImageURL),
                ),
                SizedBox(width: 12),
                Text(timebank.name),
                Spacer(),
                HideWidget(
                  hide: hideButton,
                  child: CustomElevatedButton(
                    child: Text(buttonText),
                    onPressed: onButtonPressed,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    elevation: 2.0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  secondChild: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
      secondChild: Container(),
    );
  }
}

enum MembershipStatus { JOINED, REQUESTED, REJECTED, JOIN }

MembershipStatus getMembershipStatusStatus(
    {List<JoinRequestModel>? joinRequestModels, required String timebankId}) {
  if (joinRequestModels == null) return MembershipStatus.JOIN;

  var joinRequestModel;
  try {
    joinRequestModel = joinRequestModels
        .firstWhere((element) => element.entityId == timebankId);
  } catch (e) {
    return MembershipStatus.JOIN;
  }

  if (joinRequestModel.operationTaken && !joinRequestModel.accepted) {
    logger.i("JOINED REJECTED");
    return MembershipStatus.REJECTED;
  }

  if (!joinRequestModel.operationTaken) {
    logger.i("JOINED REQUESTED");
    return MembershipStatus.REQUESTED;
  }

  if (joinRequestModel.accepted == true) {
    logger.i("JOINED ACCEPTED");
    return MembershipStatus.JOINED;
  }
  return MembershipStatus.JOIN;
}

String getLabelFromMembershipStatus({
  MembershipStatus? membshipStatus,
  required BuildContext context,
}) {
  switch (membshipStatus) {
    case MembershipStatus.JOINED:
      return S.of(context).joined;

    case MembershipStatus.REQUESTED:
      return S.of(context).requested;
    case MembershipStatus.REJECTED:
      return S.of(context).rejected;

    case MembershipStatus.JOIN:
      return S.of(context).join;

    default:
      return S.of(context).join;
  }
}

class CreateJoinRequestManager {
  static Future assembleAndSendRequest({
    required String userIdForNewMember,
    required String subTimebankLabel,
    required String subTimebankId,
    required String communityId,
    required String reasonForJoining,
  }) async {
    var joinRequestModel = _assembleJoinRequestModel(
      userIdForNewMember: userIdForNewMember,
      subTimebankLabel: subTimebankLabel,
      subtimebankId: subTimebankId,
      reasonForJoining: reasonForJoining,
    );

    var notification = _assembleNotificationForJoinRequest(
      joinRequestModel: joinRequestModel,
      userIdForNewMember: userIdForNewMember,
      creatorId: userIdForNewMember,
      subTimebankId: subTimebankId,
      communityId: communityId,
    );

    await createAndSendJoinJoinRequest(
      joinRequestModel: joinRequestModel,
      notification: notification,
      subtimebankId: subTimebankId,
    ).commit();
  }

  static WriteBatch createAndSendJoinJoinRequest({
    String? subtimebankId,
    NotificationsModel? notification,
    JoinRequestModel? joinRequestModel,
  }) {
    WriteBatch batchWrite = CollectionRef.batch;
    var timebankNotificationReference = CollectionRef.timebank
        .doc(subtimebankId)
        .collection("notifications")
        .doc(notification!.id);
    batchWrite.set(timebankNotificationReference, notification.toMap());

    batchWrite.set(CollectionRef.joinRequests.doc(joinRequestModel!.id),
        joinRequestModel.toMap());
    return batchWrite;
  }

  static JoinRequestModel _assembleJoinRequestModel({
    String? userIdForNewMember,
    String? subTimebankLabel,
    String? subtimebankId,
    required String reasonForJoining,
  }) {
    return JoinRequestModel(
      timebankTitle: subTimebankLabel ?? '',
      accepted: false,
      entityId: subtimebankId,
      entityType: EntityType.Timebank,
      operationTaken: false,
      reason: reasonForJoining,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: userIdForNewMember,
      isFromGroup: true,
      notificationId: Utils.getUuid(),
    );
  }

  static NotificationsModel _assembleNotificationForJoinRequest({
    String? userIdForNewMember,
    JoinRequestModel? joinRequestModel,
    String? subTimebankId,
    String? communityId,
    String? creatorId,
  }) {
    return NotificationsModel(
      timebankId: subTimebankId,
      id: joinRequestModel!.notificationId,
      targetUserId: creatorId,
      isRead: false,
      isTimebankNotification: true,
      senderUserId: userIdForNewMember,
      type: NotificationType.JoinRequest,
      data: joinRequestModel.toMap(),
      communityId: communityId,
    );
  }
}
